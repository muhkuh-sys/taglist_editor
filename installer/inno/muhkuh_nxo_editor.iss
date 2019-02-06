; Inno Setup Cfg for NXO Editor

#include "../../targets/version.iss"

#define SourceDir "..\.."
#define OutputDir ".."

[Setup]
AppName={#AppName}
AppVersion={#AppVersion}
AppVerName={#AppVerName}
AppPublisher=Muhkuh team and Hilscher GmbH
AppPublisherURL=http://www.hilscher.com
AppCopyright=(C) 2019, Muhkuh team and Hilscher GmbH

; works: company, copyright, product name, product version
; description goes into properties and version dialogue
VersionInfoTextVersion={#AppVersion}
VersionInfoDescription=Installer of the Hilscher Tag List Editor application
VersionInfoCopyright=(C) 2019 Muhkuh team and Hilscher GmbH
VersionInfoCompany=Hilscher GmbH
VersionInfoProductName=Hilscher Tag List Editor
VersionInfoVersion={#ProjectVersion}

Compression=lzma/max
SolidCompression=yes
AllowNoIcons=yes
LicenseFile=doc\licenses.txt

SourceDir={#SourceDir}
OutputDir={#OutputDir}
OutputBaseFilename={#InstallerName}

DefaultDirName ={pf}\Hilscher GmbH\Tag List Editor
DefaultGroupName =Hilscher GmbH\Tag List Editor

; icon stuff
SetupIconFile=netX.ico
UninstallDisplayIcon={app}\nxo_editor\netX.ico

WizardImageFile=installer\inno\Screen-netX_164x314px.bmp
WizardImageStretch=no
WizardImageBackColor=$ffffff

; notify Windows of the changes to the environment
ChangesAssociations=yes
ChangesEnvironment=yes

[Messages]
BeveledLabel=Tag List Editor
SelectDirLabel3=Setup will install [name] into the following folder. If the selected directory already contains an installation, it will be updated.
; SelectDirBrowseLabel=To continue, click Next. If you would like to select a different folder, click Browse.



[Code]
function ToFileUrl(Param: String): String;
var
  strPath: String;
begin
  strPath := ExpandConstant('{app}')+'\nxo_editor\test_description.xml';
  StringChange(strPath,'\','/');
  StringChange(strPath,':','%3A');
  Result := 'file:/' + strPath;
end;

// after the installation, load the installed changelog and display it in a page
var
  ChangelogPage: TOutputMsgMemoWizardPage;

procedure CurStepChanged(CurStep: TSetupStep);
var
  strChanges: AnsiString;
begin
  if CurStep = ssPostInstall then begin
    if not LoadStringFromFile(WizardDirValue()+'\doc\changelog.txt', strChanges) then
      strChanges:='Changelog for Tag List Editor not found';

    ChangelogPage := CreateOutputMsgMemoPage(wpInfoAfter,
      'Change Log', 'Recent changes to Tag List Editor',
      '',
      strChanges);
  end;

end;


[Types]
Name: full; Description: Full installation
Name: custom; Description: Custom installation; Flags: iscustom

;-------------------------------------------------------------------------
; NXO Editor files
;-------------------------------------------------------------------------
[Components]
Name: modulator; Description: Tag List Editor; Types: full

[Files]
Source: help\*.htm; DestDir: {app}\nxo_editor\help; Components: modulator

Source: targets\Modulator.cfg; DestDir: {app}\application; Components: modulator
Source: targets\version.lua; DestDir: {app}\nxo_editor; Components: modulator
Source: netX.ico; DestDir: {app}\nxo_editor; Components: modulator

Source: lua\comboedit.lua; DestDir: {app}\nxo_editor; Components: modulator
Source: lua\checkboxedit.lua; DestDir: {app}\nxo_editor; Components: modulator
Source: lua\hexdump.lua; DestDir: {app}\nxo_editor; Components: modulator
Source: lua\hexedit.lua; DestDir: {app}\nxo_editor; Components: modulator
Source: lua\ipv4edit.lua; DestDir: {app}\nxo_editor; Components: modulator
Source: lua\macedit.lua; DestDir: {app}\nxo_editor; Components: modulator
Source: lua\numedit.lua; DestDir: {app}\nxo_editor; Components: modulator
Source: lua\rcxveredit.lua; DestDir: {app}\nxo_editor; Components: modulator
Source: lua\stringedit.lua; DestDir: {app}\nxo_editor; Components: modulator
Source: lua\devhdredit.lua; DestDir: {app}\nxo_editor; Components: modulator

Source: lua\page_taglistedit.lua; DestDir: {app}\nxo_editor; Components: modulator
Source: lua\checklist_taglistedit.lua; DestDir: {app}\nxo_editor; Components: modulator
Source: lua\structedit.lua; DestDir: {app}\nxo_editor; Components: modulator
Source: lua\nxoeditor.lua; DestDir: {app}\nxo_editor; Components: modulator
Source: lua\tagdefs2json.lua; DestDir: {app}\nxo_editor; Components: modulator
Source: lua\tester_nextid.lua; DestDir: {app}\nxo_editor; Components: modulator
Source: test_description.xml; DestDir: {app}\nxo_editor; Components: modulator

Source: lua\nxfile.lua; DestDir: {app}\nxo_editor; Components: modulator
Source: lua\taglist.lua; DestDir: {app}\nxo_editor; Components: modulator
Source: lua\tagdefs_rcx.lua; DestDir: {app}\nxo_editor; Components: modulator
Source: lua\tagdefs_bsl.lua; DestDir: {app}\nxo_editor; Components: modulator
Source: lua\tagdefs_misc.lua; DestDir: {app}\nxo_editor; Components: modulator
Source: lua\tagdefs_io_handler.lua; DestDir: {app}\nxo_editor; Components: modulator
Source: lua\nxomaker.wx.lua; DestDir: {app}\nxo_editor; Components: modulator
Source: makenxo.bat; DestDir: {app}\nxo_editor; Components: modulator
Source: lua\tagtool.wx.lua; DestDir: {app}\nxo_editor; Components: modulator
Source: tagtool.bat; DestDir: {app}\nxo_editor; Components: modulator
Source: "doc\Tag List Editor - Viewing and Editing Tags OI 06 EN.pdf"; DestDir: {app}\doc; Components: modulator
Source: doc\changelog.txt; DestDir: {app}\doc; Components: modulator
Source: doc\licenses.txt; DestDir: {app}\doc; Components: modulator

[InstallDelete]
Type: files; Name: "{app}\doc\Tag List Editor - Viewing and Editing Tags OI 05 EN.pdf"
Type: files; Name: "{app}\doc\Tag List Editor - Viewing and Editing Tags OI 04 EN.pdf"
Type: files; Name: "{app}\doc\Tag List Editor - Viewing and Editing Tags OI 03 EN.pdf"
Type: files; Name: "{app}\doc\Tag List Editor - Viewing and Editing Tags OI 02 EN.pdf"
Type: files; Name: "{app}\doc\Tag List Editor - Viewing and Editing Tags OI 01 EN.pdf"
Type: files; Name: "{group}\Tag_List_Editor.lnk"

;-------------------------------------------------------------------------
; Muhkuh Files
;-------------------------------------------------------------------------
[Components]
Name: muhkuh; Description: Muhkuh base application; Types: full

[Files]
Source: external\bin\lua.exe; DestDir: {app}\application; Flags: ignoreversion; Components: muhkuh
Source: external\bin\wx.dll; DestDir: {app}\application; Components: muhkuh

Source: external\bin\serverkuh.exe; DestDir: {app}\application; Flags: ignoreversion; Components: muhkuh

; runtime dlls
Source: external\bin\Microsoft.VC80.CRT\*; DestDir: {app}\application\Microsoft.VC80.CRT; Components: muhkuh

; the wxwidgets dlls
Source: external\bin\wxbase28_*.dll; DestDir: {app}\application; Components: muhkuh
Source: external\bin\wxmsw28_*.dll; DestDir: {app}\application; Components: muhkuh
; the wxLua dlls
Source: external\bin\lua5.1.dll; DestDir: {app}\application; Components: muhkuh
Source: external\bin\wxlua_msw28_*.dll; DestDir: {app}\application; Components: muhkuh

; mhash
Source: external\bin\mhash.dll; DestDir: {app}\application; Components: muhkuh


;-------------------------------------------------------------------------
; Lua scripts from external repos
;-------------------------------------------------------------------------
[Components]
Name: lua_scripts; Description: Lua scripts; Types: full

[Files]
Source: external\lua_hilscher\netx_fileheader.lua; DestDir: {app}\application\lua_hilscher; Components: lua_scripts
Source: external\lua_hilscher\gui_stuff.lua; DestDir: {app}\application\lua_hilscher; Components: lua_scripts

Source: external\muhkuh_old\bin\lua\muhkuh_system.lua; DestDir: {app}\application\lua; Components: lua_scripts
Source: external\muhkuh_old\bin\lua\utils.lua; DestDir: {app}\application\lua; Components: lua_scripts




;-------------------------------------------------------------------------
; Icons/links/associations
;-------------------------------------------------------------------------
[Tasks]
Name: startmenu; Description: Create icons in Start menu; GroupDescription: Additional icons:; Components: modulator
Name: desktopicon; Description: Create a &desktop icon; GroupDescription: Additional icons:; Components: modulator
Name: quicklaunchicon; Description: Create a &Quick Launch icon; GroupDescription: Additional icons:; Components: modulator
Name: envpath; Description: Set the PATH_NXOEDITOR environment variable (required for makenxo/tagtool); GroupDescription: System:; Components: modulator
; Name: associate; Description: Associate .nxo files with Tag list editor; GroupDescription: File associations:


[Icons]
; Desktop icon
Name: {userdesktop}\Tag List Editor; Filename: {app}\application\serverkuh.exe; Parameters: "-c Modulator.cfg -i 0 ""{code:ToFileUrl}"" --"; WorkingDir: {app}\application; IconFilename: {app}\nxo_editor\netX.ico; Components: modulator; Tasks: desktopicon

; Quick launch
Name: {userappdata}\Microsoft\Internet Explorer\Quick Launch\Tag_List_Editor; Filename: {app}\application\serverkuh.exe; Parameters: "-c Modulator.cfg -i 0 ""{code:ToFileUrl}"" --"; WorkingDir: {app}\application; IconFilename: {app}\nxo_editor\netX.ico; Components: modulator; Tasks: quicklaunchicon

; link in the application directory
Name: {app}\Tag_List_Editor; Filename: {app}\application\serverkuh.exe; Parameters: "-c Modulator.cfg -i 0 ""{code:ToFileUrl}"" --"; WorkingDir: {app}\application; IconFilename: {app}\nxo_editor\netX.ico; Components: modulator

; start menu entry
Name: {group}\Tag List Editor; Filename: {app}\application\serverkuh.exe; Parameters: "-c Modulator.cfg -i 0 ""{code:ToFileUrl}"" --"; WorkingDir: {app}\application; IconFilename: {app}\nxo_editor\netX.ico; Components: modulator; Tasks: startmenu
Name: {group}\Documentation; Filename: {app}\doc\Tag List Editor - Viewing and Editing Tags OI 06 EN.pdf; Components: modulator; Tasks: startmenu
Name: {group}\Uninstall; Filename: {uninstallexe}; IconFilename: {app}\nxo_editor\netX.ico; Components: modulator; Tasks: startmenu

[Registry]
; set PATH_NXOEDITOR
Root: HKLM; Subkey: SYSTEM\CurrentControlSet\Control\Session Manager\Environment; ValueType: string; ValueName: PATH_NXOEDITOR; ValueData: {app}; Flags: uninsdeletevalue; Components: modulator; Tasks: envpath

; make .nxo known as netX Option Module
Root: HKCR; Subkey: .nxo; ValueType: string; ValueName: ; ValueData: netXOptionModule; Flags: uninsdeletevalue
Root: HKCR; Subkey: netXOptionModule; ValueType: string; ValueName: ; ValueData: netX Option Module; Flags: uninsdeletekey

; use the serverkuh icon for NXO files
;Root: HKCR; Subkey: netXOptionModule\DefaultIcon; ValueType: string; ValueName: ; ValueData: {app}\application\serverkuh.exe,0
Root: HKCR; Subkey: netXOptionModule\DefaultIcon; ValueType: string; ValueName: ; ValueData: {app}\nxo_editor\netX.ico

; start the editor when an nxo file is double-clicked
; Root: HKCR; Subkey: netXOptionModule\shell\open\command; ValueType: string; ValueName: ; ValueData: """{app}\application\serverkuh.exe"" ""-c"" ""{app}\application\Modulator.cfg"" ""-i"" ""0"" ""{app}\nxo_editor\test_description.xml"" ""--"" ""%1"""
