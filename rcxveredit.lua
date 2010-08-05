---------------------------------------------------------------------------
-- Copyright (C) 2010 Hilscher Gesellschaft für Systemautomation mbH
--
-- Description:
--   Editor for rcX version field, component of Taglist editor
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

module("rcxveredit", package.seeall)


function uint16tobin(u)
	return string.char(bit.band(u or 0, 0xff), 
	bit.band(bit.rshift(u or 0, 8), 0xff))
end

function uint16(bin, pos)
	return bin:byte(pos+1) + 0x100* bin:byte(pos+2)
end

-- bin -> string
function deserialize_version(abVer)
	local strVer = 
		string.format("%d.%d.%d.%d", 
		uint16(abVer, 0), uint16(abVer, 2), uint16(abVer, 4), uint16(abVer, 6)) 
	return strVer
end

-- string -> 4 integers
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

-- string -> bin
function serialize_version(strVer)
	local a4, a3, a2, a1 = parseVerString(strVer)
	if a4 and a3 and a2 and a1 then
		return uint16tobin(a4) .. uint16tobin(a3) .. uint16tobin(a2) .. uint16tobin(a1)
	end
end

-- display rcX version
-- rcX is the version number as an 8-byte string (four 16-bit numbers).
function setValue(self, binVer)
	self.mTextCtrl:SetValue(deserialize_version(binVer))
end

-- return the current rcxVersion no as an 8 byte string if valid.
function getValue(self)
	local strVer = self.mTextCtrl:GetValue()
	return serialize_version(strVer)
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

