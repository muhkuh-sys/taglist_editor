---------------------------------------------------------------------------
-- Copyright (C) 2010 Hilscher Gesellschaft für Systemautomation mbH
--
-- Description:
--   hex dump routines for Taglist editor
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

module("hexdump", package.seeall)

function hexDumpLine(abData, iPos, iBytes, strAddrFormat, strByteSep, iHexDataLen, fAscii)
	iPos = iPos or 0
	
	local strAddr = ""
	if strAddrFormat then
		strAddr = string.format(strAddrFormat, iPos)
	end
	
	local strHex = ""
	local strChars = ""
	
	for iXPos = 1, iBytes do
		bByte = abData:byte(iPos + iXPos)
		if bByte then
			strHex = strHex..string.format("%02x", bByte)
			if iXPos<iBytes then
				strHex = strHex..strByteSep
			end
			strChars = strChars.. (bByte>=32 and string.char(bByte) or ".")
		end
	end
	
	if fAscii then
		return strAddr .. padString(strHex, iHexDataLen, " ") .. " " .. strChars
	else
		return strAddr .. strHex
	end
end

-- pad string str up to length iLen with character cPad
function padString(str, iLen, cPad)
	if str:len()<iLen then
		return str .. string.rep(" ", iLen-str:len())
	else 
		return str
	end
end


function doHexDump(abData, strOut, strAddrFormat, iBytesPerLine, fAscii, strByteSep)
	local strAddrFormat = strAddrFormat or ""
	local iBytesPerLine = iBytesPerLine or abData:len()
	local iHexDataLen = iBytesPerLine * 3 - 1
	local strByteSeparatorChar = strByteSeparatorChar or " "
	
	local iTotalLen = abData:len()
	for iLinePos=0, iTotalLen-1, iBytesPerLine do
		local strLine = hexDumpLine(abData, iLinePos, iBytesPerLine, 
			strAddrFormat, strByteSeparatorChar, iHexDataLen, fShowAscii)
		if strOut == nil then
			print(strLine)
		elseif strOut == "" then
			strOut = strLine
		else
			strOut = strOut .. "\n" .. strLine
		end
	end
	return strOut
end

-- print the array abData as a hexdump
function printHex(abData, strAddrFormat, iBytesPerLine, fShowAscii, strByteSeparatorChar)
	doHexDump(abData, nil, strAddrFormat, iBytesPerLine, fShowAscii, strByteSeparatorChar)
end

-- construct hexdump as a string
function hexString(abData, strAddrFormat, iBytesPerLine, fShowAscii, strByteSeparatorChar)
	return doHexDump(abData, "", strAddrFormat, iBytesPerLine, fShowAscii, strByteSeparatorChar)
end

-- common styles:
-- just the data without address or ascii (for small byte arrays)
-- data with address