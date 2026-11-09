; Inno Setup script for Charon on Windows.
; Words and step order follow the InstallerWindows board in the design artifact.

#define MyAppName "Charon"
#define MyAppVersion "0.1.0"
#define MyAppPublisher "hidnira-lab"
#define MyAppURL "https://github.com/hidnira-lab/charon"
#define MyAppExeName "charon.exe"

[Setup]
AppId={{C4A20700-8B4E-4D19-9A31-0000C4A20700}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
PrivilegesRequired=admin
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
LicenseFile=..\..\..\..\LICENSE
OutputBaseFilename=Charon-Setup-{#MyAppVersion}
Compression=lzma2
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Messages]
WelcomeLabel1=Install Charon
WelcomeLabel2=Charon is a VPN client for servers you control. Setup puts four things on this PC:%n%n• The Charon window (the app you open, runs without admin rights)%n• The Charon service (keeps the tunnel and the kill switch running)%n• wintun (the network adapter driver)%n• Protection filters (used only while the kill switch holds traffic)%n%nNothing is sent anywhere during setup.
FinishedHeadingLabel=Charon is installed
FinishedLabel=The service is running. Open Charon to add your first server.

[Files]
Source: "dist\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "install.ps1"; DestDir: "{app}"; Flags: ignoreversion
Source: "uninstall.ps1"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"

[Run]
Filename: "powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -File ""{app}\install.ps1"" -SourceDir ""{app}"" -ProgramDir ""{app}"""; StatusMsg: "Installing the Charon service and protection filters..."; Flags: runhidden waituntilterminated
Filename: "{app}\{#MyAppExeName}"; Description: "Open Charon now"; Flags: nowait postinstall skipifsilent runasoriginaluser

[UninstallRun]
Filename: "{app}\charon-release.exe"; Flags: runhidden waituntilterminated skipifdoesntexist; RunOnceId: "ReleaseWFPFilters"
Filename: "powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -File ""{app}\uninstall.ps1"" -ProgramDir ""{app}"""; Flags: runhidden waituntilterminated; RunOnceId: "UninstallService"
