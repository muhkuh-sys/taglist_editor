---------------------------------------------------------------------------
-- Copyright (C) 2010 Hilscher Gesellschaft für Systemautomation mbH
--
-- Description:
--   Editor for number fields, component of Taglist editor
--
--  Changes:
--    Date        Author        Description
--  Sept 20,2011  SL            fix: bug when pasting results in illegeal value
--                              adapted to use wxValidator for key filtering
--  Mar 4, 2011   SL            fix: bug when an illegal value (e.g. 0)
--                              was present in a tag
---------------------------------------------------------------------------
--  
---------------------------------------------------------------------------
-- SVN Keywords
--
-- $Date$
-- $Revision$
-- $Author$
---------------------------------------------------------------------------



module("numedit", package.seeall)
require("tester")

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

function storeInsertionPoint(self)
	self.m_iLastValidPos = self.m_TextCtrl:GetInsertionPoint()
	-- print("last valid pos:", self.m_iLastValidPos)
end


function storeString(self)
	self.m_strLastValid = self.m_TextCtrl:GetValue()
	self.m_iLastValidPos = self.m_TextCtrl:GetInsertionPoint()
	-- print("Last valid: ", self.m_strLastValid)
	-- print("last valid pos:", self.m_iLastValidPos)
end

function restoreString(self)
	if self.m_strLastValid then
		-- print("restoreString: ", self.m_strLastValid)
		self.m_TextCtrl:ChangeValue(self.m_strLastValid)
	else
		-- print("restoreString: noting stored")
	end
	
	if self.m_iLastValidPos then
		self.m_TextCtrl:SetInsertionPoint(self.m_iLastValidPos)
	end
end



function setValue(self, bin)
	local uVal = binToUint(bin, 0, self.m_nBits)
	local strVal = string.format(self.m_format, uVal)
	assert(strVal, "numedit.setValue: failed to format value")
	self.m_TextCtrl:ChangeValue(strVal)
	self:storeString()
end


function getValue(self)
	local strVal = self.m_TextCtrl:GetValue()
	local iVal, strError = self:checkValue (strVal)
	return iVal and uintToBin(iVal, self.m_nBits) or nil, strError
end


--- Check string value and convert to integer. 
-- Checks if the string is convertible and inside the bounds of minval/maxval.
-- @param self
-- @param strVal string value
-- @return iVal the integer value if valid
-- @return strError error message if the string is invalid
function checkValue(self, strVal)
	if strVal:len() == 0 or strVal=="0x" then
		return nil, "no value"
	end
	
	local iVal = tonumber(strVal)
	if not iVal then 
		return nil, "parse error" 
	end
	
	if strVal:sub(1,2) =="0x" and strVal:len()-2 > self.m_nDigits then
		return nil, "Value out of range"
	end
	
	if iVal<self.m_minVal or iVal>self.m_maxVal then
		return nil, "Value out of range"
	end
	
	return iVal
end

-- due to the checks, the input should always be valid.
-- If an illegal value was preset and not changed by the user, 
-- we currently want to keep the value anyway.
function isValid(self)
	--local val, msg = getValue(self)
	--return val and true or false, msg
	return true
end


local hexDecValidator = wx.wxTextValidator(wx.wxFILTER_INCLUDE_CHAR_LIST )
hexDecValidator:SetIncludes({"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f", "x"})

function create(self, parent)
	local id = tester.nextID()
	self.m_id = id
	self.m_TextCtrl = wx.wxTextCtrl(parent, id, "", wx.wxDefaultPosition, wx.wxDefaultSize, 0, hexDecValidator )
	self.m_TextCtrl:Connect(id, wx.wxEVT_COMMAND_TEXT_UPDATED, function(event) self:OnTextUpdate(event) end)
	return self.m_TextCtrl
end

--- Text update handler.
-- When this event handler is called, the value of the
-- text control has already been changed.
-- If the new value does not parse, restore the stored 
-- value and cursor pos to undo the change.
function OnTextUpdate(self, event)
	local str = event:GetString()

	-- print("text update")
	-- print("current value:", str)
	-- print("Last valid: ", self.m_strLastValid)
	
	local fOk, strError = self:checkValue(str)
	--print(str, fOk, strError)
	if str:len()>0 and str~="0x" and not fOk then
		self:restoreString()
	else
		self:storeString()
	end
	event:Skip(false)
end

local emptyPars = {}
function new(_, tEditorParams)
	local inst = {}
	local pars = tEditorParams or emptyPars
	inst.m_nBits   = pars.nBits     or 32
	inst.m_nDigits =                   math.ceil(inst.m_nBits / 4)
	inst.m_format  = pars.format    or "0x%0" .. inst.m_nDigits .. "x"
	inst.m_minVal  = pars.minValue  or 0
	inst.m_maxVal  = pars.maxValue  or 2^inst.m_nBits -1
	inst.__index = numedit
	setmetatable(inst, inst)
	return inst
end
