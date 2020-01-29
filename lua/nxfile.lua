---------------------------------------------------------------------------
-- Copyright (C) Hilscher Gesellschaft für Systemautomation mbH
--
-- Description:
--   Routines for manipulating NXO/NXF files in Taglist editor
--
---------------------------------------------------------------------------

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
	t.m_abVectors        = ""
	t.m_tHBootHeader     = netx_fileheader.makeEmptyHBootHeader()
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

function showMessages(...)
	if not ... then return end

	local messages = {}
	for _, v in pairs({...}) do
		if #messages > 0 then
			table.insert(messages, "")
		end
		if type(v) == "string" and v:len()>0 then
			table.insert(messages, v)
		elseif type(v) == "table" then
			for _, str in pairs(v) do
				table.insert(messages, str)
			end
		end
	end

	for k,v in pairs(messages) do print(k,v) end
end

function parseBin(self, abBin)
	local fOk_ret, astrErrors_ret
	
	-- try to parse as an NAI file
	local fOk, astrErrors, abVectors, tHBootHeader, tDefaultHeader, tCommonHeader, abDevInfo, abRest = netx_fileheader.parseNAIFile(abBin)

	fOk_ret, astrErrors_ret = fOk, astrErrors
    
	if fOk then
		self.m_abVectors        = abVectors
		self.m_tHBootHeader     = tHBootHeader
		self.m_tDefaultHeader   = tDefaultHeader
		self.m_tCommonHeader    = tCommonHeader
		self.m_abOtherHeaders   = abDevInfo
		self.m_abHeaderGap      = ""
		self.m_abData           = abRest
		self.m_abDataGap        = ""
		self.m_abTaglist        = ""
		self.m_abTagGap         = ""
	else
		-- try to parse an NAE file
		local fOk, astrErrors, tHBootHeader, tDefaultHeader, tCommonHeader, abDevInfo, abRest = netx_fileheader.parseNAEFile(abBin)

		fOk_ret, astrErrors_ret = fOk, astrErrors
		if fOk then
			self.m_abVectors        = ""
			self.m_tHBootHeader     = tHBootHeader
			self.m_tDefaultHeader   = tDefaultHeader
			self.m_tCommonHeader    = tCommonHeader
			self.m_abOtherHeaders   = abDevInfo
			self.m_abHeaderGap      = ""
			self.m_abData           = abRest
			self.m_abDataGap        = ""
			self.m_abTaglist        = ""
			self.m_abTagGap         = ""
			
		else
			local fOk, astrErrors, 
				tDefaultHeader, tCommonHeader, 
				abHeaders, abHeaderGap, abData, abDataGap, abTags, abTagGap
				= netx_fileheader.parseNXFile(abBin)

			fOk_ret, astrErrors_ret = fOk, astrErrors
			if fOk then
				self.m_abVectors        = ""
				self.m_tHBootHeader     = ""
				self.m_tDefaultHeader   = tDefaultHeader
				self.m_tCommonHeader    = tCommonHeader
				self.m_abOtherHeaders   = abHeaders
				self.m_abHeaderGap      = abHeaderGap
				self.m_abData           = abData
				self.m_abDataGap        = abDataGap
				self.m_abTaglist        = abTags
				self.m_abTagGap         = abTagGap
			end
		end
	end
	
	return fOk_ret, astrErrors_ret
end


-- returns binary/nil, messages
function buildNXFile(self, abExtFile)
    if isNxi(self) or isMxf(self) then
        return netx_fileheader.makeNXIFile(
            self.m_tDefaultHeader, self.m_tCommonHeader, self.m_abOtherHeaders, self.m_abHeaderGap,
            self.m_abData, self.m_abDataGap,
            self.m_abTaglist, self.m_abTagGap)
    elseif isNxe(self) then
        return netx_fileheader.makeNXEFile(
            self.m_tDefaultHeader, self.m_tCommonHeader, self.m_abOtherHeaders, self.m_abHeaderGap,
            self.m_abData, self.m_abDataGap,
            self.m_abTaglist, self.m_abTagGap)
    elseif isNai(self) then
        return netx_fileheader.makeNAIFile(
            self.m_abVectors, self.m_tHBootHeader,
            self.m_tDefaultHeader, self.m_tCommonHeader, self.m_abOtherHeaders, self.m_abData, abExtFile or "")
    elseif isNae(self) then
        return netx_fileheader.makeNAEFile(
            self.m_tHBootHeader,
            self.m_tDefaultHeader, self.m_tCommonHeader, self.m_abOtherHeaders, self.m_abData)
    else
        return netx_fileheader.makeNXFile(
            self.m_tDefaultHeader, self.m_tCommonHeader, self.m_abOtherHeaders, self.m_abHeaderGap,
            self.m_abData, self.m_abDataGap,
            self.m_abTaglist, self.m_abTagGap)
    end
end


function buildNXFilePair(tBaseFile, tExtFile)
    local abBaseFile
    local abExtFile
    local strMsg
    
    updateExtensionFile(tBaseFile, tExtFile)
    updateCommonCRC32(tBaseFile, tExtFile)
    
    abExtFile = tExtFile:buildNXFile()
    if not abExtFile then
        strMsg = "Failed to build NXE/NAE file"
    else
        abBaseFile = tBaseFile:buildNXFile(abExtFile)
        if not abBaseFile then
            strMsg = "Failed to build NXI/NAI file"
        end
    end
    
    return abBaseFile, abExtFile, strMsg
end

-- returns true if headers and data are present
function isComplete(self)
	return self:hasHeaders() and self:hasData()
end


-- returns a string to pad abBin to the next multiple of length
function getPadding(abBin, length)
	return string.rep(string.char(0), (length - abBin:len()) % length)
end



function check_nai_nae(self, tExtFile, abExtFile)
	local fOk = false 
	local astrMsg = {}

	if isNai(self) and isNae(tExtFile) then
		local fOkNae, astrMsgNae = netx_fileheader.check_checksums_nae(
			tExtFile.m_tHBootHeader, 
			tExtFile.m_tDefaultHeader, 
			tExtFile.m_tCommonHeader, 
			tExtFile.m_abOtherHeaders, 
			tExtFile.m_abData)
		
		local fOkNai, astrMsgNai = netx_fileheader.check_checksums_nai(
			self.m_abVectors, 
			self.m_tHBootHeader, 
			self.m_tDefaultHeader, 
			self.m_tCommonHeader, 
			self.m_abOtherHeaders, 
			self.m_abData, 
			abExtFile)

		fOk = fOkNai and fOkNae
		astrMsg = join_lists(astrMsgNai, astrMsgNae)
	end
	return fOk, astrMsg
end

function join_lists(l1, l2)
	local l = {}
	for i, e in ipairs(l1) do 
		table.insert(l, e)
	end
	for i, e in ipairs(l2) do 
		table.insert(l, e)
	end
	return l
end

--------------------------------------------------------------------------
--                  handle base/extension file pairs
--------------------------------------------------------------------------

function needsExtensionFile(self)
	return getExtensionFileType(self) ~= nil
end

function getExtensionFileType(self)
	local tCH = self:getCommonHeader()
	if tCH.ulCommonCRC32 ~= 0 then
		if isNxi(self) then
			return "NXE"
		elseif isNai(self) then
			return "NAE"
		end
	end
	
	return nil
end


-- Checking if base and extension files match:
-- Default header: file type magic must be NXI/NXE or NAI/NAE
-- Common header bNumModuleInfos must be equal
-- Common header common CRC32 must be equal and non-null
-- Contents of device and module headers must be equal
-- Length of header area must be large enough for device and module info headers

function isExtensionFileValid(tBaseFile, tExtFile)
	if not tBaseFile:isNxi() and not tBaseFile:isNai() then
		return false, "The base file does not require an extension file"
	elseif tBaseFile:isNxi() and not tExtFile:isNxe() then
		return false, "The base file has type NXI, but the extension file does not have type NXE."
	elseif tBaseFile:isNai() and not tExtFile:isNae() then
		return false, "The base file has type NAI, but the extension file does not have type NAE."
	end
	
	local tCHBase = tBaseFile:getCommonHeader()
	local tCHExt = tExtFile:getCommonHeader()
	
	if tCHBase.ulCommonCRC32 == 0 then
		return false, "The base file does not require an extension file."
	end 
	
	if tCHBase.ulCommonCRC32 ~= tCHExt.ulCommonCRC32 then
		return true, "The common CRC values do not match."
	end
	
	-- calculate the minimal length of the header area
	local ulMinHeaderLen = 
		netx_fileheader.DEFAULT_HEADER_SIZE + 
		netx_fileheader.COMMON_HEADER_V3_SIZE +
		netx_fileheader.DEVICE_INFO_V1_SIZE + 
		tCHBase.bNumModuleInfos * netx_fileheader.MODULE_INFO_V1_SIZE
	
	if tCHBase.ulHeaderLength  < ulMinHeaderLen then
		return false, "Invalid header length in base file"
	elseif tCHExt.ulHeaderLength < ulMinHeaderLen then
		return false, "Invalid header length in extension file"
	end
	
	local abDH1 = tBaseFile:getDeviceHeader()
	local abDH2 = tExtFile:getDeviceHeader()
	if abDH1 ~= abDH2 then
		return true, "The device headers do not match."
	end
	
	if tCHBase.bNumModuleInfos ~= tCHExt.bNumModuleInfos then 
		return false, "The base and extension file differ in the number of module info headers"
	end
	
	local ulModuleInfoStart = netx_fileheader.DEVICE_INFO_V1_SIZE + 1
	local ulModuleInfoEnd  = netx_fileheader.DEVICE_INFO_V1_SIZE + tCHBase.bNumModuleInfos * netx_fileheader.MODULE_INFO_V1_SIZE
	
	local abBaseModuleInfo = tBaseFile.m_abOtherHeaders:sub(ulModuleInfoStart, ulModuleInfoEnd)
	local abExtModuleInfo  = tBaseFile.m_abOtherHeaders:sub(ulModuleInfoStart, ulModuleInfoEnd)
	if abBaseModuleInfo~=abExtModuleInfo then
		return true, "The module info headers do not match"
	end
	
	return true
end




-- Copy device info and module info headers from the base file to the extension file.
-- The base and extension file must have the same number of module info headers.
function updateExtensionFile(tBaseFile, tExtFile)
	local abDH1 = tBaseFile:getDeviceHeader()
	tExtFile:setDeviceHeader(abDH1)
	
	local tCHBase = tBaseFile:getCommonHeader()
	local tCHExt = tExtFile:getCommonHeader()
	
	if tCHBase.bNumModuleInfos ~= tCHExt.bNumModuleInfos then 
		return false, "The base and extension file differ in the number of module info headers"
	end
	
	local ulLen = netx_fileheader.DEVICE_INFO_V1_SIZE + tCHBase.bNumModuleInfos * netx_fileheader.MODULE_INFO_V1_SIZE
	
	if tCHBase.ulHeaderLength - netx_fileheader.DEFAULT_HEADER_SIZE + netx_fileheader.COMMON_HEADER_V3_SIZE < ulLen then
		return false, "Invalid header length in base file"
	end
	
	if tCHExt.ulHeaderLength - netx_fileheader.DEFAULT_HEADER_SIZE + netx_fileheader.COMMON_HEADER_V3_SIZE < ulLen then
		return false, "Invalid header length in extension file"
	end
	
	tExtFile.m_abOtherHeaders = tBaseFile.m_abOtherHeaders:sub(1, ulLen) .. tExtFile.m_abOtherHeaders:sub(ulLen+1)
end


-- Update common CRC32
-- 1. call makeNXIFile on both files to update MD5
-- 2. combine MD5 checksums to obtain common CRC32, 
-- 3. put common CRC32 into both common headers 
-- 4. call makeNXIFile on both files again (this is done later)
function updateCommonCRC32(tNXI, tNXE)
	local fOk = false
	local astrMsgs
	local abNXI, abNXE
	
	abNXI, astrMsgs = tNXI:buildNXFile()
	if abNXI then
		abNXE, astrMsgs = tNXE:buildNXFile()
		if abNXE then
			local md5_nxi = tNXI.m_tCommonHeader.aulMD5
			local md5_nxe = tNXE.m_tCommonHeader.aulMD5
			local ulCommonCRC32 = netx_fileheader.calcCRC32B(md5_nxi, md5_nxe)
			tNXI.m_tCommonHeader.ulCommonCRC32 = ulCommonCRC32
			tNXE.m_tCommonHeader.ulCommonCRC32 = ulCommonCRC32
			fOk = true
		end
	end
	
	return fOk, astrMsgs
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

function isNxi(self)
	return netx_fileheader.isNxiBootHeader(self.m_tDefaultHeader)
end

function isMxf(self)
	return netx_fileheader.isMxfBootHeader(self.m_tDefaultHeader)
end

function isNxe(self)
	return netx_fileheader.isNxeBootHeader(self.m_tDefaultHeader)
end

function isNai(self)
	return netx_fileheader.isNaiBootHeader(self.m_tDefaultHeader)
end

function isNae(self)
	return netx_fileheader.isNaeBootHeader(self.m_tDefaultHeader)
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

-- used only on NXO files.
function setHeadersBin(self, abBin)
	if isNxi(self) then
		error("setHeadersBin not supported on NXI files.")
	end

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
-- used only on NXO files.
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
-- used only in relation to nxo files

function setData(self, abBin)
	if isNxi(self) or isNxe(self) or isMxf(self) then
		error("setData not supported on NXI/NXE/MXF files.")
	end
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

-- Replace the tag list and adjust tagGap.
-- If ulTagListSizeMax is >0, only accept a tag list up to that size.
-- If the tag list is located before the data, check that it does not
-- overlap data start offset.
--
-- Adjust tag gap:
-- If the tag list is at the end of the file, and fKeepGap is false,
-- replace the tag gap with 0-3 alignment bytes.
-- If the tag list is located before the data, adjust tagGap to data start offset.
--
-- ulTagListSize is ignored here and the value is not necessarily correct.
-- It's set in makeNXFile.
function setTaglistBin(self, abBin, fKeepGap)
	abBin = abBin or ""
	local tCH = self.m_tCommonHeader
	
    -- If file is an NXI or MXF, just replace the tag list.
    -- The tag list can only be replaced with one that has the same size as the old one.
    if isNxi(self) or isMxf(self) then
        if self.m_abTaglist:len() == abBin:len() then
            self.m_abTaglist = abBin
            -- todo: replace the tag list in the binary.
            return true
        else 
            return false, "The taglist of an NXI/MXF file can only be replaced with one of the same size."
        end
    end
    
	-- no tag list or tag list at end of file: just pad to dword size
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
	
	-- tag list before data section: adjust TagGap to ulDataStartOffset
	else
		-- length of the area between taglist start and data start
		local iTagAreaLen = tCH.ulDataStartOffset - tCH.ulTagListStartOffset
		if iTagAreaLen < tCH.ulTagListSizeMax then
			return false, 
				"Error in common header: ulTagListStartOffset - ulDataStartOffset < ulTagListSizeMax"
		elseif tCH.ulTagListSizeMax ~= 0 and tCH.ulTagListSizeMax < abBin:len() then
			return false, 
				"The tag list is longer than the size allowed by ulTagListSizeMax."
		else
			self.m_abTaglist = abBin
			-- adjust the tag gap such that length of tag list + tag gap = iTagAreaLen
			-- by appending or removing bytes at the beginning of tag gap
			local iLen = abBin:len() + self.m_abTagGap:len()
			if iLen < iTagAreaLen then
				--print(string.format("enlarging tag gap by %d bytes", iTagAreaLen - iLen))
				self.m_abTagGap = string.rep(string.char(0), iTagAreaLen - iLen) .. self.m_abTagGap
			elseif iLen > iTagAreaLen then
				--print(string.format("shrinking tag gap by %d bytes", iLen - iTagAreaLen))
				self.m_abTagGap = string.sub(self.m_abTagGap, iLen - iTagAreaLen + 1)
			end
			return true
		end
	end
end

function getTaglistBin(self)
	return self.m_abTaglist
end

function hasTaglist(self)
	return self.m_abTaglist and self.m_abTaglist:len() > 0
end
