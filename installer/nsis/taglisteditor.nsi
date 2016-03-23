; NSIS installer for the Hilscher taglist editor.

;-----------------------------------------------------------------------------
;
; General
;
Name "netX Tag List Editor/NXO Builder"
OutFile taglisteditor_1.2.0.1.exe


;Request application privileges for Windows Vista
RequestExecutionLevel user


PageEx license
	LicenseData doc/licenses.txt
PageExEnd

Page components
Page directory
Page instfiles
UninstPage uninstConfirm
UninstPage instfiles


Section "documentation"
	SetOutPath $INSTDIR/doc

	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/doc/changelog.txt
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/doc/files.txt
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/doc/licenses.txt
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/doc/readme_cmdline.txt
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/doc/readme_tagtool.txt
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/doc/readme.txt
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/doc/tle_components.txt
SectionEnd



Section "help_files"
	SetOutPath $INSTDIR/help

	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/help/misc_tags.htm
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/help/RCX_TAG_DPM_BEHAVIOUR_DATA_T.htm
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/help/RCX_TAG_DPM_COMM_CHANNEL_DATA_T.htm
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/help/RCX_TAG_DPM_SETTINGS_DATA_T.htm
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/help/RCX_TAG_EIF_EDD_CONFIG_DATA_T.htm
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/help/RCX_TAG_EIF_EDD_INSTANCE_DATA_T.htm
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/help/RCX_TAG_EIF_NDIS_ENABLE_DATA_T.htm
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/help/RCX_TAG_ETHERNET_PARAMS_T.htm
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/help/RCX_TAG_FIBER_OPTIC_IF_DMI_NETX100_PARAMS_T.htm
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/help/RCX_TAG_FIBER_OPTIC_IF_DMI_NETX50_PARAMS_T.htm
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/help/RCX_TAG_INTERRUPT_GROUP_T.htm
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/help/RCX_TAG_INTERRUPT_T.htm
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/help/RCX_TAG_IOPIN_T.htm
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/help/RCX_TAG_LED_T.htm
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/help/RCX_TAG_NETPLC_IO_HANDLER_ANALOG_DATA_T.htm
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/help/RCX_TAG_NETPLC_IO_HANDLER_DIGITAL_DATA_T.htm
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/help/RCX_TAG_NETPLC_IO_HANDLER_ENABLE_DATA_T.htm
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/help/RCX_TAG_SERVX_PORT_NUMBER_DATA_T.htm
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/help/RCX_TAG_SWAP_LNK_ACT_LED_T.htm
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/help/RCX_TAG_TASK_GROUP_T.htm
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/help/RCX_TAG_TASK_T.htm
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/help/RCX_TAG_TIMER_T.htm
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/help/RCX_TAG_UART_T.htm
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/help/RCX_TAG_XC_T.htm
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/help/TAG_BSL_BACKUP_POS_PARAMS_DATA_T.htm
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/help/TAG_BSL_DISK_POS_PARAMS_DATA_T.htm
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/help/TAG_BSL_EXTSRAM_PARAMS_DATA_T.htm
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/help/TAG_BSL_FSU_PARAMS_DATA_T.htm
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/help/TAG_BSL_HIF_NETX10_PARAMS_DATA_T.htm
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/help/TAG_BSL_HIF_NETX51_52_PARAMS_DATA_T.htm
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/help/TAG_BSL_HIF_PARAMS_DATA_T.htm
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/help/TAG_BSL_HWDATA_PARAMS_DATA_T.htm
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/help/TAG_BSL_MEDIUM_PARAMS_DATA_T.htm
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/help/TAG_BSL_MMIO_NETX10_PARAMS_DATA_T.htm
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/help/TAG_BSL_MMIO_NETX50_PARAMS_DATA_T.htm
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/help/TAG_BSL_MMIO_NETX51_52_PARAMS_DATA_T.htm
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/help/TAG_BSL_SDMMC_PARAMS_DATA_T.htm
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/help/TAG_BSL_SDRAM_PARAMS_DATA_T.htm
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/help/TAG_BSL_SERFLASH_PARAMS_DATA_T.htm
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/help/TAG_BSL_UART_PARAMS_DATA_T.htm
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/help/TAG_BSL_USB_DESCR_PARAMS_DATA_T.htm
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/help/TAG_BSL_USB_PARAMS_DATA_T.htm
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/help/TAG_CCL_DEVICEID_DATA_T.htm
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/help/TAG_CIP_DEVICEID_DATA_T.htm
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/help/TAG_CO_DEVICEID_DATA_T.htm
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/help/TAG_DIAG_CTRL_DATA_T.htm
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/help/TAG_DP_DEVICEID_DATA_T.htm
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/help/TAG_ECS_CONFIG_EOE_DATA_T.htm
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/help/TAG_ECS_DEVICEID_DATA_T.htm
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/help/TAG_ECS_ENABLE_BOOTSTRAP_DATA_T.htm
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/help/TAG_ECS_MBX_SIZE_DATA_T.htm
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/help/TAG_ECS_SELECT_SOE_COE_DATA_T.htm
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/help/TAG_EIP_EDD_CONFIGURATION_DATA_T.htm
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/help/TAG_PLS_DEVICEID_DATA_T.htm
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/help/TAG_PN_DEVICEID_DATA_T.htm
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/help/TAG_PROFINET_FEATURES_DATA_T.htm
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/help/TAG_S3S_DEVICEID_DATA_T.htm
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/help/TAG_TCP_PORT_NUMBERS_DATA_T.htm
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/help/welcome.htm
SectionEnd



Section "lua_scripts"
	SetOutPath $INSTDIR/lua

	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/lua/checkboxedit.lua
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/lua/checklist_taglistedit.lua
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/lua/comboedit.lua
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/lua/devhdredit.lua
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/lua/gui_stuff.lua
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/lua/hexdump.lua
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/lua/hexedit.lua
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/lua/ipv4edit.lua
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/lua/macedit.lua
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/lua/muhkuh.lua
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/lua/netx_fileheader.lua
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/lua/numedit.lua
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/lua/nxfile.lua
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/lua/nxoeditor.lua
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/lua/nxomaker.wx.lua
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/lua/page_taglistedit.lua
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/lua/rcxveredit.lua
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/lua/select_plugin_cli.lua
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/lua/serialnr.lua
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/lua/stringedit.lua
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/lua/structedit.lua
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/lua/tagdefs_bsl.lua
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/lua/tagdefs_io_handler.lua
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/lua/tagdefs_misc.lua
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/lua/tagdefs_rcx.lua
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/lua/taglist.lua
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/lua/tagtool.wx.lua
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/lua/tester_cli.lua
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/lua/tester_nextid.lua
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/lua/utils.lua
SectionEnd



Section "lua_plugins64"
	SetOutPath $INSTDIR/lua_plugins

	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/lua_plugins/bit.dll
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/lua_plugins/mhash.dll
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/lua_plugins/wx.dll
SectionEnd



Section "lua_plugins32"
	SetOutPath $INSTDIR/lua_plugins

	File installer/ivy/targets/taglisteditor_windows_x86/taglisteditor_windows_x86/lua_plugins/bit.dll
	File installer/ivy/targets/taglisteditor_windows_x86/taglisteditor_windows_x86/lua_plugins/mhash.dll
	File installer/ivy/targets/taglisteditor_windows_x86/taglisteditor_windows_x86/lua_plugins/wx.dll
SectionEnd



Section "lua64"
	SetOutPath $INSTDIR

	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/lua5.1.dll
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/lua.exe
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/wlua.exe
SectionEnd



Section "lua32"
	SetOutPath $INSTDIR

	File installer/ivy/targets/taglisteditor_windows_x86/taglisteditor_windows_x86/lua5.1.dll
	File installer/ivy/targets/taglisteditor_windows_x86/taglisteditor_windows_x86/lua.exe
	File installer/ivy/targets/taglisteditor_windows_x86/taglisteditor_windows_x86/wlua.exe
SectionEnd



Section "shell_scripts"
	SetOutPath $INSTDIR

	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/makenxo.bat
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/makenxo_dev.bat
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/taglisteditor.bat
SectionEnd



Section "misc"
	SetOutPath $INSTDIR

	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/muhkuh_cli_init.lua
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/netX.ico
	File installer/ivy/targets/taglisteditor_windows_amd64/taglisteditor_windows_amd64/taglisteditor.lua
SectionEnd



