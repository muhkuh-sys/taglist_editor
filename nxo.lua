---------------------------------------------------------------------------
-- Copyright (C) 2010 Hilscher Gesellschaft für Systemautomation mbH
--
-- Description:
--   Routines for manipulating NXO files, for Taglist Editor
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

-- build, parse and keep the contents of an NXO module file.
-- the file consists of 
-- m_abDefaultHeader
-- m_abCommonHeader: common header V3
-- m_abOtherHeaders: device info, 0,1 or several module info blocks
-- m_abElf
-- m_abTaglist

-- uncovered cases:
-- this implementation assumes that the order of contents is
-- always headers - data - taglist, with no additional data inbetween.
-- Any data between these three blocks will be lost, 
-- if the file is saved again the order will be the default order no
-- matter what it was before

module("nxo", package.seeall)

require("netx_fileheader")

function new()
	local t = {}
	local mt = {__index=nxo}
	setmetatable(t, mt)
	return t
end


-- debug
function showtypes(...)
	local l={...}
	for i=1, table.maxn(l) do 
		local v=l[i]
		if type(v)=="string" then 
			print(i, type(v), v:len())
		else 
			print(i, type(v))
		end
	end
end

function parseNxoBin(tNxo, abBin)
	local fOk, astrErrors, abDefaultHeader, abCommonHeader, abOtherHeaders, abElf, abTaglist 
		= netx_fileheader.parseNXO(abBin)
	-- print(fOk, astrErrors, abDefaultHeader, abCommonHeader, abOtherHeaders, abElf, abTaglist )
	-- showtypes(fOk, astrErrors, abDefaultHeader, abCommonHeader, abOtherHeaders, abElf, abTaglist )
	if fOk then
		print("parsed ok")
		tNxo.m_abDefaultHeader = abDefaultHeader
		tNxo.m_abCommonHeader = abCommonHeader
		tNxo.m_abOtherHeaders = abOtherHeaders
		tNxo.m_abElf = abElf
		tNxo.m_abTaglist = abTaglist
		return true
	else
		print(abDefaultHeader) -- error message
		return nil, astrErrors
	end
end

function buildNxoBin(tNxo)
	return netx_fileheader.makeNXO(
		tNxo.m_abDefaultHeader,
		tNxo.m_abCommonHeader,
		tNxo.m_abOtherHeaders,
		tNxo.m_abElf,
		tNxo.m_abTaglist
		)
end

-- returns true if headers and ELF are present
function isComplete(tNxo)
	return tNxo:hasHeaders() and tNxo:hasElf()
end




function setCommonHeaderBin(tNxo, abBin)
	tNxo.m_abCommonHeader = abBin
end

function getCommonHeaderBin(tNxo)
	return tNxo.m_abCommonHeader
end

function hasCommonHeader(tNxo)
	return tNxo.m_abCommonHeader and true
end




-- sets common header V3, device info, and module infos; NOT the default header!
-- 
function setHeadersBin(tNxo, abBin)
	local abCH, abOH = abBin:sub(1, netx_fileheader.COMMON_HEADER_V3_SIZE), abBin:sub(netx_fileheader.COMMON_HEADER_V3_SIZE+1)
	tNxo.m_abCommonHeader = abCH
	tNxo.m_abOtherHeaders = abOH
end

-- gets common header V3, device info, and module infos; NOT the default header!
function getHeadersBin(tNxo)
	if tNxo.m_abCommonHeader and tNxo.m_abOtherHeaders then
		return tNxo.m_abCommonHeader .. tNxo.m_abOtherHeaders
	end
end

-- returns true if common header V3, device info, and module infos are present
function hasHeaders(tNxo)
	return tNxo.m_abCommonHeader and tNxo.m_abOtherHeaders and true
end





function setElf(tNxo, abBin)
	tNxo.m_abElf = abBin
end

function getElf(tNxo)
	return tNxo.m_abElf
end

function hasElf(tNxo)
	return tNxo.m_abElf and true
end





function setTaglistBin(tNxo, abBin)
	tNxo.m_abTaglist = abBin
end

function getTaglistBin(tNxo)
	return tNxo.m_abTaglist
end

function hasTaglist(tNxo)
	return tNxo.m_abTaglist and true
end
