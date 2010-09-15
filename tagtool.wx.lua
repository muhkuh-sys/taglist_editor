---------------------------------------------------------------------------
-- Copyright (C) 2010 Hilscher Gesellschaft für Systemautomation mbH
--
-- Description:
--   command-line tool which replaces the tag list in an NXF/NXO file.
--
--  Changes:
--    Date        Author        Description
--  Jul 27, 2010  SL            created
---------------------------------------------------------------------------
--  
---------------------------------------------------------------------------
-- SVN Keywords
--
SVN_DATE   ="$Date$"
SVN_VERSION="$Revision$"
-- $Author$
---------------------------------------------------------------------------
-- Load the wxLua module, does nothing if running from wxLua, wxLuaFreeze, or wxLuaEdit
package.cpath = package.cpath..";./?.dll;./?.so;../lib/?.so;../lib/vc_dll/?.dll;../lib/bcc_dll/?.dll;../lib/mingw_dll/?.dll;"
require("wx")

print_wx = print
print = print_lua

-- replacement for muhkuh.include("hexdump.lua", "hexdump")
-- (required by nxo.lua)
muhkuh = {}
function muhkuh.include(strFile, strPackage) require(strPackage) end

require("nxfile")
require("taglist")
require("devhdredit")

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
bit.band    = function(a, b) return bitretconv(band   (bitparconv(a), bitparconv(b))) end
bit.bor     = function(a, b) return bitretconv(bor    (bitparconv(a), bitparconv(b))) end
bit.bxor    = function(a, b) return bitretconv(bxor   (bitparconv(a), bitparconv(b))) end
bit.bnot    = function(a)    return bitretconv(bnot   (bitparconv(a))) end
bit.lshift  = function(a, b) return bitretconv(lshift (bitparconv(a), b)) end
bit.rshift  = function(a, b) return bitretconv(rshift (bitparconv(a), b)) end
bit.arshift = function(a, b) return bitretconv(arshift(bitparconv(a), b)) end

-- trace printing and file operations
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

loadBin = utils.loadBin
writeBin = utils.writeBin

----------------------------------------------------------------------------
--                        serialize/deserialize tags
----------------------------------------------------------------------------
-- Parse all known tags in atTags. 
-- Set tTagDesc and tValue for each tag which has a structure definition.
-- Returns true/false, strError
function deserializeKnownTags(atTags)
	for _, tTag in ipairs(atTags) do
		local strEntryName, tTagDesc = taglist.getParamTypeDesc(tTag.ulTag)
		if tTagDesc then
			if tTagDesc.datatype then
				tTag.tValue = taglist.deserialize(tTagDesc.datatype, tTag.abValue, true)
				tTag.tTagDesc = tTagDesc
			else
				-- this can only happen if the tag definition in rcx_mod_tags is incorrect
				return false, string.format("BUG: No datatype for tag 0x%08x", tTag.ulTag)
			end
			dbg_printf("parseKnownTags: %08x parsed", tTag.ulTag)
		else
			dbg_printf("parseKnownTags: %08x ignored", tTag.ulTag)
		end
	end
	return true
end

-- prints a list of tags with tValue entry set by deserialize
-- 1 no name, no tValue
-- 2 name and tValue
-- 3 name, but no tValue (should not happen)
function printTaglist(atTags)
	if #atTags==0 then
		printf("# The tag list is empty")
		print()
		print()
	end

	for iTag, tTag in ipairs(atTags) do
		-- print structure header
		strTagName = taglist.getParamTypeDesc(tTag.ulTag)
		
		if strTagName then
			-- TAG #9 RCX_MOD_TAG_IT_XC_T (0x00001050) xC Unit
			-- (RCX_MOD_TAG_IT_XC -alternatives)
			printf("Tag %d: %s (0x%08x)", iTag, strTagName, tTag.ulTag)
			-- print structure content
			if tTag.tValue then
			    taglist.printStructure(tTag.tValue)
			else
				print("# Could not deserialize tag value")
			end
		else
			-- if there is no structure definition
			printf("# Tag %d: unknown (0x%08x)", iTag, tTag.ulTag)
		end
		print()
		print()
	end
end


--[[
-- for each known tag, update abValue from tValue if tValue is set.
function serializeKnownTags(atTags)
	for _, tTag in ipairs(atTags) do
		if tTag.tValue then
			tTag.abValue = taglist.serialize(tTag.tTagDesc.datatype, tTag.tValue, true)
			vbs_printf("reconstructKnownTags: serialized %08x", tTag.ulTag)
		end
	end
end
--]]


function getDeviceHeaderVersion(tDevHdr)
	for iMember, tMember in ipairs(tDevHdr) do
		if tMember.strName == "ulStructVersion" then 
			return tMember.tValue 
		end
	end
end

function checkDeviceHeaderVersion(tDevHdr)
	local ulVersion = getDeviceHeaderVersion(tDevHdr)
	if ulVersion == 0x00010000 then
		return true
	elseif ulVersion == nil then
		return false, "no header version found, illegal structure"
	else
		return false, string.format("# Unknown device header version (0x%08x)", ulVersion)
	end
end

function loadInputFile(strInputFile)
	local tNx
	local abTags, iLen, atTags
	local abDevHdr, tDevHdr
	local fOk, strError, astrErrors

	-- load and parse the existing nxf/nxo file
	local abInputFile, strMsg = loadBin(strInputFile)
	if not abInputFile then 
		return nil,strMsg 
	end
	
	tNx = nxfile.new()
	fOk, astrErrors = tNx:parseBin(abInputFile)
	if fOk then
		printResults(fOk, astrErrors)
	else
		return nil, astrErrors
	end
	
	-- tag list
	if tNx:hasTaglist() then
		abTags = tNx:getTaglistBin()
		
		fOk, atTags, iLen, strError = taglist.binToParams(abTags)
		if fOk then
			printResults(fOk, strError)
			fOk, strError = deserializeKnownTags(atTags)
		end
		
		if fOk then
			local fEndOk, fCorrectible, strMsg = taglist.checkEndMarker(tNx, atTags)
			if not fEndOk then
				printResults(true, strMsg)
			end
		else
			return nil, strError
		end
	else
		atTags = {}
	end
	
	-- device header
	if tNx:hasDeviceHeader() then
		abDevHdr = tNx:getDeviceHeader()
		
		-- deserialize device header and check version. We only handle Version 1.0
		tDevHdr = taglist.deserialize("DEVICE_HEADER_V1_T", abDevHdr, true)
		if not tDevHdr then
			return nil, "Error while deserializing device header"
		end
	end
	
	return {
		tNx = tNx,
		atTags = atTags,
		abDevHdr = abDevHdr,
		tDevHdr = tDevHdr
	}
end



----------------------------------------------------------------------------
--                parse and perform editing instructions
----------------------------------------------------------------------------
strLineBreak          = "\r\n"
strCommentChar        = "#"
strTrimPattern        = "^%s*(.+[^%s])%s*$"
strTagNamePattern     = "^Tag[^:]*:%s*([%w_]+)"
strStructNamePattern  =             "^([%w_]+)$"
strMatchPattern       =     '^%s*%.?([%w_%.%[%]]+)%s*=%s*"?([%w%s_]+)"?'
strSetPattern         = '^SET %s*%.?([%w_%.%[%]]+)%s*=%s*"?([%w%s_]+)"?'

-- split strText into lines at "\n" and remove comments starting with "#"
function splitIntoLines(strText)
	local astrLines = {}
	local iLineStart = 1
	while iLineStart do
		-- get next line
		local iEnd, iEnd2 = string.find(strText, strLineBreak, iLineStart, false)
		local strLine
		if iEnd and iEnd2 then
			strLine = strText:sub(iLineStart, iEnd-1)
			iLineStart = iEnd2+1
		else
			strLine = strText:sub(iLineStart)
			iLineStart = nil
		end
		
		-- remove comment
		local iComStart = string.find(strLine, strCommentChar, 1, true)
		if iComStart then strLine = strLine:sub(1, iComStart-1) end
		
		-- trim leading/trailing whitespace
		local strNospace = string.match(strLine, strTrimPattern)
		if strNospace then strLine = strNospace end
		
		dbg_print(#astrLines+1, ">"..strLine.."<")
		table.insert(astrLines, strLine)
	end
	return astrLines
end



-- Parse contents of edits file.
-- astrLines are the lines from the edits file without comments
-- If successful, returns a list of editRecords.
-- If not, returns nil and an error message.

-- Each editRecord contains:
-- 1) which structure(tag) to change
-- 2) constraints
-- 3) fields to overwrite
-- 
-- strName       "RCX_MOD_TAG_IT_XC"   - tag type name or "DEVICE_HEADER"
-- strType       "RCX_MOD_TAG_IT_XC_T" - tag datatype name
-- iLineNo                             - line number in the input
-- atMatches                           - constraints, fields which have to match
-- atEdits                             - fields to overwrite
-- 
-- 
-- Each match/edit record contains:
-- strFieldName   "Identifier"   - field name from the input file (string)
-- strValue       "DPS_RDY"      - value from the input file (string)
-- astrMemberNames               - field name split into member names
-- tValue                        - parsed value
-- iLineNo                       - line number in the input

function parseEdits(astrLines)
	local atEditRecs = {}
	local tEditRec = nil
	for iLineNo, strLine in ipairs(astrLines) do
		dbg_printf("%d: %s", iLineNo, strLine)
		local strTagName, strFieldName, strValue
		
		-- empty line
		if strLine == "" then 
			dbg_printf("skipping line %d", iLineNo)
		else
			-- Tag: ...: <tag name> 
			-- <struct name>
			strName = string.match(strLine, strTagNamePattern)
				or string.match(strLine, strStructNamePattern)
			if strName then
				dbg_printf("got tag/structure name: %s", strName)
				if tEditRec then
					table.insert(atEditRecs, tEditRec)
				end
				tEditRec={
						iLineNo = iLineNo, -- line number of the tag specification
						strName = strName,
						atMatches={}, 
						atEdits={}
					}
			elseif not tEditRec then
				return nil, string.format("Line %d: parse error (no tag specified)", iLineNo)
			else
				-- <field name>=<value>
				strFieldName, strValue = string.match(strLine, strMatchPattern)
				if strFieldName and strValue then
					table.insert(tEditRec.atMatches, {strFieldName = strFieldName, strValue = strValue, iLineNo = iLineNo})
					dbg_printf("match %s = %s", strFieldName, strValue)
				else
					-- SET <field name>=<value>
					strFieldName, strValue = string.match(strLine, strSetPattern)
					if strFieldName and strValue then
						table.insert(tEditRec.atEdits, {strFieldName = strFieldName, strValue = strValue, iLineNo = iLineNo})
						dbg_printf("edit %s = %s", strFieldName, strValue)
					else
						-- anything else
						print(">"..strLine.."<")
						return nil, string.format("line %d: parse error", iLineNo)
					end
				end
			end
		end
	end
	if tEditRec then
		table.insert(atEditRecs, tEditRec)
	end
	
	return atEditRecs
end

function postprocess_editrecs(atEditRecs)
	local strName
	local iLineNo
	local tTagEntry
	local tStructDef
	local strType

	-- evaluate the edit records
	for iEditRec, tEditRec in ipairs(atEditRecs) do
		-- error if no structure name is given
		strName = tEditRec.strName
		iLineNo = tEditRec.iLineNo
		if not strName then
			-- should not happen due to parsing restrictions
			return false, string.format("Line %d: tag/structure name is missing", iLineNo)
		end
	
		if strName=="DEVICE_HEADER_V1_T" then
			tEditRec.ulTag = nil
			tEditRec.strType = strName
		else
			tTagEntry = taglist.resolveTagName(strName)
			if tTagEntry then
				tEditRec.ulTag = tTagEntry.paramtype
				dbg_printf("edit record %d: tag Id 0x%08x", iEditRec, tEditRec.ulTag)
				tEditRec.strType = tTagEntry.datatype
			else
				return false, string.format("Line %d: unknown type name %s", iLineNo, strName)
			end
		end
		
		fOk, strError = enhanceMatchesOrEdits(tEditRec.atMatches, tEditRec.strType)
		if not fOk then
			return fOk, strError
		end
		fOk, strError = enhanceMatchesOrEdits(tEditRec.atEdits, tEditRec.strType)
		if not fOk then
			return fOk, strError
		end
	end
	
	return true
end

-- Parses field name and value strings in a match/edit record, and
-- fills in astrMembernames and tValue.
-- In the input entries, the following fields must be set:
-- strFieldName
-- strValue
-- iLineNo 
function enhanceMatchesOrEdits(atMatchesOrEdits, strStructType)
	local iLineNo
	local strType
	local strValue
	local tValue
	local astrMemberNames
	local strMemberNamePattern = "[^%.]+"
	
	for iMatch, tMatch in ipairs(atMatchesOrEdits) do
		iLineNo = tMatch.iLineNo
		strValue = tMatch.strValue

		-- split the member names
		dbg_printf("parsing fieldname: >%s<", tMatch.strFieldName)
		astrMemberNames = {}
		for strMember in string.gmatch(tMatch.strFieldName, strMemberNamePattern) do
			table.insert(astrMemberNames, strMember)
		end
		tMatch.astrMemberNames = astrMemberNames
		
		-- get the type of the value
		local strMemberType, strError = structDef_findMemberType(strStructType, astrMemberNames)
		if not strMemberType then
			return false, string.format("Line %d: %s", iLineNo, strError)
		end
		
		-- parse the value in the match entry according to the type we arrived at
		tValue = taglist.resolveValueConstant(strValue)
		if tValue then 
			dbg_print(strValue, "-->", tValue) 
		else
			tValue = taglist.parsePrimitiveType(strMemberType, strValue)
		end
		
		-- store the parsed value
		if tValue then
			tMatch.tValue = tValue
		else
			return false, string.format("Line %d: Failed to parse value in match/assignment: type=%s  value=%s", 
				iLineNo, strMemberType or "nil", strValue or "nil")
		end
		
	end
	return true

end


function hexstr(str)
	local iLen = str:len()
	local strHex = ""
	for i=1, iLen do strHex = strHex .. string.format("%02x ", str:byte(i)) end
	return strHex
end

-- search structure definitions
function structDef_findMember(tStructDef, strMemberName)
	for iMember, tMember in ipairs(tStructDef) do
		if tMember[2] == strMemberName then
			return tMember
		end
	end
end

function structDef_findMemberType(strTypeName, astrMemberNames)
	local tStructDef
	local tMemberDef
	
	for iMemberName, strMemberName in ipairs(astrMemberNames) do
		tMemberDef = nil
		dbg_printf("type/member: %s/%s", strTypeName, strMemberName)
		-- get the type definition
		tStructDef = taglist.getStructDef(strTypeName)
		if not tStructDef then
			if taglist.isPrimitiveType(strTypeName) then
				return nil, string.format("tried to get member of primitive type %s", strTypeName)
			else
				return nil, string.format("type %s not found", strTypeName)
			end
		end
		
		-- look for a member with name strMemberName and get its type
		tMemberDef = structDef_findMember(tStructDef, strMemberName)
		if not tMemberDef then
			return nil, string.format("type %s has no member %s", strTypeName, strMemberName)
		end
		
		strTypeName = tMemberDef[1]
	end
	
	return strTypeName
end

-- search structure (value)
function findMember(tStruct, strMemberName)
	for iMember, tMember in ipairs(tStruct) do
		if tMember.strName == strMemberName then
			return tMember
		end
	end
end

function findLastMember(tStruct, astrMemberNames)
	local tMember
	for iMember, strMemberName in ipairs(astrMemberNames) do
		dbg_printf("member %s", strMemberName)
		tMember = findMember(tStruct, strMemberName)
		if not tMember then 
			return nil, string.format("Member %s not found", strMemberName) 
		end
		if not tMember.tValue then 
			return nil, string.format("Member %s has no value", strMemberName) 
		end
		tStruct = tMember.tValue
	end
	return tMember
end


-- Match edit record to a structure.
-- Returns true if they match, false if not.
-- tEditRecord =
-- {strTagName = "RCX_MOD_TAG_IT_XC",
--  atMatches={
--    {strFieldName="tIdentifier.abName", strValue = "RTE_XC0"}
--  }, 
--  atEdits={
--    {strFieldName="ulXcId", strValue = "2"}
--  }}
-- tEditRecord.atMatches = {
-- 	{strFieldName=strFieldName, strValue = strValue}
-- }

function matchEditRecord(tEditRecord, tValue) 
	for iMatch, tMatch in ipairs(tEditRecord.atMatches) do
		dbg_printf("Comparing match entry %s = %s", tMatch.strFieldName, tMatch.strValue)
		
		local tMember, strError = findLastMember(tValue, tMatch.astrMemberNames)
		if not tMember then 
			return false, strError
		end
		
		if tMember.tValue ~= tMatch.tValue then
			dbg_printf("Value mismatch: >%s< >%s<", tostring(tMember.tValue), tostring(tMatch.tValue))
			--tprintf(hexstr(tMember.tValue))
			--tprintf(hexstr(tMatch.tValue))
			return false
		end
	end
	
	return true
end


-- Apply edits in edit record to structure
-- Returns fOk, strError

function applyEdit(tEditRecord, tValue)
	for iEdit, tEdit in ipairs(tEditRecord.atEdits) do
		vbs_printf("applying edit entry %s = %s", tEdit.strFieldName, tEdit.strValue)
		local tMember, strError = findLastMember(tValue, tEdit.astrMemberNames)
		if not tMember then 
			return false, strError
		end
		tMember.tValue = tEdit.tValue
	end
	return true
end



function handle_editrec_device_header(nx, tEditRecord, iEdit)
	-- get the device header
	if not nx:hasDeviceHeader() then
		return false, "Device header not found"
	end
	
	local abDevHdr = nx:getDeviceHeader()
	
	-- deserialize device header and check version
	local tDevHdr = taglist.deserialize("DEVICE_HEADER_V1_T", abDevHdr, true)
	
	if not tDevHdr then
		return false, "Error while deserializing device header"
	end
	
	local fOk, strError = checkDeviceHeaderVersion(tDevHdr)
	if not fOk then
		return false, strError
	end
	
	-- match edit record
	local fOk, strMsg = matchEditRecord(tEditRecord, tDevHdr) 
	if not fOk then
		if strMsg then 
			return false, strMsg
		else
			return false, "device header does not match"
		end
	end
	
	-- apply edit record
	fOk, strMsg = applyEdit(tEditRecord, tDevHdr)
	if not fOk then
		return false, strError
	end
	
	-- serialize device header
	abDevHdr, strError = taglist.serialize("DEVICE_HEADER_V1_T", tDevHdr, true)
	if not abDevHdr then
		return false, strError
	end
	
	-- set device header
	nx:setDeviceHeader(abDevHdr)
	return true
end


function handle_editrec_tag(atTags, tEditRecord, iEdit)
	-- search the taglist for a tag which matches 
	local tSelectedTag = nil
	local iSelectedTag = nil
	for iTag, tTag in ipairs(atTags) do
		dbg_printf("edit record %d <-> tag %d", iEdit, iTag)
		if tEditRecord.ulTag == tTag.ulTag and 
			tTag.tValue and
			matchEditRecord(tEditRecord, tTag.tValue) then
			if tSelectedTag then
				return false, string.format("Line %d: edit record matches multiple tags", tEditRecord.iLineNo)
			else
				tSelectedTag = tTag
				iSelectedTag = iTag
			end
		end
	end
	-- if exactly one matching tag was found, apply the 
	if tSelectedTag then
		dbg_printf("applying edit record %d to tag %d", iEdit, iSelectedTag)
		tSelectedTag.abValue = nil
		local fOk, strError = applyEdit(tEditRecord, tSelectedTag.tValue)
		if not fOk then
			return false, strError
		end
		tSelectedTag.abValue, strError = taglist.serialize(tSelectedTag.tTagDesc.datatype, tSelectedTag.tValue, true)
		if not tSelectedTag.abValue then
			return false, strError
		end

		dbg_printf("serialized tag #%d/0x%08x", iSelectedTag, tSelectedTag.ulTag)
	else
		return false, string.format("Line %d: edit record matches no tag", tEditRecord.iLineNo)
	end
	return true
end

-- returns true/false and any messages.
-- Messages may be nil, a string or a list of strings.
function edit(strInputFile, strEditsFile, strOutputFile)
	local tRes, msgs = loadInputFile(strInputFile)
	if not tRes then
		return false, msgs
	end

	local nx, atTags = tRes.tNx, tRes.atTags
	
	-- load and parse the edits file
	local strEdits, strMsg = loadBin(strEditsFile)
	if not strEdits then 
		return false, strMsg 
	end
	
	-- split the text into lines and remove comments
	local astrLines = splitIntoLines(strEdits)

	local atEditRecs, strError = parseEdits(astrLines)
	if not atEditRecs then
		return false, strError
	end

	local fOk, strError = postprocess_editrecs(atEditRecs)
	if not fOk then
		return false, strError
	end

	-- apply the edits
	for iEdit, tEditRecord in ipairs(atEditRecs) do
		if tEditRecord.strName == "DEVICE_HEADER_V1_T" then
			fOk, strError = handle_editrec_device_header(nx, tEditRecord, iEdit)
		else
			fOk, strError = handle_editrec_tag(atTags, tEditRecord, iEdit)
		end
		if not fOk then
			return false, strError
		end
	end
	
	-- rebuild taglist binary
	local abTags = taglist.paramsToBin(atTags)
	
	-- replace the tag list
	local fOk, strError = nx:setTaglistBin(abTags, true)
	if not fOk then
		return fOk, strError
	end
	
	-- rebuild the firmware
	local abBin, astrErrors = nx:buildNXFile()
	if not abBin then 
		return false, astrErrors
	end
	
	-- write the result
	fOk, strMsg = writeBin(strOutputFile, abBin)
	return fOk, strMsg

end



----------------------------------------------------------------------------
--        print known tags and device header
----------------------------------------------------------------------------

-- returns true/false and any messages.
-- Messages may be nil, a string or a list of strings.

function listTagsAndDevHdr(strInputFile)
	local tRes, msgs = loadInputFile(strInputFile)
	if not tRes then
		return false, msgs
	end

	local atTags, tDevHdr = tRes.atTags, tRes.tDevHdr 
	
	if atTags and #atTags>0 then
		printTaglist(atTags)
	else
		print("# No tag list")
		print()
	end

	if tDevHdr then
		local fOk, strError = checkDeviceHeaderVersion(tDevHdr)
		if not fOk then
			printf("# %s", strError)
		else
			print("DEVICE_HEADER_V1_T")
			taglist.printStructure(tDevHdr)
		end
	else
		print("# No device header")
	end
	
	return true
end


----------------------------------------------------------------------------
--        print differences in known tags and device header
----------------------------------------------------------------------------

-- Extracts tag lists from file 1 and 2 and
-- prints those tags whose contents are different.
-- Both tag lists must contain the same number and types of tags in the same order.

-- returns true/false and any messages.
-- Messages may be nil, a string or a list of strings.
function listdiffs(strInputFile, strInputFile2)
	local tRes1, msgs = loadInputFile(strInputFile)
	if not tRes1 then
		return false, msgs
	end
	
	local tRes2, msgs = loadInputFile(strInputFile2)
	if not tRes2 then
		return false, msgs
	end

	local atTags1, abDevHdr1, tDevHdr1 = tRes1.atTags, tRes1.abDevHdr, tRes1.tDevHdr
	local atTags2, abDevHdr2, tDevHdr2 = tRes2.atTags, tRes2.abDevHdr, tRes2.tDevHdr
	
	
	-- compare tag lists
	if #atTags1 ~= #atTags2 then
		return false, "The two tag lists do not have the same number of entries"
	end
	
	for iTag = 1, #atTags1 do
		local tTag1 = atTags1[iTag]
		local tTag2 = atTags2[iTag]
		
		-- abort if there are two different tags at the same position
		if tTag1.ulTag ~= tTag2.ulTag then
			return false, string.format("Tag #%d is not of the same type", iTag)
			
		-- skip any tags which have the same binary value
		elseif tTag1.abValue == tTag2.abValue then
			vbs_printf("# Tag %d (0x%08x) equal", iTag, tTag1.ulTag)
		else
			-- if the binary values differ and both tags are deserialized, print the differences
			local strTagName = taglist.getParamTypeDesc(tTag2.ulTag)
			
			if tTag1.tValue and tTag2.tValue and strTagName then
				printf("Tag %d: %s (0x%08x)", iTag, strTagName, tTag2.ulTag)
				local fOk, msg = taglist.printStructureDiffs(tTag1.tValue, tTag2.tValue)
				if not fOk then
					return false, msg
				end
				print()
				print()
			else
				-- the binary values differ, but we can't print the structures
				printf("# Tag %d (0x%08x) differs - no structure definition available", iTag, tTag.ulTag)
				print()
				print()
			end
		end
	end
	
	
	-- compare device headers
	if tDevHdr1 == nil and tDevHdr2 == nil then
		print("# No device header")
	elseif tDevHdr1 == nil and tDevHdr2 ~= nil then
		return false, "File 1 has a device header but File 2 does not"
	elseif tDevHdr1 ~= nil and tDevHdr2 == nil then
		return false, "File 2 has a device header but File 1 does not"
	elseif abDevHdr1 ~= abDevHdr2 then
		local ulVer1 = getDeviceHeaderVersion(tDevHdr1)
		local ulVer2 = getDeviceHeaderVersion(tDevHdr2)
		if ulVer1 ~= ulVer2 then
			print("# File 1 and File 2 have different versions of the device header")
		elseif ulVer1 ~= 0x00010000 then
			printf("# unknown device header version: 0x%08x 0x%08x", ulVer1, ulVer2)
		else
			print("DEVICE_HEADER_V1_T")
			local fOk, msg = taglist.printStructureDiffs(tDevHdr1, tDevHdr2)
			if not fOk then
				return false, msg
			end
		end
	end
	
	return true
end



----------------------------------------------------------------------------
--                        replace tag list in NXF/NXO file
----------------------------------------------------------------------------

-- returns true/false and any messages.
-- Messages may be nil, a string or a list of strings.
function replacetags(strInputFile, strTagsFile, strOutputFile)
	-- load the existing nxf/nxo file
	local abInputFile, strMsg = loadBin(strInputFile)
	if not abInputFile then 
		return false, strMsg 
	end

	-- parse the nxf/nxo file
	nx = nxfile.new()
	local fOk, astrErrors = nx:parseBin(abInputFile)
	if fOk then
		printResults(fOk, astrErrors)
	else
		return false, astrErrors
	end
	
	-- load the new tag list
	local abTags, strMsg = loadBin(strTagsFile)
	if not abTags then 
		return false, strMsg 
	end
	
	local fOk, atTags, iLen, strError = taglist.binToParams(abTags)
	if fOk then
		printResults(fOk, strError)
	else
		return false, strError
	end
	
	local fEndOk, fCorrectible, strMsg = taglist.checkEndMarker(nx, atTags)
	if not fEndOk then
		printResults(true, strMsg)
	end
	
	-- replace the tag list
	local fOk, strError = nx:setTaglistBin(abTags, false)
	if not fOk then
		return fOk, strError
	end
	
	-- rebuild the firmware
	local abBin, astrErrors = nx:buildNXFile()
	if not abBin then 
		return false, astrErrors
	end
	
	-- write the result
	fOk, strMsg = writeBin(strOutputFile, abBin)
	return fOk, strMsg

end


----------------------------------------------------------------------------
--                         main/argument handling
----------------------------------------------------------------------------

local strUsage = [==[
tagtool prints or manipulates the tag list in an NXF or NXO file

Usage: 
   tagtool settags    [-v|-debug] infile taglistfile outfile
   tagtool edit       [-v|-debug] infile editsfile outfile
   tagtool list       [-v|-debug] infile 
   tagtool diff       [-v|-debug] infile1 infile2 
   tagtool [help|-h]
   tagtool help_tags
   tagtool help_const
   tagtool -version

Modes:
   settags     Replaces the tag list
   edit        Changes values in the tag list or device header
   list        Prints the tags list and the device header
   diff        Extract changes between infile1 and infile2
   help        Prints this help text
   help_tags   Prints a list of the known tags
   help_const  Prints a list of the known value constants
   -version    Prints version information
   
Flags:
   -v          enable verbose output
   -debug      enable debug output    
   
Arguments:
   infile      The NXF/NXO file to load
   editsfile   Text file containing editing instructions
   taglistfile The new tag list in binary format
   outfile     The NXF/NXO file to write
]==]

function printUsage()
	print(strUsage)
end

function printVersion()
	print("tagtool:")
	print(SVN_VERSION)
	print(SVN_DATE)
	print("taglist:")
	print(taglist.SVN_VERSION)
	print(taglist.SVN_DATE)
end

-- print results
function printResults(fOk, msgs)
	local strType = fOk and "Warning" or "Error"
	if type(msgs)=="string" and msgs~= "" then
		printf("%s: %s", strType, msgs)
	elseif type(msgs)=="table" then
		for _, strMsg in ipairs(msgs) do
			if strMsg ~= "" then
				printf("%s: %s", strType, strMsg)
			end
		end
	end
end


local iMode = nil
local MODE_HELP = 1
local MODE_HELP_TAGS = 2
local MODE_HELP_CONST = 3
local MODE_VERSION = 4
local MODE_SETTAGS = 5
local MODE_EDIT = 6
local MODE_LIST = 7
local MODE_DIFF = 8

local fArgsOk = false
local iArg = 1
local strInputFile, strInputFile2
local strTagsFile
local strOutputFile

-- 1st argument: mode
if #arg == 0 then
	iMode = MODE_HELP
	fArgsOk = true
elseif iArg <= #arg then
	local strMode = arg[iArg]
	if strMode=="-h" or strMode=="/h" or strMode=="/?" or strMode=="help" then
		iMode = MODE_HELP
		iArg = iArg + 1
		
	elseif strMode=="help_tags" then
		iMode = MODE_HELP_TAGS
		iArg = iArg + 1
		
	elseif strMode=="help_const" then
		iMode = MODE_HELP_CONST
		iArg = iArg + 1
		
	elseif strMode=="-version" then
		iMode = MODE_VERSION
		iArg = iArg + 1
		
	elseif strMode=="settags" then
		iMode = MODE_SETTAGS
		iArg = iArg + 1
		
	elseif strMode=="edit" then
		iMode = MODE_EDIT
		iArg = iArg + 1
		
	elseif strMode=="list" then
		iMode = MODE_LIST
		iArg = iArg + 1
	
	elseif strMode=="diff" then
		iMode = MODE_DIFF
		iArg = iArg + 1
	end

end

-- optional: -v/-debug
utils.setvbs_quiet()

if iArg <= #arg and arg[iArg]=="-v" then
	utils.setvbs_verbose()
	iArg = iArg+1
end

if iArg <= #arg and arg[iArg]=="-debug" then
	utils.setvbs_debug()
	iArg = iArg+1
end

local iRemArgs = #arg - iArg + 1

-- mode-specific arguments
if (iMode==MODE_HELP or
	iMode==MODE_HELP_TAGS or
	iMode==MODE_HELP_CONST or
	iMode==MODE_VERSION) and iRemArgs == 0 then
	fArgsOk = true
	
elseif iMode==MODE_LIST and iRemArgs == 1 then
	strInputFile = arg[iArg]
	iArg = iArg+1
	fArgsOk = true
	
elseif iMode==MODE_DIFF and iRemArgs == 2 then
	strInputFile = arg[iArg]
	strInputFile2 = arg[iArg+1]
	iArg = iArg+2
	fArgsOk = true
	
elseif (iMode==MODE_SETTAGS or 
		iMode==MODE_EDIT) and iRemArgs == 3 then
	strInputFile = arg[iArg]
	strTagsFile = arg[iArg+1]
	strOutputFile = arg[iArg+2]
	iArg = iArg+3
	fArgsOk = true
end

-- execute
local fOk, msgs
if not iMode or not fArgsOk then
	printUsage()
	fOk = false
	
elseif iMode == MODE_HELP then
	printUsage()
	fOk = true
	
elseif iMode==MODE_HELP_TAGS then
	taglist.listKnownTags()
	fOk = true
	
elseif iMode==MODE_HELP_CONST then
	taglist.listValueConstants()
	fOk = true
	
elseif iMode==MODE_VERSION then
	printVersion()
	fOk = true

elseif iMode == MODE_SETTAGS then
	fOk, msgs = replacetags(strInputFile, strTagsFile, strOutputFile)
	
elseif iMode == MODE_EDIT then
	fOk, msgs = edit(strInputFile, strTagsFile, strOutputFile)
	
elseif iMode==MODE_LIST then
	fOk, msgs = listTagsAndDevHdr(strInputFile)
	
elseif iMode==MODE_DIFF then
	fOk, msgs = listdiffs(strInputFile, strInputFile2)
end

printResults(fOk, msgs)

if fOk then
	os.exit(0)
else
	os.exit(1)
end
