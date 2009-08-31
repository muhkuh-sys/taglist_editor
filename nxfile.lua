-- build, parse and keep the contents of an NXF module file.
-- the file consists of 
-- m_abBootHeader
-- m_abBinary: common header V3 and additional headers + relocated binary
-- m_abTaglist

-- uncovered cases:
-- this implementation assumes that the order of contents is
-- always headers - data - taglist, with no additional data inbetween.
-- Any data between these three blocks will be lost, 
-- if the file is saved again the order will be the default order no
-- matter what it was before

-- modelling: default/boot and common header as structures, remaining headers and headerPad as bin
-- data and dataPad, taglist and tagPad as bin

module("nxfile", package.seeall)

require("netx_fileheader")

--[[
function parseNxoBin(self, abBin)
	return parseBin(self, abBin)
end

function buildNxoBin(self)
	return buildNXFile(self)
	-- return netx_fileheader.makeNXO(self.m_abDefaultHeader, self.m_abCommonHeader, self.m_abOtherHeaders, self.m_abData, self.m_abTaglist)
end
--]]

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

-- returns true if headers and data are present
function isComplete(self)
	return self:hasHeaders() and self:hasData()
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




-- returns a string to pad abBin to the next multiple of length
function getPadding(abBin, length)
	return string.rep(string.char(0), (length - abBin:len()) % length)
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



-- sets common header V3, device info, and module infos; NOT the default header!
-- 
function setHeadersBin(self, abBin)
	abBin = abBin or ""
	local abCH = abBin:sub(1, netx_fileheader.COMMON_HEADER_V3_SIZE)
	self.m_tCommonHeader  = netx_fileheader.binToHeader(abCH, netx_fileheader.COMMON_HEADER_V3_SPEC)
	self.m_abOtherHeaders = abBin:sub(netx_fileheader.COMMON_HEADER_V3_SIZE+1)
	self.m_abHeaderGap = getPadding(abBin, 4)
end

-- gets common header V3, device info, and module infos; NOT the default header!
function getHeadersBin(self)
	if self.m_tCommonHeader and self.m_abOtherHeaders then
		local abCH = netx_fileheader.headerToBin(self.m_tCommonHeader, netx_fileheader.COMMON_HEADER_V3_SPEC)
		return abCH .. self.m_abOtherHeaders
	end
end

-- returns true if common header V3, device info, and module infos are present
function hasHeaders(self)
	return self.m_tCommonHeader and self.m_abOtherHeaders and self.m_abOtherHeaders:len()>0 
end





function setElf(self, abBin)
	abBin = abBin or ""
	self.m_abData = abBin
	self.m_abDataGap = getPadding(abBin, 4)
end

function getElf(self)
	return self.m_abData
end

function hasElf(self)
	return self.m_abData and self.m_abData:len() > 0
end



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


-- for Taglist editor: set fKeepGap to true to skip re-padding
-- (assumes that the new taglist has the same size)
function setTaglistBin(self, abBin, fKeepGap)
	abBin = abBin or ""
	self.m_abTaglist = abBin
	-- If a common header is present which says that the tag list comes before the data,
	-- and the maximum size is set, pad the taglist up to the maximum size. 
	-- Otherwise, it is padded to dword size.
	if not fKeepGap then
		local tCH = self.m_tCommonHeader
		if tCH.ulTagListStartOffset > 0 
		and tCH.ulTagListStartOffset < tCH.ulDataStartOffset
		and tCH.ulTagListSizeMax > 0 then
			self.m_abTagGap = getPadding(abBin, tCH.ulTagListSizeMax)
		else
			self.m_abTagGap = getPadding(abBin, 4)
		end
	end
end

function getTaglistBin(self)
	return self.m_abTaglist
end

function hasTaglist(self)
	return self.m_abTaglist and self.m_abTaglist:len() > 0
end
