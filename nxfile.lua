-- build, parse and maintain the contents of an NXO module file or an NXF file.
-- 
-- m_tDefaultHeader:   Boot or default header             0 ... 63
-- m_tCommonHeader:    Common header V3.0 or higher      64 ... 127
-- m_abOtherHeaders:   device header, module infos etc. 128 ... ulHeaderLength-1 
-- m_abHeaderGap:      ulHeaderLength                       ... ulDataStartOffset - 1
-- m_abData:           ulDataStartOffset                    ... ulDataStartOffset + ulDataSize - 1
-- m_abDataGap:        ulDataStartOffset + ulDataSize       ... ulTagListStartOffset - 1
-- m_abTaglist:        ulTagListStartOffset                 ... ulTagListStartOffset + ulTagListSize - 1
-- m_abTagGap:         ulTagListStartOffset + ulTagListSize ... fileEnd - 1

-- Note:
--    The offsets, sizes and checksums in the default/boot and common header 
--    are only updated when the file is written back, i.e. the headers may 
--    not be valid during editing.

module("nxfile", package.seeall)

require("netx_fileheader")

function new()
	local t = {}
	t.m_tDefaultHeader = netx_fileheader.makeEmptyDefaultHeader()
	t.m_tCommonHeader = netx_fileheader.makeEmptyCommonHeader()
	t.m_abOtherHeaders   = ""
	t.m_abHeaderGap      = ""
	t.m_abData           = ""
	t.m_abDataGap        = ""
	t.m_abTaglist        = ""
	t.m_abTagGap         = ""
	local mt = {__index=nxfile}
	setmetatable(t, mt)
	return t
end


function parseBin(self, abBin)
	local fOk, astrErrors, 
		tDefaultHeader, tCommonHeader, 
		abHeaders, abHeaderGap, abData, abDataGap, abTags, abTagGap
		= netx_fileheader.parseNXFile(abBin)
	if fOk then
		self.m_tDefaultHeader   = tDefaultHeader
		self.m_tCommonHeader    = tCommonHeader
		self.m_abOtherHeaders   = abHeaders
		self.m_abHeaderGap      = abHeaderGap
		self.m_abData           = abData
		self.m_abDataGap        = abDataGap
		self.m_abTaglist        = abTags
		self.m_abTagGap         = abTagGap
	end
	return fOk, astrErrors
end

-- returns binary/nil, messages
function buildNXFile(self)
	return netx_fileheader.makeNXFile(
		self.m_tDefaultHeader, self.m_tCommonHeader, self.m_abOtherHeaders, self.m_abHeaderGap,
		self.m_abData, self.m_abDataGap,
		self.m_abTaglist, self.m_abTagGap)
end


-- returns true if headers and data are present
function isComplete(self)
	return self:hasHeaders() and self:hasData()
end


-- returns a string to pad abBin to the next multiple of length
function getPadding(abBin, length)
	return string.rep(string.char(0), (length - abBin:len()) % length)
end

--------------------------------------------------------------------------
--                  Boot/default header and file type
--------------------------------------------------------------------------

function initNxo(self)
	self.m_tDefaultHeader = netx_fileheader.makeEmptyDefaultHeader()
	self.m_tDefaultHeader.ulMagicCookie = netx_fileheader.HIL_FILE_HEADER_OPTION_COOKIE
	self.m_tCommonHeader = netx_fileheader.makeEmptyCommonHeader()
end

function isNxo(self)
	return netx_fileheader.isNXODefaultHeader(self.m_tDefaultHeader)
end

function isNxf(self)
	return netx_fileheader.isBootHeader(self.m_tDefaultHeader)
end

-- returns "NXF", "NXO" etc.
function getHeaderType(self)
	return netx_fileheader.getHeaderType(self.m_tDefaultHeader)
end

--[[
-- get/set the boot/default header
-- todo: boot header spec containing all fields
function setBootHeader(self, abBin)
	local tBB = netx_fileheader.binToHeader(abCommonHeader, netx_fileheader.DEFAULT_HEADER_SPEC)
	self.m_tDefaultHeader = abBin
end

function getBootHeader(self)
	return self.m_tDefaultHeader
end

function hasBootHeader(self)
	return self.m_tDefaultHeader and true
end
--]]

--------------------------------------------------------------------------
--                 Common header and any following headers
--------------------------------------------------------------------------

-- Set a new header binary.
-- If ulTagListSizeMax is set, check it against the size of the currently loaded tag list.
-- sets common header V3, device info, and module infos; NOT the default header!
-- (as it is not contained in the file)

function setHeadersBin(self, abBin)
	abBin = abBin or ""
	local abCH = abBin:sub(1, netx_fileheader.COMMON_HEADER_V3_SIZE)
	local fOk = netx_fileheader.isUnfilledHeadersBin(abBin)
	
	if fOk then
		local tCH = netx_fileheader.binToHeader(abCH, netx_fileheader.COMMON_HEADER_V3_SPEC)
		local iTLSize = self.m_abTaglist and self.m_abTaglist:len() or 0
		if tCH.ulTagListSizeMax == 0 or tCH.ulTagListSizeMax >= iTLSize then
			self.m_tCommonHeader = tCH
			self.m_abOtherHeaders = abBin:sub(netx_fileheader.COMMON_HEADER_V3_SIZE+1)
			self.m_abHeaderGap = getPadding(abBin, 4)
			return true
		else
			return false, 
				"The tag list currently loaded is larger than allowed by\n"..
				"this header according to ulTagListSizeMax"
		end
	else
		return false, "The header binary is not valid."
	end
end


-- gets common header V3, device info, and module infos; NOT the default header!
function getHeadersBin(self)
	if self.m_tCommonHeader and self.m_abOtherHeaders then
		local abCH = netx_fileheader.headerToBin(self.m_tCommonHeader, netx_fileheader.COMMON_HEADER_V3_SPEC)
		return abCH .. self.m_abOtherHeaders
	end
end

function getCommonHeader(self)
	return self.m_tCommonHeader
end

-- returns true if common header V3, device info, and module infos are present
function hasHeaders(self)
	return self.m_tCommonHeader and self.m_abOtherHeaders and self.m_abOtherHeaders:len()>0 
end



-- if hasDeviceHeader()==true, replace the first len(device header) bytes
function setDeviceHeader(self, abBin)
	if self:hasDeviceHeader() then
		self.m_abOtherHeaders = abBin .. self.m_abOtherHeaders:sub(netx_fileheader.DEVICE_INFO_V1_SIZE + 1)
	end
end

-- if hasDeviceHeader()==true, returns the first len(device header) bytes
function getDeviceHeader(self)
	if self:hasDeviceHeader() then
		return self.m_abOtherHeaders:sub(1, netx_fileheader.DEVICE_INFO_V1_SIZE)
	end
end

-- we assume a device header is present if
-- headers are present
-- length is at least len(common header v3) + len(device header)
-- common header is V3
-- 
function hasDeviceHeader(self)
	if self.m_tCommonHeader and netx_fileheader.isCommonHeaderV3(self.m_tCommonHeader) and
		self.m_abOtherHeaders and
		-- todo: check headerLength in common header?
		self.m_abOtherHeaders:len() >= netx_fileheader.DEVICE_INFO_V1_SIZE then
		-- print("hasDeviceHeader->true")
		return true
	else
		-- print("hasDeviceHeader->false")
		return false, "Device header not found"
	end
end

function hasDeviceHeaderV1(self)
	local fOk, strMsg = self:hasDeviceHeader()
	if fOk then
		local abDevHdr = self:getDeviceHeader()
		-- print("abDevHdr = ", (abDevHdr and abDevHdr:len()) or "nil")
		return netx_fileheader.isDeviceHeaderV1(abDevHdr)
	else
		return fOk, strMsg
	end
end

--------------------------------------------------------------------------
--                         Data/ELF section
--------------------------------------------------------------------------

function setData(self, abBin)
	abBin = abBin or ""
	self.m_abData = abBin
	self.m_abDataGap = getPadding(abBin, 4)
end

function getData(self)
	return self.m_abData
end

function hasData(self)
	return self.m_abData and self.m_abData:len() > 0
end



--------------------------------------------------------------------------
--                          tag list
--------------------------------------------------------------------------


-- If the tag list is at the end of the file and ulTagListSizeMax is >0,
-- we only accept a tag list up to that size.
-- If ulTagListSizeMax is 0, we accept a tag list of any size.
-- Unless fKeepGap is set, the gap behind the tag list is replaced
-- with 0-3 alignment bytes.
--
-- If the tag list is located before the data, we only allow replacing
-- it with a tag list of exactly the same size, independent of
-- ulTagListSizeMax, and no alignment bytes are inserted.

function setTaglistBin(self, abBin, fKeepGap)
	abBin = abBin or ""
	local tCH = self.m_tCommonHeader
	-- no tag list or tag list at end of file
	if tCH.ulTagListStartOffset == 0 or tCH.ulTagListStartOffset > tCH.ulDataStartOffset then
		if tCH.ulTagListSizeMax == 0 or tCH.ulTagListSizeMax >= abBin:len() then
			self.m_abTaglist = abBin
			if not fKeepGap then
				self.m_abTagGap = getPadding(abBin, 4)
			end
			return true
		else
			return false, 
				"The tag list is longer than the size allowed by ulTagListSizeMax."
		end
	
	-- tag list before data section
	else
		if abBin:len()==self.m_abTaglist:len() then
			self.m_abTaglist = abBin
			return true
		else
			return false, 
				"The tag list is located before the data/ELF section.\n"..
				"It can only be replaced with one of exactly the same size."
		end
	end
end

function getTaglistBin(self)
	return self.m_abTaglist
end

function hasTaglist(self)
	return self.m_abTaglist and self.m_abTaglist:len() > 0
end
