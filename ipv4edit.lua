module("ipv4edit", package.seeall)

-- display an IP address. 
-- binIP is the address as a 4-byte string.
function setValue(self, binIP)
	local strIP = 
		string.format("%d.%d.%d.%d", 
		binIP:byte(1) or 0, binIP:byte(2) or 0, binIP:byte(3) or 0, binIP:byte(4) or 0)
	self.mTextCtrl:SetValue(strIP)
end

-- return the current IP address if valid.
-- returns a 4-byte string.
function getValue(self)
	local strIP = self.mTextCtrl:GetValue()
	local a4, a3, a2, a1 = parseIPString(strIP)
	if a4 and a3 and a2 and a1 then
		return string.char(a4, a3, a2, a1)
	end
end

function parseIPString(strIP) -- static
	local s4,s3,s2,s1 = string.match(strIP, "^(%d+)%.(%d+)%.(%d+)%.(%d+)$")
	local a4, a3, a2, a1 = tonumber(s4), tonumber(s3), tonumber(s2), tonumber(s1)
	-- print(strIP, "->", a4, a3, a2, a1)
	if a4 and a4>=0 and a4<=255 and
		a3 and a3>=0 and a3<=255 and
		a2 and a2>=0 and a2<=255 and
		a1 and a4>=0 and a1<=255 then
		return a4, a3, a2, a1
	end
	-- print("Could not parse IP address")
end

function isValid(self) 
	local strIP = self.mTextCtrl:GetValue()
	return parseIPString(strIP) and true
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
	inst.__index=ipv4edit
	return inst
end

