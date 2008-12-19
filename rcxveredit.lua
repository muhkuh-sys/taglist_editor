module("rcxveredit", package.seeall)


function uint16tobin(u)
	return string.char(bit.band(u or 0, 0xff), 
	bit.band(bit.rshift(u or 0, 8), 0xff))
end

function uint16(bin, pos)
	return bin:byte(pos+1) + 0x100* bin:byte(pos+2)
end


-- display rcX version
-- rcX is the version number as an 8-byte string (four 16-bit numbers).
function setValue(self, binVer)
	local strVer = 
		string.format("%d.%d.%d.%d", 
		uint16(binVer, 0), uint16(binVer, 2), uint16(binVer, 4), uint16(binVer, 6)) 
	self.mTextCtrl:SetValue(strVer)
end

-- return the current rcxVersion no as an 8 byte string if valid.
function getValue(self)
	local strVer = self.mTextCtrl:GetValue()
	local a4, a3, a2, a1 = parseVerString(strVer)
	if a4 and a3 and a2 and a1 then
		return uint16tobin(a4) .. uint16tobin(a3) .. uint16tobin(a2) .. uint16tobin(a1)
	end
end

function parseVerString(strVer) -- static
	local s4,s3,s2,s1 = string.match(strVer, "^(%d+)%.(%d+)%.(%d+)%.(%d+)$")
	local a4, a3, a2, a1 = tonumber(s4), tonumber(s3), tonumber(s2), tonumber(s1)
	--print(strVer, "->", a4, a3, a2, a1)
	if a4 and a4>=0 and a4<=65535 and
		a3 and a3>=0 and a3<=65535 and
		a2 and a2>=0 and a2<=65535 and
		a1 and a4>=0 and a1<=65535 then
		return a4, a3, a2, a1
	end
	-- print("Could not parse rcX version")
end

function isValid(self) 
	local strVer = self.mTextCtrl:GetValue()
	return parseVerString(strVer) and true
end

function create(self, parent)
	local id = tester.nextID()
	textCtrl = wx.wxTextCtrl(parent, id, "")
	self.mTextCtrl = textCtrl
	return textCtrl
end

--[[
function createPanel(self, parent)
	local panel = wx.wxPanel(parent, wx.wxID_ANY)

	local id = tester.nextID()
	textCtrl = wx.wxTextCtrl(panel, id, "")
	
	local mainSizer = wx.wxBoxSizer(wx.wxHORIZONTAL)
	mainSizer:Add(textCtrl)
	panel:SetSizer(mainSizer)
	
	self.mPanel = panel
	self.mTextCtrl = textCtrl
	
	return panel
end
--]]

function new()
	local inst = {}
	setmetatable(inst, inst)
	inst.__index=rcxveredit
	return inst
end

