#!/bin/sh
# Install ChordWave Lite for this user: the app in ~/.local/lib/chordwave, a `chordwave` command in
# ~/.local/bin, and a menu entry with its icon. Installed this way, the app updates
# itself. Libraries it needs that are missing get installed with the system's package
# manager (that step asks for your password).
#
# Run it from the extracted download.
# `install.sh --uninstall` removes it again.
set -e

data=${XDG_DATA_HOME:-$HOME/.local/share}
lib=$HOME/.local/lib/chordwave
bin=$HOME/.local/bin
desktop=$data/applications/chordwave.desktop
icon=$data/icons/hicolor/256x256/apps/chordwave.png

refresh() {
    update-desktop-database -q "$data/applications" 2>/dev/null || true
    gtk-update-icon-cache -q -t "$data/icons/hicolor" 2>/dev/null || true
}

if [ "$1" = "--uninstall" ]; then
    rm -rf "$lib"
    rm -f "$desktop" "$icon"
    [ -L "$bin/chordwave" ] && rm -f "$bin/chordwave"
    refresh
    echo "ChordWave Lite is uninstalled. Settings are still in $data/chordwave, and sign-ins in your keyring."
    exit 0
fi

# The files to install: beside this script, or (run from the web) the latest release.
here=$(cd "$(dirname "$0")" && pwd)
[ -f "$here/chordwave" ] || { echo "Run install.sh from the extracted download."; exit 1; }

mkdir -p "$lib" "$bin" "$data/applications" "$(dirname "$icon")"
# Put the new binary next to the old one and rename it over, so a copy that's
# running keeps going.
cp "$here/chordwave" "$lib/chordwave.new"
chmod 755 "$lib/chordwave.new"
mv -f "$lib/chordwave.new" "$lib/chordwave"
cp "$here/install.sh" "$lib/install.sh"
chmod 755 "$lib/install.sh"
echo "Installed by install.sh. This file lets ChordWave Lite update itself." > "$lib/install.txt"
ln -sf "$lib/chordwave" "$bin/chordwave"
sed "s|^Exec=.*|Exec=$lib/chordwave|" "$here/chordwave.desktop" > "$desktop"
cp "$here/chordwave.png" "$icon"
refresh

# Libraries: WebKitGTK (sign-in, lyrics), GTK, the tray's appindicator and ALSA.
missing=$(ldd "$lib/chordwave" 2>/dev/null | awk '/not found/ { print $1 }' | tr '\n' ' ')
# (Loaded at run time, so ldd doesn't list it. ldconfig is in /sbin, off a user's PATH on Debian.)
ldconfig=$(command -v ldconfig || echo /sbin/ldconfig)
appindicator=$("$ldconfig" -p 2>/dev/null | grep -c 'libayatana-appindicator3\|libappindicator3' || true)
if [ -n "$missing" ] || [ "$appindicator" = 0 ]; then
    sudo=""
    [ "$(id -u)" = 0 ] || sudo=sudo
    echo "Installing the libraries ChordWave Lite needs${missing:+ ($missing)}"
    if command -v apt-get >/dev/null; then
        $sudo apt-get install -y libwebkit2gtk-4.1-0 libgtk-3-0 libayatana-appindicator3-1 libasound2
    elif command -v dnf >/dev/null; then
        $sudo dnf install -y webkit2gtk4.1 gtk3 libayatana-appindicator-gtk3 alsa-lib
    elif command -v pacman >/dev/null; then
        $sudo pacman -S --needed --noconfirm webkit2gtk-4.1 gtk3 libayatana-appindicator alsa-lib
    elif command -v zypper >/dev/null; then
        $sudo zypper --non-interactive install libwebkit2gtk-4_1-0 libgtk-3-0 libayatana-appindicator3-1 alsa
    else
        echo "Install these with your package manager: $missing"
    fi
fi

echo "ChordWave Lite is installed. Open ChordWave Lite from your app menu, or run chordwave."
echo "To uninstall: $lib/install.sh --uninstall"
