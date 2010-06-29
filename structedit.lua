---------------------------------------------------------------------------
-- Copyright (C) 2010 Hilscher Gesellschaft für Systemautomation mbH
--
-- Description:
--   Structure editor for Taglist Editor
--
--  Changes:
--    Date        Author        Description
---------------------------------------------------------------------------
--  
---------------------------------------------------------------------------
-- SVN Keywords
--
-- $Date$
-- $Revision$
-- $Author$
---------------------------------------------------------------------------

module("structedit", package.seeall)

--- Display bin in the edit controls.
-- @param self the instance
-- @param bin the binary value of the structure
function setValue(self, bin)
	local tMemberValues = taglist.splitStructValue(self.strTypeName, bin) -- todo
	-- entries of the form: {strMemberName = ..., ulSize = ... abValue = ...}
	self.m_tMemberValues = tMemberValues
	self.m_abValue = bin
	local strMemberName, abValue, editor
	for _, entry in pairs(tMemberValues) do
		strMemberName, abValue = entry.strName, entry.abValue
		assert(abValue, "structedit.setValue: no value for field "..strMemberName)
		editor = self.m_editorAssoc[strMemberName]
		--print(strMemberName, abValue)
		if editor then editor:setValue(abValue) end
	end
end

--- read back the values of the edit controls and collect error 
-- messages if values do not parse, or are out of range.
-- @param self the instance
-- @return fValid true if no errors occurred, false otherwise
-- @return newvals values which could be read back correctly
-- @return allErrors descriptions of errors in values which could
-- not be read back.
function readEditorValues(self)
	-- check all edit controls
	local newvals = {}
	local allErrors = {}
	local fValid = true
	local fOk, strMsg, abParVal = nil, nil, nil
	
	for strMemberName, editor in pairs(self.m_editorAssoc) do
		fOk, errors = editor:isValid()
		if fOk then
			abParVal = editor:getValue()
			newvals[strMemberName] = abParVal
		else
			fValid = false
			table.insert(allErrors, {strMemberName, errors})
		end
	end
	
	return fValid, newvals, allErrors
end


--- Update values in a struct member list. 
-- @param origList the original member list. 
-- @param newvalues values to update. 
-- Entries have the form newvalues[strMemberName]=value.
function updateMemberValues(origList, newvalues)
	for _, entry in pairs(origList) do
		local strMemberName = entry.strName
		if newvalues[strMemberName] then 
			entry.abValue = newvalues[strMemberName] 
			newvalues[strMemberName] = nil
		end
	end
	-- unless some error occurred, the newvalues list must now be empty.
	if next(newvalues) then
	--if #newvalues >0 then
		for strMemberName, val in pairs(newvalues) do 
			print("Could not update struct member: " .. strMemberName) 
		end
		error("Could not update all members: ")
	end
end


--- get the binary value
-- @return a binary string
function getValue(self)
	local fValid, newvals, errors = self:readEditorValues()
	updateMemberValues(self.m_tMemberValues, newvals)
	return taglist.joinStructElements(self.strTypeName, self.m_tMemberValues)
end

--- Check if the current contents of the editor is valid, i.e. can be
-- read back as a struct.
-- @return fValid true if the contents can be parsed, false otherwise
-- @return errors error descriptions.
function isValid(self)
	-- check all edit controls
	local allErrors = {}
	local fValid = true
	local fOk, strMsg = nil, nil
	
	for strMemberName, editor in pairs(self.m_editorAssoc) do
		fOk, errors = editor:isValid()
		if not fOk then
			fValid = false
			table.insert(allErrors, {strMemberName, errors})
		end
	end
	
	return fValid, allErrors
end

--[[
function isValid(self)
	local fValid, newvals, errors = self:readEditorValues()
	return fValid, errors
end
--]]

--- Create the edit controls for the structure using the structure definition
-- passed during creation.
function create(self, parent)
	--print("creating editors")
	self.m_controls = {}
	self.m_editorAssoc = {}
	local tStructDef = taglist.getStructDef(self.strTypeName)
	assert(tStructDef, "no struct def for "..self.strTypeName)
	-- create panel/main sizer
	local structPanel = wx.wxPanel(parent, wx.wxID_ANY)
	local strMemberName, strMemberType, strMemberDesc
	local tMemberTypeDef
	-- loop through the struct members 
	local elements = {}
	for _, member in ipairs(tStructDef) do
	
		-- skip invisible members
		if not taglist.isHidden(member) then
			
			-- get name/type/mode
			strMemberName, strMemberType = member[2], member[1]
			strMemberDesc = member.desc or strMemberName
			-- get editor
			strEditorName, tEditorParams = taglist.getStructMemberEditorInfo(member)
		
			if strEditorName then
				--print(strMemberName, strEditorName)
				-- instantiate editor
				local tEditPackage = _G[strEditorName]
				assert(tEditPackage, "package " .. strEditorName .. " not available")
				--print(strMemberName, strMemberType)
				local editor = tEditPackage.new(strMemberType, tEditorParams)
				local editCtrl = editor:create(structPanel)
	
				if taglist.isReadOnly(member) then
					-- print("disabling ", strMemberName)
					disableControl(editCtrl)
				end
		
				-- put name and editor into sub-sizer, add to main sizer
				local statictext = wx.wxStaticText(structPanel, wx.wxID_ANY, strMemberDesc)
				elements[strMemberName] = {staticText=statictext, editCtrl=editCtrl}
				table.insert(elements, strMemberName) -- order of elements, used for default layout
				--{strMemberName=strMembername, staticText=statictext, editCtrl=editCtrl})
			
				-- store association: name->edit control
				self.m_editorAssoc[strMemberName] = editor
		
				-- store static text and edit control in list
				table.insert(self.m_controls, statictext)
				table.insert(self.m_controls, editCtrl)
			else
				print("no editor for "..strMemberType.." "..strMemberName)
			end
		end
	end
	local structSizer = doLayout(structPanel, elements, tStructDef.layout) 
	structPanel:SetSizer(structSizer)
	self.m_panel = structPanel
	self.m_sizer = structSizer
	
	return structPanel
end



function isControl(object)
	return object:IsKindOf(wx.wxClassInfo.FindClass("wxControl"))
end

function isTextCtrl(object)
	return object:IsKindOf(wx.wxClassInfo.FindClass("wxTextCtrl"))
end

function disableControl(control)
	if isTextCtrl(control) then
		control:Connect(control:GetId(), wx.wxEVT_CHAR, function() end)
		control:SetBackgroundColour(wx.wxLIGHT_GREY)
	elseif isControl(control) then
		control:Enable(false)
	end
end

--- Lay out the structure elements.
-- @param parent the parent window (used for static boxes)
-- @param elements a list containing the elements to lay out,
-- mapping member names to pairs of label and edit control
-- e.g. elements["tMode"]={staticText=wxStaticText, editCtrl=wxTextCtrl}
-- @param layout the layout description: 
--  "h" or "v" for a box sizer,
--  "grid" for a grid sizer, 
--  nil for a vertical default layout
-- @return sizer a sizer with the laid out structure elements
function doLayout(parent, elements, layout)
	--print("custom layout")
	if layout == nil then
		return doDefaultLayout(structPanel, elements)
	elseif layout.sizer == "h" or layout.sizer == "v" then
		return combineWithBoxSizer(parent, elements, layout)
	elseif layout.sizer == "grid" then
		return combineWithGrid(parent, elements, layout)
	else
		error ("unsupported layout: " .. (layout.sizer or "?"))
	end
end

--- Lay out elements using a box sizer.
-- @param parent the parent window (used for static boxes)
-- @param elements a list containing the elements to lay out,
-- mapping member names to pairs of label and edit control
-- e.g. elements["tMode"]={staticText=wxStaticText, editCtrl=wxTextCtrl}
-- @param layout the layout description
-- layout=  {sizer="v", "tIdentifier",  
--                     {sizer="h", "tMode", "tDirection"},
--                     {sizer="h", "tSet", "tClear", "tInput"}}
-- @return sizer
function combineWithBoxSizer(parent, elements, layout)
	local iOrientation = layout.sizer=="v" and wx.wxVERTICAL or wx.wxHORIZONTAL
	local sizer, esizer, element
	if type(layout.box)=="string" then
		sizer = wx.wxStaticBoxSizer(iOrientation, parent, layout.box)
	else
		sizer = wx.wxBoxSizer(iOrientation)
	end
	
	local iAlignment = (iOrientation == wx.wxHORIZONTAL and wx.wxRIGHT) or wx.wxBOTTOM
	local x
	for i = 1, #layout do
		x = layout[i]
		if type(x)=="string" then
			element = elements[x]
			esizer = wx.wxBoxSizer(wx.wxHORIZONTAL)
			esizer:Add(element.staticText, 0, wx.wxALIGN_CENTER_VERTICAL + wx.wxRIGHT, 3)
			esizer:Add(element.editCtrl)
			sizer:Add(esizer, 0, iAlignment, 3)
		elseif type(x)=="table" then
			sizer:Add(doLayout(parent, elements, x), 0, iAlignment, 3)
		elseif x==nil then
			-- do nothing
		end
	end
	return sizer
end

--- Lay out elements in a grid.
-- @param parent the parent window (used for static boxes)
-- @param elements a list containing the elements to lay out,
-- mapping member names to pairs of label and edit control
-- e.g. elements["tMode"]={staticText=wxStaticText, editCtrl=wxTextCtrl}
-- @param layout the layout description
-- layout = {sizer="grid", rows=3, cols=4, box="Options",
--  "usDeviceClass", "bHwCompatibility", nil, nil
--  "usHWOptions_1", "usHWOptions_2", "usHWOptions_3", "usHWOptions_4",
--  "ulLicenseFlags1", "ulLicenseFlags2", "usNetXLicenseID", "usNetXLicenseFlags"
-- }
-- @return sizer

function combineWithGrid(parent, elements, layout)
	--print("combine as grid")
	local rows, cols = layout.rows or 0, 2*(layout.cols or 1)
	-- print("rows: ", rows, "cols: ", cols, "elements: ", #elements)
	local hgap, vgap = layout.hgap or 3, layout.vgap or 3
	local sizer = wx.wxFlexGridSizer(rows, cols, hgap, vgap)
	local x, element
	for i = 1, #layout do
		x = layout[i]
		if type(x)=="string" then
			element = elements[x]
			sizer:Add(element.staticText, 0, wx.wxALIGN_CENTER_VERTICAL + wx.wxALIGN_RIGHT)
			sizer:Add(element.editCtrl, 0, wx.wxALIGN_LEFT)
		elseif type(x)=="table" then
			sizer:Add(doLayout(parent, elements, x))
		elseif x==nil then
			-- print("nil")
			sizer:AddSpacer(0)
			sizer:AddSpacer(0)
		end
	end
	
	if type(layout.box)=="string" then
		local mainsizer = wx.wxStaticBoxSizer(wx.wxHORIZONTAL, parent, layout.box)
		mainsizer:Add(sizer, 1, wx.wxEXPAND)
		return mainsizer
	else
		return sizer
	end
end


function doDefaultLayout(parent, elements)
	local sizer = wx.wxFlexGridSizer(0, 2, 3, 3)
	local element
	for _, strElementName in ipairs(elements) do
		assert(type(strElementName)=="string", "non-string entry in default layout")
		element = elements[strElementName]
		if isControl(element.editCtrl) then
			sizer:Add(element.staticText, 0, wx.wxALIGN_CENTER_VERTICAL + wx.wxALIGN_RIGHT)
			sizer:Add(element.editCtrl, 0, wx.wxEXPAND + wx.wxALIGN_LEFT)
		else
			sizer:Add(element.staticText, 0, wx.wxALIGN_RIGHT)
			sizer:Add(element.editCtrl, 0, wx.wxALIGN_RIGHT)
		end
	end
	return sizer
end

--- construct a struct editor
-- @param strTypeName the name of the structure type
-- @param tParamDesc a description of the structure
-- @return inst the instance
function new(strTypeName, tParamDesc)
	local inst = {}
	inst.strTypeName = strTypeName
	inst.__index = structedit
	setmetatable(inst, inst)
	return inst
end

