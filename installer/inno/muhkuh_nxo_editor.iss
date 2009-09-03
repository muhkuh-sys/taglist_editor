; Inno Setup Cfg for NXO Editor

; call batch file to get the svnversion of the nxo_editor directory.
#define ExitCode
#expr ExitCode = Exec("get_svnversion.bat")
#pragma message "exit code of batch file: "+str(ExitCode)

; read the output of the batch file into SVNVersion
#define FileHandle
#define SVNVersion "0000"
#expr FileHandle = FileOpen("modulator_version.txt");
#if FileHandle
#expr SVNVersion = FileRead(FileHandle)
#pragma message "SVN version = " + SVNVersion
#expr FileClose(FileHandle)
#endif

; remove the letters M, P or S from SVNVersion
#define iPos
#expr iPos = Pos("M", SVNVersion);
#if (iPos > 0)
#expr SVNVersion = Copy(SVNVersion, 1, iPos-1)
#endif
#expr iPos = Pos("P", SVNVersion);
#if (iPos > 0)
#expr SVNVersion = Copy(SVNVersion, 1, iPos-1)
#endif
#expr iPos = Pos("S", SVNVersion);
#if (iPos > 0)
#expr SVNVersion = Copy(SVNVersion, 1, iPos-1)
#endif

; if SVNVersion if of the form 1234:1236, strip the first number
#expr iPos = Pos(":", SVNVersion);
#if (iPos > 0)
#expr SVNVersion = Copy(SVNVersion, iPos+1)
#endif
#pragma message "numeric SVN version: "+SVNVersion


; read change logs (not used)
#define Changelog ""
#define FileLine
#sub AppendChangelogLine
	#define iPos
	#for {iPos = Pos("'", FileLine); iPos>0 ; iPos = Pos("'", FileLine)} FileLine = Copy(FileLine, 1, iPos-1) + "''" + Copy(FileLine, iPos+1)
	#pragma message FileLine
	#expr Changelog = Changelog + "\n" + FileLine
#endsub

#define ChangelogFile
#sub ReadChangelog
	#expr FileLine = ""
	#expr Changelog = ""
	#for {FileHandle = FileOpen(ChangelogFile); FileHandle && !FileEof(FileHandle); FileLine = FileRead(FileHandle)} AppendChangelogLine
	#if FileHandle
		#expr FileClose(FileHandle)
	#endif
#endsub

;#expr ChangelogFile = "..\..\changelog.txt"
;#expr ReadChangelog
;#define ModulatorChangelog Changelog
;#pragma message ModulatorChangelog

;#expr ChangelogFile = "..\..\..\changelog.txt"
;#expr ReadChangelog
;#define MuhkuhChangelog Changelog
;#pragma message MuhkuhChangelog

#define AppName "netX Tag List Editor/NXO Builder"
;#define AppVersion GetFileVersion("..\..\..\bin\muhkuh.exe")
#define AppVersion "1.0."+SVNVersion
#define AppVerName AppName+" "+AppVersion
#define InstallerName "tag_list_editor_"+AppVersion+"_setup"

#define SourceDir "..\..\.."
#define OutputDir "."

; include the common muhkuh settings
#include "..\..\..\installer\inno\muhkuh_common.iss"

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
      strMuhChanges:='Muhkuh changelog not found';

    ChangelogPage := CreateOutputMsgMemoPage(wpInfoAfter,
      'Change Log', 'Recent changes to Tag List Editor and the underlying Muhkuh platform',
      '',
      strMChanges + #13 + strMuhChanges);
  end;

end;





[Setup]
DefaultDirName ={pf}\Hilscher GmbH\nxo_editor
DefaultGroupName =Hilscher GmbH\Tag List Editor

; misc info
AppPublisher =Muhkuh team and Hilscher GmbH
AppPublisherURL=http://muhkuh.sourceforge.net/
AppSupportURL=http://www.sourceforge.net/projects/muhkuh
AppUpdatesURL=http://www.sourceforge.net/projects/muhkuh
VersionInfoCopyright =Copyright (C) 2008, Muhkuh team and Hilscher GmbH
AppCopyright =Copyright (C) 2008, Muhkuh team and Hilscher GmbH

; icon stuff
SetupIconFile=nxo_editor\modulator.ico
UninstallDisplayIcon={app}\nxo_editor\modulator.ico

WizardImageFile=nxo_editor\installer\inno\bootwizard_install_logo.bmp
WizardImageStretch=no
WizardImageBackColor=$ffffff

; notify Windows of the changes to the environment
ChangesEnvironment =yes

[Messages]
BeveledLabel=NXO Editor

; add the modulator first to get it on top of the list
[Components]
Name: modulator; Description: Tag List Editor; Types: full; Flags: fixed

[Tasks]
Name: startmenu; Description: Create icons in Start menu; GroupDescription: Additional icons:; Components: modulator
Name: desktopicon; Description: Create a &desktop icon; GroupDescription: Additional icons:; Components: modulator
Name: quicklaunchicon; Description: Create a &Quick Launch icon; GroupDescription: Additional icons:; Components: modulator
Name: envpath; Description: Set the PATH_NXO_EDITOR environment variable; GroupDescription: System:; Components: modulator

; include the components
#include "..\..\..\installer\inno\muhkuh_app.iss"
#include "..\..\..\installer\inno\lua_scripts.iss"

; add the modulator components
[Files]
Source: bin\lua_hilscher\netx_fileheader.lua; DestDir: {app}\application\lua_hilscher; Components: lua_scripts
Source: bin\lua_hilscher\gui_stuff.lua; DestDir: {app}\application\lua_hilscher; Components: lua_scripts

Source: bin\lua.exe; DestDir: {app}\application; Components: muhkuh
Source: bin\wx.dll; DestDir: {app}\application; Components: muhkuh

Source: nxo_editor\help\misc_tags.htm; DestDir: {app}\nxo_editor\help; Components: modulator
Source: nxo_editor\help\RCX_MOD_TAG_IT_GPIO_T.htm; DestDir: {app}\nxo_editor\help; Components: modulator
Source: nxo_editor\help\RCX_MOD_TAG_IT_INTERRUPT_T.htm; DestDir: {app}\nxo_editor\help; Components: modulator
Source: nxo_editor\help\RCX_MOD_TAG_IT_LED_T.htm; DestDir: {app}\nxo_editor\help; Components: modulator
Source: nxo_editor\help\RCX_MOD_TAG_IT_PIO_T.htm; DestDir: {app}\nxo_editor\help; Components: modulator
Source: nxo_editor\help\RCX_MOD_TAG_IT_STATIC_TASKS_T.htm; DestDir: {app}\nxo_editor\help; Components: modulator
Source: nxo_editor\help\RCX_MOD_TAG_IT_TIMER_T.htm; DestDir: {app}\nxo_editor\help; Components: modulator
Source: nxo_editor\help\RCX_MOD_TAG_IT_XC_T.htm; DestDir: {app}\nxo_editor\help; Components: modulator
Source: nxo_editor\help\TAG_BSL_EXTSRAM_PARAMS_DATA_T.htm; DestDir: {app}\nxo_editor\help; Components: modulator
Source: nxo_editor\help\TAG_BSL_HIF_PARAMS_DATA_T.htm; DestDir: {app}\nxo_editor\help; Components: modulator
Source: nxo_editor\help\TAG_BSL_MEDIUM_PARAMS_DATA_T.htm; DestDir: {app}\nxo_editor\help; Components: modulator
Source: nxo_editor\help\TAG_BSL_SDMMC_PARAMS_DATA_T.htm; DestDir: {app}\nxo_editor\help; Components: modulator
Source: nxo_editor\help\TAG_BSL_SDRAM_PARAMS_DATA_T.htm; DestDir: {app}\nxo_editor\help; Components: modulator
Source: nxo_editor\help\TAG_BSL_UART_PARAMS_DATA_T.htm; DestDir: {app}\nxo_editor\help; Components: modulator
Source: nxo_editor\help\TAG_BSL_USB_PARAMS_DATA_T.htm; DestDir: {app}\nxo_editor\help; Components: modulator

Source: nxo_editor\Modulator.cfg; DestDir: {app}\application; Components: modulator
Source: nxo_editor\modulator.ico; DestDir: {app}\nxo_editor; Components: modulator

Source: nxo_editor\comboedit.lua; DestDir: {app}\nxo_editor; Components: modulator
Source: nxo_editor\checkboxedit.lua; DestDir: {app}\nxo_editor; Components: modulator
Source: nxo_editor\hexdump.lua; DestDir: {app}\nxo_editor; Components: modulator
Source: nxo_editor\hexedit.lua; DestDir: {app}\nxo_editor; Components: modulator
Source: nxo_editor\ipv4edit.lua; DestDir: {app}\nxo_editor; Components: modulator
Source: nxo_editor\macedit.lua; DestDir: {app}\nxo_editor; Components: modulator
Source: nxo_editor\numedit.lua; DestDir: {app}\nxo_editor; Components: modulator
Source: nxo_editor\rcxveredit.lua; DestDir: {app}\nxo_editor; Components: modulator
Source: nxo_editor\stringedit.lua; DestDir: {app}\nxo_editor; Components: modulator

Source: nxo_editor\page_taglistedit.lua; DestDir: {app}\nxo_editor; Components: modulator
Source: nxo_editor\structedit.lua; DestDir: {app}\nxo_editor; Components: modulator
Source: nxo_editor\nxoeditor.lua; DestDir: {app}\nxo_editor; Components: modulator
Source: nxo_editor\test_description.xml; DestDir: {app}\nxo_editor; Components: modulator

Source: nxo_editor\nxfile.lua; DestDir: {app}\nxo_editor; Components: modulator
Source: nxo_editor\taglist.lua; DestDir: {app}\nxo_editor; Components: modulator
Source: nxo_editor\nxomaker.wx.lua; DestDir: {app}\nxo_editor; Components: modulator
Source: nxo_editor\makenxo.bat; DestDir: {app}\nxo_editor; Components: modulator
Source: nxo_editor\doc\readme.txt; DestDir: {app}\doc; Components: modulator
Source: nxo_editor\doc\readme_cmdline.txt; DestDir: {app}\doc; Components: modulator
Source: nxo_editor\doc\files.txt; DestDir: {app}\doc; Components: modulator
Source: nxo_editor\doc\changelog.txt; DestDir: {app}\doc; DestName: modulator_changelog.txt; Components: modulator

[Icons]
Name: {app}\Tag_List_Editor; Filename: {app}\application\serverkuh.exe; Parameters: "-c Modulator.cfg -i 0 ""{code:ToFileUrl}"""; WorkingDir: {app}\application; IconFilename: {app}\nxo_editor\modulator.ico; Components: modulator
Name: {group}\Tag_List_Editor; Filename: {app}\application\serverkuh.exe; Parameters: "-c Modulator.cfg -i 0 ""{code:ToFileUrl}"""; WorkingDir: {app}\application; IconFilename: {app}\nxo_editor\modulator.ico; Components: modulator; Tasks: startmenu
Name: {group}\Readme; Filename: {app}\doc\readme.txt; Components: modulator; Tasks: startmenu
Name: {group}\Using makenxo.bat; Filename: {app}\doc\readme_cmdline.txt; Components: modulator; Tasks: startmenu
Name: {group}\Files and directories; Filename: {app}\doc\files.txt; Components: modulator; Tasks: startmenu
; Name: {group}\Uninstall; Filename: {uninstallexe}; IconFilename: {app}\nxo_editor\modulator.ico; Components: modulator; Tasks: startmenu

Name: {userdesktop}\Tag List Editor; Filename: {app}\application\serverkuh.exe; Parameters: "-c Modulator.cfg -i 0 ""{code:ToFileUrl}"""; WorkingDir: {app}\application; IconFilename: {app}\nxo_editor\modulator.ico; Components: modulator; Tasks: desktopicon
Name: {userappdata}\Microsoft\Internet Explorer\Quick Launch\Tag_List_Editor; Filename: {app}\application\serverkuh.exe; Parameters: "-c Modulator.cfg -i 0 ""{code:ToFileUrl}"""; WorkingDir: {app}\application; IconFilename: {app}\nxo_editor\modulator.ico; Components: modulator; Tasks: quicklaunchicon

[Registry]
Root: HKLM; Subkey: SYSTEM\CurrentControlSet\Control\Session Manager\Environment; ValueType: string; ValueName: PATH_NXOEDITOR; ValueData: {app}; Flags: uninsdeletevalue; Components: modulator; Tasks: envpath
