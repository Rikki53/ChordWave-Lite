; Inno Setup script for ChordWave Lite.
; Build: cargo build --release, then
;   iscc installer\chordwave.iss
; Output: installer\Output\ChordWave-Lite-setup-<version>.exe
; ARM64: cargo build --release --target aarch64-pc-windows-msvc, then
;   iscc /DArm64 installer\chordwave.iss  ->  ChordWave-Lite-setup-<version>-arm64.exe

#define AppName "ChordWave Lite"
#define AppVersion "2.1.1"
#define AppExe "chordwave.exe"
#ifdef Arm64
  #define Arch "arm64"
  #define Suffix "-arm64"
  #define BinDir "..\target\aarch64-pc-windows-msvc\release"
#else
  #define Arch "x64compatible"
  #define Suffix ""
  #define BinDir "..\target\release"
#endif

[Setup]
AppId={{38E876B4-D960-4C2A-86F9-94AC10B42625}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher=Rikki53
AppPublisherURL=https://github.com/Rikki53/ChordWave-Lite
AppSupportURL=https://github.com/Rikki53/ChordWave-Lite/issues
DefaultDirName={autopf}\{#AppName}
DefaultGroupName={#AppName}
DisableProgramGroupPage=yes
; Per-user install by default (no UAC prompt); the user can pick all-users instead.
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
ArchitecturesAllowed={#Arch}
ArchitecturesInstallIn64BitMode={#Arch}
MinVersion=10.0
OutputBaseFilename=ChordWave-Lite-setup-{#AppVersion}{#Suffix}
Compression=lzma2/ultra
SolidCompression=yes
WizardStyle=modern
SetupIconFile=..\assets\icon\icon.ico
UninstallDisplayIcon={app}\{#AppExe}
CloseApplications=yes

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#BinDir}\{#AppExe}"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\README.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\LICENSE"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\{#AppName}"; Filename: "{app}\{#AppExe}"
Name: "{group}\Uninstall {#AppName}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\{#AppExe}"; Tasks: desktopicon

[Registry]
; ytm-rs:// links (jam invites). HKA is HKCU for per-user installs, HKLM for all-users.
; The installed app also re-registers itself under HKCU on launch.
Root: HKA; Subkey: "Software\Classes\ytm-rs"; ValueType: string; ValueName: ""; ValueData: "URL:ytm-rs Protocol"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\ytm-rs"; ValueType: string; ValueName: "URL Protocol"; ValueData: ""
Root: HKA; Subkey: "Software\Classes\ytm-rs\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: """{app}\{#AppExe}"",0"
Root: HKA; Subkey: "Software\Classes\ytm-rs\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\{#AppExe}"" ""%1"""

[UninstallDelete]
; Installers downloaded by the in-app updater.
Type: filesandordirs; Name: "{userappdata}\chordwave\data\updates"

[Run]
Filename: "{app}\{#AppExe}"; Description: "{cm:LaunchProgram,{#AppName}}"; Flags: nowait postinstall skipifsilent
