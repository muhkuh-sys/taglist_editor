---------------------------------------------------------------------------
-- Copyright (C) 2010 Hilscher Gesellschaft fЭr Systemautomation mbH
--
-- Description:
--   Hex editor component for Taglist editor
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

---------------------------------------------------------------------------
-- A simple hexeditor
-- Major limitations:
--   only good for small files up to some KB
--   You can't change the size of the data
--   No undo
-- Stephan Lesch/Hilscher GmbH
-- Send feedback to SLesch@hilscher.com
---------------------------------------------------------------------------

-- Interface:
-- new
-- createPanel
-- getData/setData

-- Todo:
-- allow editing of the chars area?
-- put the caret to the nearest hex data char if the user has clicked somewhere else
-- prevent the user from making the window narrower than the width of the hexdump, as this breaks 
-- the coordinate handling

module("hexedit", package.seeall)
require("tester")
muhkuh.include("hexdump.lua", "hexdump")

---------------------------------------------------------------------
--     Reading and writing a binary from/to the text control
---------------------------------------------------------------------

-- print a hexdump of abData with self.miHexBytesPerLine to mHexCtrl
function setValue(self, abData)
	local hexCtrl = self.mHexCtrl
	hexCtrl:Clear()
	self.miTotalLen = abData:len()
	local strLine
	local iMaxLineLen, iLineCount = 0, 0
	for iLinePos=0, self.miTotalLen-1, self.miHexBytesPerLine do
		strLine = hexDumpLine(self, abData, iLinePos)
		if strLine:len() > iMaxLineLen then iMaxLineLen = strLine:len() end
		iLineCount = iLineCount + 1
		if iLinePos+self.miHexBytesPerLine<self.miTotalLen-1 then
			strLine = strLine .. "\n"
		end
		hexCtrl:AppendText(strLine)
	end
	self.miLineCount = iLineCount
	
	local iSizeX = iMaxLineLen * hexCtrl:GetCharWidth()
	local iSizeY = (iLineCount + 0.5) * hexCtrl:GetCharHeight()
	local size = wx.wxSize(iSizeX, iSizeY)
	--print("chars x/y", iMaxLineLen, iLineCount)
	--print("char width/height", hexCtrl:GetCharWidth(), hexCtrl:GetCharHeight())
	--print("calculated size: ", iSizeX, iSizeY)
	hexCtrl:SetMinSize(size)
	hexCtrl:SetMaxSize(size)
	--hexCtrl:SetSize(size)
	--hexCtrl:SetInitialSize(size)
	
	--self.mPanel:Fit()
	--self.mPanel:Layout()
	--self.mPanel:Refresh()
	hexCtrl:SetInsertionPoint(hexCtrl:XYToPosition(self.miHexDataStart, 0))
end

-- read the hex data back from the text control and convert it back to binary.
function getValue(self)
	local hexCtrl = self.mHexCtrl
	local nLines = hexCtrl:GetNumberOfLines()
	local abNewData = ""
	for lineNo = 0, nLines-1 do
		local strLine = hexCtrl:GetLineText(lineNo)
		if not strLine or strLine=="" then
			print("got empty line from text control")
			return
		end
		local abLineData = self:parseHexdumpLine(strLine)
		if abLineData then 
			abNewData=abNewData..abLineData
		else
			print("Error parsing hex data!")
			return
		end
	end
	return abNewData
end

function isValid(self)
	return true
end


---------------------------------------------------------------------
--               generate/parse hex dump lines
---------------------------------------------------------------------

--hexDumpLine(abData, iPos, iBytes, strAddrFormat, strByteSep, iHexDataLen, fAscii)
function hexDumpLine(self, abData, iPos) -- static
	return hexdump.hexDumpLine(abData, iPos, self.miHexBytesPerLine, 
		self.mStrAddrFormat, self.mStrByteSeparatorChar, 
		self.miHexDataLen, self.mfShowAscii)
end


-- parse a line of the form
-- 0x00000020: cc cc cc cc cc cc cc cc cc cc cc cc cc cc cc cc лллллллллллллллл
-- assuming that there are self.miHexBytesPerLine space-separated byte values in the line.
--
-- returns a string with the binary data if successful,
-- false if not

function parseHexdumpLine(self, strLine)
--	if strLine:len() < self.miHexLineLen then
--		print("line too short!")
--		return false
--	end
	strLine = strLine:sub(self.miHexDataStart, self.miHexDataStart + self.miHexDataLen)
	--print(strLine)
	local abData=""
	for w in strLine:gmatch("%x%x") do
		--print(w, tonumber(w, 16))
		abData=abData..string.char(tonumber(w, 16))
	end
	return abData
end

---------------------------------------------------------------------
--                   editing functions
---------------------------------------------------------------------


local KEYCODE_0 = string.byte("0")
local KEYCODE_9 = string.byte("9")
local KEYCODE_A = string.byte("a")
local KEYCODE_F = string.byte("f")
local KEYCODE_AA = string.byte("A")
local KEYCODE_FF = string.byte("F")

-- handle keys. Allowed keys are
-- crsr left/right/up/down and backspace,
-- 0-9 a-f A-F
function OnHexKey(self, event)
	local key = event:GetKeyCode()
	if key then
		if key==wx.WXK_DOWN or key==wx.WXK_UP or key==wx.WXK_LEFT or key==wx.WXK_RIGHT then 
			self:moveCursor(key)
		elseif key==wx.WXK_BACK then
			self:moveCursor(wx.WXK_LEFT)
		elseif (key>=KEYCODE_0 and key<=KEYCODE_9) then
			self:writeDigit(key-KEYCODE_0)
		elseif (key>=KEYCODE_A and key<=KEYCODE_F) then
			self:writeDigit(key-KEYCODE_A+10)
		elseif (key>=KEYCODE_AA and key<=KEYCODE_FF) then
			self:writeDigit(key-KEYCODE_AA+10)
		end
	end
end



-- write a hex digit at the cursor position, and move the cursor one digit to the right
-- TODO: make sure that the user only writes into data hex digits
function writeDigit(self, nibble)
	local hexCtrl = self.mHexCtrl
	local pos = hexCtrl:GetInsertionPoint()
	local strNibble = string.format("%x", nibble)
	hexCtrl:Replace(pos, pos+1, strNibble)
	
	-- get the hex number from the current position
	local fOK, x, y = hexCtrl:PositionToXY(pos)
	if fOK then
		local bytecol = (x-self.miHexDataStart) / self.miHexByteLen
		local bytenibble = (x-self.miHexDataStart) % self.miHexByteLen
		local readpos = pos - bytenibble
		local strByte = hexCtrl:GetRange(readpos, readpos+2)
		local bByte = tonumber(strByte,16)
		--print(strByte, bByte)
	-- write the appropriate char
		if self.mfShowAscii and bByte then
			local strChar = bByte>=32 and string.format("%s", string.char(bByte)) or "."
			x = self.miHexAsciiStart + bytecol
			local charpos = hexCtrl:XYToPosition(x,y)
			hexCtrl:Replace(charpos, charpos+1, strChar)
		end
	end
	
	hexCtrl:SetInsertionPoint(pos)
	--setCursors()
	self:moveCursor(wx.WXK_RIGHT)
end




-- handler for left mouse button clicks
-- The user can set the cursor to any position in the hex dump window by
-- clicking on a position. We want to avoid that, but to do this, we have to
-- map mouse coordinates to window coordinates...
-- hit test results:
--  wxTE_HT_UNKNOWN this means HitTest() is simply not implemented
--  wxTE_HT_BEFORE  either to the left or upper
--  wxTE_HT_ON_TEXT directly on
--  wxTE_HT_BELOW   below [the last line]
--  wxTE_HT_BEYOND  after [the end of line]

function OnHexLeftDown(self, event)
	--print("left button")
	local pos = event:GetPosition()
	local hitTestRes, y, x = self.mHexCtrl:HitTest(pos)
	--print("Pixel coord: ", event:GetX(), event:GetY(), "Text coord: ", x, y)
	if hitTestRes == wx.wxTE_HT_ON_TEXT and textPositionInData(self,y,x) then
		setCursors(self, x,y)
		--event:StopPropagation()
		event:Skip()
	end
end




-- test if character position y, x is in the data:
-- - inside the data bytes in a line of the hexdump
-- - and not beyond the last byte on the last line
-- returns true if the position is in the data, false otherwise
function textPositionInData(self, y, x)
	if x>=self.miHexDataStart and x<=self.miHexDataStart + self.miHexDataLen then
		local x1 = x-self.miHexDataStart
		local byteno = x1 / self.miHexByteLen
		local xmod = x1 % self.miHexByteLen
		local datapos = y * self.miHexBytesPerLine + byteno
		if datapos < self.miTotalLen and xmod ~=2 then
			return true
		end
	end
	return false
end

--[[
-- unused
function getCurrentByte(self)
	local pos = mHexCtrl:GetInsertionPoint()
	local fOK, x, y = mHexCtrl:PositionToXY(pos)
	if fOK then
		local bytecol = (x-self.miHexDataStart) / self.miHexByteLen
		local bytenibble = (x-self.miHexDataStart) % self.miHexByteLen
		pos = pos - bytenibble
		local strByte = mHexCtrl:GetRange(pos, pos+2)
		print(strByte)
	end
end


-- returns line, byte, column in byte (all 0-based)
function getHexDataPos(self) -- unused
	local pos = mHexCtrl:GetInsertionPoint()
	local fOK, x, y = mHexCtrl:PositionToXY(pos)
	if fOK then
		local line = y
		if y<0 or y>mHexCtrl:GetNumberOfLines()-2 then line = -1 end
		local byt = (x - self.miHexDataStart) / self.miHexByteLen
		if byt<0 or byt >= self.miHexBytesPerLine then byt = -1 end
		local column = (x - self.miHexDataStart) % self.miHexByteLen
		return line, byt, column
	else
		return -1, -1, -1
	end
end
--]]
---------------------------------------------------------------------
---------------------------  cursors
---------------------------------------------------------------------

-- move the cursor. Keycode should be wx.wxK_LEFT/RIGHT/UP/DOWN
function moveCursor(self, keycode)
	local mHexCtrl = self.mHexCtrl
	local pos = mHexCtrl:GetInsertionPoint()
	local fOK, x, y = mHexCtrl:PositionToXY(pos)
	if fOK then
		if keycode==wx.WXK_DOWN and y<self.miLineCount-1 and self:textPositionInData(y+1,x) then
			y=y+1
		elseif keycode==wx.WXK_UP and y>0 then
			y=y-1
		elseif keycode==wx.WXK_LEFT then
			x=x-self.miHexDataStart
			if x>0 then
				if x%self.miHexByteLen==0 then x=x-2 else x=x-1 end
			elseif y>0 then
				y=y-1 
				x=self.miHexDataLen - 1
			end
			x=x+self.miHexDataStart
		elseif keycode==wx.WXK_RIGHT then
			x=x-self.miHexDataStart
			-- the index of the byte under the cursor in the current line
			local iByte = x / self.miHexByteLen
			-- the offset of the byte in all data
			local iDataPos = y * self.miHexBytesPerLine + iByte
			-- going from the first to the second nibble of a byte
			if x % self.miHexByteLen == 0 then 
				x=x+1
			elseif iDataPos+1 < self.miTotalLen then
				-- going from second nibble to next byte in current line
				if iByte +1 < self.miHexBytesPerLine then
					x=x+2
				else
					-- or to the first byte in the next line
					x=0
					y=y+1
				end
			end
			x=x+self.miHexDataStart
		end
		mHexCtrl:SetInsertionPoint(mHexCtrl:XYToPosition(x,y))
		self:setCursors()
	else
		print("error converting position!")
	end
end


-- simulate cursors in the hex and the ascii areas using text styles
-- (this is the reason why we're using a rich text 2 control...)

-- set the byte/char cursors. x/y is a position in the hex data area,
-- if no position is given, the current insertion point is used.
function setCursors(self, x,y)
	local mHexCtrl = self.mHexCtrl
	-- get position from insertion point if not given as parameter
	local ok
	if not (x and y) then
		ok, x, y = mHexCtrl:PositionToXY(mHexCtrl:GetInsertionPoint())
	end
	
	-- correct x position to the start of a byte
	local iByte = math.floor((x-self.miHexDataStart) / self.miHexByteLen)
	local xByte = self.miHexDataStart + self.miHexByteLen * iByte
	local xChar = self.miHexAsciiStart + iByte

	local iNewBytePos = mHexCtrl:XYToPosition(xByte,y)
	local iNewCharPos = mHexCtrl:XYToPosition(xChar,y)
	
	--mHexCtrl:SetInsertionPoint(mHexCtrl:XYToPosition(x,y))
	--mHexCtrl:ShowPosition(iNewBytePos)
	--mHexCtrl:Freeze()

	-- byte cursor: remove from old position, paint at new position
	if self.iByteCursorPos ~= iNewBytePos then
		if self.iByteCursorPos then
			self:removeCursor(self.iByteCursorPos, 2)
		end
		self:paintCursor(iNewBytePos, 2)
		self.iByteCursorPos = iNewBytePos
	end
	-- char cursor: remove from old position, paint at new position
	if self.mfShowAscii and self.miCharCursorPos ~= iNewCharPos then
		if self.miCharCursorPos then
			self:removeCursor(self.miCharCursorPos, 1)
		end
		self:paintCursor(iNewCharPos, 1)
		self.miCharCursorPos = iNewCharPos
	end
	--mHexCtrl:ShowPosition(iNewBytePos)
	--mHexCtrl:SetInsertionPoint(mHexCtrl:XYToPosition(x,y))
	--mHexCtrl:Thaw()
	--mHexCtrl:Refresh()
end

function paintCursor(self,iPos, iLen)
	--print("paintCursor", iPos, iLen)
	if not self.cursorStyle then
		local ds = self.mHexCtrl:GetDefaultStyle()
		self.cursorStyle = wx.wxTextAttr(
			ds:GetTextColour(),
			wx.wxCYAN,
			ds:GetFont(),
			ds:GetAlignment())
	end
	local fOk = self.mHexCtrl:SetStyle(iPos, iPos+iLen, self.cursorStyle)
	--print(fOk and "OK" or "fail")
end

function removeCursor(self,iPos, iLen)
	--print("removeCursor", iPos, iLen)
	if not self.defaultStyle then
		local ds = self.mHexCtrl:GetDefaultStyle()
		self.defaultStyle = wx.wxTextAttr(
			ds:GetTextColour(),
			wx.wxWHITE,
			ds:GetFont(),
			ds:GetAlignment())
	end
	local fOk = self.mHexCtrl:SetStyle(iPos, iPos+iLen, self.defaultStyle)
	--print(fOk and "OK" or "fail")
end



---------------------------------------------------------------------
--                   Initialization
---------------------------------------------------------------------
--strInitMsg = 
--"Limitations:\n"..
--"- Only suitable for small files (up to some KB).\n" ..
--"- The size of the data cannot be changed.\n"..
--"- You can't write directly into the ascii area.\n"..
--"- No undo."

function setStyle(self, strAddrFormat, iBytesPerLine, strByteSeparatorChar, fShowAscii, iMultiLine)
	self.mStrAddrFormat = strAddrFormat
	--self.miBytesPerLine = iBytesPerLine
	self.mStrByteSeparatorChar = strByteSeparatorChar
	self.mfShowAscii = fShowAscii
	
	local test = string.format(strAddrFormat, 0)
	self.miHexDataStart = test:len()
	self.miHexByteLen = 3 -- including the space
	self.miHexBytesPerLine = iBytesPerLine
	self.miHexDataLen = self.miHexBytesPerLine * self.miHexByteLen -1
	self.miHexAsciiStart = self.miHexDataStart + self.miHexDataLen +1
	-- self.miHexLineLen = self.miHexAsciiStart + self.miHexBytesPerLine
	
	self.miMultiline = iMultiLine or 0
end

--0x00000020: cc cc cc cc cc cc cc cc cc cc cc cc cc cc cc cc лллллллллллллллл
function setDefaultStyle(self)
	self:setStyle("0x%08x: ", 16, " ", true, wx.wxTE_MULTILINE)
end


function create(self, parent)
	local id = tester.nextID()
	local hexCtrl = wx.wxTextCtrl(parent, id, "",
		wx.wxDefaultPosition, wx.wxDefaultSize,
		self.miMultiline + wx.wxTE_READONLY + wx.wxTE_RICH2)
	hexCtrl:Connect(id, wx.wxEVT_CHAR, function (event) hexedit.OnHexKey(self, event) end)
	hexCtrl:Connect(id, wx.wxEVT_LEFT_DOWN, function (event) hexedit.OnHexLeftDown(self, event) end)
	local font = wx.wxFont(9, wx.wxFONTFAMILY_MODERN, wx.wxFONTSTYLE_NORMAL, wx.wxFONTWEIGHT_NORMAL,
		false, "")
	hexCtrl:SetFont(font)
	
	self.mPanel = parent
	self.mHexCtrl = hexCtrl
	return hexCtrl
end

--[[
function createPanel(self, parent)
	local panel = wx.wxPanel(parent, wx.wxID_ANY)
	local id = tester.nextID()
	hexCtrl = wx.wxTextCtrl(panel, id, strInitMsg,
		wx.wxDefaultPosition, wx.wxDefaultSize,
		wx.wxTE_MULTILINE + wx.wxTE_READONLY + wx.wxTE_RICH2 + wx.wxHSCROLL)
	hexCtrl:Connect(id, wx.wxEVT_CHAR, function (event) hexedit.OnHexKey(self, event) end)
	hexCtrl:Connect(id, wx.wxEVT_LEFT_DOWN, function (event) hexedit.OnHexLeftDown(self, event) end)
	local font = wx.wxFont(9, wx.wxFONTFAMILY_MODERN, wx.wxFONTSTYLE_NORMAL, wx.wxFONTWEIGHT_NORMAL,
		false, "")
	hexCtrl:SetFont(font)
	
	local mainSizer = wx.wxBoxSizer(wx.wxHORIZONTAL)
	mainSizer:Add(hexCtrl, 1, wx.wxEXPAND + wx.wxALL, 3)
	panel:SetSizer(mainSizer)
	
	self.mPanel = panel
	self.mHexCtrl = hexCtrl
	self:setDefaultStyle()
	return panel
end
--]]

function new()
	local inst = {}
	setmetatable(inst, inst)
	inst.__index=hexedit
	inst:setDefaultStyle()
	return inst
end

