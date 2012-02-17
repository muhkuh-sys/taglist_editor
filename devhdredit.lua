---------------------------------------------------------------------------
-- Copyright (C) 2010 Hilscher Gesellschaft für Systemautomation mbH
--
-- Description:
--   Editor for device header, component of Taglist editor
--
--  Changes:
--    Date        Author   Description
---------------------------------------------------------------------------
--  2012-02-16    SL       allow editing of HW compatibility field
---------------------------------------------------------------------------
-- SVN Keywords
--
-- $Date$
-- $Revision$
-- $Author$
---------------------------------------------------------------------------

module("devhdredit", package.seeall)


---------------------------------------------------------------------
--       Definition of /GUI for device header V1
---------------------------------------------------------------------

require("taglist")

--[[
UINT32	ulStructVersion	structure version (high word = major, low word = minor version), V1.0 = 0x00010000
UINT16	usManufacturer	manufacturer code as defined in the Security EEPROM specification
UINT16	usDeviceClass	device class ID
UINT8	bHwCompatibility	hardware compatibility ID
UINT8	bChipType	0=ignore, 1=netX500, 2=netX100, 3=netX50, 0x40=xPEC500, 0x41=xPEC100, 0x42=xPEC50
UINT16	usReserved	reserved, set to zero
UINT16	ausHwOptions[4]	required hardware assembly option for xC0 (summary for complete firmware, 0 =xC not used by firmware)
UINT16	     "	required hardware assembly option for xC1 (summary for complete firmware, 0 =xC not used by firmware)
UINT16	     "	required hardware assembly option for xC2 (summary for complete firmware, 0 =xC not used by firmware)
UINT16	     "	required hardware assembly option for xC3 (summary for complete firmware, 0 =xC not used by firmware)
UINT32	ulLicenseFlags1	each bit signals the requirement for a dedicated Hilscher protocol master license (for a quick check)
UINT32	ulLicenseFlags2	each bit signals the requirement for a dedicated Hilscher tool license (for a quick check)
UINT16	usNetXLicenseID	defines a special netX user license ID
UINT16	usNetXLicenseFlags	each bit enables a dedicated netX user license
UINT16	ausFwVersion[4]	firmware version (major)
UINT16	     "	firmware version (minor)
UINT16	     "	firmware version (build)
UINT16	     "	firmware version (revision)
UINT32	ulFwNumber	firmware product code (order number, Hilscher ERP system reference) OR project number (zero, if unused)
UINT32	ulDeviceNumber	target device product code (order number, Hilscher ERP system reference, set to zero if unused)
UINT32	ulSerialNumber	target device serial number (set to zero if unused)
UINT32	aulReserved[3]	reserved, set to zero
UINT32	     "	reserved, set to zero
UINT32	     "	reserved, set to zero
--]]

taglist.registerStructType("DEVICE_HEADER_V1_T", 
{
  {"UINT32", "ulStructVersion",     desc="Structure Version",     mode="read-only"},
  {"UINT16", "usManufacturer",      desc="Manufacturer Code"},
  {"UINT16", "usDeviceClass",       desc="Device Class"},
  {"UINT8",  "bHwCompatibility",    desc="HW Compatibility"},
  {"UINT8",  "bChipType",           desc="Chip Type",             mode="read-only"},
  {"UINT16", "usReserved",          desc="Reserved",              mode="hidden"},
  {"UINT16", "usHWOptions_1",       desc="HW Options 1"},
  {"UINT16", "usHWOptions_2",       desc="HW Options 2"},
  {"UINT16", "usHWOptions_3",       desc="HW Options 3"},
  {"UINT16", "usHWOptions_4",       desc="HW Options 4"},
  {"UINT32", "ulLicenseFlags1",     desc="License Flags 1",       mode="read-only"},
  {"UINT32", "ulLicenseFlags2",     desc="License Flags 2",       mode="read-only"},
  {"UINT16", "usNetXLicenseID",     desc="netX License Id",       mode="read-only"},
  {"UINT16", "usNetXLicenseFlags",  desc="netX License Flags",    mode="read-only"},
  {"UINT16", "ulFwVersion_Major",   desc="Major",                 mode="read-only", editorParam={format="%u"}},
  {"UINT16", "ulFwVersion_Minor",   desc="Minor",                 mode="read-only", editorParam={format="%u"}},
  {"UINT16", "ulFwVersion_Build",   desc="Build",                 mode="read-only", editorParam={format="%u"}},
  {"UINT16", "ulFwVersion_Revision",desc="Revision",              mode="read-only", editorParam={format="%u"}},
  {"UINT32", "ulFwNumber",          desc="Firmware Product Code", mode="read-only", editorParam={format="%u"}},
  {"UINT32", "ulDeviceNumber",      desc="Device Product Code",                     editorParam={format="%u"}},  
  {"UINT32", "ulSerialNumber",      desc="Device Serial Number",                    editorParam={format="%u"}},  
  {"UINT32", "ulReserved1",         desc="Reserved",              mode="hidden"},
  {"UINT32", "ulReserved2",         desc="Reserved",              mode="hidden"},
  {"UINT32", "ulReserved3",         desc="Reserved",              mode="hidden"},

   
  layout =
  {sizer="v",
     "ulStructVersion",
     {sizer="h",
        {sizer="grid", box="Device",
			"usManufacturer", "usDeviceClass", "bHwCompatibility", "bChipType"},
        {sizer="grid", box="Hardware Options",
        	"usHWOptions_1", "usHWOptions_2", "usHWOptions_3", "usHWOptions_4"},  
        {sizer="grid", box="Procuct Codes/Serial Number",
        	"ulFwNumber", "ulDeviceNumber", "ulSerialNumber"}
     },
     {sizer="h",     
        {sizer="grid", box="License information", 
        	"ulLicenseFlags1", "ulLicenseFlags2", "usNetXLicenseID", "usNetXLicenseFlags"},
        {sizer="grid", box="Firmware Version",
        	"ulFwVersion_Major", "ulFwVersion_Minor", "ulFwVersion_Build", "ulFwVersion_Revision"},
     }
  }
})

---------------------------------------------------------------------
--       Edit dialogue for device header
---------------------------------------------------------------------
--[[
function getDevHdrBin()
	local fOk, aErrors = devhdredit.m_editor:isValid()
	if fOk then
		return devhdredit.m_editor:getValue()
	else
		local strMsg = "Please enter correct values for the following parameters:\n"
		.. table.concat(taglist.makeErrorStrings(aErrors), "\n")
		gui_stuff.errorDialog("Incorrect entries", strMsg)
		return nil
	end
end

local function OnConfirm()
	if devhdredit.getDevHdrBin() then
		devhdredit.m_win:EndModal(wx.wxID_OK)
	end
end

-- get binary
-- File requester, Query overwrite
-- Save, Report write errors
local function OnSave()
	local abDevHdr = devhdredit.getDevHdrBin()
	if abDevHdr then
		local strFilename = nxoeditor.saveFileDialog(devhdredit.m_win, "Save Device Header")
		if strFilename then 
			nxoeditor.saveFile(strFilename, abDevHdr)
		end
	end
end
--]]

local function OnConfirm()
	local fOk, aErrors = devhdredit.m_editor:isValid()
	if fOk then
		devhdredit.m_win:EndModal(wx.wxID_OK)
	else
		local strMsg = "Please enter correct values for the following parameters:\n"
		.. table.concat(taglist.makeErrorStrings(aErrors), "\n")
		gui_stuff.errorDialog("Incorrect entries", strMsg)
		return
	end
end

local function OnDiscard()
	devhdredit.m_win:EndModal(wx.wxID_CANCEL)
end

-- get binary
-- File requester, Query overwrite
-- Save, Report write errors
local function OnSave()
	local fOk, aErrors, strMsg
	fOk, aErrors = devhdredit.m_editor:isValid()
	if fOk then
		local abDevHdr = devhdredit.m_editor:getValue()
		local strFilename = nxoeditor.saveFileDialog(devhdredit.m_win, "Save Device Header")
		if strFilename then 
			nxoeditor.saveFile(strFilename, abDevHdr)
		end
	else
		strMsg = "Please enter correct values for the following parameters:\n"
		.. table.concat(taglist.makeErrorStrings(aErrors), "\n")
		gui_stuff.errorDialog("Incorrect entries", strMsg)
	end
end

-- File requester
-- load, Report load errors
-- check if device header V1
-- update editor
local function OnLoad()
	local strFilename = nxoeditor.loadFileDialog(devhdredit.m_win, "Load Device Header")
	if strFilename then
		local iStatus, abDevHdr = nxoeditor.loadFile(strFilename)
		if iStatus == nxoeditor.STATUS_OK and abDevHdr then
			local fOk, strMsg = netx_fileheader.isDeviceHeaderV1(abDevHdr)
			if fOk then
				devhdredit.m_editor:setValue(abDevHdr)
			else
				gui_stuff.errorDialog("Invalid binary", "This file is not a Device Header V1.\n" .. (strMsg or ""))
			end
		end
	end
end


function editDeviceHeader(nxfile)
	m_win = wx.wxDialog(wx.NULL, wx.wxID_ANY, "Edit Device Header", 
		wx.wxDefaultPosition, wx.wxDefaultSize, wx.wxDEFAULT_DIALOG_STYLE+wx.wxRESIZE_BORDER)
	local mainSizer = wx.wxBoxSizer(wx.wxVERTICAL)
	m_win:SetSizer(mainSizer)

	m_abDevHdr = nxfile:getDeviceHeader()
	m_editor = structedit.new("DEVICE_HEADER_V1_T")
	m_editCtrl = m_editor:create(m_win)
	m_editor:setValue(m_abDevHdr)
	
	mainSizer:Add(m_editCtrl, 1, wx.wxEXPAND + wx.wxALL, 3)
	-- buttons/button sizer
	--local buttonSizer = m_win:CreateButtonSizer(wx.wxOK + wx.wxCANCEL)
	local buttonSizer = wx.wxBoxSizer(wx.wxHORIZONTAL)
	local buttonConfirm = gui_stuff.createButton(m_win, "Confirm Changes", OnConfirm)
	local buttonDiscard = gui_stuff.createButton(m_win, "Discard Changes", OnDiscard)
	local buttonSave = gui_stuff.createButton(m_win, "Save to File", OnSave)
	local buttonLoad = gui_stuff.createButton(m_win, "Load from File", OnLoad)
	buttonSizer:Add(buttonSave, 0, wx.wxALL, 3)
	buttonSizer:Add(buttonLoad, 0, wx.wxALL, 3)
	buttonSizer:Add(buttonConfirm, 0, wx.wxALL, 3)
	buttonSizer:Add(buttonDiscard, 0, wx.wxALL, 3)
	mainSizer:Add(buttonSizer, 0, wx.wxALIGN_CENTER )

	m_win:Fit()
	m_win:Layout()
	m_win:Refresh()
	
	local iRet = m_win:ShowModal()
	if iRet == wx.wxID_OK then
		local abDevHdr = m_editor:getValue()
		nxfile:setDeviceHeader(abDevHdr)
	end
	m_win:Destroy()
end
