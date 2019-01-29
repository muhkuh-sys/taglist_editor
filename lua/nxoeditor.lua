---------------------------------------------------------------------------
-- Copyright (C) 2010 Hilscher Gesellschaft für Systemautomation mbH
--
-- Description:
--   Main program of Taglist editor
--
--  Changes:
--    Date        Author        Description
--   2012/04/12   SL        replaced tester with tester_nextid
--   2011/05/16   SL        Fixed: changes to the file were not saved if
--                          the file contained an empty tag list
---------------------------------------------------------------------------
--
---------------------------------------------------------------------------
-- SVN Keywords
--
-- $Date$
-- $Revision$
-- $Author$
---------------------------------------------------------------------------

module("nxoeditor", package.seeall)

require("tester_nextid")
require("gui_stuff")
createButton = gui_stuff.createButton
createRadioButton = gui_stuff.createRadioButton
createLabel = gui_stuff.createLabel
messageDialog = gui_stuff.messageDialog
errorDialog = gui_stuff.errorDialog
internalErrorDialog = gui_stuff.internalErrorDialog
require("utils")


require("taglist")
--require("page_taglistedit")
require("checklist_taglistedit")
require("nxfile")
require("structedit")
require("hexdump")
require("devhdredit")


function createToggleButton(parentPanel, strLabel, eventFunction)
	local id = tester.nextID()
	local button = wx.wxToggleButton(parentPanel, id, strLabel)
	parentPanel:Connect(id, wx.wxEVT_COMMAND_TOGGLEBUTTON_CLICKED, eventFunction)
	return button
end

function createCheckBox(parentPanel, strLabel, fChecked, eventFunction)
	local id = tester.nextID()
	local checkbox = wx.wxCheckBox(parentPanel, id, strLabel)
	checkbox:SetValue(fChecked)
	parentPanel:Connect(id, wx.wxEVT_COMMAND_CHECKBOX_CLICKED , eventFunction)
	return checkbox
end

function confirmDialog(strCaption, strMessage)
	print(strCaption .. ": " .. strMessage)
	local dialog = wx.wxMessageDialog(__MUHKUH_PANEL, strMessage, strCaption,
		wx.wxOK + wx.wxCANCEL + wx.wxICON_QUESTION + wx.wxSTAY_ON_TOP)
	local res = dialog:ShowModal()
	dialog:Destroy()
	return res==wx.wxID_OK
end

function yesNoDialog(strCaption, strMessage)
	print(strCaption .. ": " .. strMessage)
	local dialog = wx.wxMessageDialog(__MUHKUH_PANEL, strMessage, strCaption,
		wx.wxYES_NO + wx.wxICON_QUESTION + wx.wxSTAY_ON_TOP)
	local res = dialog:ShowModal()
	dialog:Destroy()
	return res==wx.wxID_YES
end

-- Show messages
-- if fOk = true, a notice is displayed, if false, an error message is displayed.
-- ... may be any strings or lists of strings.
function showMessages(fOk, strInfoTitle, strErrTitle, ...)
	if not ... then return end

	strInfoTitle = strInfoTitle or "Notice"
	strErrTitle = strErrTitle or "Error"

	local messages = {}
	for _, v in pairs({...}) do
		if #messages > 0 then
			table.insert(messages, "")
		end
		if type(v) == "string" and v:len()>0 then
			table.insert(messages, v)
		elseif type(v) == "table" then
			for _, str in pairs(v) do
				table.insert(messages, str)
			end
		end
	end

	--for k,v in pairs(messages) do print(k,v) end
	local strMsg = table.concat(messages, "\n")

	if fOk and #messages > 0 then
		messageDialog(strInfoTitle, strMsg)
	elseif not fOk  and #messages > 0 then
		errorDialog(strErrTitle, strMsg)
	elseif not fOk then
		errorDialog(strErrTitle, "Unknown error")
	end
end

-- DEBUG = true
m_nxfile = nil

m_headerFilebar = nil
m_elfFilebar = nil
m_tagsFilebar = nil
m_nxFilebar = nil

m_buttonCreateTags = nil
m_buttonDeleteTags = nil
m_buttonSizer = nil

-- the muhkuh panel for all gui objects
m_panel = nil
-- the tag list
m_paramPanel = nil
-- static box around the load/save buttons
m_fileBox = nil


STATUS_OK = 0
STATUS_LOAD_ERROR = 1
STATUS_SAVE_ERROR = 2

---------------------------------------------------------------------
-- Button handlers
---------------------------------------------------------------------


local function OnQuit()
	if nxoeditor.confirmDialog("Please Confirm",
	                           "Do you really want to close the application?") then
		if nxoeditor.m_fShowHelp then
			nxoeditor.getSplitRatio()
		end
		nxoeditor.saveConfig()
		
		-- If muhkuh.TestHasFinished() exists, call it to exit the application.
		-- If we're running from within Serverkuh, it will write the generic 
		-- configuration items (window position etc.) and flush the configuration to disk.
		if muhkuh.TestHasFinished then
			muhkuh.TestHasFinished()
			-- Linux may need an additional call to os.exit()
		else
		-- If it does not exist, just exit the Lua interpreter. The configuration won't be written.
			os.exit()
		end
	end
end

local function OnClear()
	if nxoeditor.yesNoDialog("Please Confirm",
			"This will discard all currently loaded data.\n"..
			"Do you want to proceed?") then
		nxoeditor.emptyNxo()
		nxoeditor.showWelcomePage()
		nxoeditor.setButtons()
	end
end


function OnHelp(event)
	local fVal = nxoeditor.m_checkboxHelp:GetValue()
	-- print("help", fVal)
	nxoeditor.displayHelp(fVal)
end

function OnEditDevHdr()
	devhdredit.editDeviceHeader(nxoeditor.m_nxfile)
end

-- debug
local function OnCreateTags()
	-- local bin = string.rep(string.char(0), 8)
	local bin = taglist.makeEmptyParblock()
	local fTagsOk, params, iLen, strMsg = taglist.binToParams(bin)
	nxoeditor.displayTags(params)
	nxoeditor.m_nxfile:setTaglistBin(bin)
	nxoeditor.m_fParamsLoaded = true
	nxoeditor.setButtons()
end

-- debug
local function OnDeleteTags()
	nxoeditor.clearTags()
	nxoeditor.setButtons()
end

---------------------------------------------------------------------
--
---------------------------------------------------------------------



---------------------------------------------------------------------
-- GUI update
---------------------------------------------------------------------
function clearTags()
	m_nxfile:setTaglistBin(nil)
	taglistedit.destroyEditors()
	m_fParamsLoaded = nil
	m_tagsFilebar:clearFilename()
end

function emptyNxo()
	m_nxfile = nxfile.new()
	m_nxfile:initNxo()
	m_headerFilebar:clearFilename()
	m_elfFilebar:clearFilename()
	m_tagsFilebar:clearFilename()
	m_nxFilebar:clearFilename()
	m_fParamsLoaded = nil
	taglistedit.destroyEditors()
end

function displayTags(atTags)
	-- remove any old editors/controls
	if m_fParamsLoaded then
		taglistedit.destroyEditors()
	end
	-- create the new controls
	--if #atTags > 0 then
		taglistedit.createEditors(atTags)
	--end
	m_fParamsLoaded = true
end


--- Enable/disable load/save buttons depending on which data is in memory.
-- loading is always possible,
-- save/save as for headers, ELF and taglist is only possible if header/data/tags are in memory
-- save NXO (as) is possible when headers ,elf and tags data are in memory.
-- The load/save headers/data buttons are only shown if the file type is NXO.

function setButtons() -- should be adapt_GUI or something

	-- determine which buttons are active
	local fHeaders = m_nxfile:hasHeaders()
	local fElf = m_nxfile:hasData()
	local fTags = m_nxfile:hasTaglist()
	local fComplete = m_nxfile:isComplete()


	m_headerFilebar:enableButtons(true, fHeaders, fHeaders)
	m_elfFilebar:enableButtons(true, fElf, fElf)
	m_tagsFilebar:enableButtons(true, fTags, fTags)
	m_nxFilebar:enableButtons(true, fComplete, fComplete)

	if DEBUG then
		m_buttonCreateTags:Enable(not fTags)
		m_buttonDeleteTags:Enable(fTags)
	end

	-- If file type is nxo, show all four filebars.
	-- For other file types, show only taglist and nx* filebars
	local fShow_Hdr_Elf = m_nxfile:isNxo()
	m_headerFilebar:show(fShow_Hdr_Elf)
	m_elfFilebar:show(fShow_Hdr_Elf)

	-- Show the current file type
	local strType = m_nxfile:getHeaderType() or "unknown"
	m_fileBox:SetLabel(string.format("Load/Save (Current file type: %s)", strType))

	-- show edit device header button if device header V1 is present
	local fDevHdr = m_nxfile:hasDeviceHeaderV1()
	m_buttonEditDevHdr:Enable(fDevHdr)

	m_leftPanel:Layout()
	m_leftPanel:Refresh()
	--m_leftPanel:Update()
end

---------------------------------------------------------------------
-- loading and saving
---------------------------------------------------------------------
strHdrFilenameFilters = "Header files (*.bin)|*.bin|All Files (*)|*"
strElfFilenameFilters = "ELF files (*.elf)|*.elf|All Files (*)|*"
strTagFilenameFilters = "Tag list files (*.bin)|*.bin|All Files (*)|*"
strNxFilenameFilters = "NXO/NXF/NXI/BIN files (*.nxo/*.nxf/*.nxi/*.bin)|*.nxo;*.nxf;*.nxi;*.bin|All Files (*)|*"
strsaveNxFilenameFilters = "NXO files (*.nxo)|*.nxo|NXF files (*.nxf)|*.nxf|NXI files (*.nxi)|*.nxi|BIN files (*.bin)|*.bin|All Files (*)|*"
strNxoFilenameFilters = "NXO files (*.nxo)|*.nxo|All Files (*)|*"
strNxiFilenameFilters = "NXI files (*.nxi)|*.nxi|All Files (*)|*"
strNxfFilenameFilters = "NXF files (*.nxf)|*.nxf|NXI files (*.nxi)|*.nxi|BIN files (*.bin)|*.bin|All Files (*)|*"
strDefaultFilenameFilters = "All Files (*)|*"

function loadFileDialog(parent, strTitle, strFilters)
	local fileDialog = wx.wxFileDialog(
		parent,
		strTitle or "Select file to load",
		"",
		"",
		strFilters or strDefaultFilenameFilters,
		wx.wxFD_OPEN + wx.wxFD_FILE_MUST_EXIST)
	local iResult = fileDialog:ShowModal()
	local strFilename
	if iResult == wx.wxID_OK then
		strFilename = fileDialog:GetPath()
	end
	fileDialog:Destroy()
	return strFilename
end

function saveFileDialog(parent, strTitle, strFilters)
	local fileDialog = wx.wxFileDialog(
		parent,
		strTitle or "Select file to save to",
		"",
		"",
		strFilters or strDefaultFilenameFilters,
		wx.wxFD_SAVE + wx.wxFD_OVERWRITE_PROMPT)
	local iResult = fileDialog:ShowModal()
	local strFilename
	if iResult == wx.wxID_OK then
		strFilename = fileDialog:GetPath()
	end
	fileDialog:Destroy()
	return strFilename
end


function loadFile(strFilename)
	local strBin, strMsg = utils.loadBin(strFilename)
	if strBin then
		return STATUS_OK, strBin
	else
		errorDialog("Load error", strMsg)
		return STATUS_LOAD_ERROR
	end

end

function saveFile(strFilename, strBin)
	local fOk, strmsg = utils.writeBin(strFilename, strBin)
	if fOk then
		return STATUS_OK
	else
		errorDialog("Save error", strmsg)
		return STATUS_SAVE_ERROR
	end
end

function checkOverwrite(strFilename)
	if not wx.wxFileExists(strFilename) then
		return true
	else
		local iRes = wx.wxMessageBox(
			"The file " .. strFilename .. "\nalready exists. Do you want to overwrite it?",
			"Overwrite file?",
			wx.wxICON_EXCLAMATION + wx.wxYES_NO,
			m_panel);
		return iRes == wx.wxYES
	end
end

function saveFile1(filebar, strFilename, strTitle, strFilenameFilters, abBin)
	if strFilename and strFilename:len()>0 then
		if not checkOverwrite(strFilename) then return end
	else
		strFilename = saveFileDialog(m_panel, strTitle, strFilenameFilters)
		if not strFilename then return end
	end

	local iStatus = saveFile(strFilename, abBin)
	if iStatus==STATUS_OK then
		filebar:setFilename(strFilename)
		setButtons()
	end
end






function loadHdr(strFilename)
	local strFilename = strFilename or loadFileDialog(m_panel, "Select header file", strHdrFilenameFilters)
	if not strFilename then return end
	local iStatus, abBin = loadFile(strFilename)
	if iStatus==STATUS_OK then
		local fOk, strMsg = m_nxfile:setHeadersBin(abBin)
		showMessages(fOk, "Notice", "Error in Headers", strMsg)
		if fOk then
			m_headerFilebar:setFilename(strFilename)
			setButtons()
		end
	end
end



function saveHdr(strFilename)
	local abBin = m_nxfile:getHeadersBin()
	saveFile1(m_headerFilebar, strFilename, "Save headers as", strHdrFilenameFilters, abBin)
end




function isELF(abBin)
	return abBin:byte(2)==0x45 and abBin:byte(3)==0x4c and abBin:byte(4)==0x46
end

function loadElf(strFilename)
	local strFilename = strFilename or loadFileDialog(m_panel, "Select Elf file", strElfFilenameFilters)
	if not strFilename then return end
	local iStatus, abBin = loadFile(strFilename)
	if iStatus==STATUS_OK then
		if isELF(abBin) then
			m_nxfile:setData(abBin)
			m_elfFilebar:setFilename(strFilename)
			setButtons()
		else
			errorDialog("Not an ELF file", "The file does not have an ELF signature.")
		end
	end
end

function saveElf(strFilename)
	local abBin = m_nxfile:getData()
	saveFile1(m_elfFilebar, strFilename, "Save Elf as", strElfFilenameFilters, abBin)
end




function loadTags(strFilename)
	local strFilename = strFilename or loadFileDialog(m_panel, "Select Tag list file", strTagFilenameFilters)
	if not strFilename then return end
	local iStatus, abBin = loadFile(strFilename)
	if iStatus==STATUS_OK then
		print(string.format("tag list size: 0x%08x", abBin:len()))
		-- parse tag list
		local fOk, params, iLen, strMsg = taglist.binToParams(abBin)
		showMessages(fOk, "Notice", "Error parsing tag list", strMsg)

		-- replace tag list
		if fOk then
			if not m_nxfile:isNxi() then
				local fChanged = checkEndMarker(params)
				if fChanged then
					abBin = taglist.paramsToBin(params)
				end
			end
			fOk, strMsg = m_nxfile:setTaglistBin(abBin)
			showMessages(fOk, "Notice", "Error", strMsg)
		end

		-- update GUI
		if fOk then
			m_tagsFilebar:setFilename(strFilename)
			displayTags(params)
			setButtons()
		end
	end
end

function saveTags(strFilename)
	local abBin = taglistedit.getTagBin()
	if abBin then
		saveFile1(m_tagsFilebar, strFilename, "Save tag list as", strTagFilenameFilters, abBin)
	else
		errorDialog("Internal Error", "Could not reconstruct tag list from GUI")
	end
end

-- Check if the end marker is 0 or 4 bytes long.
-- If it is, and it can be replaced with an 8 byte end marker,
-- offer to do so and replace it if the user choses yes.
-- If it cannot be replaced, just notify the user.
--
-- Returns true if the end marker was changed, false otherwise
function checkEndMarker(atTags)
	-- check/correct end marker
	local fEndOk, fCorrectible, strMsg = taglist.checkEndMarker(m_nxfile, atTags)
	print("check end marker: ", fEndOk, fCorrectible, strMsg)
	local fChanged = false
	if not fEndOk then
		if fCorrectible then
			local fDoCorrect = yesNoDialog(
				"Notice",
				"The tag list has a non-standard ending:\n"..
				strMsg.."\n"..
				"Do you want to replace the end marker with a correct one?"
				)
			if fDoCorrect then
				print("replacing end marker with eight zero bytes")
				taglist.correctEndMarker(atTags)
				fChanged = true
			end
		else
			messageDialog(
				"Notice",
				"The tag list has a non-standard ending:\n"..
				strMsg.."\n"..
				"The end marker cannot be replaced."
				)
		end
	end

	return fChanged
end

function loadNx(strFilename)
	strFilename = strFilename or loadFileDialog(m_panel, "Select NXO/NXF/bin file", strNxFilenameFilters)
	if not strFilename then return end
	local iStatus, abBin = loadFile(strFilename)
	-- loaded successfully
	if iStatus==STATUS_OK then
		emptyNxo()

		local fOk, astrMsgs = m_nxfile:parseBin(abBin)
		showMessages(fOk, "Warning", "Error parsing file", astrMsgs)

		-- overall file structure is ok, now look after the tag list.
		if fOk then
			-- file has tag list
			if m_nxfile:hasTaglist() then
				local abTags = m_nxfile:getTaglistBin()
				local fTagsOk, params, iLen, strMsg = taglist.binToParams(abTags)
				showMessages(fTagsOk, "Notice", "Error parsing tag list", strMsg)

				if fTagsOk and not m_nxfile:isNxi() then
					local fChanged = checkEndMarker(params)
					if fChanged then
						abTags = taglist.paramsToBin(params)
						fTagsOk, strMsg = m_nxfile:setTaglistBin(abTags)
						showMessages(fOk, "Notice", "Error", strMsg)
					end
				end

				if fTagsOk then
					displayTags(params)
					m_nxFilebar:setFilename(strFilename)
				else
					m_nxfile = nxfile.new()
					m_nxfile:initNxo()
				end
			else
			-- no tag list
				messageDialog("No tag list", "The file does not contain a tag list")
				m_nxFilebar:setFilename(strFilename)
			end
		end
		setButtons()
	end
end


function saveNx(strFilename)
	-- if a tag list is loaded, read its current value from the
	-- editor and replace it in the file.
	if m_nxfile:hasTaglist() then
		-- get taglist
		local abTags = taglistedit.getTagBin()
		if not abTags then
			return
		end
		-- true = replace tag list, but keep any gap data behind the tag list
		m_nxfile:setTaglistBin(abTags, true)
	end

	-- build nxo file
	local abNxFile = m_nxfile:buildNXFile()
	if not abNxFile then
		errorDialog("Error", "Failed to build NX* file")
		return
	end

	local strFilter, strTitle
	if m_nxfile:isNxf() then
		strFilter = strNxfFilenameFilters
		strTitle = "Save NXF/BIN file as"
	elseif m_nxfile:isNxo() then
		strFilter = strNxoFilenameFilters
		strTitle = "Save NXO file as"
	elseif m_nxfile:isNxi() then
		strFilter = strNxiFilenameFilters
		strTitle = "Save NXI file as"
	else
		strFilter = strsaveNxFilenameFilters
		strTitle = "Save as"
	end
	saveFile1(m_nxFilebar, strFilename, strTitle, strFilter, abNxFile)
end


---------------------------------------------------------------------
-- a bar consisting of a label, textbox for a filename and
-- load/save as/save buttons
---------------------------------------------------------------------
function filebar_setFilename(filebar, strFilename)
	filebar.m_textctrl:SetValue(strFilename)
end

function filebar_getFilename(filebar)
	return filebar.m_textctrl:GetValue(strFilename)
end

function filebar_clearFilename(filebar)
	return filebar.m_textctrl:SetValue("")
end


function filebar_enableButtons(filebar, fLoad, fSave, fSaveAs)
	if filebar.m_buttonLoad then filebar.m_buttonLoad:Enable(fLoad) end
	if filebar.m_buttonSaveAs then filebar.m_buttonSaveAs:Enable(fSaveAs) end
	if filebar.m_buttonSave then filebar.m_buttonSave:Enable(fSave) end
end

function filebar_show(filebar, fShow)
	if filebar.m_label then filebar.m_label:Show(fShow) end
	if filebar.m_textctrl then filebar.m_textctrl:Show(fShow) end
	if filebar.m_buttonLoad then filebar.m_buttonLoad:Show(fShow) end
	if filebar.m_buttonSaveAs then filebar.m_buttonSaveAs:Show(fShow) end
	if filebar.m_buttonSave then filebar.m_buttonSave:Show(fShow) end
end

function insertFilebar(parent, sizer, strStaticText, fnLoad, fnSave)
	-- create elements
	local filebar = {}
	local label = createLabel(parent, strStaticText)
	local textctrl = wx.wxTextCtrl(parent, wx.wxID_ANY)
	textctrl:SetEditable(false)
	local buttonLoad, buttonSaveAs, buttonSave
	if fnLoad then
		buttonLoad = createButton(parent, "Load", function() fnLoad() end)
	end
	if fnSave then
		buttonSaveAs = createButton(parent, "Save as", function() fnSave() end)
		buttonSave = createButton(parent, "Save", function() fnSave(filebar:getFilename()) end)
	end

	-- add to sizer
	sizer:Add(label, 0, wx.wxALIGN_CENTER_VERTICAL)
	sizer:Add(textctrl, 1, wx.wxEXPAND + wx.wxALIGN_CENTER_VERTICAL)
	if buttonLoad then
		sizer:Add(buttonLoad, 0, wx.wxALIGN_CENTER_VERTICAL)
	else
		print("spacer")
		sizer:AddSpacer(0)
	end
	if buttonSaveAs then
		sizer:Add(buttonSaveAs, 0, wx.wxALIGN_CENTER_VERTICAL)
	else
		print("spacer")
		sizer:AddSpacer(0)
	end
	if buttonSave then
		sizer:Add(buttonSave, 0, wx.wxALIGN_CENTER_VERTICAL)
	else
		print("spacer")
		sizer:AddSpacer(0)
	end

	-- put into table
	filebar.m_label = label
	filebar.m_textctrl = textctrl
	filebar.m_buttonLoad = buttonLoad
	filebar.m_buttonSaveAs = buttonSaveAs
	filebar.m_buttonSave = buttonSave
	filebar.setFilename = filebar_setFilename
	filebar.getFilename = filebar_getFilename
	filebar.clearFilename = filebar_clearFilename
	filebar.enableButtons = filebar_enableButtons
	filebar.show = filebar_show
	return filebar
end

---------------------------------------------------------------------
-- create GUI at startup
---------------------------------------------------------------------
--[[
Object hierarchy:
m_panel sizer:mainSizer
	m_splitterPanel
		m_leftPanel sizer:leftSizer
			load/save buttons etc.
			m_paramPanel
		m_helpWindow

	buttonSizer
	m_buttonQuit
	m_checkboxHelp
	m_buttonCreateTags
	m_buttonDeleteTags

Sizer Hierarchy:
	mainSizer
		m_splitterPanel

		m_buttonSizer
			m_buttonQuit
			m_checkboxHelp
			m_buttonCreateTags
			m_buttonDeleteTags

	leftSizer
		m_paramPanel
		inputSizer
			fileSizer
				load/save buttons etc.
--]]

function createPanel()
	m_splitterPanel = wx.wxSplitterWindow(m_panel, wx.wxID_ANY)
	m_leftPanel = wx.wxPanel(m_splitterPanel, wx.wxID_ANY)

	-- Tag editor
	local parent = m_leftPanel
	m_paramPanel = taglistedit.createTaglistPanel(parent)

	-- Filename/load/save
	local inputSizer = wx.wxStaticBoxSizer(wx.wxHORIZONTAL, parent, "Load/Save")
	m_fileBox = inputSizer:GetStaticBox()
	local fileSizer = wx.wxFlexGridSizer(4, 5, 3, 3)
	fileSizer:AddGrowableCol(1, 1)
	inputSizer:Add(fileSizer, 1, wx.wxEXPAND)
	m_headerFilebar = insertFilebar(parent, fileSizer, "Headers", loadHdr, saveHdr)
	m_elfFilebar = insertFilebar(parent, fileSizer, "ELF", loadElf, saveElf)
	m_tagsFilebar = insertFilebar(parent, fileSizer, "Tag list", loadTags, saveTags)
	m_nxFilebar = insertFilebar(parent, fileSizer, "NXO/NXF", loadNx, saveNx)

	-- HTML help window
	m_helpWindow = wx.wxHtmlWindow(m_splitterPanel)

	-- quit / create Params / delete params buttons
	m_buttonQuit = createButton(m_panel, "Quit", OnQuit)
	m_checkboxHelp = createCheckBox(m_panel, "Display Help", m_fShowHelp, OnHelp)
	m_buttonClear = createButton(m_panel, "Clear", OnClear)
	m_buttonEditDevHdr = createButton(m_panel, "Edit Device Header", OnEditDevHdr)
	m_buttonSizer = wx.wxBoxSizer(wx.wxHORIZONTAL)
	m_buttonSizer:Add(m_buttonQuit, 0, wx.wxALIGN_CENTER_VERTICAL + wx.wxALL, 3)
	m_buttonSizer:Add(m_checkboxHelp, 0, wx.wxALIGN_CENTER_VERTICAL + wx.wxALL, 3)
	m_buttonSizer:Add(m_buttonClear, 0, wx.wxALIGN_CENTER_VERTICAL + wx.wxALL, 3)
	m_buttonSizer:Add(m_buttonEditDevHdr, 0, wx.wxALIGN_CENTER_VERTICAL + wx.wxALL, 3)

	if DEBUG then
		m_buttonCreateTags = createButton(m_panel, "Create Empty Parameters", OnCreateTags)
		m_buttonDeleteTags = createButton(m_panel, "Delete Parameters", OnDeleteTags)
		m_buttonSizer:Add(m_buttonCreateTags, 0, wx.wxALIGN_CENTER_VERTICAL + wx.wxALL, 3)
		m_buttonSizer:Add(m_buttonDeleteTags, 0, wx.wxALIGN_CENTER_VERTICAL + wx.wxALL, 3)
	end

	-- combine
	local leftSizer = wx.wxBoxSizer(wx.wxVERTICAL)
	leftSizer:Add(m_paramPanel, 1, wx.wxEXPAND + wx.wxALL, 3)
	leftSizer:Add(inputSizer, 0, wx.wxEXPAND + wx.wxALL, 3)
	m_leftPanel:SetSizer(leftSizer)

	m_splitterPanel:SetSashGravity(0.3)
	m_splitterPanel:SetMinimumPaneSize(20)
	m_splitterPanel:SplitVertically(m_leftPanel, m_helpWindow)

	local mainSizer = wx.wxBoxSizer(wx.wxVERTICAL)
	mainSizer:Add(m_splitterPanel, 1, wx.wxEXPAND + wx.wxALL, 3)
	mainSizer:Add(m_buttonSizer, 0, wx.wxALL, 3)

	setButtons()
	m_panel:SetSizer(mainSizer)
	m_panel:Layout()
	m_panel:Refresh()

end


---------------------------------------------------------------------
--          handle the help viewer
---------------------------------------------------------------------

m_fShowHelp = true
m_dSplitRatio = 0.5

-- stores the last requested and the last displayed tag help
-- used to ensure that the correct help page is shown when
-- help display is turned on
m_tLastRequestedTagHelp = nil
m_tLastDisplayedTagHelp = nil

function getSplitRatio()
	local iPos = m_splitterPanel:GetSashPosition()
	local iWidth = m_splitterPanel:GetSize():GetWidth()
	m_dSplitRatio = iPos/iWidth
	-- print("iPos: ", iPos, "iWidth: ", iWidth, "sash rel pos:", m_dSplitRatio)
end

-- @param fShow hide or show help area
function displayHelp(fShow)
	-- print("displayHelp: ", fShow)
	m_fShowHelp = fShow
	if fShow then
		local iWidth = m_splitterPanel:GetSize():GetWidth()
		local iPos = iWidth * m_dSplitRatio
		m_splitterPanel:SplitVertically(m_leftPanel, m_helpWindow)
		m_splitterPanel:SetSashPosition(iPos)
		-- print("iPos: ", iPos, "iWidth: ", iWidth, "sash rel pos:", m_dSplitRatio)
		showTagHelp(m_tLastRequestedTagHelp)
	else
		getSplitRatio()
		m_splitterPanel:Unsplit()
	end
	m_panel:Layout()
	m_panel:Refresh()
end

function showTagHelp(tTagDesc)
	m_tLastRequestedTagHelp = tTagDesc

	if not tTagDesc or
		not m_fShowHelp or
		(m_tLastRequestedTagHelp == m_tLastDisplayedTagHelp) then
		return
	end

	local strPageFilename, strAnchor = taglist.getTagHelp(tTagDesc)
	if not strPageFilename then
		return
	end

	showHelpPage("help/"..strPageFilename, strAnchor)
end

function showHelpPage(strPageFilename, strAnchor)
	local strPageSource = muhkuh.load(strPageFilename)
	if strPageSource then
		m_helpWindow:SetPage(strPageSource)

		if strAnchor then
			m_helpWindow:LoadPage(strAnchor)
		end

		m_tLastDisplayedTagHelp = tTagDesc
	else
		print("error loading help page: page = ", strPageFilename)
	end
end

function showWelcomePage()
	showHelpPage("help/welcome.htm")
end

---------------------------------------------------------------------
---------------------   load/save configuration
---------------------------------------------------------------------

-- the section name in the config file
CONFIG_PATH = "/tag_list_editor"
-- key for the help flag
KEY_HELP = "display_help"
KEY_HELP_SPLIT_RATIO = "help_split_ratio"

---------------------------------------------------------------------------
-- read the configuration from Muhkuh.cfg
-- (the m_fShowHelp flag)

function loadConfig()
	local config = wx.wxConfigBase.Get(true)
	if not config then
		print("Error accessing config.")
		return
	end

	if not config:HasGroup(CONFIG_PATH) then
		print("Group " .. CONFIG_PATH .. " not found in config. Using default values.")
		return
	end

	print("reading config")

	config:SetPath(CONFIG_PATH)

	local fOK, strVal
	fOK, strVal = config:Read(KEY_HELP)
	if fOK then
		m_fShowHelp = strVal == "true"
	end

	fOK, strVal = config:Read(KEY_HELP_SPLIT_RATIO)
	if fOK then
		if tonumber(strVal) then
			m_dSplitRatio = tonumber(strVal)
			--print("m_dSplitRatio=",m_dSplitRatio)
		else
			print("Error parsing split_ratio value: " .. KEY_HELP_SPLIT_RATIO)
		end
	end
end

---------------------------------------------------------------------------
-- save the configuration to Muhkuh.cfg
-- (the m_fShowHelp flag)

function saveConfig()
	local config = wx.wxConfigBase.Get(true)
	if not config then
		print("Error opening config.")
		return
	end

	print("writing config")
	config:DeleteGroup(CONFIG_PATH)
	config:SetPath(CONFIG_PATH)

	if config:Write(KEY_HELP, tostring(m_fShowHelp)) and
		config:Write(KEY_HELP_SPLIT_RATIO, tostring(m_dSplitRatio)) then
		print("OK")
	else
		print("Error writing config!")
	end
end



---------------------------------------------------------------------
------------------------------  test
---------------------------------------------------------------------


function printParamList(paramList)
	for _, par in pairs(paramList) do
		-- print tag, data size and hexdump
		print(string.format("type: 0x%08x len: %d data:\n", par.ulTag, par.ulSize) ..
		hexdump.hexString(par.abValue, "", 16))
	end

end

function tryExtract(origbin, trybin)
	local fOk, params, iLen, strMsg = taglist.binToParams(trybin)
	print("binToParam status: ", fOk)
	print("message:", strMsg)
	print("len: ", iLen)
	printParamList(params)
end

-- self:setStyle("0x%08x: ", 16, " ", true, wx.wxTE_MULTILINE)
function test()
	local bin = taglist.makeEmptyParblock()
	assert(bin, "failed to generate param block")
	print("parblock: ")
	hexdump.printHex(bin, "0x%08x", 16, true)
	local junk = "tritratrullallabullatrullahoppsassa"
	tryExtract(bin, bin..junk)
	tryExtract(bin, junk)

	local fOk, params, iLen, strMsg = taglist.binToParams(bin)
	printParamList(params)
	local rebin = taglist.paramsToBin(params)
	hexdump.printHex(rebin, "0x%08x", 16, true)
end
---------------------------------------------------------------------
-- startup function, called by the code snippet in test_description.xml

function run()
	if not arg or #arg==0 then
		print ("no command line args")
	else
		print("command line args: ")
		for i, v in ipairs(arg) do
			print(i, v)
		end
	end

	m_nxfile = nxfile.new()
	m_nxfile:initNxo()
	loadConfig()

	m_panel = __MUHKUH_PANEL
	createPanel()
	local dSplitRatio = m_dSplitRatio
	displayHelp(m_fShowHelp)
	m_dSplitRatio = dSplitRatio

	if arg and arg[1] then
		loadNx(arg[1])
	end

	showWelcomePage()
end
