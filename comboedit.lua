---------------------------------------------------------------------------
-- Copyright (C) 2010 Hilscher Gesellschaft für Systemautomation mbH
--
-- Description:
--   Combo box editing component for Taglist editor
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

module("comboedit", package.seeall)
require("tester")

-- RX_PIO_VALUE_TYPE = {size=2, editor="comboedit", editorParam={
-- 	nBits=16, -- nBits = 8*size
-- 	values={
-- 		{name="no register", value=0},
-- 		{name="active high", value=1},
-- 		{name="active low", value=2},
-- 		{name="absolute", value=3},
-- 	}}

function uintToBin(u, nBits)
	local u = u or 0
	local nBytes = math.ceil(nBits/8)
	local bin = ""
	for i=1, nBytes do
		bin = bin .. string.char(bit.band(u, 0xff))
		u=bit.rshift(u, 8)
	end
	return bin
end

function binToUint(bin, pos, nBits)
	if nBits <= 8 then
		return bin:byte(pos+1)
	elseif nBits <= 16 then
		return bin:byte(pos+1) + 256*bin:byte(pos+2)
	elseif nBits <= 24 then
		return bin:byte(pos+1) + 256*bin:byte(pos+2) + 65536*bin:byte(pos+3)
	elseif nBits <= 32 then
		return bin:byte(pos+1) + 256*bin:byte(pos+2) + 65536*bin:byte(pos+3) + 0x1000000 * bin:byte(pos+4)
	end
end

function choiceGetValueNames(values)
	local names = {}
	for i=1, #values do
		names[i]=values[i].name
	end
	return names
end

function choiceValue2Index(values, ulChoiceValue)
	for i=1, #values do
		if values[i].value == ulChoiceValue then return i end
	end
end

-- wxLua bug: 
-- SetSelection requires 0xffffffff for no selection,
-- GetSelection returns -1
function setValue(self, bin)
	-- if the value is not in the value list, and the user does not
	-- select a valid entry, we want to return the original value unchanged.
	self.m_abOrigValue = bin
	
	-- convert binary to uint
	local val = binToUint(bin, 0, self.m_nBits)
	-- find the value
	local iIndex = choiceValue2Index(self.m_values, val)
	-- select the entry, or deselect if the value was not found
	self.m_choiceCtrl:SetSelection(iIndex and iIndex-1 or 0xffffffff)
end

function getValue(self)
	local iSelection = self.m_choiceCtrl:GetCurrentSelection()
	--print("comboedit/getValue", iSelection)
	if iSelection == -1 then
		return self.m_abOrigValue
	else
		local iVal = self.m_values[iSelection+1].value
		return uintToBin(iVal, self.m_nBits)
	end
end


function isValid(self)
	return true
end


function create(self, parent)
	local id = tester.nextID()
	local choiceCtrl = wx.wxChoice(parent, id) 
	choiceCtrl:Freeze()
	choiceCtrl:Append(choiceGetValueNames(self.m_values))
	choiceCtrl:Thaw()
	self.m_id = id
	self.m_choiceCtrl = choiceCtrl
	return choiceCtrl
end



function new(_, tEditorParams)
	--if tEditorParams then
	--	for k,v in pairs(tEditorParams) do print(k,v) end
	--end
	
	local inst = {}
	if tEditorParams then
		inst.m_values = tEditorParams.values
		if tEditorParams.minValue and tEditorParams.maxValue then
			inst.m_values={}
			for i=tEditorParams.minValue, tEditorParams.maxValue do
				inst.m_values[#inst.m_values+1]= {name=string.format("%d", i), value=i}
			end
		end
		inst.m_nBits = tEditorParams.nBits
	else
		error("parameters required for combo box editor!")
	end
	
	inst.__index = comboedit
	setmetatable(inst, inst)
	return inst
end

