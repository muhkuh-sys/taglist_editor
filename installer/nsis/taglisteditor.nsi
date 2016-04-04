;-----------------------------------------------------------------------------
; NSIS installer for the Hilscher taglist editor.

!include FileFunc.nsh
!include MUI.nsh
!include x64.nsh


;-----------------------------------------------------------------------------
;
; General
;
!define APPNAME "Tag List Editor"
!define COMPANYNAME "Hilscher GmbH"
!define DESCRIPTION "netX Tag List Editor/NXO Builder"
!define APPICON "installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/netX.ico"

!define VERSION_MAJOR 1
!define VERSION_MINOR 2
!define VERSION_MICRO 0
!define VERSION_SUB   1

# These will be displayed by the "Click here for support information" link in "Add/Remove Programs"
# It is possible to use "mailto:" links in here to open the email client
!define HELPURL "https://kb.hilscher.com/display/TLE/Tag+List+Editor"
!define UPDATEURL "https://kb.hilscher.com/display/TLE/Tag+List+Editor"
!define ABOUTURL "https://kb.hilscher.com/display/TLE/Tag+List+Editor"


!define SRC_CM "installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64"
!define SRC_32 "installer/ivy/targets/taglisteditor_windows_x86/taglisteditor_windows_x86"
!define SRC_64 "installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64"



Name "${DESCRIPTION} ${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_MICRO}.${VERSION_SUB}"
OutFile "taglisteditor_${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_MICRO}.${VERSION_SUB}.exe"
; NOTE: Do not use "InstallDir" here, the variable "INSTDIR" is set in the ".onInit" function.

;Request admin privileges for Windows Vista and later.
; NOTE: This is necessary to create the default installation folder in the "Program Files".
; FIXME: Maybe there is a way to offer an installation for the current user only without admin rights.
RequestExecutionLevel admin


; Use solid LZMA compression for the complete file.
SetCompressor /SOLID /FINAL lzma


; Set the icon for the installer.
Icon "${APPICON}"


;-----------------------------------------------------------------------------
;
; MUI configuration
; See http://nsis.sourceforge.net/Docs/Modern%20UI/Readme.html for details.
;
!define MUI_HEADERIMAGE
!define MUI_ABORTWARNING
!define MUI_COMPONENTSPAGE_SMALLDESC
!define MUI_HEADERIMAGE_BITMAP_NOSTRETCH
!define MUI_FINISHPAGE
!define MUI_FINISHPAGE_TEXT "Thank you for installing the ${DESCRIPTION}."
!define MUI_WELCOMEFINISHPAGE_BITMAP "installer/nsis/Screen-netX_164x314px.bmp"
!define MUI_ICON "${APPICON}"


;-----------------------------------------------------------------------------
;
; Pages
;
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "doc/licenses.txt"
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES


;-----------------------------------------------------------------------------
;
; Languages
;
!insertmacro MUI_LANGUAGE "English"



;-----------------------------------------------------------------------------
;
; The .onInit function will be called at the beginning of the installation
; process.
;
Function .onInit
	; Set the default installation folder to programfiles32
	; or ...64 depending on the platform.
	${If} ${RunningX64}
		StrCpy $INSTDIR "$programfiles64\Hilscher GmbH\Tag List Editor"
	${Else}
		StrCpy $INSTDIR "$programfiles32\Hilscher GmbH\Tag List Editor"
	${EndIf}
FunctionEnd



function un.onInit
	; Ask the user to confirm removing the program.
	MessageBox MB_OKCANCEL "Permanantly remove the ${APPNAME}?" IDOK next
		Abort
	next:
functionEnd


;-----------------------------------------------------------------------------
;
; There is only one big install section to keep things simple for the user.
; It would be possible to create multiple components, but is it really useful
; to install only a part of the taglisteditor?
;
Section "-install"
	SetOutPath "$INSTDIR"

	${If} ${RunningX64}
		File ${SRC_64}/lua5.1.dll
		File ${SRC_64}/lua.exe
		File ${SRC_64}/wlua.exe
	${Else}
		File ${SRC_32}/lua5.1.dll
		File ${SRC_32}/lua.exe
		File ${SRC_32}/wlua.exe
	${EndIf}

	File ${SRC_CM}/makenxo.bat
	File ${SRC_CM}/makenxo_dev.bat
	File ${SRC_CM}/muhkuh_cli_init.lua
	File ${SRC_CM}/taglisteditor.bat
	File ${SRC_CM}/taglisteditor.lua

	File ${SRC_CM}/netX.ico



	SetOutPath "$INSTDIR\doc"

	File ${SRC_CM}/doc/changelog.txt
	File ${SRC_CM}/doc/files.txt
	File ${SRC_CM}/doc/licenses.txt
	File ${SRC_CM}/doc/readme_cmdline.txt
	File ${SRC_CM}/doc/readme_tagtool.txt
	File ${SRC_CM}/doc/readme.txt
	File ${SRC_CM}/doc/tle_components.txt



	SetOutPath "$INSTDIR\help"

	File ${SRC_CM}/help/misc_tags.htm
	File ${SRC_CM}/help/RCX_TAG_DPM_BEHAVIOUR_DATA_T.htm
	File ${SRC_CM}/help/RCX_TAG_DPM_COMM_CHANNEL_DATA_T.htm
	File ${SRC_CM}/help/RCX_TAG_DPM_SETTINGS_DATA_T.htm
	File ${SRC_CM}/help/RCX_TAG_EIF_EDD_CONFIG_DATA_T.htm
	File ${SRC_CM}/help/RCX_TAG_EIF_EDD_INSTANCE_DATA_T.htm
	File ${SRC_CM}/help/RCX_TAG_EIF_NDIS_ENABLE_DATA_T.htm
	File ${SRC_CM}/help/RCX_TAG_ETHERNET_PARAMS_T.htm
	File ${SRC_CM}/help/RCX_TAG_FIBER_OPTIC_IF_DMI_NETX100_PARAMS_T.htm
	File ${SRC_CM}/help/RCX_TAG_FIBER_OPTIC_IF_DMI_NETX50_PARAMS_T.htm
	File ${SRC_CM}/help/RCX_TAG_INTERRUPT_GROUP_T.htm
	File ${SRC_CM}/help/RCX_TAG_INTERRUPT_T.htm
	File ${SRC_CM}/help/RCX_TAG_IOPIN_T.htm
	File ${SRC_CM}/help/RCX_TAG_LED_T.htm
	File ${SRC_CM}/help/RCX_TAG_NETPLC_IO_HANDLER_ANALOG_DATA_T.htm
	File ${SRC_CM}/help/RCX_TAG_NETPLC_IO_HANDLER_DIGITAL_DATA_T.htm
	File ${SRC_CM}/help/RCX_TAG_NETPLC_IO_HANDLER_ENABLE_DATA_T.htm
	File ${SRC_CM}/help/RCX_TAG_SERVX_PORT_NUMBER_DATA_T.htm
	File ${SRC_CM}/help/RCX_TAG_SWAP_LNK_ACT_LED_T.htm
	File ${SRC_CM}/help/RCX_TAG_TASK_GROUP_T.htm
	File ${SRC_CM}/help/RCX_TAG_TASK_T.htm
	File ${SRC_CM}/help/RCX_TAG_TIMER_T.htm
	File ${SRC_CM}/help/RCX_TAG_UART_T.htm
	File ${SRC_CM}/help/RCX_TAG_XC_T.htm
	File ${SRC_CM}/help/TAG_BSL_BACKUP_POS_PARAMS_DATA_T.htm
	File ${SRC_CM}/help/TAG_BSL_DISK_POS_PARAMS_DATA_T.htm
	File ${SRC_CM}/help/TAG_BSL_EXTSRAM_PARAMS_DATA_T.htm
	File ${SRC_CM}/help/TAG_BSL_FSU_PARAMS_DATA_T.htm
	File ${SRC_CM}/help/TAG_BSL_HIF_NETX10_PARAMS_DATA_T.htm
	File ${SRC_CM}/help/TAG_BSL_HIF_NETX51_52_PARAMS_DATA_T.htm
	File ${SRC_CM}/help/TAG_BSL_HIF_PARAMS_DATA_T.htm
	File ${SRC_CM}/help/TAG_BSL_HWDATA_PARAMS_DATA_T.htm
	File ${SRC_CM}/help/TAG_BSL_MEDIUM_PARAMS_DATA_T.htm
	File ${SRC_CM}/help/TAG_BSL_MMIO_NETX10_PARAMS_DATA_T.htm
	File ${SRC_CM}/help/TAG_BSL_MMIO_NETX50_PARAMS_DATA_T.htm
	File ${SRC_CM}/help/TAG_BSL_MMIO_NETX51_52_PARAMS_DATA_T.htm
	File ${SRC_CM}/help/TAG_BSL_SDMMC_PARAMS_DATA_T.htm
	File ${SRC_CM}/help/TAG_BSL_SDRAM_PARAMS_DATA_T.htm
	File ${SRC_CM}/help/TAG_BSL_SERFLASH_PARAMS_DATA_T.htm
	File ${SRC_CM}/help/TAG_BSL_UART_PARAMS_DATA_T.htm
	File ${SRC_CM}/help/TAG_BSL_USB_DESCR_PARAMS_DATA_T.htm
	File ${SRC_CM}/help/TAG_BSL_USB_PARAMS_DATA_T.htm
	File ${SRC_CM}/help/TAG_CCL_DEVICEID_DATA_T.htm
	File ${SRC_CM}/help/TAG_CIP_DEVICEID_DATA_T.htm
	File ${SRC_CM}/help/TAG_CO_DEVICEID_DATA_T.htm
	File ${SRC_CM}/help/TAG_DIAG_CTRL_DATA_T.htm
	File ${SRC_CM}/help/TAG_DP_DEVICEID_DATA_T.htm
	File ${SRC_CM}/help/TAG_ECS_CONFIG_EOE_DATA_T.htm
	File ${SRC_CM}/help/TAG_ECS_DEVICEID_DATA_T.htm
	File ${SRC_CM}/help/TAG_ECS_ENABLE_BOOTSTRAP_DATA_T.htm
	File ${SRC_CM}/help/TAG_ECS_MBX_SIZE_DATA_T.htm
	File ${SRC_CM}/help/TAG_ECS_SELECT_SOE_COE_DATA_T.htm
	File ${SRC_CM}/help/TAG_EIP_EDD_CONFIGURATION_DATA_T.htm
	File ${SRC_CM}/help/TAG_PLS_DEVICEID_DATA_T.htm
	File ${SRC_CM}/help/TAG_PN_DEVICEID_DATA_T.htm
	File ${SRC_CM}/help/TAG_PROFINET_FEATURES_DATA_T.htm
	File ${SRC_CM}/help/TAG_S3S_DEVICEID_DATA_T.htm
	File ${SRC_CM}/help/TAG_TCP_PORT_NUMBERS_DATA_T.htm
	File ${SRC_CM}/help/welcome.htm



	SetOutPath "$INSTDIR\lua"

	File ${SRC_CM}/lua/checkboxedit.lua
	File ${SRC_CM}/lua/checklist_taglistedit.lua
	File ${SRC_CM}/lua/comboedit.lua
	File ${SRC_CM}/lua/devhdredit.lua
	File ${SRC_CM}/lua/gui_stuff.lua
	File ${SRC_CM}/lua/hexdump.lua
	File ${SRC_CM}/lua/hexedit.lua
	File ${SRC_CM}/lua/ipv4edit.lua
	File ${SRC_CM}/lua/macedit.lua
	File ${SRC_CM}/lua/muhkuh.lua
	File ${SRC_CM}/lua/netx_fileheader.lua
	File ${SRC_CM}/lua/numedit.lua
	File ${SRC_CM}/lua/nxfile.lua
	File ${SRC_CM}/lua/nxoeditor.lua
	File ${SRC_CM}/lua/nxomaker.wx.lua
	File ${SRC_CM}/lua/page_taglistedit.lua
	File ${SRC_CM}/lua/rcxveredit.lua
	File ${SRC_CM}/lua/select_plugin_cli.lua
	File ${SRC_CM}/lua/serialnr.lua
	File ${SRC_CM}/lua/stringedit.lua
	File ${SRC_CM}/lua/structedit.lua
	File ${SRC_CM}/lua/tagdefs_bsl.lua
	File ${SRC_CM}/lua/tagdefs_io_handler.lua
	File ${SRC_CM}/lua/tagdefs_misc.lua
	File ${SRC_CM}/lua/tagdefs_rcx.lua
	File ${SRC_CM}/lua/taglist.lua
	File ${SRC_CM}/lua/tagtool.wx.lua
	File ${SRC_CM}/lua/tester_cli.lua
	File ${SRC_CM}/lua/tester_nextid.lua
	File ${SRC_CM}/lua/utils.lua



	SetOutPath "$INSTDIR\lua_plugins"

	${If} ${RunningX64}
		File ${SRC_64}/lua_plugins/bit.dll
		File ${SRC_64}/lua_plugins/mhash.dll
		File ${SRC_64}/lua_plugins/wx.dll
	${Else}
		File ${SRC_32}/lua_plugins/bit.dll
		File ${SRC_32}/lua_plugins/mhash.dll
		File ${SRC_32}/lua_plugins/wx.dll
	${EndIf}



	SetOutPath "$INSTDIR"

	CreateShortCut "taglisteditor.lnk" "$INSTDIR\wlua.exe" "$\"$INSTDIR\taglisteditor.lua$\"" "$INSTDIR\netX.ico" 0



	; Write the uninstaller.
	writeUninstaller "$INSTDIR\uninstall.exe"



	# Registry information for add/remove programs
	# See http://nsis.sourceforge.net/Add_uninstall_information_to_Add/Remove_Programs for details and how-to's.
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "DisplayName" "${COMPANYNAME} - ${APPNAME} - ${DESCRIPTION}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "UninstallString" "$\"$INSTDIR\uninstall.exe$\""
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "QuietUninstallString" "$\"$INSTDIR\uninstall.exe$\" /S"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "InstallLocation" "$\"$INSTDIR$\""
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "DisplayIcon" "$\"$INSTDIR\netX.ico$\""
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "Publisher" "$\"${COMPANYNAME}$\""
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "HelpLink" "$\"${HELPURL}$\""
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "URLUpdateInfo" "$\"${UPDATEURL}$\""
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "URLInfoAbout" "$\"${ABOUTURL}$\""
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "DisplayVersion" "$\"${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_MICRO}.${VERSION_SUB}$\""
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "VersionMajor" ${VERSION_MAJOR}
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "VersionMinor" ${VERSION_MINOR}
	# There is no option for modifying or repairing the install
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "NoModify" 1
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "NoRepair" 1
	# Get the size of the installed folder.
	${GetSize} "$INSTDIR" "/S=0K" $0 $1 $2
	IntFmt $0 "0x%08X" $0
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "EstimatedSize" "$0"
SectionEnd



Section "Desktop shortcut" section_desktop_shortcut
	SetOutPath "$INSTDIR"
	CreateShortCut "$DESKTOP\taglisteditor.lnk" "$INSTDIR\wlua.exe" "$\"$INSTDIR\taglisteditor.lua$\"" "$INSTDIR\netX.ico" 0
SectionEnd



Section "Quicklaunch entry" section_quicklaunch_entry
	SetOutPath "$INSTDIR"
	CreateShortCut "$QUICKLAUNCH\taglisteditor.lnk" "$INSTDIR\wlua.exe" "$\"$INSTDIR\taglisteditor.lua$\"" "$INSTDIR\netX.ico" 0
SectionEnd



Section "Start menu entries" section_start_menu_entries
	SetOutPath "$INSTDIR"

	createDirectory "$SMPROGRAMS\${COMPANYNAME}"
	createShortCut "$SMPROGRAMS\${COMPANYNAME}\${APPNAME}.lnk" "$INSTDIR\wxlua.exe" "$\"$INSTDIR\taglisteditor.lua$\"" "$INSTDIR\netX.ico"
	createShortCut "$SMPROGRAMS\${COMPANYNAME}\Uninstall.lnk" "$INSTDIR\uninstall.exe" "" "$INSTDIR\netX.ico"
SectionEnd



Section "uninstall"
	; Remove Start Menu launcher
	delete "$SMPROGRAMS\${COMPANYNAME}\${APPNAME}.lnk"
	delete "$SMPROGRAMS\${COMPANYNAME}\Uninstall.lnk"
	; Try to remove the Start Menu folder - this will only happen if it is empty
	rmDir "$SMPROGRAMS\${COMPANYNAME}"

	; Remove the quicklaunch entries.
	delete "$QUICKLAUNCH\taglisteditor.lnk"

	; Remove the desktop shortcut.
	delete "$DESKTOP\taglisteditor.lnk"



	delete "$INSTDIR\doc\changelog.txt"
	delete "$INSTDIR\doc\files.txt"
	delete "$INSTDIR\doc\licenses.txt"
	delete "$INSTDIR\doc\readme_cmdline.txt"
	delete "$INSTDIR\doc\readme_tagtool.txt"
	delete "$INSTDIR\doc\readme.txt"
	delete "$INSTDIR\doc\tle_components.txt"
	rmDir "$INSTDIR\doc"

	delete "$INSTDIR\help\misc_tags.htm"
	delete "$INSTDIR\help\RCX_TAG_DPM_BEHAVIOUR_DATA_T.htm"
	delete "$INSTDIR\help\RCX_TAG_DPM_COMM_CHANNEL_DATA_T.htm"
	delete "$INSTDIR\help\RCX_TAG_DPM_SETTINGS_DATA_T.htm"
	delete "$INSTDIR\help\RCX_TAG_EIF_EDD_CONFIG_DATA_T.htm"
	delete "$INSTDIR\help\RCX_TAG_EIF_EDD_INSTANCE_DATA_T.htm"
	delete "$INSTDIR\help\RCX_TAG_EIF_NDIS_ENABLE_DATA_T.htm"
	delete "$INSTDIR\help\RCX_TAG_ETHERNET_PARAMS_T.htm"
	delete "$INSTDIR\help\RCX_TAG_FIBER_OPTIC_IF_DMI_NETX100_PARAMS_T.htm"
	delete "$INSTDIR\help\RCX_TAG_FIBER_OPTIC_IF_DMI_NETX50_PARAMS_T.htm"
	delete "$INSTDIR\help\RCX_TAG_INTERRUPT_GROUP_T.htm"
	delete "$INSTDIR\help\RCX_TAG_INTERRUPT_T.htm"
	delete "$INSTDIR\help\RCX_TAG_IOPIN_T.htm"
	delete "$INSTDIR\help\RCX_TAG_LED_T.htm"
	delete "$INSTDIR\help\RCX_TAG_NETPLC_IO_HANDLER_ANALOG_DATA_T.htm"
	delete "$INSTDIR\help\RCX_TAG_NETPLC_IO_HANDLER_DIGITAL_DATA_T.htm"
	delete "$INSTDIR\help\RCX_TAG_NETPLC_IO_HANDLER_ENABLE_DATA_T.htm"
	delete "$INSTDIR\help\RCX_TAG_SERVX_PORT_NUMBER_DATA_T.htm"
	delete "$INSTDIR\help\RCX_TAG_SWAP_LNK_ACT_LED_T.htm"
	delete "$INSTDIR\help\RCX_TAG_TASK_GROUP_T.htm"
	delete "$INSTDIR\help\RCX_TAG_TASK_T.htm"
	delete "$INSTDIR\help\RCX_TAG_TIMER_T.htm"
	delete "$INSTDIR\help\RCX_TAG_UART_T.htm"
	delete "$INSTDIR\help\RCX_TAG_XC_T.htm"
	delete "$INSTDIR\help\TAG_BSL_BACKUP_POS_PARAMS_DATA_T.htm"
	delete "$INSTDIR\help\TAG_BSL_DISK_POS_PARAMS_DATA_T.htm"
	delete "$INSTDIR\help\TAG_BSL_EXTSRAM_PARAMS_DATA_T.htm"
	delete "$INSTDIR\help\TAG_BSL_FSU_PARAMS_DATA_T.htm"
	delete "$INSTDIR\help\TAG_BSL_HIF_NETX10_PARAMS_DATA_T.htm"
	delete "$INSTDIR\help\TAG_BSL_HIF_NETX51_52_PARAMS_DATA_T.htm"
	delete "$INSTDIR\help\TAG_BSL_HIF_PARAMS_DATA_T.htm"
	delete "$INSTDIR\help\TAG_BSL_HWDATA_PARAMS_DATA_T.htm"
	delete "$INSTDIR\help\TAG_BSL_MEDIUM_PARAMS_DATA_T.htm"
	delete "$INSTDIR\help\TAG_BSL_MMIO_NETX10_PARAMS_DATA_T.htm"
	delete "$INSTDIR\help\TAG_BSL_MMIO_NETX50_PARAMS_DATA_T.htm"
	delete "$INSTDIR\help\TAG_BSL_MMIO_NETX51_52_PARAMS_DATA_T.htm"
	delete "$INSTDIR\help\TAG_BSL_SDMMC_PARAMS_DATA_T.htm"
	delete "$INSTDIR\help\TAG_BSL_SDRAM_PARAMS_DATA_T.htm"
	delete "$INSTDIR\help\TAG_BSL_SERFLASH_PARAMS_DATA_T.htm"
	delete "$INSTDIR\help\TAG_BSL_UART_PARAMS_DATA_T.htm"
	delete "$INSTDIR\help\TAG_BSL_USB_DESCR_PARAMS_DATA_T.htm"
	delete "$INSTDIR\help\TAG_BSL_USB_PARAMS_DATA_T.htm"
	delete "$INSTDIR\help\TAG_CCL_DEVICEID_DATA_T.htm"
	delete "$INSTDIR\help\TAG_CIP_DEVICEID_DATA_T.htm"
	delete "$INSTDIR\help\TAG_CO_DEVICEID_DATA_T.htm"
	delete "$INSTDIR\help\TAG_DIAG_CTRL_DATA_T.htm"
	delete "$INSTDIR\help\TAG_DP_DEVICEID_DATA_T.htm"
	delete "$INSTDIR\help\TAG_ECS_CONFIG_EOE_DATA_T.htm"
	delete "$INSTDIR\help\TAG_ECS_DEVICEID_DATA_T.htm"
	delete "$INSTDIR\help\TAG_ECS_ENABLE_BOOTSTRAP_DATA_T.htm"
	delete "$INSTDIR\help\TAG_ECS_MBX_SIZE_DATA_T.htm"
	delete "$INSTDIR\help\TAG_ECS_SELECT_SOE_COE_DATA_T.htm"
	delete "$INSTDIR\help\TAG_EIP_EDD_CONFIGURATION_DATA_T.htm"
	delete "$INSTDIR\help\TAG_PLS_DEVICEID_DATA_T.htm"
	delete "$INSTDIR\help\TAG_PN_DEVICEID_DATA_T.htm"
	delete "$INSTDIR\help\TAG_PROFINET_FEATURES_DATA_T.htm"
	delete "$INSTDIR\help\TAG_S3S_DEVICEID_DATA_T.htm"
	delete "$INSTDIR\help\TAG_TCP_PORT_NUMBERS_DATA_T.htm"
	delete "$INSTDIR\help\welcome.htm"
	rmDir "$INSTDIR\help"

	delete "$INSTDIR\lua\checkboxedit.lua"
	delete "$INSTDIR\lua\checklist_taglistedit.lua"
	delete "$INSTDIR\lua\comboedit.lua"
	delete "$INSTDIR\lua\devhdredit.lua"
	delete "$INSTDIR\lua\gui_stuff.lua"
	delete "$INSTDIR\lua\hexdump.lua"
	delete "$INSTDIR\lua\hexedit.lua"
	delete "$INSTDIR\lua\ipv4edit.lua"
	delete "$INSTDIR\lua\macedit.lua"
	delete "$INSTDIR\lua\muhkuh.lua"
	delete "$INSTDIR\lua\netx_fileheader.lua"
	delete "$INSTDIR\lua\numedit.lua"
	delete "$INSTDIR\lua\nxfile.lua"
	delete "$INSTDIR\lua\nxoeditor.lua"
	delete "$INSTDIR\lua\nxomaker.wx.lua"
	delete "$INSTDIR\lua\page_taglistedit.lua"
	delete "$INSTDIR\lua\rcxveredit.lua"
	delete "$INSTDIR\lua\select_plugin_cli.lua"
	delete "$INSTDIR\lua\serialnr.lua"
	delete "$INSTDIR\lua\stringedit.lua"
	delete "$INSTDIR\lua\structedit.lua"
	delete "$INSTDIR\lua\tagdefs_bsl.lua"
	delete "$INSTDIR\lua\tagdefs_io_handler.lua"
	delete "$INSTDIR\lua\tagdefs_misc.lua"
	delete "$INSTDIR\lua\tagdefs_rcx.lua"
	delete "$INSTDIR\lua\taglist.lua"
	delete "$INSTDIR\lua\tagtool.wx.lua"
	delete "$INSTDIR\lua\tester_cli.lua"
	delete "$INSTDIR\lua\tester_nextid.lua"
	delete "$INSTDIR\lua\utils.lua"
	rmDir "$INSTDIR\lua"

	${If} ${RunningX64}
		delete "$INSTDIR\lua_plugins\bit.dll"
		delete "$INSTDIR\lua_plugins\mhash.dll"
		delete "$INSTDIR\lua_plugins\wx.dll"
	${Else}
		delete "$INSTDIR\lua_plugins\bit.dll"
		delete "$INSTDIR\lua_plugins\mhash.dll"
		delete "$INSTDIR\lua_plugins\wx.dll"
	${EndIf}
	rmDir "$INSTDIR\lua_plugins"

	${If} ${RunningX64}
		delete "$INSTDIR\lua5.1.dll"
		delete "$INSTDIR\lua.exe"
		delete "$INSTDIR\wlua.exe"
	${Else}
		delete "$INSTDIR\lua5.1.dll"
		delete "$INSTDIR\lua.exe"
		delete "$INSTDIR\wlua.exe"
	${EndIf}

	delete "$INSTDIR\makenxo.bat"
	delete "$INSTDIR\makenxo_dev.bat"
	delete "$INSTDIR\muhkuh_cli_init.lua"
	delete "$INSTDIR\netX.ico"
	delete "$INSTDIR\taglisteditor.bat"
	delete "$INSTDIR\taglisteditor.lnk"
	delete "$INSTDIR\taglisteditor.lua"


	# Always delete uninstaller as the last action
	delete "$INSTDIR\uninstall.exe"



	# Try to remove the install directory - this will only happen if it is empty
	rmDir "$INSTDIR"



	# Remove uninstaller information from the registry
	DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}"
SectionEnd



LangString DESC_section_desktop_shortcut   ${LANG_ENGLISH} "A desktop shortcut for the ${APPNAME}."
LangString DESC_section_quicklaunch_entry  ${LANG_ENGLISH} "A quicklaunch entry for the ${APPNAME}."
LangString DESC_section_start_menu_entries ${LANG_ENGLISH} "Start menu entries for the ${APPNAME}."



!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
	!insertmacro MUI_DESCRIPTION_TEXT ${section_desktop_shortcut} $(DESC_section_desktop_shortcut)
	!insertmacro MUI_DESCRIPTION_TEXT ${section_quicklaunch_entry} $(DESC_section_quicklaunch_entry)
!insertmacro MUI_FUNCTION_DESCRIPTION_END
