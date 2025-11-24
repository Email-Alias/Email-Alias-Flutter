[Setup]
AppName=Email Alias
AppVersion=1.0.0
DefaultDirName={pf64}\Email Alias
DefaultGroupName=Email Alias
OutputBaseFilename=email-alias-installer
Compression=lzma
SolidCompression=yes
SetupIconFile=app_icon.ico

ArchitecturesAllowed=x64

[Files]
Source: "email-alias\*"; DestDir: "{app}"; Flags: recursesubdirs ignoreversion

[Icons]
Name: "{group}\Email Alias"; Filename: "{app}\email_alias.exe"
Name: "{commondesktop}\Email Alias"; Filename: "{app}\email_alias.exe"; Tasks: desktopicon

[Languages]
Name: "en"; MessagesFile: "compiler:Default.isl"
Name: "de"; MessagesFile: "compiler:Languages\German.isl"

[Tasks]
Name: "desktopicon"; Description: "Create a desktop icon"; Flags: unchecked
