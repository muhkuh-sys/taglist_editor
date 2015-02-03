; Inno Setup Cfg for NXO Editor

; ; call batch file to get the svnversion of the nxo_editor directory.
; #define ExitCode
; #expr ExitCode = Exec("get_svnversion.bat")
; #pragma message "exit code of batch file: "+str(ExitCode)
; 
; ; read the output of the batch file into SVNVersion
; #define FileHandle
; #define SVNVersion "0000"
; #expr FileHandle = FileOpen("modulator_version.txt");
; #if FileHandle
; #expr SVNVersion = FileRead(FileHandle)
; #pragma message "SVN version = " + SVNVersion
; #expr FileClose(FileHandle)
; #endif
; 
; ; remove the letters M, P or S from SVNVersion
; #define iPos
; #expr iPos = Pos("M", SVNVersion);
; #if (iPos > 0)
; #expr SVNVersion = Copy(SVNVersion, 1, iPos-1)
; #endif
; #expr iPos = Pos("P", SVNVersion);
; #if (iPos > 0)
; #expr SVNVersion = Copy(SVNVersion, 1, iPos-1)
; #endif
; #expr iPos = Pos("S", SVNVersion);
; #if (iPos > 0)
; #expr SVNVersion = Copy(SVNVersion, 1, iPos-1)
; #endif
; 
; ; if SVNVersion if of the form 1234:1236, strip the first number
; #expr iPos = Pos(":", SVNVersion);
; #if (iPos > 0)
; #expr SVNVersion = Copy(SVNVersion, iPos+1)
; #endif
; #pragma message "numeric SVN version: "+SVNVersion
; 
; 
; ; read change logs (not used)
; #define Changelog ""
; #define FileLine
; #sub AppendChangelogLine
; 	#define iPos
; 	#for {iPos = Pos("'", FileLine); iPos>0 ; iPos = Pos("'", FileLine)} FileLine = Copy(FileLine, 1, iPos-1) + "''" + Copy(FileLine, iPos+1)
; 	#pragma message FileLine
; 	#expr Changelog = Changelog + "\n" + FileLine
; #endsub
; 
; #define ChangelogFile
; #sub ReadChangelog
; 	#expr FileLine = ""
; 	#expr Changelog = ""
; 	#for {FileHandle = FileOpen(ChangelogFile); FileHandle && !FileEof(FileHandle); FileLine = FileRead(FileHandle)} AppendChangelogLine
; 	#if FileHandle
; 		#expr FileClose(FileHandle)
; 	#endif
; #endsub

; comment out if ExitCode was defined above when getting the SVN version
#define ExitCode

#define AppName "netX Tag List Editor/NXO Builder"
;#define AppVersion GetFileVersion("..\..\..\bin\muhkuh.exe")
;#define AppVersion "1.1."+SVNVersion+".0"
#define AppVersion "1.2.0.0"
#define AppVerName AppName+" "+AppVersion
#define InstallerName "tag_list_editor_"+AppVersion+"_setup"


; make .cfg file with AppVerName as customtitle
#define NXOEditorDir "..\.."
#expr ExitCode = Exec("cmd", '/c m4 --define __CUSTOMTITLE__="' + AppVerName + '" Modulator_cfg.m4 >Modulator.cfg', NXOEditorDir)
#pragma message "m4 exited with code "+str(ExitCode)
#if ExitCode > 0
  #error Failed to build Modulator.cfg file
#endif


#define SourceDir "..\..\.."
#define OutputDir "."

; include the common muhkuh settings
;-------------------------------------------------------------------------
[Setup]
AppName={#AppName}
AppVersion={#AppVersion}
AppVerName={#AppVerName}
AppPublisher=Muhkuh team and Hilscher GmbH
AppPublisherURL=http://www.hilscher.com
;AppSupportURL=http://www.sourceforge.net/projects/muhkuh
;AppUpdatesURL=http://www.sourceforge.net/projects/muhkuh
AppCopyright=(C) 2013, Muhkuh team and Hilscher GmbH

; works: company, copyright, product name, product version
; description goes into properties and version dialogue
VersionInfoTextVersion={#AppVersion}
VersionInfoDescription=Installer of the Hilscher Tag List Editor application
VersionInfoCopyright=(C) 2013 Muhkuh team and Hilscher GmbH
VersionInfoCompany=Hilscher GmbH
VersionInfoProductName=Hilscher Tag List Editor
VersionInfoVersion={#AppVersion}

Compression=lzma/max
SolidCompression=yes
AllowNoIcons=yes
LicenseFile=nxo_editor\doc\licenses.txt

SourceDir={#SourceDir}
OutputDir={#OutputDir}
OutputBaseFilename={#InstallerName}

DefaultDirName ={pf}\Hilscher GmbH\Tag List Editor
DefaultGroupName =Hilscher GmbH\Tag List Editor

; icon stuff
SetupIconFile=nxo_editor\netX.ico
UninstallDisplayIcon={app}\nxo_editor\netX.ico

WizardImageFile=nxo_editor\installer\inno\Screen-netX_164x314px.bmp
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

// after the installation, load the installed changelogs for Muhkuh and Modulator and display them in a page
var
  ChangelogPage: TOutputMsgMemoWizardPage;

//procedure CurPageChanged(CurPageID: Integer);
//var
//	strModChanges: String;
//	strMuhChanges: String;
//begin
//	strModChanges:='Modulator changelog';
//	strMuhChanges:='Muhkuh changelog' + #13 + ExpandConstant('{#MuhkuhChangelog}');
//	if CurPageID = wpWelcome then begin
//		ChangelogPage := CreateOutputMsgMemoPage(wpInfoBefore,
//		'Change Log', 'Recent changes to Modulator',
//		'',
//		strModChanges + #13 + strMuhChanges);
//	end;
//end;


procedure CurStepChanged(CurStep: TSetupStep);
var
  strMuhChanges: String;
  strMChanges: String;
begin
  if CurStep = ssPostInstall then begin
    if not LoadStringFromFile(WizardDirValue()+'\doc\modulator_changelog.txt', strMChanges) then
      strMChanges:='Changelog for Tag List Editor not found';

    if not LoadStringFromFile(WizardDirValue()+'\docs\changelog.txt', strMuhChanges) then
      strMuhChanges:='Muhkuh change log not found';

    ChangelogPage := CreateOutputMsgMemoPage(wpInfoAfter,
      'Change Log', 'Recent changes to Tag List Editor and the underlying Muhkuh platform',
      '',
      strMChanges + #13 + strMuhChanges);
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
Source: bin\lua_hilscher\netx_fileheader.lua; DestDir: {app}\application\lua_hilscher; Components: lua_scripts
Source: bin\lua_hilscher\gui_stuff.lua; DestDir: {app}\application\lua_hilscher; Components: lua_scripts

Source: bin\lua.exe; DestDir: {app}\application; Flags: ignoreversion; Components: muhkuh
Source: bin\wx.dll; DestDir: {app}\application; Components: muhkuh

Source: nxo_editor\help\*.htm; DestDir: {app}\nxo_editor\help; Components: modulator

Source: nxo_editor\Modulator.cfg; DestDir: {app}\application; Components: modulator
Source: nxo_editor\netX.ico; DestDir: {app}\nxo_editor; Components: modulator

Source: nxo_editor\comboedit.lua; DestDir: {app}\nxo_editor; Components: modulator
Source: nxo_editor\checkboxedit.lua; DestDir: {app}\nxo_editor; Components: modulator
Source: nxo_editor\hexdump.lua; DestDir: {app}\nxo_editor; Components: modulator
Source: nxo_editor\hexedit.lua; DestDir: {app}\nxo_editor; Components: modulator
Source: nxo_editor\ipv4edit.lua; DestDir: {app}\nxo_editor; Components: modulator
Source: nxo_editor\macedit.lua; DestDir: {app}\nxo_editor; Components: modulator
Source: nxo_editor\numedit.lua; DestDir: {app}\nxo_editor; Components: modulator
Source: nxo_editor\rcxveredit.lua; DestDir: {app}\nxo_editor; Components: modulator
Source: nxo_editor\stringedit.lua; DestDir: {app}\nxo_editor; Components: modulator
Source: nxo_editor\devhdredit.lua; DestDir: {app}\nxo_editor; Components: modulator

Source: nxo_editor\page_taglistedit.lua; DestDir: {app}\nxo_editor; Components: modulator
Source: nxo_editor\checklist_taglistedit.lua; DestDir: {app}\nxo_editor; Components: modulator
Source: nxo_editor\structedit.lua; DestDir: {app}\nxo_editor; Components: modulator
Source: nxo_editor\nxoeditor.lua; DestDir: {app}\nxo_editor; Components: modulator
Source: nxo_editor\tester_nextid.lua; DestDir: {app}\nxo_editor; Components: modulator
Source: nxo_editor\test_description.xml; DestDir: {app}\nxo_editor; Components: modulator

Source: nxo_editor\nxfile.lua; DestDir: {app}\nxo_editor; Components: modulator
Source: nxo_editor\taglist.lua; DestDir: {app}\nxo_editor; Components: modulator
Source: nxo_editor\tagdefs_rcx.lua; DestDir: {app}\nxo_editor; Components: modulator
Source: nxo_editor\tagdefs_bsl.lua; DestDir: {app}\nxo_editor; Components: modulator
Source: nxo_editor\tagdefs_misc.lua; DestDir: {app}\nxo_editor; Components: modulator
Source: nxo_editor\tagdefs_io_handler.lua; DestDir: {app}\nxo_editor; Components: modulator
Source: nxo_editor\nxomaker.wx.lua; DestDir: {app}\nxo_editor; Components: modulator
Source: nxo_editor\makenxo.bat; DestDir: {app}\nxo_editor; Components: modulator
Source: nxo_editor\tagtool.wx.lua; DestDir: {app}\nxo_editor; Components: modulator
Source: nxo_editor\tagtool.bat; DestDir: {app}\nxo_editor; Components: modulator
Source: "H:\Manual netX Products\Tools\TagListEditor\man.004\Tag List Editor - Viewing and Editing Tags OI 04 EN.pdf"; DestDir: {app}\doc; Components: modulator
Source: nxo_editor\doc\changelog.txt; DestDir: {app}\doc; DestName: modulator_changelog.txt; Components: modulator
Source: nxo_editor\doc\licenses.txt; DestDir: {app}\doc; Components: modulator

[InstallDelete]
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
Source: bin\muhkuh.exe; DestDir: {app}\application; Flags: ignoreversion; Components: muhkuh
Source: bin\serverkuh.exe; DestDir: {app}\application; Flags: ignoreversion; Components: muhkuh
Source: bin\muhkuh_tips.txt; DestDir: {app}\application; Components: muhkuh
;Source: icons\custom\muhkuh_uninstall.ico; DestDir: {app}\application; Components: muhkuh

; system dlls
;Source: bin\msvcr71.dll; DestDir: {app}\application; Components: muhkuh
;Source: bin\msvcp71.dll; DestDir: {app}\application; Components: muhkuh
Source: bin\Microsoft.VC80.CRT\*; DestDir: {app}\application\Microsoft.VC80.CRT; Components: muhkuh


; the wxwidgets dlls
Source: bin\wxbase28_*.dll; DestDir: {app}\application; Components: muhkuh
Source: bin\wxmsw28_*.dll; DestDir: {app}\application; Components: muhkuh
; the wxLua dlls
Source: bin\lua5.1.dll; DestDir: {app}\application; Components: muhkuh
Source: bin\wxlua_msw28_*.dll; DestDir: {app}\application; Components: muhkuh

; mhash
Source: bin\mhash.dll; DestDir: {app}\application; Components: muhkuh

; the docs
Source: changelog.txt; DestDir: {app}\docs; Components: muhkuh



;-------------------------------------------------------------------------
; Muhkuh Lua scripts
;-------------------------------------------------------------------------
[Components]
Name: lua_scripts; Description: Lua scripts; Types: full

[Files]
Source: bin\lua\muhkuh_system.lua; DestDir: {app}\application\lua; Components: lua_scripts
Source: bin\lua\utils.lua; DestDir: {app}\application\lua; Components: lua_scripts




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
Name: {group}\Documentation; Filename: {app}\doc\Tag List Editor - Viewing and Editing Tags OI 04 EN.pdf; Components: modulator; Tasks: startmenu
Name: {group}\Uninstall; Filename: {uninstallexe}; IconFilename: {app}\nxo_editor\netX.ico; Components: modulator; Tasks: startmenu
;Name: {group}\Tag List Editor Documentation; Filename: {app}\doc\Tag List Editor - Viewing and Editing Tags OI 04 EN.pdf; Components: modulator; Tasks: startmenu
;Name: {group}\Uninstall Tag List Editor; Filename: {uninstallexe}; IconFilename: {app}\nxo_editor\netX.ico; Components: modulator; Tasks: startmenu

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
