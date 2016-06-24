---------------------------------------------------------------------------
-- Copyright (c) Hilscher Gesellschaft fuer Systemautomation mbH. 
-- All Rights Reserved.
--
-- $Id:  $:
--
-- Description:
--   Writes the tag definitions to a file in JSON format.
--
---------------------------------------------------------------------------

module("tagdefs2json", package.seeall)


--[[
{
    "structDefs" : {
        "TAG_BSL_SDRAM_PARAMS_DATA_T" : {
                "fields" : [
                        { "datatype" : "UINT32", "name" : "ulGeneralCtrl", "desc" : "General Control", "editorParam" : { "format" : "0x%08x" }},
                        { "datatype" : "UINT32", "name" : "ulTimingCtrl", "desc" : "Timing Control", "editorParam" : { "format" : "0x%08x" }}
                ]
        },
        ...
    },
    "tags" : {
        "TAG_BSL_SDRAM_PARAMS" : {
            "id" : "0x40000000",
            "datatype" : "TAG_BSL_SDRAM_PARAMS_DATA_T",
            "desc" : "SDRAM"
        },
        ...
    }
}
--]]

--------------------------------------------------------------------------
-- write out structure as JSON
--------------------------------------------------------------------------

-- If outfd is a descriptor of an open file, the output is written ot 
-- the file. If it is nil, the output is written to stdout.
outfd = nil

function write(...)
	local l = {...}
	for i=1, table.maxn(l) do
		if outfd then
			outfd:write(l[i])
		else
			io.write(l[i])
		end
	end
end

function writeln(...)
	write(...)
	write("\n")
end

function print_json(tData, tKeyOrder, iIndent)
	iIndent = iIndent or 0
	local strIndent = string.rep(" ", iIndent)
	local iSubIndent = iIndent + 4
	local strSubIndent = string.rep(" ", iSubIndent)
	
	tKeyOrder = tKeyOrder or {}
	
	if type(tData) == "table" and tData[1] then
		-- Print an array.
		local iLen = table.maxn(tData)
		writeln("[")
		for i = 1, iLen do
			write(strSubIndent)
			print_json(tData[i], tKeyOrder, iSubIndent)
			if i<iLen then
				writeln(",")
			else
				writeln()
			end
		end
		write(strIndent, "]")
		
	elseif type(tData) == "table" then
		-- Print key-value list.
		
		-- Put the key-value pairs in the right order:
		-- first all those whose key is in the key ordering list,
		-- then any others.
		local keys_done = {}
		local astrKeys = {}
		
		for i, strKey in ipairs(tKeyOrder) do
			if tData[strKey] then
				table.insert(astrKeys, strKey)
				keys_done[strKey] = true
			end
		end
		
		for strKey, tValue in pairs(tData) do
			if not keys_done[strKey] then
				table.insert(astrKeys, strKey)
			end
		end
		
		-- Print the key-value pairs in the determined order.
		writeln("{")
		for i, strKey in ipairs(astrKeys) do
			local tValue = tData[strKey]
			write(strSubIndent, '"', strKey, '" : ')
			print_json(tValue, tKeyOrder[strKey], iSubIndent )
			if i<#astrKeys then
				writeln(",")
			else
				writeln()
			end
		end
		write(strIndent, "}")
		
	elseif type(tData) == "number" then
		-- Print numbers < 1000 in decimal, larger ones in hex.
		if tData < 1000 then
			write('"', tostring(tData), '"')
		else
			write(string.format('"0x%08x"', tData))
		end
		
	elseif type(tData) == "string" then
		write('"', tostring(tData), '"')
		
	elseif type(tData) == "boolean" then
		write('"', tostring(tData), '"')
	
	elseif type(tData) == "nil" then
		write('null')
		
	else 
		error ("unknown type: " .. type(tData))
	end
	
	--writeln(",")
end


--------------------------------------------------------------------------
-- conversion/adaption of the tag definitions
--------------------------------------------------------------------------

tJsonKeyOrder_tag = {"id", "datatype", "desc"}

tJsonKeyOrder_structDef={
	"fields", "layout",
	fields = {
		"datatype", "name", "desc", "offset", "mask", "size", "mode", "editor", "editorParam",
		editorParam = {
			"nBits", "values", "onValue", "offValue", "otherValues",
			values = {
				"name", "value"
			}
		}
	},
	layout = {
		"sizer", "box", "cols", "children"
	}
}

tJsonKeyOrder_structDef.layout.children = tJsonKeyOrder_structDef.layout

function insertKeyOrder (tKeyOrder, strKey, tSubKeyOrder)
	table.insert(tKeyOrder, strKey)
	tKeyOrder[strKey] = tSubKeyOrder
end

	-- todo: make sure datatypes used by the members are written out
function adaptTypeDef(tTypeDef)
	-- move member definitions to subtable "fields"
	tTypeDef.fields = {}
	for i, e in ipairs(tTypeDef) do
		tTypeDef.fields[i] = e
		tTypeDef[i] = nil
		
		-- in each member definition, rename index 1 to "datatype", 2 to "name"
		-- Do not do this if the index "datatype" exists, as this entry has
		-- already been processed before and is referenced from somewhere else.
		if e.datatype == nil then
			e.datatype = e[1]
			e.name = e[2]
			e[1] = nil
			e[2] = nil
			if e.mask then
				e.mask = mask2number(e.mask)
			end
		end
		
		-- adapt layout definition
		if tTypeDef.layout and table.maxn(tTypeDef.layout) > 0 then
			adaptTypeDef_Layout(tTypeDef.layout)
		end
		
		-- remove "configure GUI" function
		tTypeDef.configureGui = nil
	end
end

-- If a layout is present, move positional indices to 
function adaptTypeDef_Layout(tLayout)
	tLayout.children = {}
	for i=1, table.maxn(tLayout) do
		local tEntry = tLayout[i]
		tLayout.children[i] = tEntry
		tLayout[i] = nil
		if type(tEntry) == "table" then
			adaptTypeDef_Layout(tEntry)
		end
	end
end

-- convert a binary mask, e.g. string.char(0x01, 00, 00, 00) 
-- to an ascii/hex number, e.g. "0x00000001"
function mask2number(strMask)
	local iLen = strMask:len()
	local astrFormats = {
		"0x%02x",
		"0x%04x",
		"0x%08x",
		"0x%08x"
	}
	local strFormat = astrFormats[iLen]
	assert(strFormat, "mask value has strange len: " .. iLen)
	
	local iMask = 0
	local iByteVal = 1
	for i=1, iLen do
		iMask = iMask + strMask:byte(i) * iByteVal
		iByteVal = iByteVal * 256
	end
	
	return string.format(strFormat, iMask)
end

predefined_types = {
	STRING  = true,
	UINT8   = true,
	UINT16  = true,
	UINT32  = true,
	rcxver  = true,
	bindata = true,
}

function insertTypeDef(strTypeName, atJson, tJsonKeyOrder)
	if atJson.structDefs[strTypeName] == nil and not predefined_types[strTypeName] then
		local tTypeDef = taglist.getStructDef(strTypeName)
		assert(tTypeDef, "Error: can't find definition to type " .. strTypeName)
		adaptTypeDef(tTypeDef)
		atJson.structDefs[strTypeName] = tTypeDef
		
		-- Find any field types which have not been included yet,
		-- and process these recursively.
		-- Add them before the current type.
		for i, tFieldDef in pairs(tTypeDef.fields) do
			local strFieldType = tFieldDef.datatype
			assert(strFieldType, strType)
			insertTypeDef(strFieldType, atJson, tJsonKeyOrder)
		end
		
		insertKeyOrder(tJsonKeyOrder.structDefs, strTypeName, tJsonKeyOrder_structDef)
	end
end

function tagdefs2json()
	
	local atJson = {
		structDefs = {},
		tags = {},
	}
	
	local tJsonKeyOrder = {
		"structDefs", "tags",
		structDefs = {},
		tags = {},
	}
	
	local atLuaTags = taglist.get_tags_by_id()
	-- Each entry consists of:
	-- key = table key
	-- id =  paramtype
	-- desc = desc
	-- datatype = datatype
	
	for i, tTag in ipairs(atLuaTags) do
	--for i = 1, 2 do
		--tTag = atLuaTags[i]
		local strKey = tTag.key
		tTag.key = nil
		atJson.tags[strKey] = tTag
		insertKeyOrder(tJsonKeyOrder.tags, strKey, tJsonKeyOrder_tag)
		
		-- get the struct def.
		local strTypeName = tTag.datatype
		insertTypeDef(strTypeName, atJson, tJsonKeyOrder)
	end
	
	print_json(atJson, tJsonKeyOrder, 0)
end

function tagdefs2json_main(strOutputFile)
	local fOk = false
	if strOutputFile then
		local fd, msg = io.open(strOutputFile, "w")
		if fd == nil then	
			return false, msg
		else
			assert(fd, msg)
			outfd = fd
			local fOk, strError = pcall(tagdefs2json)
			fd:close()
			return fOk, strError
		end
	else
		outfd = nil
		return pcall(tagdefs2json)
	end
end