---------------------------------------------------------------------------
-- Copyright (C) 2010 Hilscher Gesellschaft für Systemautomation mbH
--
-- Description:
--   Editor for taglist, main part of the Taglist Editor
--
--  Changes:
--    Date        Author        Description
-- Oct 21, 2010   SL            derived from page_taglistedit.lua
--                              Support for enabling/disabling tags using Checkbox list
---------------------------------------------------------------------------
--  
---------------------------------------------------------------------------
-- SVN Keywords
--
-- $Date: 2010-10-21 11:03:04 +0200 (Do, 21 Okt 2010) $
-- $Revision: 9313 $
-- $Author: slesch $
---------------------------------------------------------------------------

module("taglistedit", package.seeall)
require("tester")
require("gui_stuff")
errorDialog = gui_stuff.errorDialog

if not taglist then muhkuh.include("taglist.lua", "taglist") end
muhkuh.include("numedit.lua", "numedit")
muhkuh.include("stringedit.lua", "stringdit")
muhkuh.include("hexedit.lua", "hexedit")
muhkuh.include("hexdump.lua", "hexdump")
muhkuh.include("ipv4edit.lua", "ipv4edit")
muhkuh.include("macedit.lua", "macedit")
muhkuh.include("rcxveredit.lua", "rcxveredit")
muhkuh.include("structedit.lua", "structedit")
muhkuh.include("comboedit.lua", "comboedit")
muhkuh.include("checkboxedit.lua", "checkboxedit")


-- public: createEditors, destroyEditors, getTagBin

--- all tags

--- the tag list
m_tagList = {}

--- list of page names/tags
-- each entry has the form {desc="xC Unit...", tag=<m_tagList entry>}
m_pages = {}



--- for the current tag

--- current editor, e.g. numEdit
m_editor = nil

--- current edit control, e.g. the text control containing the number
m_editCtrl = nil

--- the tag being edited, m_pages[index].tag
m_tag = nil

--- 1-based index into m_pages - remove?
m_iPageIndex = nil


--- static  items

--- the parent window
m_parent = nil

-- the panel containing the list and tag editor
m_panel = nil

-- sizer for m_panel
m_panelSizer = nil

-- The checked list control 
m_listCtrl = nil

-- id of m_listCtrl
m_listId = nil

-- the panel holding the single tag editor
m_bookPanel = nil

-- the sizer for m_bookPanel
m_bookPanelSizer = nil

--- static text to display whether a tag is enabled or disabled
m_tagEnabledDisplay = nil



--- Event handler called when a new page has been selected,
-- after calling OnPageChanging. This handler will show the 
-- editor for the new tag.
local function OnPageChanged(event)
	--print("OnPageChanged")
	if taglistedit.readbackPage() then
		taglistedit.clearPage()
	else
		event:Veto()
	end
	
	local iNewPage = event:GetSelection()+1
	-- print("changed to page", iNewPage)
	taglistedit.enterPage(iNewPage)
end

-- When a tag has been checked/unchecked in the checklist,
-- updates fDisabled of the respective tag
-- Updates the display, if the currently selected tag has been 
-- checked/unchecked.
function OnToggle (event)
	local iItem = event:GetSelection() -- 0-based list index
	local fChecked = taglistedit.m_listCtrl:IsChecked(iItem)
	-- print("OnToggle: GetSelection =", iItem, " m_listCtrl:IsChecked =", tostring(fChecked))
	local tTag = taglistedit.m_pages[iItem+1].tag
	tTag.fDisabled = not fChecked
	if tTag == taglistedit.m_tag then
		taglistedit.updateTagEnabledDisplay()
	end
end

-- Makes the enabled/disabled text line invisible
function clearTagEnabledDisplay()
	m_tagEnabledDisplay:SetLabel("")
	m_tagEnabledDisplay:SetBackgroundColour(wx.wxNullColour)
	m_tagEnabledDisplay:Refresh()
end

-- Updates the "Tag enabled/disabled" display and 
-- enables/disables the edit control for the current tag
-- depending on the state of m_tag.fDisabled 
local yellow = wx.wxColour(255,255,0)

function updateTagEnabledDisplay()
	local fEnabled = (m_tag.fDisabled ~= true)
	local strText = fEnabled and "Tag enabled" or "Tag disabled"
	local iColor = fEnabled and wx.wxGREEN or yellow
	m_tagEnabledDisplay:SetLabel(strText)
	m_tagEnabledDisplay:SetBackgroundColour(iColor)
	m_tagEnabledDisplay:Refresh()
	m_editCtrl:Enable(fEnabled)
end


--- Given a list of tags, make a list of page titles and tags and 
-- create the book pages.
-- @param tagList a list of parameters and values. Each entry is a list with keys
-- strTagName (the name string in the rcx_mod_tags list) and abValue (the value
-- as binary data).
function createEditors(tagList)
	--print("creating editors, params=", tagList, "len=", #tagList)
	m_tagList = tagList
	m_pages = {}
	for i, tTag in ipairs(tagList) do
		local strDesc = taglist.getTagDescString(tTag.ulTag)
		if strDesc then
			local strInstName = taglist.getTagInstanceName(tTag)
			if strInstName then
				strDesc = strDesc .. ": " .. strInstName
			end
			print(strDesc)
			table.insert(m_pages, {desc=strDesc, tag=tTag})
		else
			-- print(string.format("skipping unknown tag: 0x%0x", tTag.ulTag))
		end
	end
	
	for i, page in ipairs(m_pages) do
		m_listCtrl:Append(page.desc)
		m_listCtrl:Check(i-1, not page.tag.fDisabled)
	end
	
	m_listCtrl:Connect(m_listId, wx.wxEVT_COMMAND_LISTBOX_SELECTED , OnPageChanged)
	m_listCtrl:Connect(m_listId, wx.wxEVT_COMMAND_CHECKLISTBOX_TOGGLED , OnToggle)
	
	if #tagList > 0 then
		m_listCtrl:SetSelection(0)
		enterPage(1)
	end
	m_listCtrl:FitInside()
	m_panel:Layout()
	m_panel:Refresh()
end


--- Get the current tags as a binary string.
-- Reads the values off the edit controls, and
-- shows an error message if any values are invalid.
--
-- NOTE: This works because the entries in m_pages
-- contain references to the entries of m_taglist.
-- When a tag page is left and the values are read back
-- from the controls, they are automatically stored in m_taglist.
-- 
-- @return abTags The tag block as a binary string
function getTagBin()
	if readbackPage() then
		local bin = taglist.paramsToBin(m_tagList)
		print("length of binary: " .. bin:len() .. " bytes.")
		hexdump.printHex(bin, "0x%04x ", 16, true)
		return bin
	end
end

--- Create the editor for a tag.
-- @param iPage the page number, i.e. the number of the tag in taglist.
function enterPage(iPage)
	-- get strEditorName, tEditorParams, strDatatype
	local pageentry = m_pages[iPage]
	local strDesc, tTag = pageentry.desc, pageentry.tag
	local ulTag, abValue = tTag.ulTag, tTag.abValue
	local strEditorName, tEditorParams = taglist.getTagEditorInfo(ulTag)
	local strTagName, tTagDesc = taglist.getParamTypeDesc(ulTag)
	assert(tTagDesc, "tag "..ulTag.." not found")
	local strDatatype = tTagDesc.datatype
	
	-- instantiate the editor and the edit control
	local tEditPackage = _G[strEditorName]
	assert(tEditPackage, "package " .. strEditorName .. " not available")
	local editor = tEditPackage.new(strDatatype, tEditorParams)
	
	
	m_bookPanel:Freeze()
	local editCtrl = editor:create(m_bookPanel)
	-- set the value
	editor:setValue(abValue)
	if taglist.isReadOnly(tTagDesc) then
		structedit.disableControl(editCtrl)
	end
	
	m_editor = editor
	m_editCtrl = editCtrl
	m_tag = tTag
	m_iPageIndex = iPage

	updateTagEnabledDisplay()

	nxoeditor.showTagHelp(tTagDesc)
	
	-- insert into panel/sizer
	m_bookPanelSizer:Add(editCtrl, 0, wx.wxALL, 3)
	m_editCtrl:Fit()
	m_bookPanel:FitInside()
	m_bookPanel:Layout()
	m_bookPanel:Thaw()
	m_bookPanel:Refresh()
end

--- Read back the values in the currently displayed editor.
-- If ok, store the values in the current tag. Otherwise show
-- an error message
-- @return true if all values could be read back, false if there were errors.
function readbackPage()
	if m_editor and m_tag then
		local fValid, astrErrors = m_editor:isValid()
		if fValid then
			local abNewValue = m_editor:getValue()
			m_tag.abValue = abNewValue
			return true
		else
			local strMsg = astrErrors and 
			"Please enter correct values for the following parameters:\n"
			.. table.concat(taglist.makeErrorStrings(astrErrors), "\n") 
			or
			"Please check your input"
			errorDialog("Incorrect entries", strMsg)
			return false
		end
	else
		return true
	end
end

--- Clear the notebook panel. 
function clearPage()
	if m_editCtrl then
		m_bookPanelSizer:Detach(m_editCtrl)
		m_bookPanel:RemoveChild(m_editCtrl)
		m_editCtrl:Destroy()
		m_editor = nil
		m_editCtrl = nil
		m_tag = nil
		m_iPageIndex = nil
	end
end


function destroyEditors()
	m_listCtrl:Disconnect(m_listId, wx.wxEVT_COMMAND_LISTBOX_SELECTED)
	m_listCtrl:Disconnect(m_listId, wx.wxEVT_COMMAND_CHECKLISTBOX_TOGGLED)

	clearPage()
	m_listCtrl:Clear()
	clearTagEnabledDisplay()
	
	m_tagList = {}
	m_pages = {}
end


--- Initialize the notebook and the contents panel to hold editors.
function createTaglistPanel(parent)
	m_parent = parent
	m_tagList = {}
	m_pages = {}
	m_editor = nil
	m_editCtrl = nil
	m_tag = nil
	m_iPageIndex = nil
	
	m_panel = wx.wxPanel(m_parent, wx.wxID_ANY, wx.wxDefaultPosition, wx.wxDefaultSize)
	
	m_listId = tester.nextID()
	m_listCtrl = wx.wxCheckListBox(m_panel, m_listId, 
		wx.wxDefaultPosition, wx.wxDefaultSize, {},
		wx.wxLB_SINGLE + wx.wxLB_NEEDED_SB )--+ wx.wxLB_HSCROLL )

	m_bookPanel = wx.wxScrolledWindow(m_panel) 
	m_bookPanel:SetScrollRate(32, 32)
	m_bookPanelSizer = wx.wxBoxSizer(wx.wxVERTICAL)
	m_bookPanel:SetSizer(m_bookPanelSizer)
	
	m_tagEnabledDisplay = wx.wxStaticText(m_bookPanel, wx.wxID_ANY, "",
		wx.wxDefaultPosition, wx.wxDefaultSize, wx.wxALIGN_LEFT + wx.wxST_NO_AUTORESIZE )
	m_bookPanelSizer:Add(m_tagEnabledDisplay, 0, wx.wxEXPAND + wx.wxBOTTOM, 3)
	
	m_panelSizer = wx.wxBoxSizer(wx.wxHORIZONTAL)
	m_panel:SetSizer(m_panelSizer)
	m_panelSizer:Add(m_listCtrl, 0, wx.wxEXPAND + wx.wxRIGHT, 3)
	m_panelSizer:Add(m_bookPanel, 1, wx.wxEXPAND)
	
	return m_panel
end
