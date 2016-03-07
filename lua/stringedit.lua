---------------------------------------------------------------------------
-- Copyright (C) 2010 Hilscher Gesellschaft für Systemautomation mbH
--
-- Description:
--   String field editor component for Taglist Editor
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

module("stringedit", package.seeall)

-- editor for fixed-size strings.
-- The string is padded with 0 bytes, but does not have to end
-- with 0, if the full length is used.
function setValue(self, bin)
	self.mTextCtrl:SetValue(bin)
	self.mLen = bin:len()
	self.mTextCtrl:SetMaxLength(bin:len())
end

function getValue(self)
	local str = self.mTextCtrl:GetValue()
	if str:len()<self.mLen then
		str = str .. string.rep(string.char(0), self.mLen-str:len())
	end
	-- print("string length: ", str:len())
	--for i=1, str:len() do print(string.format("%2d %02x ", i, str:byte(i))) end
	return str
end

function isValid(self) 
	return true
end

function create(self, parent)
	local id = tester.nextID()
	textCtrl = wx.wxTextCtrl(parent, id, "")
	self.mTextCtrl = textCtrl
	return textCtrl
end

function new()
	local inst = {}
	setmetatable(inst, inst)
	inst.__index=stringedit
	return inst
end
