module("macedit", package.seeall)

-- display a MAC address. 
-- binMAC is the address as a 6-byte string.
function setValue(self, binMAC)
	local strMAC = 
		string.format("%02x:%02x:%02x:%02x:%02x:%02x",
		binMAC:byte(1) or 0, binMAC:byte(2) or 0, binMAC:byte(3) or 0, 
		binMAC:byte(4) or 0, binMAC:byte(5) or 0, binMAC:byte(6) or 0)
	self.mTextCtrl:SetValue(strMAC)
end

-- return the current MAC address if valid.
-- returns a 6-byte string.
function getValue(self)
	local strMAC = self.mTextCtrl:GetValue()
	local a6, a5, a4, a3, a2, a1 = parseMACString(strMAC)
	--print(a6, a5, a4, a3, a2, a1)
	if a6 and a5 and a4 and a3 and a2 and a1 then
		return string.char(a6, a5, a4, a3, a2, a1)
	end
end

function parseMACString(strMAC) -- static
	local a6,a5,a4,a3,a2,a1 = string.match(strMAC, "^(%x%x):(%x%x):(%x%x):(%x%x):(%x%x):(%x%x)$")
	if a6 and a5 and a4 and a3 and a2 and a1 then
		return tonumber(a6,16), tonumber(a5,16), tonumber(a4,16),
		tonumber(a3,16), tonumber(a2,16), tonumber(a1,16)
	end
end

function isValid(self) 
	local strMAC = self.mTextCtrl:GetValue()
	return parseMACString(strMAC) and true
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
	inst.__index=macedit
	return inst
end

