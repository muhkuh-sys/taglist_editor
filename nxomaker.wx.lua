-- Load the wxLua module, does nothing if running from wxLua, wxLuaFreeze, or wxLuaEdit
package.cpath = package.cpath..";./?.dll;./?.so;../lib/?.so;../lib/vc_dll/?.dll;../lib/bcc_dll/?.dll;../lib/mingw_dll/?.dll;"
require("wx")

-- makeshift replacement for print
print=function(...) 
	local l = {...}
	local out = io.stdout
	for i=1, table.maxn(l) do out:write(l[i] or "nil", "  ") end
	out:write("\n")
end

-- replacement for muhkuh.include("hexdump.lua", "hexdump")
-- (required by nxo.lua)
muhkuh = {}
function muhkuh.include(strFile, strPackage) require(strPackage) end

-- get nxo package
require("nxfile")


-- input: unsigned->signed
function bitparconv(x)
	local ret = x<0x80000000 and x or x - 0x80000000 - 0x80000000
	--print("bitparconv:", x, "->", ret, string.format("%08x -> %08x", x, ret))
	return ret
end
-- output: signed->unsigned
function bitretconv(x)
	local ret = x>=0 and x or x + 0x80000000 + 0x80000000
	--print("bitretconv:", x, "->", ret, string.format("%08x -> %08x", x, ret))
	return ret
end


-- fix the bit operations
local band, bor, bxor, bnot, lshift, rshift, arshift = bit.band, bit.bor, bit.bxor, bit.bnot, bit.lshift, bit.rshift, bit.arshift
bit.band = function(a, b) return bitretconv(band(bitparconv(a), bitparconv(b))) end
bit.bor = function(a, b) return bitretconv(bor(bitparconv(a), bitparconv(b))) end
bit.bxor = function(a, b) return bitretconv(bxor(bitparconv(a), bitparconv(b))) end
bit.bnot = function(a) return bitretconv(bnot(bitparconv(a))) end
bit.lshift = function(a,b) return bitretconv(lshift(bitparconv(a), b)) end
bit.rshift = function(a,b) return bitretconv(rshift(bitparconv(a), b)) end
bit.arshift = function(a,b) return bitretconv(arshift(bitparconv(a), b)) end

-- trace print command 
local fVerbose = nil
function tprint(...)
	if fVerbose then 
		print(...)
	end
end

-- loadBin/saveBin from utils package
function loadBin(strName)
	tprint("reading file " .. strName)
	local f = wx.wxFile(strName)
	if not f:IsOpened() then 
		return nil, "Cannot open file " .. strName 
	end
	
	local iLen = f:Length()
	local iBytesRead, bin = f:Read(iLen)
	f:Close()
	tprint(iBytesRead .. " bytes read")
	if iBytesRead ~= iLen then
		local msg = "Error reading file " .. strName
		print(msg)
		return nil, msg
	else
		return bin
	end
end


function writeBin(strName, bin)
	tprint("writing to file " .. strName)
	local f = wx.wxFile(strName, wx.wxFile.write)
	if not f:IsOpened() then 
		return false, "Error opening file " .. strName .. " for writing"
	end

	local iBytesWritten = f:Write(bin, bin:len())
	f:Close()
	tprint(iBytesWritten .. " bytes written")
	if iBytesWritten ~= bin:len() then
		msg = "Error while writing to file " .. strName
		print(msg)
		return false, msg
	else
		return true
	end
end


--- load the component files and combine them to an nxo file.
-- the header must be in binary form, with common header V3.
-- returns true or false and an error message
-- new variant using nxfile
function makenxo(strHeaderFile, strTaglistFile, strElfFile, strNxoFile)
	nxo = nxfile.new()
	nxo:initNxo()
	
	local abDefaultHeader, abHeaders, abTags, abElf, abNxo, strMsg
	
	abHeaders, strMsg = loadBin(strHeaderFile)
	if not abHeaders then return false, strMsg end
	nxo:setHeadersBin(abHeaders)
	
	abElf, strMsg = loadBin(strElfFile)
	if not abElf then return false, strMsg end
	nxo:setElf(abElf)
	
	if strTaglistFile then
		abTags, strMsg = loadBin(strTaglistFile)
		if not abTags then return false, strMsg end
		nxo:setTaglistBin(abTags)
	end
	
	abNxo = nxo:buildNXFile()
	if not abNxo then return false, "failed to build nxo file" end
	
	local fSaved, strMsg = writeBin(strNxoFile, abNxo)
	if not fSaved then return false, strMsg end
	return true
end

-- old variant using nxo
--[[
function makenxo_(strHeaderFile, strTaglistFile, strElfFile, strNxoFile)
	nxo = nxo.new()
	local abDefaultHeader, abHeaders, abTags, abElf, abNxo, strMsg
	
	abHeaders, strMsg = loadBin(strHeaderFile)
	if not abHeaders then return false, strMsg end
	nxo:setHeadersBin(abHeaders)
	
	abElf, strMsg = loadBin(strElfFile)
	if not abElf then return false, strMsg end
	nxo:setElf(abElf)
	
	if strTaglistFile then
		abTags, strMsg = loadBin(strTaglistFile)
		if not abTags then return false, strMsg end
		nxo:setTaglistBin(abTags)
	end
	
	abNxo = nxo:buildNxoBin()
	if not abNxo then return false, "failed to build nxo file" end
	
	local fSaved, strMsg = writeBin(strNxoFile, abNxo)
	if not fSaved then return false, strMsg end
	return true
end
--]]

local aStrUsage={
"makenxo creates an rcX loadable module in NXO format from a binary",
"header file, a firmware stack in ELF format, and a tag list.",
"",
"Usage:",
"   makenxo -o OUTPUT -H HEADER [-t TAGLIST] [-v] ELFFILE",
"",
"Arguments:",
"   -o OUTPUT   Write NXO to OUTPUT",
"   -H HEADER   Load headers from binary file HEADER. The file must contain",
"               a common header V3, usually followed by a device info block",
"               and a module info block.",
"   -t TAGLIST  Use binary file TAGLIST as default tag list. If no tag list ",
"                 is specified, an empty tag list is generated",
"   -v          Verbose operation",
"   -h          This help text."
}

function printUsage()
	for i=1, #aStrUsage do print(aStrUsage[i]) end
end


-- parse command line (simple version)
-- header, Elf file and output file are mandatory
-- taglist, -v, -h are optional
-- c:\> lua.exe gennxo.lua -o OUTPUT -h Fileheader.bin -t DefaultTagList.bin -v Firmware.elf
local fOK = true
local strOutFile = nil
local strHeaderFile = nil
local strTaglistFile = nil
local strElfFile = nil
local i=1

if #arg == 0 then
	printUsage()
	os.exit(0)
end

while i<=#arg do
	--print("current arg:", arg[i])
	if arg[i]=="-o" and i+1<=#arg and not strOutFile then
		strOutFile = arg[i+1]
		i=i+2
	elseif arg[i]=="-H" and i+1<=#arg and not strHeaderFile then
		strHeaderFile = arg[i+1]
		i=i+2
	elseif arg[i]=="-t" and i+1<=#arg and not strTaglistFile then
		strTaglistFile = arg[i+1]
		i=i+2
	elseif arg[i]=="-v" then
		fVerbose = true
		i=i+1
	elseif arg[i]=="-h" then
		printUsage()
		os.exit(0)
	elseif not strElfFile then
		strElfFile = arg[i] 
		i=i+1
	else
		printUsage()
		os.exit(1)
	end
end

netx_fileheader.m_iVerbosity = fVerbose and netx_fileheader.VL_NORMAL or netx_fileheader.VL_ERRORS

tprint("header file:   ", strHeaderFile or "none")
tprint("tag list file: ", strTaglistFile or "none")
tprint("ELF file:      ", strElfFile or "none")
tprint("ouput file:    ", strOutFile or "none")

if not strHeaderFile or not strOutFile or not strElfFile then 
	print("You must supply the header file, the ELF file and the output file.")
	print("Use option -h for help")
	os.exit(1)
else
	local fOK, strMsg
	fOK, strMsg = makenxo(strHeaderFile, strTaglistFile, strElfFile, strOutFile)
	if not fOK then
		print("makenxo failed: ", strMsg)
		os.exit(1)
	end
	os.exit(0)
end


