---------------------------------------------------------------------------
-- Copyright (C) 2010 Hilscher Gesellschaft für Systemautomation mbH
--
-- Description:
--   Tag definitions for Taglist editor
--
--  Changes:
--    Date        Author        Description
---------------------------------------------------------------------------
--  2011-05-11    SL            factored out the tag definitions, added 
--                              functions to register tags, data types,
--                              constants, help files
--  2011-04-15    MT            added new FSU MMIO Layout (netX50)
--  2011-03-14    SL            corrected type and range of device/vendor 
--                              ID in TAG_PN_DEVICEID_DATA_T
--  2011-02-23    SL            updated tag IDs
--  2011-02-11    SL            added RCX_TAG_DP_DEVICEID 
--                                    RCX_TAG_EIP_DEVICEID
--                                    RCX_TAG_DEVICENET_DEVICEID
--                                    RCX_TAG_COMPONET_DEVICEID
--                                    RCX_TAG_CO_DEVICEID 
--                                    RCX_TAG_CCL_DEVICEID
--                                    RCX_TAG_PN_DEVICEID 
--                                    RCX_TAG_EIP_EDD_CONFIGURATION
--  2010-10-14    SL/YZ         added RCX_TAG_ETHERNET_PARAMS, 
--                                    RCX_TAG_FIBER_OPTIC_IF_DMI_NETX50_PARAMS
--                                    RCX_TAG_FIBER_OPTIC_IF_DMI_NETX100_PARAMS
--  2010-09-13    MS            added TAG_BSL_DISK_POS_PARAMS
--  2010-09-08    MS            added TAG_BSL_MMIO_NETX50_PARAMS
--                                    TAG_BSL_MMIO_NETX10_PARAMS 
--                                    TAG_BSL_HIF_NETX10_PARAMS 
--                                    TAG_BSL_USB_DESCR_PARAMS
--  2010-08-27    MS            added RCX_TAG_TASK_T
--                                    RCX_TAG_INTERRUPT_T
--  2010-08-03    SL            added functions for tagtool
--  2010-06-28    SL            added diag interface tags
--  2010-07-30    SL            serialize/deserialize, value constants
--                              support for command line tool
--  2010-08-13    SL            recognizes and corrects abnormal end marker

---------------------------------------------------------------------------

module("taglist", package.seeall)

---------------------------------------------------------------------------
-- SVN Keywords
--
SVN_DATE   ="$Date$"
SVN_VERSION="$Revision$"
-- $Author$
---------------------------------------------------------------------------



require("utils")
local vbs_printf = utils.vbs_printf
local dbg_printf = utils.dbg_printf
local msg_printf = utils.msg_printf
local err_printf = utils.err_printf
local vbs_print = utils.vbs_print
local dbg_print = utils.dbg_print
local msg_print = utils.msg_print
local err_print = utils.err_print
local function printf(...) print(string.format(...)) end


muhkuh.include("numedit.lua", "numedit")
muhkuh.include("rcxveredit.lua", "rcxveredit")


--[[
This module contains functions and definitions related to
taglists, tags AND structures.

Tags:
memsize = {paramtype = 0x800, datatype="UINT32", desc="Memory Size"},
RCX_TAG_LED =
    {paramtype = 0x00001040, datatype ="RCX_TAG_LED_T", desc="LED description"},
->  {ulTag = ulTag, ulSize = ulSize, abValue = abValue }

Structs:
RCX_TAG_LED_T = {
  {"RCX_MOD_TAG_IDENTIFIER_T",              "tIdentifier",  mode="read-only"},
  {"UINT32",                                "ulUsesResourceType"},
    },
->  {{strName=..., abValue=..., ulSize=...} ...}

Headers:
COMMON_HEADER_SPEC = {
    {name="ulHeaderVersion"  ,offset=0, type="uint32", default = 0}, -- insert real value
    {name="aulMD5"           ,offset=20, type="bin", len=16},
}
->  header[strKey]=value



Size information is in several places:
- in the chunks of the binary structure, also in the list representation
- in the list representation of a struct value
- in the datatype definitions
- in the parameter definitions
- in the struct member definitions

How to add a new tag:
1)
The table rcx_mod_tags contains mappings of the tag id numbers to structure definitions.
Insert an entry of the form
RCX_TAG_TASK_GROUP =
    {paramtype = 0x00001000, datatype="RCX_TAG_TASK_GROUP_T", desc="Task Group"},
where
RCX_TAG_TASK_GROUP is an internal key,
paramtype is the tag id number,
datatype is the name under which the data portion of the tag is defined in the datatypes list and
desc is a string which appears in the tag selection area in the editor.

2)
Add the structure definition to the datatypes table.
RCX_TAG_TASK_GROUP_T = {
  {"STRING", "szTaskListName",   desc="Task List Name", size=64, mode="read-only"},
  -- base priority for the tasks in the group
  {"UINT32", "ulBasePriority",
  desc="Base Priority",          editor="comboedit", editorParam=COMBO_TASKPRIO},
  -- base token for the tasks in the group
  {"UINT32", "ulBaseToken",
  desc="Base Token",             editor="comboedit", editorParam=COMBO_TASKTOKEN},
  -- range for priority and token
  {"UINT32", "ulRange",
  desc="Task Range",   editorParam={format="%u"}, mode="read-only"},
  -- group reference number (common to all tasks in the group)
  {"UINT32", "ulTaskGroupRef", desc="Task Group Ref.", mode="read-only"},
  nameField = "szTaskListName"
    },

where
RCX_TAG_TASK_GROUP_T is the same data type name used in the entry in rcx_mod_tags
   member type  internal name          Screen name
  {"STRING", "szTaskListName",   desc="Task List Name", size=64, mode="read-only"},

3)
Create a HTML help page for the tag and add it to the nxoeditor/help directory.
Add an entry to the HELP_MAPPING table:
    RCX_TAG_TASK_GROUP         = {file="RCX_TAG_TASK_GROUP_T.htm"},
RCX_TAG_TASK_GROUP is the key used in rcx_mod_tags.
Add the HTML page to the SVN and to the installer.


--]]


---------------------------------------------------------------------------
--   Value constants
---------------------------------------------------------------------------
CONSTANTS = {}

-- Add a single named constant
-- example:
-- addConstant ("EIP_XC_TYPE_DLR_2PORT_SWITCH", 1)
function addConstant(strName, ulValue)
	CONSTANTS[strName] = ulValue
end

-- Add a list of named constants
-- example:
-- addConstants({
--     EIP_XC_TYPE_DLR_2PORT_SWITCH          = 1,
-- })
function addConstants(l)
	for k, v in pairs(l) do
		CONSTANTS[k]=v
	end
end

-- Add a list of combo box choices as constants
-- example:
-- addComboAsConstants({
--    {name="UNDEFINED"           ,value =  0x0000},
--    {name="UNCLASSIFIABLE"      ,value =  0x0001},
--    {name="CHIP_NETX_500"       ,value =  0x0002},
--     ...
-- })
function addComboAsConstants(l)
	for entry in ipairs(l) do
		assert(entry.name and entry.value, "name/value missing from Combo entry")
		CONSTANTS[entry.name] = entry.value
	end
end


function resolveValueConstant(strConst)
    strConst = CONSTANT_ALIASES[strConst] or strConst
    return CONSTANTS[strConst]
end

function listValueConstants()
    local aastrAliases = {}
    for strAltTagname, strTagname in pairs(CONSTANT_ALIASES) do
        aastrAliases[strTagname] = aastrAliases[strTagname] or {}
        table.insert(aastrAliases[strTagname], strAltTagname)
    end

    -- sort constants by name
    local atSortedConstants = {}
    for strName, ulValue in pairs(CONSTANTS) do
        table.insert(atSortedConstants, {
            strName = strName,
            ulValue = ulValue
        })
    end
    table.sort(atSortedConstants, function(a,b) return a.strName < b.strName end)

    -- print
    print()
    print("Name                                      Value hex/dec")
    print("--------------------------------------------------------")
    for i, tConst in ipairs(atSortedConstants) do
        printf("%-40s 0x%08x %d", tConst.strName, tConst.ulValue, tConst.ulValue)
        local astrAliases = aastrAliases[tConst.strName]
        if astrAliases then
            for j, strAlias in ipairs(astrAliases) do
                printf("  Alias: %s", strAlias)
            end
        end
    end
end




---------------------------------------------------------------------------
--   Backward Compatibility Definitions
---------------------------------------------------------------------------

TAGNAME_ALIASES = {
    -- tag type codes for NXO specific tags
    RCX_MOD_TAG_IT_STATIC_TASKS                  ="RCX_TAG_TASK_GROUP",
    RCX_MOD_TAG_IT_TIMER                         ="RCX_TAG_TIMER",
    RCX_MOD_TAG_IT_INTERRUPT                     ="RCX_TAG_INTERRUPT_GROUP",
    RCX_MOD_TAG_IT_LED                           ="RCX_TAG_LED",
    RCX_MOD_TAG_IT_XC                            ="RCX_TAG_XC",
}

CONSTANT_ALIASES = {
    -- resource codes for LED tag
    RCX_MOD_TAG_IT_LED_RESOURCE_TYPE_PIO         ="RCX_LED_RESOURCE_TYPE_PIO",
    RCX_MOD_TAG_IT_LED_RESOURCE_TYPE_GPIO        ="RCX_LED_RESOURCE_TYPE_GPIO",
    RCX_MOD_TAG_IT_LED_RESOURCE_TYPE_HIFPIO      ="RCX_LED_RESOURCE_TYPE_HIFPIO",

    -- polarity codes for LED tag
    RCX_MOD_TAG_IT_LED_POLARITY_NORMAL           ="RCX_LED_POLARITY_NORMAL",
    RCX_MOD_TAG_IT_LED_POLARITY_INVERTED         ="RCX_LED_POLARITY_INVERTED",
}



---------------------------------------------------------------------------
-- The elementary data types. Each entry may contain:
-- size, if the size is constant for all instances of the type
-- editor, the lua package name of the editor control
-- editorParam, parameters to pass to the editor control at instantiation
---------------------------------------------------------------------------
datatypes = {
UINT32 = {size=4, editor="numedit"},
UINT16 = {size=2, editor="numedit", editorParam={nBits=16}},
UINT8 = {size=1, editor="numedit", editorParam={nBits=8}},
STRING = {editor="stringedit"},
rcxver = {size=8, editor="rcxveredit"},

-- for unused tags
mac = {size=6, editor="macedit"},
ipv4 = {size=4, editor="ipv4edit"},
bindata = {editor="hexedit"},
}



---------------------------------------------------------------------------
-- structure definitions.
-- table keys are the type names used where a structure occurs as a tag,
-- or as a substructure. The entries have the form {"type", "member name"}.
-- "leaf" datatypes: UINT8, UINT16, UINT32, 16 byte string, 63 byte string

-- actually, the structure member names are now only used internally; if
-- the desc strings are unique, we might as well use those instead.
-- possible todo: enhance makeErrorStrings to use desc strings instead of member names.
---------------------------------------------------------------------------

structures = {}

-- Add a single structure definition
function addDataType(strName, tDef)
	structures[strName] = tDef
end

-- Add a list of structure definitions
function addDataTypes(l)
	for k, v in pairs(l) do
		structures[k]=v
	end
end


function registerStructType(structname, structdef)
    structures[structname]=structdef
end


function getStructDef(strTypeName)
    return structures[strTypeName]
end

-- isReadOnly is also used with tag defs in checklist_taglistedit
-- (might be removed there)
function isReadOnly(tDef)
    return tDef.mode=="read-only"
end


function isHidden(tDef)
    return tDef.mode=="hidden"
end





---------------------------------------------------------------------
--                primitive value conversions
---------------------------------------------------------------------



-- If the string contains a zero byte, strip the zero and everything behind it
function deserialize_string(abStr)
    local iZeroPos = string.find(abStr, string.char(0), 1, true)
    if iZeroPos then
        return string.sub(abStr, 1, iZeroPos-1)
    else
        return abStr
    end
end


function parseUINT(strNum, iMax)
    local iNum = tonumber(strNum)
    if not iNum then
        return nil, string.format("Can't parse %s as a number", strNum or "<nil>")
    elseif iNum>iMax then
        return nil, string.format("number exceeds maximum: %d (max. %d)", iNum, iMax)
    else
        return iNum
    end
end

-- Note:
-- The deserializer for strings removes anything starting from the first 0-byte, if present.
-- The serializer does NOT pad the string with zeros, as it does not know the required size.
-- This has to be done in the structure serializer.

primitive_type_deserializers = {
    UINT8 = function(abValue) return numedit.binToUint(abValue, 0, 8) end,
    UINT16 = function(abValue) return numedit.binToUint(abValue, 0, 16) end,
    UINT32 = function(abValue) return numedit.binToUint(abValue, 0, 32) end,
    STRING = deserialize_string,
    rcxver = rcxveredit.deserialize_version
}

primitive_type_serializers = {
    UINT8 = function(iValue) return numedit.uintToBin(iValue, 8) end,
    UINT16 = function(iValue) return numedit.uintToBin(iValue, 16) end,
    UINT32 = function(iValue) return numedit.uintToBin(iValue, 32) end,
    STRING = function(abValue) return abValue end,
    rcxver = rcxveredit.serialize_version
}

primitive_type_parsers = {
    UINT8 = function(strNum) return parseUINT(strNum, 2^8-1) end,
    UINT16 = function(strNum) return parseUINT(strNum, 2^16-1) end,
    UINT32 = function(strNum) return parseUINT(strNum, 2^32-1) end,
    STRING = function(abValue) return abValue end,
    rcxver = function(strValue) return strValue end
}

primitive_type_tostring = {
    UINT8 = function(iNum) return string.format("0x%02x", iNum) end,
    UINT16 = function(iNum) return string.format("0x%04x", iNum) end,
    UINT32 = function(iNum) return string.format("0x%08x", iNum) end,
    STRING = function(abValue) return string.format('"%s"', abValue) end,
    rcxver = function(strValue) return strValue end
}

function isPrimitiveType(strTypeName)
    return primitive_type_deserializers[strTypeName] and true
end

function parsePrimitiveType(strTypeName, strValue)
    local fnConv = primitive_type_parsers[strTypeName]
    if fnConv then return fnConv(strValue) end
end

function primitiveTypeToString(strTypeName, strValue)
    local fnConv = primitive_type_tostring[strTypeName]
    if fnConv then return fnConv(strValue) end
end

function deserializePrimitiveType(strTypeName, abValue)
    local fnConv = primitive_type_deserializers[strTypeName]
    if fnConv then return fnConv(abValue) end
end

function serializePrimitiveType(strTypeName, value)
    local fnConv = primitive_type_serializers[strTypeName]
    if fnConv then return fnConv(value) end
end


---------------------------------------------------------------------
--                split/reconstruct structures
---------------------------------------------------------------------

-- used to separate structure members located at the same offset
function stringAnd(str1, str2)
    local strRes = ""
    if (str1:len() ~= str2:len()) then
        error (string.format("stringAnd: str1 %d bytes, str2 %d bytes", str1:len(), str2:len()))
    else
        for i=1, str1:len() do
            strRes = strRes .. string.char(bit.band(str1:byte(i), str2:byte(i)))
        end
    end
    return strRes
end

-- used to combine structure members located at the same offset
function stringOr(str1, str2)
    local strRes = ""
    if (str1:len() ~= str2:len()) then
        error (string.format("stringAnd: str1 %d bytes, str2 %d bytes", str1:len(), str2:len()))
    else
        for i=1, str1:len() do
            strRes = strRes .. string.char(bit.bor(str1:byte(i), str2:byte(i)))
        end
    end
    return strRes
end

--- split a structure value into separate fields.
-- @param strTypeName the structure type name
-- @param abValue the binary value of the structure
-- @return a list of member values. Each element has the form
-- {strName=..., abValue=..., ulSize=...}
function splitStructValue(strTypeName, abValue)
    local elements = {}
    local iPos = 0 -- position inside abValue
    local strMemberName, strMemberType, ulMemberSize, abMemberValue
    local tStructDef = getStructDef(strTypeName)

    for index, tMemberDef in ipairs(tStructDef) do
        iPos = tMemberDef.offset or iPos
        strMemberName, strMemberType = tMemberDef[2], tMemberDef[1]
        ulMemberSize = getStructMemberSize(tMemberDef)
        abMemberValue = string.sub(abValue, iPos+1, iPos+ulMemberSize)
        if tMemberDef.mask then
            abMemberValue = stringAnd(abMemberValue, tMemberDef.mask)
        end
        iPos = iPos + ulMemberSize
        elements[index] =
            {strName = strMemberName,
             strType = strMemberType,
             ulSize = ulSize,
             abValue = abMemberValue}
    end

    if tStructDef.fBinToStruct then
        elements = tStructDef.fBinToStruct(abValue, elements)
    end
    return elements
end



--- join structure members into the whole structure.
-- @param strTypeName the structure type name
-- @param elements the names and values of the elements
-- Elements have the form {strName=..., abValue=..., ulSize=...}
-- @return the binary of the structure
function joinStructElements(strTypeName, elements)
    local tStructDef = getStructDef(strTypeName)
    local bin = ""

    if tStructDef.fStructToBin then
        bin = tStructDef.fStructToBin(elements)
    else
        local strMemberName, strMemberType, ulMemberSize, abMemberValue
        for index, tMemberDef in ipairs(tStructDef) do
            abMemberValue = elements[index].abValue

            ulMemberSize = getStructMemberSize(tMemberDef)
            assert(ulMemberSize == abMemberValue:len(),
                string.format("struct member size has changed: actual = %u, correct = %u",
                abMemberValue:len(), ulMemberSize))

            local iOffset = tMemberDef.offset
            if iOffset and bin:len() > iOffset then
                bin = string.sub(bin, 1, iOffset) ..
                    stringOr(string.sub(bin, iOffset+1), abMemberValue)
            else
                bin = bin .. abMemberValue
            end
        end
    end

    return bin
end



-- If fRecursive = true, member.tValue is serialized.
-- If false, member.abValue is used.
function serialize(strTypeName, atMembers, fRecursive)
    if isPrimitiveType(strTypeName) then
        return serializePrimitiveType(strTypeName, atMembers)
    end

    local tStructDef = getStructDef(strTypeName)
    local bin = ""
    if not tStructDef then
        return nil
    end


    if tStructDef.fStructToBin then
        bin = tStructDef.fStructToBin(atMembers)
    else
        local strMemberName, strMemberType, ulMemberSize, abMemberValue
        local tMember, abMemberValue, strError
        for index, tMemberDef in ipairs(tStructDef) do
            strMemberName, strMemberType = tMemberDef[2], tMemberDef[1]

            -- get binary value
            tMember = atMembers[index]
            if fRecursive and tMember.tValue then
                abMemberValue, strError = serialize(strMemberType, tMember.tValue, fRecursive)
                if not abMemberValue then
                	return nil, strError
                end
                tMember.abValue = abMemberValue
            else
                abMemberValue = tMember.abValue
            end
            assert(abMemberValue,
                string.format("failed to get binary value for %s.%s", strTypeName, strMemberType))

            -- check size
            -- pad strings to the required size. Error if this size is exceeded.
            ulMemberSize = getStructMemberSize(tMemberDef)
            ulActualSize = abMemberValue:len()
            if strMemberType=="STRING" then
                if ulActualSize<ulMemberSize then
                    abMemberValue = abMemberValue .. string.rep(string.char(0), ulMemberSize - ulActualSize)
                    ulActualSize = ulMemberSize
                elseif ulActualSize>ulMemberSize then
                    return nil, string.format(
                        "string too long: %s max. size = %d actual size = %d", 
                        strMemberName, ulMemberSize, ulActualSize)
                end 
            end
            assert(ulMemberSize == abMemberValue:len(),
                string.format("struct member size has changed: actual = %u, correct = %u",
                abMemberValue:len(), ulMemberSize))

            -- append to structure binary, handle overlayed members
            local iOffset = tMemberDef.offset
            if iOffset and bin:len() > iOffset then
                bin = string.sub(bin, 1, iOffset) ..
                    stringOr(string.sub(bin, iOffset+1), abMemberValue)
            else
                bin = bin .. abMemberValue
            end
        end
    end

    return bin
end




-- convert abValue into a list of members
-- each having strName, strType, ulSize, abValue
-- if fRecursive = true, parse each abValue and store result in tValue
function deserialize(strTypeName, abValue, fRecursive)
    if isPrimitiveType(strTypeName) then
        return deserializePrimitiveType(strTypeName, abValue)
    end
    local tStructDef = getStructDef(strTypeName)
    if not tStructDef then
        return abValue
    end

    local iPos = 0 -- position inside abValue
    local atMembers = {}
    local strMemberName, strMemberType, ulMemberSize, abMemberValue, tMemberValue

    for index, tMemberDef in ipairs(tStructDef) do
        iPos = tMemberDef.offset or iPos
        strMemberName, strMemberType = tMemberDef[2], tMemberDef[1]
        ulMemberSize = getStructMemberSize(tMemberDef)
        abMemberValue = string.sub(abValue, iPos+1, iPos+ulMemberSize)
        if tMemberDef.mask then
            abMemberValue = stringAnd(abMemberValue, tMemberDef.mask)
        end
        tMemberValue = fRecursive and deserialize(strMemberType, abMemberValue, fRecursive) or nil
        atMembers[index] =
            {strName = strMemberName,
             strType = strMemberType,
             ulSize = ulSize,
             abValue = abMemberValue,
             tValue = tMemberValue
             }
        iPos = iPos + ulMemberSize
    end

    if tStructDef.fBinToStruct then
        atMembers = tStructDef.fBinToStruct(abValue, atMembers)
    end
    return atMembers
end


---------------------------------------------------------------------
--                       print a structure
---------------------------------------------------------------------

-- make format string for member names
function makeMemberFormatString(tStruct)
    local iMaxNameLen = 0
    for iMember, tMember in ipairs(tStruct) do
        if isPrimitiveType(tMember.strType) and tMember.strName:len()>iMaxNameLen then
            iMaxNameLen = tMember.strName:len()
        end
    end
    return "%-" .. tostring(iMaxNameLen) .. "s"
end

-- recursively print a structure
-- fPretty = false:
-- prints nested structure members with full member path, e.g.
--    .tDpmIsaAuto.ulIfConf0 = 0x00000000
-- fPretty = true:
-- prints nested structures enclosed in { }, e.g.
--    .tDpmIsaAuto = {
--        .ulIfConf0 = 0x00000000
--        ...
--     }

function printStructure(tStruct, fPretty, strIndent)
    strIndent = strIndent or ""
    if type(tStruct)=="table" then
        -- print the members
        local strNameFormat = makeMemberFormatString(tStruct)
        for iMember, tMember in ipairs(tStruct) do
            local strName = string.format(strNameFormat, tMember.strName)
            if isPrimitiveType(tMember.strType) then
                local strValue = primitiveTypeToString(tMember.strType, tMember.tValue)
                printf("%s.%s = %s", strIndent, strName, strValue)
            elseif type(tMember.tValue)=="table" then
                if fPretty then
                    printf("%s.%s = {",  strIndent, tMember.strName)
                    printStructure(tMember.tValue, fPretty, strIndent.."    ")
                    printf("%s }",  strIndent)
                else
                    printStructure(tMember.tValue, fPretty, strIndent .. "." .. tMember.strName)
                end
            else
                printf("%s.%s = %s(%s)", strIndent, tMember.strName, tostring(tMember.tValue), type(tMember.tValue))
            end
        end
    else
        printf("%s (string)", strIndent)
    end
end

---------------------------------------------------------------------
-- Check if two structures are structurally identical, i.e.
-- they have the same number, names and types of members.
---------------------------------------------------------------------
function checkStructuralIdentity(tStruct1, tStruct2)
    if type(tStruct1)~="table" then
        return false, "arg1 is not a structure"
    elseif type(tStruct2)~="table" then
        return false, "arg2 is not a structure"
    elseif #tStruct1~=#tStruct2 then
        return false, "arg1 and arg2 do not have the same number of members"
    else
        for iMember = 1, #tStruct1 do
            local tMember1 = tStruct1[iMember]
            local tMember2 = tStruct2[iMember]

            if not tMember1 or not tMember2 or
                tMember1.strName ~= tMember2.strName or
                tMember1.strType ~= tMember2.strType then
                return false, "structures do not have the same members"
            end
        end
    end

    return true
end



---------------------------------------------------------------------
-- Compare the values in two structures with the same type.
-- Members with equal values are listed as by printStructure,
-- members with different values are listed as
-- SET fieldname = <value in tStruct2>
---------------------------------------------------------------------
function printStructureDiffs(tStruct1, tStruct2, strIndent)
    strIndent = strIndent or ""

    local fOk, strError = checkStructuralIdentity(tStruct1, tStruct2)
    if not fOk then
        return fOk, strError
    end

    local strNameFormat = makeMemberFormatString(tStruct2)

    -- compare and print the members
    for iMember = 1, #tStruct2 do
        local tMember1 = tStruct1[iMember]
        local tMember2 = tStruct2[iMember]
        local strName = string.format(strNameFormat, tMember2.strName)
        if isPrimitiveType(tMember2.strType) then
            local strValue = primitiveTypeToString(tMember2.strType, tMember2.tValue)
            if tMember1.tValue == tMember2.tValue then
                printf("    %s.%s = %s", strIndent, strName, strValue)
            else
                printf("SET %s.%s = %s", strIndent, strName, strValue)
            end
        elseif type(tMember2.tValue)=="table" then
            local fOk, msg = printStructureDiffs(tMember1.tValue, tMember2.tValue, strIndent .. "." .. tMember2.strName, fPretty)
            if not fOk then
                return fOk, msg
            end
        else
            printf("%s.%s = %s(%s)", strIndent, tMember2.strName, tostring(tMember2.tValue), type(tMember2.tValue))
        end
    end
    return true
end



     
---------------------------------------------------------------------------
-- RCX_MOD_TAG definitions (mapping from tag number to type name)
-- paramtype = the 32 bit tag number
-- datatype: the elementary or struct data type of this tag
-- desc = a string to be displayed in the GUI
---------------------------------------------------------------------------



-- end marker
TAG_END = 0

-- tags whose number has its 31th bit set are to be ignored.
TAG_IGNORE_FLAG = 0x80000000

-- This list will contain the tag definitions
-- RCX_TAG_MEMSIZE = {paramtype = 0x800, datatype="RCX_TAG_MEMSIZE_T", desc="Memory Size"},
-- key       : name string which is also used in the help mapping and the tagname aliases mapping
-- paramtype : 32 bit tag ID
-- datatype  : name of the structure
-- desc      : descriptive string for the tag list overview in the editor
rcx_mod_tags = {}

-- add a tag definition
function addTag(strName, tTagDef)
	rcx_mod_tags[strName] = tTagDef
end

-- add several tag definition from a list
function addTags(l)
	for k,v in pairs(l) do
		rcx_mod_tags[k] = v
	end
end



--- Find the parameter description for a given parameter type
-- @param iParamType 32 bit tag number
-- @return name, desc
function getParamTypeDesc(ulTag)
    for k, v in pairs(rcx_mod_tags) do
        if v.paramtype == ulTag then return k,v end
    end
end


--- get the descriptor string and the definition of a tag.
-- If the tag doesn't have a descriptor string, return the
-- name of the tag.
-- @param ulTag a tag number
-- @return strDesc the description/name string of the tag
function getTagDescString(ulTag)
    local strKey, tDesc = getParamTypeDesc(ulTag)
    return (tDesc and tDesc.desc) or strKey
end


-- find the tag description given either
-- a key from rcx_mod_tags ("RCX_MOD_TAG_IT_STATIC_TASKS"),
-- an alternative key ("RCX_TAG_TASK_GROUP"), or
-- the desc value from an entry of rcx_mod_tags ("Task Group")
-- RCX_TAG_TASK_GROUP =
--    {paramtype = 0x00001000, datatype="RCX_TAG_TASK_GROUP_T", desc="Task Group"},
-- alternative keys? RCX_TAG_TASK_GROUP

function resolveTagName(strTagName)
    strTagName = TAGNAME_ALIASES[strTagName] or strTagName
    if rcx_mod_tags[strTagName] then
        return rcx_mod_tags[strTagName]
    end
    for k, v in pairs(rcx_mod_tags) do
        if v.desc == strTagName then
            return v
        end
    end
end


-- Extract the name string from a tag, if it has one.
-- @param tTag the list representation of the tag
-- (ulTag, ulSize, abValue)
-- @return the name string,
--  or the empty string if the tag does not have a name
function getTagInstanceName(tTag)
    local strTagName, tTagDesc = taglist.getParamTypeDesc(tTag.ulTag)
    assert(tTagDesc, "tag "..tTag.ulTag.." not found")
    local strTypeName = tTagDesc.datatype
    local tStructDef = getStructDef(strTypeName)
    if tStructDef and tStructDef.nameField then
        local tStruct = splitStructValue(strTypeName, tTag.abValue)
        for _, field in pairs(tStruct) do
            if field.strName==tStructDef.nameField then
                return field.abValue
            end
        end
    end
end



-- Returns a list of tags sorted by id, based on rcx_mod_tags.
-- Each entry consists of:
-- key = table key
-- id =  paramtype
-- desc = desc
-- datatype = datatype
function get_tags_by_id()
	local tags = {} 
	for k,v in pairs(rcx_mod_tags) do
		local e = {
			key = k,
			id = v.paramtype,
			desc = v.desc,
			datatype = v.datatype
		}
		table.insert(tags, e)
	end
	
	local function sort(e1, e2) 
		return e1.id < e2.id
	end
	
	table.sort(tags, sort)
	return tags
end

-- debugging:
-- generate a binary of a tag list containing one of any tag.
function makeEmptyParblock()
	local atTags = get_tags_by_id()
	local abParblock = ""
	for i, e in ipairs(atTags) do
		local strTagname = e.key
		local ulTagID = e.id
		local ulSize = getSize(strTagname)
		assert(ulSize, "datatype size not found")
		local ulSizeRounded = ulSize + (4 - ulSize) % 4
		vbs_printf("tag: 0x%08x size: %u  %-25s ", ulTagID, ulSize, strTagname)
		abParblock = abParblock ..
			uint32tobin(ulTagID) ..
			uint32tobin(ulSize) ..
			string.rep(string.char(0), ulSizeRounded)
	end
	abParblock = abParblock .. uint32tobin(TAG_END) .. uint32tobin(0)
	return abParblock
end

-- Print a list of the known tags sorted by id (for tagtool)
-- function print_tag_overview()
-- 	local atTags = get_tags_by_id()
-- 	for i,e in ipairs(atTags) do
-- 		print(string.format("0x%08x  %-50s %-50s %s", e.id, e.key, e.datatype, e.desc))
-- 	end
-- end

function listKnownTags()
	local atTags = get_tags_by_id()
	
	print()
	print("Name                            Tag Id      Description")
	print("-------------------------------------------------------------------")
	
	for iTag, tTag in ipairs(atTags) do
		printf("%-48s (0x%08x) %s", tTag.key, tTag.id, tTag.desc)
		for strAltTagname, strTagname in pairs(TAGNAME_ALIASES) do
		
			-- list the aliases, if any
			if strTagname == tTag.key then
				printf("  Alias: %s", strAltTagname)
			end
		end
	end
end




---------------------------------------------------------------------------
------------------------  editors
---------------------------------------------------------------------------

--- find the editor for a tag.
-- @param ulTag the 32 bit tag number
-- @return the name of the editor package, or nil
function getTagEditorInfo(ulTag)
    for _, tParamDesc in pairs(rcx_mod_tags) do
        if tParamDesc.paramtype==ulTag then
            if tParamDesc.editor then
                return tParamDesc.editor, tParamDesc.editorParam
            else
                local strTypeName = tParamDesc.datatype
                return getEditorInfo(strTypeName)
            end
        end
    end
end


function getEditorInfo(strTypeName)
    local datatypeDesc = datatypes[strTypeName]
    if datatypeDesc then
        return datatypeDesc.editor, datatypeDesc.editorParam
    else
        local structDesc = structures[strTypeName]
        if structDesc then
            local strEditor = structDesc.editor
            if strEditor then
                return strEditor, structDesc.editorParam
            else
                return "structedit"
            end
        else
            err_printf("no editor for type %s", strTypeName)
        end
    end
end


--- Get the editor name and editor params for a struct member.
-- If the member definition contains an editor name,
-- this name and any param list is returned.
-- If there is no editor name, but a param list,
-- find editor name/param list using the member type.
-- if there is a param list in the member def and the type def,
-- overlay the two lists.
-- @param tStructMemberDef
-- @return strEditor
-- @return editorParams a list or nil

function getStructMemberEditorInfo(tStructMemberDef)
    local strEditor = tStructMemberDef.editor
    local aMemberPar = tStructMemberDef.editorParam

    if strEditor then
        return strEditor, aMemberPar
    else
        local strType = tStructMemberDef[1]
        local strEditor, aTypePar = getEditorInfo(strType)
        if aMemberPar and aTypePar then
            -- overlay editor parameters in the member definition
            -- over those in the type definition
            -- i.e. member params take precedence over type params
            for k,v in pairs(aTypePar) do
                -- aMemberPar[k] = aMemberPar[k] or v
                if not aMemberPar[k] then aMemberPar[k] = v end
            end
            return strEditor, aMemberPar
        else
            return strEditor, aMemberPar or aTypePar
        end
    end
end



---------------------------------------------------------------------------
--  mapping tag types to help files
---------------------------------------------------------------------------

HELP_MAPPING = {}

function addTagHelpPage(strName, tHelp)
	HELP_MAPPING[strName] = tHelp
end

function addTagHelpPages(l)
	for k,v in pairs(l) do
		HELP_MAPPING[k] = v
	end
end

--- Get help for a tag
-- @param tTagDesc
-- @return html filename
-- @return anchor string (or nil)
function getTagHelp(tTagDesc)
    for k,v in pairs(rcx_mod_tags) do
        if v == tTagDesc then
            topic = HELP_MAPPING[k]
            if topic then
                return topic.file, topic.anchor
            end
        end
    end
end

---------------------------------------------------------------------------
--                       Helper functions
---------------------------------------------------------------------------


--- Turn an error list as returned by readEditorValues into
-- a list of strings.
-- @param errors a recursive error list
-- @param strPre prefix (for recursion)
-- @param strings (for recursion)
-- @return strings the list of error strings
function makeErrorStrings(errors, strPre, strings)
    strings = strings or {}
    local strOut
    for _, el in pairs(errors) do
        local key, val = el[1], el[2]
        strOut = (strPre and (strPre .. ".")) or ""
        if type(key) == "number" then
            local name, desc = taglist.getParamTypeDesc(key)
            strOut = strOut .. (name or key)
        elseif type(key) == "string" then
            strOut = strOut .. key
        end

        if type(val) == "string" then
            strOut = strOut .. ": " .. val
            table.insert(strings, strOut)
        elseif type(val) == "table" then
            makeErrorStrings(val, strOut, strings)
        else
            table.insert(strings, strOut)
        end
    end
    return strings
end

---------------------------------------------------------------------------
--                        size operators
---------------------------------------------------------------------------


--- Calculate the size of an elementary datatype, a tag or structure.
-- @param strType the type name/tag name/structure name
-- @return the size

function getSize(strType)
    -- elementary data type (has an editor and size info)
    local tTypedef = datatypes[strType]
    if tTypedef then
        return tTypedef.size

    -- tag (maps to a type)
    elseif rcx_mod_tags[strType] then
        return getParamSize(strType)

    -- structure (consists of sub-structures or elementary data types)
    elseif structures[strType] then
        return getStructSize(strType)

    -- unknown
    else
        error("no size for "..strType)
    end
end


--- Map a tag code to its structure size.
-- (used by taglist parser)
-- @param ulTag the 32 bit tag code
-- @return the size of the structure for the tag, or nil if the tag is unknown.
function tagCodeToSize(ulTag)
    for _, v in pairs(rcx_mod_tags) do
        if v.paramtype == ulTag then return getSize(v.datatype) end
    end
end


-- get the size of a tag.
-- The size is either stored in a .size entry in the tag description,
-- or obtained via the datatype.
function getParamSize(strParamName)
    local tTagDesc = rcx_mod_tags[strParamName]
    assert(tTagDesc, "Unknown tag: "..strParamName)
    if tTagDesc.size then
        return tTagDesc.size
    else
        local strTypeName = tTagDesc.datatype
        return getSize(strTypeName)
    end
end



-- Get the size of a structure.
-- If the structure definition has a .size entry, return it
-- Otherwise, return the sum of the component sizes.

function getStructSize(strType)
    local tStructDef = structures[strType]
    assert(tStructDef, "no definition for structure type: "..strType)
    if tStructDef.size then
        return tStructDef.size
    else
        local iSize, iSizeMax = 0, 0
        for _, tMemberDef in ipairs(tStructDef) do
            iSize = tMemberDef.offset or iSize
            iSize = iSize + getStructMemberSize(tMemberDef)
            if iSize > iSizeMax then iSizeMax = iSize end
        end
        return iSizeMax
    end
end




--- Determine the size of a struct member.
-- @param tMemberDef member entry of a struct definition
-- @return size of the member in bytes
function getStructMemberSize(tMemberDef)
    return tMemberDef.size or getSize(tMemberDef[1]) -- the type name
end




---------------------------------------------------------------------
--        parse/construct tag list
---------------------------------------------------------------------


function uint32tobin(u)
    return string.char(bit.band(u or 0, 0xff),
    bit.band(bit.rshift(u or 0, 8), 0xff),
    bit.band(bit.rshift(u or 0, 16), 0xff),
    bit.band(bit.rshift(u or 0, 24), 0xff))
end


function uint32(bin, pos)
    return bin:byte(pos+1) + 0x100* bin:byte(pos+2) + 0x10000 * bin:byte(pos+3) + 0x1000000*bin:byte(pos+4)
end



--- Convert a list representation of a taglist to binary form.
-- Concatenates the BINARY values (abValue) of the tags
-- and appends the end marker. The tags are padded to dword size.
-- @param params a list of tags. Each element is a list of
--   ulTag, ulSize, abParVal.
-- @return the binary taglist. If params is empty, an empty taglist
--   consisting only of the end marker is returned.
function paramsToBin(atTags)
    local abTags = ""
    vbs_print("Serializing tag list")
    for _, tTag in ipairs(atTags) do
        local ulTag, fDisabled, ulSize, abValue = tTag.ulTag, tTag.fDisabled, tTag.ulSize, tTag.abValue
        vbs_printf("tag = 0x%08x  size=%d  value len=%d  %s",
            ulTag, ulSize, abValue:len(), fDisabled and "disabled" or "enabled")
        if fDisabled then
        	ulTag = ulTag + TAG_IGNORE_FLAG
        end
        local abTag =
            uint32tobin(ulTag) ..
            uint32tobin(ulSize) .. -- original size
            abValue ..
            string.rep(string.char(0), (4-abValue:len()) % 4)
        abTags = abTags .. abTag
    end

    abTags = abTags .. atTags.abEndMarker
    vbs_print("Done")

    return abTags

end



--- Tries to extract a parameter list from binary data.
-- If a well-formed parameter block is found, the parameters are extracted.
-- Accepts a tag list which ends directly after a tag, or
-- ends with 4 or 8 zero bytes.
--
-- @param abBin binary data
--
-- @return fOk, paramlist, iLen, strError.
-- fOk is true if a well-formed parameter list was found, false otherwise.
-- paramlist contains whatver parameters could be extracted. Each entry is a
-- list with the keys ulTag = the 32 bit tag number, ulSize = the size of this
-- parameter in the list (including padding), abValue = the binary value of
-- the parameter
-- If the tag list is accepted, abEndMarker is either 0, 4 or 8 zero bytes.
-- len is the length of the binary data that was parsed, including the end marker.
-- strError contains an error message if any parameter could not be parsed.

function binToParams(abBin)
    local fOk = false
    local atTags = {}
    local strMsg = nil

    -- 0-based offsets
    local iLen = abBin:len()
    local iPos = 0

    local ulTag, fDisabled, ulSize, abValue
    local ulStructSize

    local abEndMarker = nil
    local abEndMarker0 = ""
    local abEndMarker4 = string.char(0,0,0,0)
    local abEndMarker8 = string.char(0,0,0,0,0,0,0,0)

    vbs_print("Deserializing tag list")

    while (iPos <= iLen) do
        -- no end marker, 8 zero bytes or 4 zero bytes
        if iPos==iLen then
            abEndMarker = abEndMarker0
            break
        elseif abBin:sub(iPos+1, iPos+8)==abEndMarker8 then
            iPos = iPos + 8
            abEndMarker = abEndMarker8
            break
        elseif abBin:sub(iPos+1, iPos+4)==abEndMarker4 then
            iPos = iPos + 4
            abEndMarker = abEndMarker4
            break
        end

        if (iPos+8 > iLen) then
            strMsg = "Tag list truncated (in tag header)"
            break
        end

        -- get tag type and size
        ulTag = uint32(abBin, iPos)
        iPos = iPos + 4
        
        ulSize = uint32(abBin, iPos)
        iPos = iPos + 4

        -- print position, size, type
        if ulTag >= TAG_IGNORE_FLAG then
        	ulTag = ulTag - TAG_IGNORE_FLAG
        	fDisabled = true
        else
        	fDisabled = false
        end

        vbs_printf("pos: 0x%08x, tag: 0x%08x, size: 0x%08x %s", iPos-8, ulTag, ulSize, 
        	fDisabled and "disabled" or "enabled")

        -- if the tag is known, its value size must be either equal to the
        -- struct size, or equal to the struct size rounded up to dword size.
        ulStructSize = tagCodeToSize(ulTag)
        if ulStructSize and
            ulSize ~= ulStructSize and
            ulSize ~= ulStructSize + ((4-ulStructSize) % 4) then
            strMsg = string.format(
                "The length of a tag value does not match the data structure definition:\n"..
                "tag type = 0x%08x, tag data length = %d, required length = %d",
                ulTag, ulSize, ulStructSize)
            break
        end

        -- get the value. the value size must not be larger than the remaining data
        if iPos + ulSize > iLen then
            strMsg = "Incorrect tag size or tag list truncated: size = " .. ulSize
            break
        end
        abValue = string.sub(abBin, iPos+1, iPos+ulSize)
        iPos = iPos + ulSize

        -- insert the param name and value
        table.insert(atTags, {
            ulTag = ulTag,
            fDisabled = fDisabled,
            ulSize = ulSize, -- original size, allows to reconstruct the binary
            abValue = abValue
        })

        -- skip padding
        if (iPos % 4 > 0) then
            vbs_printf("Alignment correction: Skipped %d padding bytes.", 4 - iPos % 4)
            iPos = iPos + ((4 - iPos) % 4)
        end

        if iPos > iLen then
            strMsg = "Tag list truncated (in padding)"
            break
        end
    end

    atTags.abEndMarker = abEndMarker
    atTags.iLen = iPos

    if abEndMarker then
        if iPos == iLen then
            fOk = true
        else
            -- if there is any data behind the end marker, reject the tag list.
            fOk = false
            strMsg = "There is extraneous data behind the end marker."
        end
    else
        fOk = false
        strMsg = strMsg or "Unknown error in tag list."
    end

    vbs_print("Done")

    return fOk, atTags, iPos, strMsg
end

-- Check if the end marker is 0 or 4 bytes long, and if it can be corrected.
-- atTags must contain the entries abEndMarker and iLen,
-- abEndMarker must be 0, 4 or 8 bytes long.
function checkEndMarker(tNx, atTags)
    local fOk          -- ok (only if the tag list ends with 8x0)
    local fCorrectible -- if not ok: indicates if the ending can be corrected
    local strMsg       -- type of ending (no end marker or 4 bytes)

    local abEnd = atTags.abEndMarker
    local iEndLen = abEnd:len()
    local iLen = atTags.iLen

    if iEndLen == 8 then
        fOk = true
    elseif iEndLen == 4 then
        fOk = false
        strMsg = "The tag list ends with only four zero bytes."
    elseif iEndLen == 0 then
        fOk = false
        strMsg = "The tag list does not have an end marker."
    end

    if not fOk then
        local tCH = tNx:getCommonHeader()
        if not tCH or
            tCH.ulTagListSizeMax >= iLen - iEndLen + 8 or
            --tCH.ulTagListSizeMax >= iLen - iEndLen + 8 and tCH.ulTagListStartOffset >= tCH.ulDataStartOffset or
            tCH.ulTagListSizeMax == 0 and (tCH.ulTagListStartOffset == 0 or tCH.ulTagListStartOffset >= tCH.ulDataStartOffset) then
            fCorrectible = true
        else
            fCorrectible = false
        end
    end

    return fOk, fCorrectible, strMsg
end

-- replace the end marker with eight zero bytes and adjust the length field
function correctEndMarker(atTags)
    atTags.iLen = atTags.iLen - atTags.abEndMarker:len()
    atTags.abEndMarker = string.char(0,0,0,0,  0,0,0,0)
    atTags.iLen = atTags.iLen + atTags.abEndMarker:len()
end



function include_option(strFilename, strPackage)
	pcall(muhkuh.include, strFilename, strPackage)
end

muhkuh.include("tagdefs_rcx.lua", "tagdefs_rcx")
muhkuh.include("tagdefs_bsl.lua", "tagdefs_bsl")
muhkuh.include("tagdefs_misc.lua", "tagdefs_misc")
include_option("tagdefs_io_handler.lua", "tagdefs_io_handler")
