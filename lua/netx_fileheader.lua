---------------------------------------------------------------------------
-- Copyright (C) 2010 Hilscher Gesellschaft für Systemautomation mbH
--
-- Description:
--   Tag definitions for Taglist editor
--
--  Changes:
--    Date        Author        Description
---------------------------------------------------------------------------
--  2010-08       SL            switched to vbs_/dbg_print
--  2010-09       SL            MakeNXF sets DataSize only if 0
--  2019-01       SL            add handling of NXI files.
---------------------------------------------------------------------------

module("netx_fileheader", package.seeall)

---------------------------------------------------------------------------
-- SVN Keywords
--
SVN_DATE   ="$Date: 2010-08-12 14:57:01 +0200 (Do, 12 Aug 2010) $"
SVN_VERSION="$Revision: 8903 $"
-- $Author: slesch $
---------------------------------------------------------------------------

require("utils")
require("mhash")
HIL_FILE_HEADER_NXI_COOKIE        = 0x49584e2e -- 2E 4E 58 49 ".NXI"
HIL_FILE_HEADER_MODULE_COOKIE     = 0x4d584e2e -- 2E 4E 58 4D ".NXM"
HIL_FILE_HEADER_OPTION_COOKIE     = 0x4f584e2e -- 2E 4E 58 4F ".NXO"
HIL_FILE_HEADER_DATABASE_COOKIE   = 0x44584e2e -- 2E 4E 58 44 ".NXD"
HIL_FILE_HEADER_LICENSE_COOKIE    = 0x4c584e2e -- 2E 4E 58 4C ".NXL"
HIL_FILE_HEADER_BINARY_COOKIE     = 0x42584e2e -- 2E 4E 58 42 ".NXB"
HIL_FILE_HEADER_BOOT_COOKIE       = 0xF8BEAF00 -- 00 AF BE F8 bootblock cookie
HIL_FILE_HEADER_MAGIC_COOKIE_MASK = 0xFFFFFF00
HIL_FILE_HEADER_SIGNATURE 		  = 0x5854454E -- "NETX" in boot header


-- this description is only for illustration (has overlapping fields...)
BOOT_HEADER_SPEC = {
	{offset = 0, type = "uint32", name = "ulMagicCookie"},		-- see HIL_FILE_HEADER_FIRMWARE_xxx_COOKIE

	{offset = 4, type = "uint32", name = "ulSpiClockSpeed"},	-- serial flash on SPI:        clock speed value
	--{offset = 4, type = "uint32", name = "ulSramBusTiming"},	-- parallel flash on SRAM bus: bus timing value

	{offset = 8, type = "uint32", name = "ulAppEntryPoint"},	-- app. entry point, netX code execution starts here
	{offset =12, type = "uint32", name = "ulAppChecksum"},	    -- app. checksum starting from byte offset 64
	{offset =16, type = "uint32", name = "ulAppFileSize"},		-- app. size in DWORDs starting from byte offset 64
	{offset =20, type = "uint32", name = "ulAppStartAddress"},	-- app. relocation start address for binary image
	{offset =24, type = "uint32", name = "ulSignature"},		-- app. signature, always 0x5854454E = "NETX"

	-- SDRAM
	{offset =28, type = "uint32", name = "ulSdramGeneralCtrl"},	-- value for SDRAM General Control register
	{offset =32, type = "uint32", name = "ulSdramTimingCtrl"},	-- value for SDRAM Timing register
	--{offset =36, type = "uint32", name = "ulSdramMR"},	-- value for SDRAM Mode register
	
	-- ext SRAM
	--{offset =28, type = "uint32", name = "ulExtConfigSRAMn"},	-- HBOOT/netx50: value for EXT_SRAMn_CTRL register

	-- extension bus
	--{offset =28, type = "uint32", name = "ulExtConfigCS0"},		-- value for EXT_CONFIG_CS0 register
	--{offset =32, type = "uint32", name = "ulIoRegMode0"},		-- value for DPMAS_IO_MODE0 register
	{offset =36, type = "uint32", name = "ulIoRegMode1"},		-- value for DPMAS_IO_MODE1 register
	{offset =40, type = "uint32", name = "ulIfConf0"},			-- value for DPMAS_IF_CONF0 register
	{offset =44, type = "uint32", name = "ulIfConf1"},			-- value for DPMAS_IF_CONF1 register
	
	{offset =48, type = "uint32", name = "ulMiscAsicCtrl"},		-- internal ASIC control register value (set to 1 for netx500/100/50/10, to 0 for netx51/52)
	{offset =52, type = "uint32", name = "ulSerialNumber"},		-- serial no. or user param. (ignored by ROM loader)
	{offset =56, type = "uint32", name = "ulSrcDeviceType"},	-- HIL_SRC_DEVICE_TYPE_xxx
	{offset =60, type = "uint32", name = "ulBootHeaderChecksum"},
}


DEFAULT_HEADER_SIZE = 64 -- 64 bytes
DEFAULT_HEADER_SPEC = {
	{offset = 0, type = "uint32", name = "ulMagicCookie"},
	{offset = 4, type = "bin",    name = "gap1", size=8},
	{offset =12, type = "uint32", name = "ulAppChecksum"},	    -- app. checksum starting from byte offset 64
	{offset =16, type = "uint32", name = "ulAppFileSize"},		-- app. size in DWORDs starting from byte offset 64
	{offset =20, type = "bin",    name = "gap2", size=4},
	{offset =24, type = "uint32", name = "ulSignature"},		-- app. signature, always 0x5854454E = "NETX"
	{offset =28, type = "bin",    name = "gap3", size=32},
	{offset =60, type = "uint32", name = "ulBootHeaderChecksum"},
}

-- checks NXF cookie and netX signature
function isBootHeader(tDefaultHeader)
	return bit.band(tDefaultHeader.ulMagicCookie, HIL_FILE_HEADER_MAGIC_COOKIE_MASK) 
			== HIL_FILE_HEADER_BOOT_COOKIE 
		and tDefaultHeader.ulSignature == HIL_FILE_HEADER_SIGNATURE
end

function isNxiBootHeader(tDefaultHeader)
    return tDefaultHeader.ulMagicCookie == HIL_FILE_HEADER_NXI_COOKIE 
     and tDefaultHeader.ulSignature == HIL_FILE_HEADER_SIGNATURE
end

function isChecksumBootHeader(tDefaultHeader)
    return isBootHeader(tDefaultHeader) or isNxiBootHeader(tDefaultHeader)
end

function isBootOrDefaultHeader(tDefaultHeader)
    return isChecksumBootHeader(tDefaultHeader) or isDefaultHeader(tDefaultHeader)
end

function isNXODefaultHeader(tDefaultHeader)
	return tDefaultHeader.ulMagicCookie == HIL_FILE_HEADER_OPTION_COOKIE
end

function isDefaultHeader(tDefaultHeader)
	return tDefaultHeader.ulMagicCookie == HIL_FILE_HEADER_OPTION_COOKIE or
	tDefaultHeader.ulMagicCookie == HIL_FILE_HEADER_DATABASE_COOKIE or
	tDefaultHeader.ulMagicCookie == HIL_FILE_HEADER_LICENSE_COOKIE or
	tDefaultHeader.ulMagicCookie == HIL_FILE_HEADER_BINARY_COOKIE
end

function getHeaderType(tDefaultHeader)
	if isBootHeader(tDefaultHeader) then
		return "NXF" 
	elseif tDefaultHeader.ulMagicCookie == HIL_FILE_HEADER_NXI_COOKIE then
		return "NXI"
	elseif tDefaultHeader.ulMagicCookie == HIL_FILE_HEADER_OPTION_COOKIE then
		return "NXO"
	elseif tDefaultHeader.ulMagicCookie == HIL_FILE_HEADER_DATABASE_COOKIE then
		return "NXD"
	elseif tDefaultHeader.ulMagicCookie == HIL_FILE_HEADER_LICENSE_COOKIE then
		return "NXL"
	elseif tDefaultHeader.ulMagicCookie == HIL_FILE_HEADER_BINARY_COOKIE then
		return "NXB"
	else 
		return nil
	end
end

COMMON_HEADER_V1_SIZE = 64 -- 64 bytes
COMMON_HEADER_V2_SIZE = 64 -- 64 bytes
COMMON_HEADER_V3_SIZE = 64 -- 64 bytes
COMMON_HEADER_MAJOR_VERSION_MASK = 0xffff0000
COMMON_HEADER_MINOR_VERSION_MASK = 0x0000ffff
HIL_FILE_COMMON_HEADER_VERSION_1  =  0x00010000 -- High Word = Major, Low Word = Minor Version
HIL_FILE_COMMON_HEADER_VERSION_2  =  0x00020000 -- High Word = Major, Low Word = Minor Version
HIL_FILE_COMMON_HEADER_VERSION_3  =  0x00030000 -- High Word = Major, Low Word = Minor Version

function getCommonHeaderVersion(tCH)
	return
		bit.rshift(bit.band(tCH.ulHeaderVersion, COMMON_HEADER_MAJOR_VERSION_MASK), 16),
		bit.band(tCH.ulHeaderVersion, COMMON_HEADER_MINOR_VERSION_MASK)
end

COMMON_HEADER_V1_SPEC = {
	{name="ulHeaderVersion"  ,offset=0, type="uint32", default = HIL_FILE_COMMON_HEADER_VERSION_1}, 
	{name="ulHeaderLength"   ,offset=4, type="uint32"},
	{name="ulFileSize"       ,offset=8, type="uint32"},
	{name="ulDataStartOffset",offset=12, type="uint32"},
	{name="ulTagListOffset"  ,offset=16, type="uint32"},
	{name="aulMD5"           ,offset=20, type="bin", size=16},
	{name="reserved"         ,offset=36, type="bin", size=24},
	{name="ulCheckSum"       ,offset=60, type="uint32"}
}


-- Common header V2 (obsolete)
COMMON_HEADER_V2_SPEC = {
	{name="ulHeaderVersion"  ,offset=0, type="uint32", default = HIL_FILE_COMMON_HEADER_VERSION_2}, 
	{name="ulHeaderLength"   ,offset=4, type="uint32"},
	{name="ulFileSize"       ,offset=8, type="uint32"},
	{name="ulDataStartOffset",offset=12, type="uint32"},
	{name="ulTagListOffset"  ,offset=16, type="uint32"},
	{name="aulMD5"           ,offset=20, type="bin", size=16},
	{name="usManufacturer"   ,offset=36, type="uint16"},
	{name="reserved"         ,offset=38, type="bin", size=22},
	{name="ulCheckSum"       ,offset=60, type="uint32"}
}

-- Common header V3 
COMMON_HEADER_V3_SPEC = {
	{name="ulHeaderVersion"  ,offset=0, type="uint32", default = HIL_FILE_COMMON_HEADER_VERSION_3}, 
	{name="ulHeaderLength"   ,offset=4, type="uint32"},
	{name="ulDataSize"       ,offset=8, type="uint32"}, 
	{name="ulDataStartOffset",offset=12, type="uint32"},
	{name="bNumModuleInfos"  ,offset=16, type="uint8"},
	{name="bReserved1"       ,offset=17, type="uint8"},
	{name="usReserved2"      ,offset=18, type="uint16"},
	{name="aulMD5"           ,offset=20, type="bin", size=16},
	{name="ulTagListSize"    ,offset=36, type="uint32"},
	{name="ulTagListStartOffset",offset=40, type="uint32"},
	{name="ulTagListSizeMax" ,offset=44, type="uint32"},
	{name="ulResrved3"       ,offset=48, type="uint32"},
	{name="ulResrved4"       ,offset=52, type="uint32"},
	{name="ulResrved5"       ,offset=56, type="uint32"},
	{name="ulHeaderCRC32"    ,offset=60, type="uint32"}
}

-- Firmware header used with Common header V2 (obsolete)
FIRMWARE_HEADER_GROUPNAME = "nxm_header_3" -- used when reading contents from .ini file
FIRMWARE_HEADER_SIZE = 55 + 64 -- bytes
FIRMWARE_HEADER_SPEC = {
  {type="uint16",          offset=0, name="usDeviceClass"},
  {type="uint8",           offset=2, name="bHwCompatibility"},
  {type="uint16",          offset=3, name="usHWOptions_1"},
  {type="uint16",          offset=5, name="usHWOptions_2"},
  {type="uint16",          offset=7, name="usHWOptions_3"},
  {type="uint16",          offset=9, name="usHWOptions_4"},
  {type="uint32",          offset=11, name="ulLicenseFlags1"},
  {type="uint32",          offset=15, name="ulLicenseFlags2"},
  {type="uint16",          offset=19, name="usNetXLicenseID"},
  {type="uint16",          offset=21, name="usNetXLicenseFlags"},
  {type="uint32",          offset=25, name="ulRevision_Major"},
  {type="uint32",          offset=29, name="ulRevision_Minor"},
  {type="uint32",          offset=33, name="ulRevision_Sub"},
  {type="uint32",          offset=37, name="ulSwNumber"},
  {type="uint16",          offset=39, name="usCommunicatonClass"},
  {type="uint16",          offset=41, name="usProtocolClass"},
  {type="string",          offset=43, name="abName", size=64},
  {type="uint32",          offset=43+64, name="ulDBVersion_Major"},
  {type="uint32",          offset=47+64, name="ulDBVersion_Minor"},
  {type="uint32",          offset=51+64, name="ulSDN"},
}


-- Device info header used with Common header V3
HIL_VERSION_DEVICE_INFO_V1_0 = 0x00010000 -- V1.0, initial version used with Common Header V3.0
DEVICE_INFO_GROUPNAME = "device_info" -- used when reading contents from .ini file
DEVICE_INFO_V1_SIZE = 64 -- bytes
DEVICE_INFO_SPEC = {
  {type="uint32",          offset=0, name="ulStructVersion"},
  {type="uint16",          offset=4, name="usManufacturer"},
  {type="uint16",          offset=6, name="usDeviceClass"},
  {type="uint8",           offset=8, name="bHwCompatibility"},
  {type="uint8",           offset=9, name="bChipType"},
  {type="uint16",          offset=10, name="usReserved"},
  {type="uint16",          offset=12, name="usHWOptions_1"},
  {type="uint16",          offset=14, name="usHWOptions_2"},
  {type="uint16",          offset=16, name="usHWOptions_3"},
  {type="uint16",          offset=18, name="usHWOptions_4"},
  {type="uint32",          offset=20, name="ulLicenseFlags1"},
  {type="uint32",          offset=24, name="ulLicenseFlags2"},
  {type="uint16",          offset=28, name="usNetXLicenseID"},
  {type="uint16",          offset=30, name="usNetXLicenseFlags"},
  {type="uint16",          offset=32, name="ausFWVersion_Major"},
  {type="uint16",          offset=34, name="ausFWVersion_Minor"},
  {type="uint16",          offset=36, name="ausFWVersion_Build"},
  {type="uint16",          offset=38, name="ausFWVersion_Revision"},
  {type="uint32",          offset=40, name="ulFWNumber"},
  {type="uint32",          offset=44, name="ulDeviceNumber"},
  {type="uint32",          offset=48, name="ulSerialNumber"},
  {type="uint32",          offset=52, name="ulReserved1"},
  {type="uint32",          offset=56, name="ulReserved2"},
  {type="uint32",          offset=60, name="ulReserved3"},
}

MODULE_INFO_V1_SIZE = 32 -- bytes

-- tracing

require("utils")
local function printf(...) print(string.format(...)) end
local vbs_printf = utils.vbs_printf
local dbg_printf = utils.dbg_printf
local msg_printf = utils.msg_printf
local err_printf = utils.err_printf
local vbs_print = utils.vbs_print
local dbg_print = utils.dbg_print
local msg_print = utils.msg_print
local err_print = utils.err_print
local isvbs_verbose = utils.isvbs_verbose
local isvbs_debug = utils.isvbs_debug

--[[
VL_QUIET = 0
VL_ERRORS = 1
VL_NORMAL = 2
VL_DEBUG = 3
m_iVerbosity = VL_NORMAL -- 0 = be quiet, 1 = print only error messages, 2 = print standard messages, >2 = print extended messages

-- trace print for errors
function eprint(...)
	if m_iVerbosity >=VL_ERRORS then
		print(...)
	end
end
-- trace print for standard messges
function tprint(...)
	if m_iVerbosity >=VL_NORMAL then
		print(...)
	end
end
-- trace print for debug messages
function dprint(...)
	if m_iVerbosity >=VL_DEBUG then
		print(...)
	end
end
--]]

-- conversion of numbers

function uinttobin(u, nBits)
	local u = u or 0
	if type(u)=="string" then
		u = tonumber(u)
		if not u then
			return nil, "parse error"
		end
	end
	local nBytes = math.ceil(nBits/8)
	local bin = ""
	for i=1, nBytes do
		bin = bin .. string.char(bit.band(u, 0xff))
		u=bit.rshift(u, 8)
	end
	if u~=0 then
		return bin, "number too large"
	end
	return bin
end


function uint(bin, pos, nBits)
	--print("nBits=", nBits, "bin: ", bin:len())
	local nBytes = math.ceil(nBits/8)
	local val, mult = 0, 1
	for i=1, nBytes do
		val = val + mult * bin:byte(pos+i)
		mult = mult * 256
	end
	return val
end


-- header conversion
-- if the header description contains fields at overlapping positions,
-- all these fields are filled.
function binToHeader(bin, tHeaderSpec)
	local header = {}
	local strKey, iOffset, strType, iLen
	for _, tFieldSpec in pairs(tHeaderSpec) do
		strKey, iOffset, strType, iLen = 
			tFieldSpec.name, tFieldSpec.offset, tFieldSpec.type, tFieldSpec.size
		local value
		if strType=="uint32" then
			value = uint(bin, iOffset, 32)
		elseif strType=="uint16" then
			value = uint(bin, iOffset, 16)
		elseif strType=="uint8" then
			value = uint(bin, iOffset, 8)
		elseif strType=="bin" then
			value = bin:sub(iOffset+1, iOffset+iLen)
		elseif strType=="string" then
			value = bin:sub(iOffset+1, iOffset+iLen)
		else
			error("unknown type: "..strType.." in field "..strName)
		end
		header[strKey]=value
	end
	return header
end

-- unused
--[[
function headerToBin_test (tContent, tHeaderSpec)
	-- check for unknown field names
	local knownFields = {}
	local strKey
	for _, tFieldSpec in ipairs(tHeaderSpec) do
		strKey = tFieldSpec.name
		knownFields[strKey] = tContent[strKey]
	end
	if #tContent>0 then
		err_print("unknown fields in header content: ")
		for strKey, _ in pairs(tContent) do
			err_print(strKey)
		end
		return
	end

	-- convert the separate entries to binary
	local bin = ""
	local aBinElems = {}
	local aErrors = {}
	for _, tFieldSpec in ipairs(tHeaderSpec) do
		local strKey, iOffset, strType, defaultVal, iLen = 
			tFieldSpec.name, tFieldSpec.offset, tFieldSpec.type, tFieldSpec.default, tFieldSpec.size
		--print(strKey)
		
		local strVal, abVal, strError = knownFields[strKey] or defaultVal, nil, nil
		
		if strType=="uint32" then
			abVal, strError = uinttobin(strVal or 0, 32)
		elseif strType=="uint16" then
			abVal, strError = uinttobin(strVal or 0, 16)
		elseif strType=="uint8" then
			abVal, strError = uinttobin(strVal or 0, 8)
		elseif strType=="bin" then
			abVal = strVal or string.rep(string.char(0), iLen)
		elseif strType=="string" then
			abVal = strVal or ""
			if abVal:len()<iLen then
				abVal = abVal ..  string.rep(string.char(0), iLen - abVal:len())
			end
		else
			error("unknown type: "..strType.." for field "..strKey)
		end
		if abVal then
			aBinElems[iOffset] = abVal
		else
			error("could not construct binary value for field "..strKey)
		end
		if strError then
			aErrors[#aErrors+1] = {strKey, strError}
		end
	end
	
	if #aErrors > 0 then
		return nil, aErrors
	end
	
	-- combine the binary pieces to the header
	for iOffset=0, table.maxn(aBinElems) do
		if aBinElems[iOffset] then
			if bin:len()<iOffset then
				bin = bin .. string.rep(string.char(0), iOffset-bin:len())
			elseif bin:len()>iOffset then
				error("overlapping fields in header spec!")
			end
			bin = bin .. aBinElems[iOffset]
		end
	end
	
	vbs_printf("header len: %d", bin:len())
	if isvbs_debug() then
		utils.printHex(bin, "0x%04x ", 16, true)
	end
	if #aErrors > 0 then
		return nil, aErrors
	else 
		return bin, aErrors
	end
end
--]]
 
-- the fields header description must be ordered by offset, and
-- must exactly cover the entire byte range of the header.
function headerToBin(tContent, tHeaderSpec)
	-- check for unknown field names
	local knownFields = {}
	local strKey
	for _, tFieldSpec in ipairs(tHeaderSpec) do
		strKey = tFieldSpec.name
		knownFields[strKey] = tContent[strKey]
	end
	if #tContent>0 then
		err_print("unknown fields in header content: ")
		for strKey, _ in pairs(tContent) do
			err_print(strKey)
		end
		return
	end

	-- build the binary
	local bin = ""
	local aErrors = {}
	for _, tFieldSpec in ipairs(tHeaderSpec) do
		local strKey, iOffset, strType, defaultVal, iLen = 
			tFieldSpec.name, tFieldSpec.offset, tFieldSpec.type, tFieldSpec.default, tFieldSpec.size
		--print(strKey)
		
		local strVal, abVal, strError = knownFields[strKey] or defaultVal, nil, nil
		
		if strType=="uint32" then
			abVal, strError = uinttobin(strVal or 0, 32)
		elseif strType=="uint16" then
			abVal, strError = uinttobin(strVal or 0, 16)
		elseif strType=="uint8" then
			abVal, strError = uinttobin(strVal or 0, 8)
		elseif strType=="bin" then
			abVal = strVal or string.rep(string.char(0), iLen)
		elseif strType=="string" then
			abVal = strVal or ""
			if abVal:len()<iLen then
				abVal = abVal ..  string.rep(string.char(0), iLen - abVal:len())
			end
		else
			error("unknown type: "..strType.." for field "..strKey)
		end
		if abVal then
			bin = bin .. abVal
		else
			error("could not construct binary value for field "..strKey)
		end
		if strError then
			aErrors[#aErrors+1] = {strKey, strError}
		end
	end
	dbg_printf("header len: %d", bin:len())
	if isvbs_debug() then
		utils.printHex(bin, "0x%04x ", 16, true)
	end
	if #aErrors > 0 then
		return nil, aErrors
	else 
		return bin, aErrors
	end
end


function printHeader(tContent, tHeaderSpec)
	local strKey, val
	for _, tFieldSpec in ipairs(tHeaderSpec) do
		strKey = tFieldSpec.name
		val = tContent[strKey]
		if type(val)=="number" then
			print(string.format("%-20s: 0x%08x", strKey, val))
		elseif type(val)=="string" then
			print(string.format("%-20s: %s", strKey, utils.hexString(val)))
		elseif type(val)=="nil" then
			print(string.format("%-20s: no value", strKey))
		end
	end
end


-- make a "flat" copy of a header
function copyHeader(tHeader) 
	local copy={}
	for k,v in pairs(tHeader) do
		copy[k] = v
	end
	return copy
end


function makeEmptyDefaultHeader()
	return binToHeader(string.rep(string.char(0), DEFAULT_HEADER_SIZE), DEFAULT_HEADER_SPEC)
end

function makeEmptyCommonHeader()
	return binToHeader(string.rep(string.char(0), COMMON_HEADER_V3_SIZE), COMMON_HEADER_V3_SPEC)
end



-- calculates MD5 over the concatenation of all arguments (must be strings)
-- returns MD5 as 16 byte string
function calcMD5(...)
	return calcMHash(mhash.MHASH_MD5, ...)
end

-- calculates CRC32B over the concatenation of all arguments (must be strings)
-- returns checksum as 32 bit uint
function calcCRC32B(...)
	local hash = calcMHash(mhash.MHASH_CRC32B, ...)
	vbs_printf("CRC32B: %02x %02x %02x %02x", hash:byte(1), hash:byte(2), hash:byte(3), hash:byte(4))
	return hash:byte(1) + 256 * hash:byte(2) + 65536 * hash:byte(3) + 0x1000000 * hash:byte(4)
end

function calcAppChecksum(...)
	local hash = calcMHash(mhash.MHASH_HILROM, ...)
	vbs_printf("app checksum: %02x %02x %02x %02x", hash:byte(1), hash:byte(2), hash:byte(3), hash:byte(4))
	return hash:byte(1) + 256 * hash:byte(2) + 65536 * hash:byte(3) + 0x1000000 * hash:byte(4)
end

function calcBootblockChecksum(abBootblock)
	local hash = calcMHash(mhash.MHASH_HILROMI, abBootblock:sub(1, 60))
	vbs_printf("bootblock checksum: %02x %02x %02x %02x", hash:byte(1), hash:byte(2), hash:byte(3), hash:byte(4))
	return hash:byte(1) + 256 * hash:byte(2) + 65536 * hash:byte(3) + 0x1000000 * hash:byte(4)
end

function calcSHA384(abChunk) 
	local hash = calcMHash(mhash.MHASH_SHA384, abChunk)
	vbs_printf("chunk checksum: %02x %02x %02x %02x", hash:byte(1), hash:byte(2), hash:byte(3), hash:byte(4))
	return hash
end


-- calculates hash over the concatenation of varargs (must be strings)
-- returns hash as a string
function calcMHash(hash_id, ...)
	local l = {...}
	local mh = mhash.mhash_state()
	mh:init(hash_id)
	for i = 1, table.maxn(l) do
		if not l[i] then
			error("nil at position " .. i)
		elseif type(l[i])~="string" then
			error("invalid hash data at pos " .. i)
		end
		mh:hash(l[i]) 
	end
	return mh:hash_end()
end

-- Update the checksums in boot header and common header V3.
-- boot/default header and common header must be in list form according to 
-- the definitions in this file, common header must be V3.
-- 0) set all checksums to 0
-- 1) calculate and set MD5 over everything starting from the boot/default header
-- 2) calculate and set CRC32B over boot header and common header
-- 3) calculate and set application checksum over everything following the boot header
-- 4) calculate and set boot header checksum


function updateChecksums(tDefaultHeader, tCommonHeader, ...)
	if isChecksumBootHeader(tDefaultHeader) then
		tDefaultHeader.ulAppChecksum = 0
		tDefaultHeader.ulBootHeaderChecksum = 0
	end
	tCommonHeader.aulMD5 = nil
	tCommonHeader.ulHeaderCRC32 = 0
	
	-- MD5
	local abDefaultHeader = headerToBin(tDefaultHeader, DEFAULT_HEADER_SPEC)
	local abCommonHeader = headerToBin(tCommonHeader, COMMON_HEADER_V3_SPEC)
	tCommonHeader.aulMD5 = calcMD5(abDefaultHeader, abCommonHeader, ...)
	
	-- common header CRC32B
	abCommonHeader = headerToBin(tCommonHeader, COMMON_HEADER_V3_SPEC)
	tCommonHeader.ulHeaderCRC32 = calcCRC32B(abDefaultHeader, abCommonHeader)
	abCommonHeader = headerToBin(tCommonHeader, COMMON_HEADER_V3_SPEC)

	-- appChecksum and bootheader checksum
	if isChecksumBootHeader(tDefaultHeader) then
		tDefaultHeader.ulAppChecksum = calcAppChecksum(abCommonHeader, ...)
		abDefaultHeader = headerToBin(tDefaultHeader, DEFAULT_HEADER_SPEC)
		tDefaultHeader.ulBootHeaderChecksum = calcBootblockChecksum(abDefaultHeader)
	end
end


-- checks conditions that hold on both a freshly compiled
-- and a valid common header V3:
-- the following fields should always be set:
-- ulHeaderVersion, ulHeaderLength, ulDataStartOffset, bNumModuleInfos 
--
-- the following conditions should always hold:
-- major header version = 3
-- 0<=bNumModuleInfos<=6
-- sizeof (Default header) + sizeof (common header v3) + sizeof (device info)
--     + bNumModuleInfos * sizeof(module info)
--  <= ulHeaderLength
--  <= fileSize
--
-- parameters: 
-- tCommonHeader list representation of common header V3
-- iFileSize: file size including default header, may have to add 64 (optional)
function isCommonHeaderV3(tCommonHeader, iFileSize)
	return 
		bit.band(tCommonHeader.ulHeaderVersion, COMMON_HEADER_MAJOR_VERSION_MASK)
		== HIL_FILE_COMMON_HEADER_VERSION_3 
		and
		tCommonHeader.ulHeaderLength >=
		DEFAULT_HEADER_SIZE + COMMON_HEADER_V3_SIZE + DEVICE_INFO_V1_SIZE + 
		tCommonHeader.bNumModuleInfos * MODULE_INFO_V1_SIZE
		and
		(not iFileSize or tCommonHeader.ulHeaderLength <= iFileSize)
		and 
		tCommonHeader.bNumModuleInfos >= 0
		and 
		tCommonHeader.bNumModuleInfos <= 6
end

function isDeviceHeaderV1(devHdr)
	local tDevHdr, abDevHdr
	if type(devHdr)=="table" then
		tDevHdr = devHdr
	elseif type(devHdr)=="string" then
		abDevHdr = devHdr
		tDevHdr = binToHeader(devHdr, DEVICE_INFO_SPEC)
	end
	
	if abDevHdr and abDevHdr:len() ~= DEVICE_INFO_V1_SIZE then
		return false, string.format("Wrong length: %d, expected: %d", 
			abDevHdr:len(), DEVICE_INFO_V1_SIZE)
	elseif not tDevHdr then
		return false, "No data"
	elseif tDevHdr.ulStructVersion ~= HIL_VERSION_DEVICE_INFO_V1_0 then
		return false, string.format("Wrong header version: %08x, expected: %08x", 
			tDevHdr.ulStructVersion, HIL_VERSION_DEVICE_INFO_V1_0)
	else
		return true
	end
end

-- check if header binary contains a raw (unfilled) 
-- common header V3, Device info and n * module info
-- abBin: header binary
-- returns true or false and an error message
-- used by NXO editor

-- common Header Major Version = 3
-- 0 <= bNumModuleInfos <= 6
-- ulHeaderLength = DEFAULT_HEADER_SIZE + file size
-- ulHeaderLength = 
--   DEFAULT_HEADER_SIZE + COMMON_HEADER_V3_SIZE + DEVICE_INFO_V1_SIZE + 
--   bNumModuleInfos * MODULE_INFO_V1_SIZE 


function isUnfilledHeadersBin(abBin)
	if abBin:len() < COMMON_HEADER_V3_SIZE then
		return false, "Incorrect file size (file too short)"
	end
	
	local tCommonHeader = binToHeader(abBin, COMMON_HEADER_V3_SPEC)
	if not isCommonHeaderV3(tCommonHeader, DEFAULT_HEADER_SIZE + abBin:len()) then
		return false, "File does not start with a common header V3"
	end
	
	if abBin:len() ~= 
			COMMON_HEADER_V3_SIZE + 
			DEVICE_INFO_V1_SIZE + 
			tCommonHeader.bNumModuleInfos * MODULE_INFO_V1_SIZE then
		return false, "Incorrect file size"
	end
	
	return true
end

-- unused 
function checkBootHeaderChecksums(tBootBlock, ...)
	local fOk, msgs = true, {}
	local tBB = copyHeader(tBootBlock)
	tBB.ulAppChecksum = calcAppChecksum(...)
	local abBootHeader = headerToBin(tBootHeader, BOOT_HEADER_SPEC)
	tBB.ulBootHeaderChecksum = calcBootblockChecksum(abDefaultHeader)
	if tBootBlock.ulAppChecksum ~= tBB.ulAppChecksum then
		fOk = false
		table.insert(msgs, "Incorrect application checksum")
	end
	if tBootBlock.ulBootHeaderChecksum ~= tBB.ulBootHeaderChecksum then
		fOk = false
		table.insert(msgs, "Incorrect boot header checksum")
	end
end

-- unused
-- extend this to check the bootblock checksums, too?
function checkCommonHeaderChecksums(tBootBlock, tCommonHeader, ...)
	local tBB = copyHeader(tBootBlock)
	local tCH = copyHeader(tCommonHeader)
	updateChecksums(tBB, tCH, ...)
	if vbs_isverbose() then
		printHeader(tBootBlock, DEFAULT_HEADER_SPEC)
		printHeader(tBB, DEFAULT_HEADER_SPEC)
		printHeader(tCommonHeader, COMMON_HEADER_V3_SPEC)
		printHeader(tCH, COMMON_HEADER_V3_SPEC)
	end
	local errors = {}
	if tCH.aulMD5 ~= tCommonHeader.aulMD5 then
		table.insert(errors, "incorrect MD5")
	end
	if tCH.ulHeaderCRC32 ~= tCommonHeader.ulHeaderCRC32 then
		table.insert(errors, "incorrect CRC")
	end
	if #errors==0 then
		return true
	else
		return false, errors
	end
end


-- Tests for a valid Common header V3:
--
-- ulHeaderVersion		== predefined value
-- ulHeaderLength		<= file size
--  ()bNumModuleInfos		*sizeof(moduleinfo) + sizeof(default header) + sizeof(common header) + sizeof (firmware header) <= headerLength
--
-- ulDataSize			dataStartOffset + dataSize <= file size
-- ulDataStartOffset	>= headerLength, <= file size
--
-- ulTagListSize		tagListOffset + tagListSize <= file size
-- ulTagListStartOffset	>= headerLength, <= file size
--
-- aulMD5				ok
-- ulHeaderCRC32		ok
--
-- Parameters:
-- tBB, tCH: boot and common header
-- ... remaining binary parts

-- unused
function isValidCommonHeaderV3(tBB, tCH, ...)
	local parts = {...}
	local iTotalLen = DEFAULT_HEADER_SIZE+COMMON_HEADER_V3_SIZE
	for i=1, #parts do
		iTotalLen = iTotalLen + parts[i]:len()
	end
	
	-- header version/length
	local fOk = isCommonHeaderV3(tCH, iTotalLen)
	if not fOk then
		return false, {"Common Header V3 not found"}
	end
	
	-- MD5/CRC
	fOk, errors = checkCommonHeaderChecksums(tBB, tCH, ...)
	if not fOk then
		return false, errors
	end
	
	-- dataSize/dataStartOffset
	if tCH.ulDataStartOffset + tCH.ulDataSize > iTotalLen then
		return false, {"ulDataStartOffset > file size"}
	elseif tCH.ulDataStartOffset < tCH.ulHeaderLength then
		return false, {"ulDataStartOffset < ulHeaderLength"}
	elseif tCH.ulTagListStartOffset + tCH.ulTagListSize > iTotalLen then
		return false, {"ulTagListStartOffset > file size"}
	elseif tCH.ulTagListStartOffset < tCH.ulHeaderLength then
		return false, {"ulTagListStartOffset < ulHeaderLength"}
	end
	
	return true
end


-- build an NXF file, used by bootblocker
--
-- abBootblock: boot header
-- abImage: a common header v3 followed by other headers and firmware
-- abTaglist: taglist binary, may be nil
--
-- common header V3 must at least contain 
-- ulHeaderVersion, ulHeaderLength, ulDataStartOffset, bNumModuleInfos 


-- If the tag list is included in the image, all fields except
-- the checksums must already have been set to their correct values in
-- the ELF file. In this case, skip the next line.
-- If the tag list is NOT included in the image, ulDataSize must be 0.
-- 
-- image is padded up to dword size
-- common header and checksums are updated
-- does not set ulTagListSizeMax

-- Common Header fields:  calculated by compiler/linker/bootblocker
---------------------------------------------------------------------
-- ulHeaderVersion     -- by compiler/linker
-- ulHeaderLength      -- by compiler/linker
-- ulDataSize          -- by bootblocker if 0
-- ulDataStartOffset   -- by compiler/linker
-- bNumModuleInfos     -- by compiler/linker
-- bReserved1          
-- usReserved2         
-- aulMD5              -- by bootblocker
-- ulTagListSize       -- by bootblocker if external tag list is specified
-- ulTagListStartOffset-- by bootblocker if external tag list is specified
-- ulTagListSizeMax    -- by compiler/linker
-- ulResrved3          
-- ulResrved4          
-- ulResrved5          
-- ulHeaderCRC32       -- by bootblocker


function makeNXF(abBootBlock, abImage, abTaglist)
	dbg_print("makenxf")
	local abCommonHeader = abImage:sub(1, COMMON_HEADER_V3_SIZE)
	local tCommonHeader = binToHeader(abCommonHeader, COMMON_HEADER_V3_SPEC)
	local abDataPad
	
	if not isCommonHeaderV3(tCommonHeader) then
		return false, "Common header V3 not found"
	end
	
	local abData = abImage:sub(COMMON_HEADER_V3_SIZE+1)
	
	-- set ulDataSize if it's 0
	if tCommonHeader.ulDataSize == 0 then
		tCommonHeader.ulDataSize = DEFAULT_HEADER_SIZE + abImage:len() - tCommonHeader.ulDataStartOffset
	end
	
	-- append tag list and update ulTagListStartOffset/Size
	-- pad data to dword size
	if abTaglist then
		tCommonHeader.ulTagListSize = abTaglist:len()
		local ulTagListOffset = DEFAULT_HEADER_SIZE + abImage:len()
		local iDataPad = (4 - ulTagListOffset) % 4
		abDataPad = string.rep(string.char(0), iDataPad)
		ulTagListOffset = ulTagListOffset + iDataPad
		tCommonHeader.ulTagListStartOffset = ulTagListOffset
	end
	
	-- update checksums
	local tBootBlock = binToHeader(abBootBlock, DEFAULT_HEADER_SPEC)
	assert(tBootBlock.ulMagicCookie ~= 0)
	updateChecksums(tBootBlock, tCommonHeader, abData, abDataPad, abTaglist)
	
	-- build binary
	abBootBlock = headerToBin(tBootBlock, DEFAULT_HEADER_SPEC)
	abCommonHeader = headerToBin(tCommonHeader, COMMON_HEADER_V3_SPEC)
	
	local abNXF = abBootBlock .. abCommonHeader .. abData
	if abTaglist then
		abNXF = abNXF .. abDataPad .. abTaglist
	end
	return abNXF
end



-- Parse contents of an nx* file consisting of
--   boot/default header, 
--   common header, 
--   additional headers (optional), 
--   data, 
--   tag list (optional)

-- Return values:
--   true/false indicating success
--   error/warning messages
--   boot/default header, common header (as list)
--   additional headers, gap behind headers
--   data, gap behind data
--   tag list, gap behind tag list (as string)

function parseNXFile(abBin)
	local msgs = {}
	local iBinSize = abBin:len()

	local FILELAYOUT_DATA_TAGS = 1
	local FILELAYOUT_TAGS_DATA = 2
	local FILELAYOUT_DATA = 3
	local filelayout
	
	-- if file size is too small for a boot header + common header, exit

	if iBinSize < DEFAULT_HEADER_SIZE + COMMON_HEADER_V3_SIZE then
		return false, {"The file is too small."}
	end
	
	-- extract boot/default header and common header
	
	local abBootHeader = abBin:sub(1, DEFAULT_HEADER_SIZE)
	local abCommonHeader = abBin:sub(DEFAULT_HEADER_SIZE+1, DEFAULT_HEADER_SIZE+COMMON_HEADER_V3_SIZE)
	local abRest = abBin:sub(DEFAULT_HEADER_SIZE+COMMON_HEADER_V3_SIZE+1)
	-- todo: replace with a printable boot header spec
	local tBB = binToHeader(abBootHeader, DEFAULT_HEADER_SPEC)
	local tCH = binToHeader(abCommonHeader, COMMON_HEADER_V3_SPEC)

	if isvbs_verbose() then
		print("Boot/Default Header:")
		printHeader(tBB, DEFAULT_HEADER_SPEC)
		print("Common Header:")
		printHeader(tCH, COMMON_HEADER_V3_SPEC)
	end
	-- identify boot/default header, warn if unknown

	if not(isBootOrDefaultHeader(tBB)) then
		table.insert(msgs, string.format(
			"Unknown cookie or no netX signature in boot/default header: 0x%08x/0x%08x",
			tBB.ulMagicCookie, tBB.ulSignature))
		return false, msgs
	end
	
	-- TODO: insert a common header check? isCommonHeaderV3
	-- suggestion: 
	-- if Common header V3.0 is found -> ok
	-- if Common header V3.x is found -> warn
	-- otherwise reject the file           
	
	-- check common header version, reject file if major version is <3.0, warn if >3.0
	local usCHMajorVer, usCHMinorVer = getCommonHeaderVersion(tCH)
	if usCHMajorVer < 3 then
		table.insert(msgs, string.format(
			"This tool cannot handle common headers below version 3. "..
			"This header is version %d.%d.", usCHMajorVer, usCHMinorVer))
		return false, msgs
	elseif usCHMajorVer > 3 or usCHMinorVer > 0 then
		table.insert(msgs, string.format(
			"This tool was written for common header version 3.0 "..
			"This header is version %d.%d.", usCHMajorVer, usCHMinorVer))
	end
	
	-- Split the file into its parts. 
	-- Check if any sections overlap or size indications exceed the file.
	-- In these cases, reject the file.
	-- Offsets are 1-based
	
	local abHeaders, abHeaderGap, abData, abDataGap, abTags, abTagGap
	local headerStart = DEFAULT_HEADER_SIZE+COMMON_HEADER_V3_SIZE + 1
	local headerEnd = tCH.ulHeaderLength
	local dataStart = tCH.ulDataStartOffset + 1
	local dataEnd = tCH.ulDataStartOffset + tCH.ulDataSize
	local tagStart = tCH.ulTagListStartOffset + 1
	local tagEnd = tCH.ulTagListStartOffset + tCH.ulTagListSize
	local fileEnd = iBinSize
	-- headers, data, tags
	if headerStart < headerEnd and headerEnd < dataStart and dataEnd < tagStart and tagEnd <= fileEnd then
		filelayout    = FILELAYOUT_DATA_TAGS
		abHeaders     = abBin:sub(headerStart, headerEnd)
		abHeaderGap   = abBin:sub(headerEnd + 1, dataStart - 1)
		abData        = abBin:sub(dataStart, dataEnd)
		abDataGap     = abBin:sub(dataEnd + 1, tagStart - 1)
		abTags        = abBin:sub(tagStart, tagEnd)
		abTagGap      = abBin:sub(tagEnd + 1, fileEnd)
	-- headers, tags, data
	elseif headerStart < headerEnd and headerEnd < tagStart and tagEnd < dataStart and dataEnd <= fileEnd then
		filelayout    = FILELAYOUT_TAGS_DATA
		abHeaders     = abBin:sub(headerStart, headerEnd)
		abHeaderGap   = abBin:sub(headerEnd + 1, tagStart - 1)
		abTags        = abBin:sub(tagStart, tagEnd)
		abTagGap      = abBin:sub(tagEnd + 1, dataStart - 1)
		abData        = abBin:sub(dataStart, dataEnd)
		abDataGap     = abBin:sub(dataEnd + 1, fileEnd)
	-- headers, data
	elseif tCH.ulTagListSize == 0 and headerStart < headerEnd and headerEnd < dataStart and dataEnd <= fileEnd then
		filelayout    = FILELAYOUT_DATA
		abHeaders     = abBin:sub(headerStart, headerEnd)
		abHeaderGap   = abBin:sub(headerEnd + 1, dataStart - 1)
		abData        = abBin:sub(dataStart, dataEnd)
		abDataGap     = abBin:sub(dataEnd + 1, fileEnd)
		abTags        = ""
		abTagGap      = ""
	else
		table.insert(msgs, "Inconsistent offset/size entries in common header")
		return false, msgs
	end
	
	if isNxiBootHeader(tBB) then
        print("NXI boot header")
        local fOk, strMsg
        fOk, abTags, strMsg = nxi_get_taglist(abBin)
        print("fOk: ", fOk, "abTags.len", abTags:len(), "strMsg:", strMsg)
        if strMsg then
            table.insert(msgs, strMsg)
        end
        if not fOk then
            return false, msgs
        end
	end
	
	-- warn if the file contains gap data
	local strSections = ""
	if abHeaderGap:len()>0 then
		strSections = strSections .. "Headers "
	end
	if abDataGap:len()>0 then
		strSections = strSections .. "Data/ELF "
	end
	if abTagGap:len()>0 and filelayout ~= FILELAYOUT_TAGS_DATA then
		strSections = strSections .. "Tag list "
	end
	if strSections:len()>0 then
		table.insert(msgs, 
		"The file contains a gap behind the the following section(s):\n" ..
		strSections.."\n" ..
		"This gap data will be kept intact as long as you only edit the tag list,\n" ..
		"but it will be discarded if you replace the section(s).")
	end
	
	-- check checksums, warn on errors
	local ulAppChecksum = tBB.ulAppChecksum
	local ulBootHeaderChecksum = tBB.ulBootHeaderChecksum
	local aulMD5 = tCH.aulMD5
	local ulHeaderCRC32 = tCH.ulHeaderCRC32
	updateChecksums(tBB, tCH, abRest)
	if isChecksumBootHeader(tBB) then
		if ulAppChecksum ~= tBB.ulAppChecksum then
			table.insert(msgs, "Incorrect application checksum")
		end
		if ulBootHeaderChecksum ~= tBB.ulBootHeaderChecksum then
			table.insert(msgs, "Incorrect boot header checksum")
		end
	end
	if aulMD5 ~= tCH.aulMD5 then
		table.insert(msgs, "Incorrect MD5 checksum")
	end
	if ulHeaderCRC32 ~= tCH.ulHeaderCRC32 then
		table.insert(msgs, "Incorrect common header checksum")
	end
	
	return true, msgs, tBB, tCH, abHeaders, abHeaderGap, abData, abDataGap, abTags, abTagGap
end


-- 
function makeNXFile(tBootBlock, tCH, abHeaders, abHeaderGap, abData, abDataGap, abTags, abTagGap)
	if tBootBlock.ulMagicCookie == 0 then
		return nil, {"No cookie in default/boot header"}
	end

	abHeaders = abHeaders or ""
	abHeadersGap = abHeadersGap or ""
	abData = abData or ""
	abDataGap = abDataGap or ""
	abTags = abTags or ""
	abTagGap = abTagGap or ""
	local abBin 
	
	if abTags and abTags:len() > 0 then
		-- tag list in front of data
		if tCH.ulTagListStartOffset > 0 and tCH.ulTagListStartOffset < tCH.ulDataStartOffset then
			tCH.ulHeaderLength = DEFAULT_HEADER_SIZE + COMMON_HEADER_V3_SIZE + abHeaders:len()
			tCH.ulTagListStartOffset = tCH.ulHeaderLength + abHeaderGap:len()
			tCH.ulTagListSize = abTags:len()
			tCH.ulDataStartOffset = tCH.ulTagListStartOffset + tCH.ulTagListSize + abTagGap:len()
			tCH.ulDataSize = abData:len()
			abBin = abHeaders .. abHeaderGap .. abTags .. abTagGap .. abData .. abDataGap
		else
		-- tag list behind data
			tCH.ulHeaderLength = DEFAULT_HEADER_SIZE + COMMON_HEADER_V3_SIZE + abHeaders:len()
			tCH.ulDataStartOffset = tCH.ulHeaderLength + abHeaderGap:len()
			tCH.ulDataSize = abData:len()
			tCH.ulTagListStartOffset = tCH.ulDataStartOffset + tCH.ulDataSize + abDataGap:len()
			tCH.ulTagListSize = abTags:len()
			abBin = abHeaders .. abHeaderGap .. abData .. abDataGap .. abTags .. abTagGap
		end
	else
	-- no tag list
		tCH.ulHeaderLength = DEFAULT_HEADER_SIZE + COMMON_HEADER_V3_SIZE + abHeaders:len()
		tCH.ulDataStartOffset = tCH.ulHeaderLength + abHeaderGap:len()
		tCH.ulDataSize = abData:len()
		-- keep the old value if no taglist
		-- tCH.ulTagListStartOffset = 0
		tCH.ulTagListSize = 0
		abBin = abHeaders .. abHeaderGap .. abData .. abDataGap
	end
	
	if isChecksumBootHeader(tBootBlock) then
		tBootBlock.ulAppFileSize = (COMMON_HEADER_V3_SIZE + abBin:len()) / 4
	end

	updateChecksums(tBootBlock, tCH, abBin)
	abDefaultHeader = headerToBin(tBootBlock, DEFAULT_HEADER_SPEC)
	abCommonHeader = headerToBin(tCH, COMMON_HEADER_V3_SPEC)
	return abDefaultHeader .. abCommonHeader .. abBin, {}
end



function makeNXIFile(tBootBlock, tCH, abHeaders, abHeaderGap, abData, abDataGap, abTags, abTagGap)
    assert(abTagGap == "")
    local abBin = abHeaders .. abHeaderGap .. abData .. abDataGap
    assert(abBin)
    abBin = nxi_replace_taglist(abBin, abTags)
    assert(abBin)
    updateChecksums(tBootBlock, tCH, abBin)
    local abDefaultHeader = headerToBin(tBootBlock, DEFAULT_HEADER_SPEC)
    local abCommonHeader = headerToBin(tCH, COMMON_HEADER_V3_SPEC)
    abBin = abDefaultHeader .. abCommonHeader .. abBin
    
    return abBin, {}
end




-- Search a binary containing a list of HBoot chunks for a tag list.
-- 
-- ulStartPos is 0x200 to search in the complete binary including boot and common header,
-- or 0x180 when the boot and common headers have been removed.
--
-- netX 90:
-- 0-3     TEXT chunk ID
-- 4-7     chunk size (remaining size in dwords)
-- 8-15    TagList> tag list identifier/delimiter
-- 16-17   size of tag list including delimiters
-- 18-19   size of tag list contents (actual tags)
-- 20-     tag list contents 
-- 4 bytes 0x00 (reserved)
-- 8 bytes <TagList delimiter 
-- 4 bytes Chunk checksum 

-- netX 4000:
-- 0-3     DATA chunk ID
-- 4-7     chunk size (remaining size in dwords)
-- 8-11    load address
-- 12-19   TagList> tag list identifier/delimiter
-- 20-21   size of tag list including delimiters
-- 22-23   size of tag list contents (actual tags)
-- 24-     tag list contents 
-- 4 bytes 0x00 (reserved)
-- 8 bytes <TagList delimiter 
-- 4 bytes Chunk checksum 

-- 24 is the min. overhead of the structure wrapping the tag list 

function nxi_find_taglist(abBin, ulStartPos)
    local ulChunkPos = ulStartPos
    local iSize = abBin:len()
    local tRes = {}
    local fFound = false
    
    dbg_print("Searching HBoot image chunks for tag list")
    while fFound == false and ulChunkPos + 24 < iSize do
        -- Get the chunk type and size.
        local strChunkType = abBin:sub(ulChunkPos+1, ulChunkPos+4)
        local b1, b2, b3, b4 = abBin:byte(ulChunkPos+5, ulChunkPos+8)
        local ulChunkSizeDword = 2+b1+0x100*b2+0x10000*b3+0x1000000*b4
        local ulChunkSizeBytes = 4*ulChunkSizeDword
        local ulMarkerOffset = nil
        
        dbg_printf("Offset: 0x%08x, chunk: %s", ulChunkPos, strChunkType)
        
        -- Get the offset at which the marker should be expected.
        if "TEXT" == strChunkType then
            ulMarkerOffset = 8
        elseif "DATA" == strChunkType then
            ulMarkerOffset = 12
        end
        
        -- Check if the marker is present.
        if ulMarkerOffset then
            local strMarker = abBin:sub(ulChunkPos+ulMarkerOffset+1, ulChunkPos+ulMarkerOffset+8)
            if "TagList>" == strMarker then
                fFound = true
                tRes.ulChunkPos = ulChunkPos
                tRes.strChunkType = strChunkType
                tRes.ulChunkSizeBytes = ulChunkSizeBytes
                
                -- Offset of the length fields in the chunk.
                -- The tag list is behind the length fields.
                tRes.ulTagListOffset = ulMarkerOffset+8
                
                -- b1/b2: taglist size: from header to footer
                -- b3/b4: content size: only the actual tags
                local b1, b2, b3, b4 = abBin:byte(ulChunkPos+tRes.ulTagListOffset+1, ulChunkPos+tRes.ulTagListOffset+4)
                tRes.ulTagListSize = b1+0x100*b2
                tRes.ulContentSize = b3+0x100*b4
                
                dbg_printf("Found tag list:")
                dbg_printf("Chunk at offset 0x%08x  size 0x%08x  type %s", 
                    ulChunkPos, ulChunkSizeBytes, strChunkType)
                dbg_printf("Tag list offset: 0x%08x  total size: 0x%08x content size: 0x%08x", 
                    tRes.ulTagListOffset, tRes.ulTagListSize, tRes.ulContentSize)
                
            end
        end
        
        ulChunkPos = ulChunkPos + ulChunkSizeBytes
    end
    
    if fFound then
        return tRes
    else 
        dbg_print("No tag list found")
        return nil
    end
end



-- Find Text/data chunk with tag list header 
-- Check chunk checksum  (Warning if not correct)
-- Get tag list/content size 
-- Check for consistency (Error if not correct)
-- Check presence of tag list footer (Error if not correct)

-- Returns:
-- true, tag list binary, optional warning message
-- true, "",              optional warning message: no tag list found 
-- false, nil,            error message
function nxi_get_taglist(abBin)
    local fOk = true
    local strTagList = ""
    local strMsg = nil
    
    local tRes = nxi_find_taglist(abBin, 0x200)
    if tRes then
        
        local abChunk = abBin:sub(tRes.ulChunkPos+1, tRes.ulChunkPos+tRes.ulChunkSizeBytes)
        local abChunkHash =  abChunk:sub(-4)
        local abChunkData = abChunk:sub(1, -5)
        local abNewHash = calcSHA384(abChunkData)
        abNewHash = abNewHash:sub(1, 4)
        if abChunkHash ~= abNewHash then
            -- Warning: chunk hashsum not ok
            print("Chunk hash incorrect")
            strMsg = "Incorrect chunk hashsum"
        else
            dbg_print("Chunk hash ok")
        end
        
        -- ulTagListSize = ulContentSize + wrapping elements:
        -- Header            8 bytes
        -- size fields       4 bytes
        -- reserved field    4 bytes
        -- Footer            8 bytes 
        if tRes.ulTagListSize ~= tRes.ulContentSize+ 0x18 then
            fOk = false
            strMsg = "Tag list size and content size are inconsistent"
        else
            local ulFooterOffset = tRes.ulTagListOffset+4+tRes.ulContentSize+4
            if ulFooterOffset+8 > tRes.ulChunkSizeBytes then
                fOk = false
                strMsg = "Incorrect size field in tag list"
            else
                local strFooter = abChunk:sub(ulFooterOffset+1, ulFooterOffset+8)
                if strFooter ~= "<TagList" then
                    fOk = false
                    strMsg = "Tag list footer not found"
                else 
                    strTagList = abChunk:sub(tRes.ulTagListOffset+ 4 + 1, tRes.ulTagListOffset + 4 + tRes.ulContentSize)
                end
            end
        end
    else 
        dbg_print("No tag list found")
    end
    
    return fOk, strTagList, strMsg
end


-- replace the tag list an NXI image.
function nxi_replace_taglist(abBin, abNewTagList)
    local tRes = nxi_find_taglist(abBin, 0x180)
    if tRes then
        -- separate the chunk containing the tag list
        local ulChunkPos = tRes.ulChunkPos
        local ulChunkSizeBytes = tRes.ulChunkSizeBytes 
        local abChunksBefore = abBin:sub(1, ulChunkPos)
        local abChunk = abBin:sub(ulChunkPos+1, ulChunkPos+ulChunkSizeBytes)
        local abChunksAfter = abBin:sub(ulChunkPos+ulChunkSizeBytes+1)
        
        -- construct a new chunk with the tag list replaced
        local ulTagListOffset = tRes.ulTagListOffset + 4
        local ulContentSize = tRes.ulContentSize
        
        assert(abNewTagList:len() == ulContentSize, "Length of new tag list differs!")
        
        local abBeforeTags = abChunk:sub(1, ulTagListOffset )
        local abAfterTags = abChunk:sub(ulTagListOffset + ulContentSize + 1)
        local abNewChunk = abBeforeTags ..abNewTagList .. abAfterTags

        -- update the chunk's checksum
        -- The checksum is a SHA384 of the entire chunk including the chunk type and size, except the checksum field.
        abNewChunk = abNewChunk:sub(1, -5)
        local abHash = calcSHA384(abNewChunk)
        abHash = abHash:sub(1, 4)
        abNewChunk = abNewChunk .. abHash
        
        -- construct a new image with the chunk replaced
        abBin = abChunksBefore .. abNewChunk .. abChunksAfter
        return abBin
    else
        return nil
    end
end
