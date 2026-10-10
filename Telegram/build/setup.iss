#define MyAppShortName "Felogram Dev"
#define MyAppName "Felogram Dev"
#define MyAppPublisher "Felogram contributors"
#define MyAppURL "https://github.com/Uvaisbugh/felogram-desktop"
#define MyAppExeName "Felogram.exe"
#define MyAppId "AB551605-20C7-4F1B-9B10-FE103A0DE001"
#define FelogramVersion "0.1.0"
#define CurrentYear GetDateTimeString('yyyy','','')

#ifndef FelogramUnsignedDevelopment
  #ifndef FelogramMaintainerApiConfigured
    #error Signed packaging requires a verified maintainer API build. Baseline or missing configuration cannot be distributed.
  #endif
#endif

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{{#MyAppId}}
AppName={#MyAppName}
AppVersion={#FelogramVersion}
AppCopyright=Telegram Desktop contributors 2014-{#CurrentYear}; Felogram contributors 2026
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
VersionInfoProductName=Felogram Dev
DefaultDirName={localappdata}\Programs\{#MyAppName}
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
OutputDir={#ReleasePath}
SetupIconFile={#SourcePath}..\Resources\art\felogram\felogram.ico
UninstallDisplayName={#MyAppName}
UninstallDisplayIcon={app}\{#MyAppExeName}
Compression=lzma
SolidCompression=yes
DisableStartupPrompt=yes
PrivilegesRequired=lowest
VersionInfoVersion={#FelogramVersion}.0
CloseApplications=yes
DisableDirPage=no
DisableProgramGroupPage=no
WizardStyle=modern
#ifndef FelogramUnsignedDevelopment
SignTool=sha256
#endif

#ifndef MyOutputBaseFilename
  #if MyBuildTarget == "winarm"
    #define MyOutputBaseFilename "felogram-dev-setup-arm64." + FelogramVersion + "-dev"
  #elif MyBuildTarget == "win64"
    #define MyOutputBaseFilename "felogram-dev-setup-x64." + FelogramVersion + "-dev"
  #else
    #define MyOutputBaseFilename "felogram-dev-setup." + FelogramVersion + "-dev"
  #endif
#endif
#ifdef FelogramUnsignedDevelopment
OutputBaseFilename={#MyOutputBaseFilename}-unsigned-local
#else
OutputBaseFilename={#MyOutputBaseFilename}
#endif

#if MyBuildTarget == "winarm"
  ArchitecturesAllowed="arm64"
  #define ArchModulesFolder "arm64"
  AppVerName={#MyAppName} {#FelogramVersion} arm64
#elif MyBuildTarget == "win64"
  ArchitecturesAllowed="x64compatible"
  ArchitecturesInstallIn64BitMode="x64compatible"
  #define ArchModulesFolder "x64"
  AppVerName={#MyAppName} {#FelogramVersion} 64bit
#else
  #define ArchModulesFolder "x86"
  AppVerName={#MyAppName} {#FelogramVersion} 32bit
#endif

#define ModulesFolder "modules\" + ArchModulesFolder

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "it";      MessagesFile: "compiler:Languages\Italian.isl"
Name: "es";      MessagesFile: "compiler:Languages\Spanish.isl"
Name: "de";      MessagesFile: "compiler:Languages\German.isl"
Name: "nl";      MessagesFile: "compiler:Languages\Dutch.isl"
Name: "pt_BR";   MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"
Name: "ru";      MessagesFile: "compiler:Languages\Russian.isl"
Name: "fr";      MessagesFile: "compiler:Languages\French.isl"
Name: "ua";      MessagesFile: "compiler:Languages\Ukrainian.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"

[Files]
Source: "{#ReleasePath}\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
#if MyBuildTarget != "winarm"
Source: "{#ReleasePath}\{#ModulesFolder}\d3d\d3dcompiler_47.dll"; DestDir: "{app}\{#ModulesFolder}\d3d"; Flags: ignoreversion
#endif
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{group}\{#MyAppShortName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\{cm:UninstallProgram,{#MyAppShortName}}"; Filename: "{uninstallexe}"
Name: "{userdesktop}\{#MyAppShortName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppShortName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: files; Name: "{app}\data"
Type: files; Name: "{app}\data_config"
Type: files; Name: "{app}\log.txt"
Type: filesandordirs; Name: "{app}\DebugLogs"
Type: filesandordirs; Name: "{app}\tupdates"
Type: filesandordirs; Name: "{app}\tdata"
Type: filesandordirs; Name: "{app}\tcache"
Type: filesandordirs; Name: "{app}\tdumps"
Type: filesandordirs; Name: "{app}\modules"
Type: dirifempty; Name: "{app}"

[Code]
procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var ResultCode: Integer;
begin
  if CurUninstallStep = usUninstall then
  begin
    Exec(ExpandConstant('{app}\{#MyAppExeName}'), '-cleanup', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  end;
end;

const CSIDL_DESKTOPDIRECTORY = $0010;
      CSIDL_COMMON_DESKTOPDIRECTORY = $0019;

procedure CurStepChanged(CurStep: TSetupStep);
var ResultCode: Integer;
    HasOldKey: Boolean;
    HasNewKey: Boolean;
    HasOldLnk: Boolean;
    HasNewLnk: Boolean;
    UserDesktopLnk: String;
    CommonDesktopLnk: String;
begin
  if CurStep = ssPostInstall then
  begin
    HasNewKey := RegKeyExists(HKEY_CURRENT_USER, 'Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{{#MyAppId}}_is1') or RegKeyExists(HKEY_CURRENT_USER, 'Software\Microsoft\Windows\CurrentVersion\Uninstall\{{#MyAppId}}_is1');
    HasOldKey := RegKeyExists(HKEY_LOCAL_MACHINE, 'SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{{#MyAppId}}_is1') or RegKeyExists(HKEY_LOCAL_MACHINE, 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{{#MyAppId}}_is1');
    UserDesktopLnk := ExpandFileName(GetShellFolderByCSIDL(CSIDL_DESKTOPDIRECTORY, False) + '\{#MyAppShortName}.lnk');
    CommonDesktopLnk := ExpandFileName(GetShellFolderByCSIDL(CSIDL_COMMON_DESKTOPDIRECTORY, False) + '\{#MyAppShortName}.lnk');
    HasNewLnk := FileExists(UserDesktopLnk);
    HasOldLnk := FileExists(CommonDesktopLnk) and (UserDesktopLnk <> CommonDesktopLnk);
    if (HasOldKey and HasNewKey) or (HasOldLnk and HasNewLnk) then
    begin
      if (GetWindowsVersion >= $06000000) then // Vista or later
        ShellExec('runas', ExpandConstant('{app}\{#MyAppExeName}'), '-fixprevious', '', SW_SHOW, ewWaitUntilTerminated, ResultCode)
      else
        ShellExec('', ExpandConstant('{app}\{#MyAppExeName}'), '-fixprevious', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
    end;
  end;
end;
