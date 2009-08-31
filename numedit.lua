module("numedit", package.seeall)
require("tester")

--[[
function binToUint(bin, pos, nBits)
	--print("nBits=", nBits, "bin: ", bin:len())
	local nBytes = math.ceil(nBits/8)
	local val = 0
	for i= nBytes, 1, -1 do
		val = val *256 +  bin:byte(pos+i)
	end
	return val
end

function uint32tobin(u)
	return string.char(bit.band(u or 0, 0xff), 
	bit.band(bit.rshift(u or 0, 8), 0xff),
	bit.band(bit.rshift(u or 0, 16), 0xff),
	bit.band(bit.rshift(u or 0, 24), 0xff))
end

function binToUint32(bin, pos)
	return bin:byte(pos+1) + 0x100* bin:byte(pos+2) + 0x10000 * bin:byte(pos+3) + 0x1000000*bin:byte(pos+4)
end

function uint_big_endian(bin, pos, nBits)
	--print("nBits=", nBits, "bin: ", bin:len())
	local nBytes = math.ceil(nBits/8)
	local val = 0
	for i=1, nBytes do
		local b = bin:byte(pos+i)
		val = 256*val + b
	end
	return val
end
--]]


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
	--print("numedit.setValue: self.m_tEditorParams=", self.m_tEditorParams)
	local uVal = binToUint(bin, 0, self.m_nBits)
	--local strFormat = self.m_tEditorParams.format or
	--	string.format("0x%%0%dx", self.m_nDigits)
	--print(strFormat)
	--local strVal = string.format(strFormat, uVal)
	local strVal = string.format(self.m_format, uVal)
	assert(strVal, "numedit.setValue: failed to format value")
	--print(strVal)
	self.m_TextCtrl:SetValue(strVal)
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
function isValid(self)
	--local val, msg = getValue(self)
	--return val and true or false, msg
	return true
end

function create(self, parent)
	local id = tester.nextID()
	self.m_id = id
	self.m_TextCtrl = wx.wxTextCtrl(parent, id, "")
	self.m_TextCtrl:Connect(id, wx.wxEVT_CHAR, function(event) self:OnKey(event) end)
	self.m_TextCtrl:Connect(id, wx.wxEVT_COMMAND_TEXT_UPDATED, function(event) self:OnTextUpdate(event) end)
	return self.m_TextCtrl
end

local CHAR_0 = string.byte("0")
local CHAR_9 = string.byte("9")
local CHAR_A = string.byte("a")
local CHAR_F = string.byte("f")
local CHAR_X = string.byte("x")
local CHAR_AA = string.byte("A")
local CHAR_FF = string.byte("F")
local CHAR_XX = string.byte("X")

--- Key event handler. 
-- The only keys accepted are 0-9, a-f, A-F, x/X and
-- cursor left/right, home/end and backspace. If the key is
-- accepted, the current text and cursor position are stored.
function OnKey(self, event)
	local key = event:GetKeyCode()
	if key==wx.WXK_LEFT or 
		key==wx.WXK_RIGHT or
		key==wx.WXK_HOME or
		key==wx.WXK_END or
		key==wx.WXK_BACK or
		key>=CHAR_0 and key<=CHAR_9 or
		key>=CHAR_A and key<=CHAR_F or
		key>=CHAR_AA and key<=CHAR_FF or
		key == CHAR_X or
		key == CHAR_XX then
		self.m_strLastValid = self.m_TextCtrl:GetValue()
		self.m_iLastValidPos = self.m_TextCtrl:GetInsertionPoint()
		--print("OnKey")
		--print("Last valid: ", self.m_strLastValid)
		--print("last valid pos:", self.m_iLastValidPos)
		event:Skip()
	end
end


--- Text update handler.
-- If the new value does not parse, the old value and cursor pos
-- stored by the key handler are used to undo the input.
function OnTextUpdate(self, event)
	--local str = event:GetString()
	--print("text update")
	--print("current value:", str)
	--print("Last valid: ", self.m_strLastValid)
	--print("undoUpdate: ", self.m_ignoreUpdate)
	
	if self.m_ignoreUpdate then
		self.m_ignoreUpdate = nil
	else
		local str = event:GetString()
		local fOk, strError = self:checkValue(str)
		--print(str, fOk, strError)
		if str:len()>0 and str~="0x" and not fOk then
			self.m_ignoreUpdate = true
			self.m_TextCtrl:SetValue(self.m_strLastValid)
			self.m_TextCtrl:SetInsertionPoint(self.m_iLastValidPos)
		end
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

function new_old(_, tEditorParams)
	--if tEditorParams then
	--	for k,v in pairs(tEditorParams) do print(k,v) end
	--end
	
	local inst = {}
	inst.m_tEditorParams = tEditorParams or {}
	inst.m_nBits = 32
	if tEditorParams then
		inst.m_tEditorParams = tEditorParams
		inst.m_nBits = tEditorParams.width or inst.m_nBits
		inst.m_fSigned = tEditorParams.signed or inst.m_fSigned
		inst.m_minVal = tEditorParams.minVal or 0
		inst.m_maxVal = tEditorParams.maxVal or 2^inst.m_nBits -1
	end

	inst.m_minVal = 0
	inst.m_maxVal = 2^inst.m_nBits -1
	
	inst.m_nDigits = math.ceil(inst.m_nBits / 4)
	inst.__index = numedit
	setmetatable(inst, inst)
	return inst
end

