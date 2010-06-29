---------------------------------------------------------------------------
-- Copyright (C) 2010 Hilscher Gesellschaft für Systemautomation mbH
--
-- Description:
--   check box editing component for Taglist editor
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
module("checkboxedit", package.seeall)
require("tester")

-- editorParam={nBits = 8, offValue = 0, onValue = 1, otherValues = true}

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

function setValue(self, bin)
	-- convert binary to uint
	local val = binToUint(bin, 0, self.m_nBits)
	
	-- set the checkbox according to the value
	local fState
	if val == self.m_iOnValue then
		fState = true
	elseif val == self.m_iOffValue then
		fState = false
	else 
		fState = self.m_fOtherValues
	end
	self.m_checkboxCtrl:SetValue(fState)
end

function getValue(self)
	local fState = self.m_checkboxCtrl:GetValue()
	local iVal = fState and self.m_iOnValue or self.m_iOffValue
	return uintToBin(iVal, self.m_nBits)
end

function isValid(self)
	return true
end


function create(self, parent)
	local id = tester.nextID()
	local checkboxCtrl = wx.wxCheckBox(parent, id, self.m_strLabel) 
	self.m_id = id
	self.m_checkboxCtrl = checkboxCtrl
	return checkboxCtrl
end


local emptyList = {}
function new(_, tEditorParams)
	local par = tEditorParams or emptyList
	local inst = {
		m_iOnValue     = par.onValue     or 1,
		m_iOffValue    = par.offValue    or 0,
		m_fOtherValues = par.otherValues or true,
		m_nBits        = par.nBits       or 8,
		m_strLabel     = par.label       or ""
	}

	inst.__index = checkboxedit
	setmetatable(inst, inst)
	return inst
end

