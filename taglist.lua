module("taglist", package.seeall)


--[[
This module contains functions and definitions related to
taglists, tags AND structures.

Tags:
memsize = {paramtype = 0x800, datatype="UINT32", desc="Memory Size"},
RCX_MOD_TAG_IT_LED = 
	{paramtype = 0x00001040, datatype ="RCX_MOD_TAG_IT_LED_T", desc="LED description"},
->  {ulTag = ulTag, ulSize = ulSize, abValue = abValue }

Structs:
RCX_MOD_TAG_IT_LED_T = {
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

--]]


---------------------------------------------------------------------------
-- structure definitions.
-- table keys are the type names used where a structure occurs as a tag,
-- or as a substructure. The entries have the form {"type", "member name"}.
-- "leaf" datatypes: UINT8, UINT16, UINT32, 16 byte string, 63 byte string

-- actually, the structure member names are now only used internally; if
-- the desc strings are unique, we might as well use those instead.
-- possible todo: enhance makeErrorStrings to use desc strings instead of member names.
---------------------------------------------------------------------------

-- for task priorities
-- local COMBO_TASKPRIO={nBits=32, minValue=1, maxValue=55}
local COMBO_TASKPRIO={nBits=32, values={{name="-----", value=0}}}
for i=2, 55 do 
	table.insert(COMBO_TASKPRIO.values, {name="TSK_PRIO_"..tonumber(i), value=i+7})
end

-- for task tokens
local COMBO_TASKTOKEN={nBits=32, values={{name="-----", value=0}}}
for i=2, 55 do 
	table.insert(COMBO_TASKTOKEN.values, {name="TSK_TOK_"..tonumber(i), value=i+7})
end


structures = {
RCX_MOD_TAG_IDENTIFIER_T = {
  {"STRING", "abName", desc="Name", size=16}
	},

----------------------------------------------------------------------------------------------
-- Task priorities

RCX_MOD_TAG_IT_STATIC_TASKS_T = {
  {"STRING", "szTaskListName",   desc="Task List Name", size=64, mode="read-only"},
  -- priority range used by static task list
  {"UINT32", "ulBasePriority",
  desc="Base Priority",          editor="comboedit", editorParam=COMBO_TASKPRIO},
  -- token range used by static task list 
  {"UINT32", "ulBaseToken",
  desc="Base Token",             editor="comboedit", editorParam=COMBO_TASKTOKEN},  
  -- range for priority and token
  {"UINT32", "ulRange",
  desc="Priority/Token Range",   editorParam={format="%u"}, mode="read-only"},
  -- task group reference id
  {"UINT32", "ulTaskGroupRef", desc="Task Group Reference Id", mode="read-only"},
	},
	
----------------------------------------------------------------------------------------------
-- Timer

RCX_MOD_TAG_IT_TIMER_T = {
  {"RCX_MOD_TAG_IDENTIFIER_T",              "tIdentifier",
  desc="Identifier", mode="read-only"},
  -- following structure entries are compatible to RX_TIMER_SET_T
  {"UINT32",                                "ulTimNum", 
  desc="Timer Number", editor="comboedit", editorParam={nBits=32, minValue=0, maxValue=4}},
	},

----------------------------------------------------------------------------------------------
-- Interrupt

RCX_MOD_TAG_IT_INTERRUPT_T = {
  {"STRING", "szInterruptListName",    desc="Name", size=64, 
  mode="read-only"}, 
  
  -- priority range used by interrupts list 
  {"UINT32", "ulBaseIntPriority",      desc="Base Priority", 
  editor="comboedit", editorParam=COMBO_TASKPRIO},

  -- range for interrupt priorities 
  {"UINT32", "ulRangeInt",             desc="Priority Range",
  editorParam={format="%u"}, mode="read-only"},
  
  -- priority range used by interrupts configuring tasks 
  {"UINT32", "ulBaseTaskPriority",     desc="Task Priority Base",
  editor="comboedit", editorParam=COMBO_TASKPRIO},
  
  -- token range used by interrupts configuring tasks 
  {"UINT32", "ulBaseTaskToken",        desc="Task Token Base",
  editor="comboedit", editorParam=COMBO_TASKTOKEN},
  
  -- range for priority and token 
  {"UINT32", "ulRangeTask",            desc="Task Range",
  editorParam={format="%u"}, mode="read-only"},
  
  -- task group reference id XXX MGr Reserved, soll nicht in die GUI!
  {"UINT32", "ulInterruptGroupRef",    desc="Interrupt group ref.",
  mode="hidden"}, 
},


----------------------------------------------------------------------------------------------
--        xC

RCX_MOD_TAG_IT_XC_T = 
{
  {"RCX_MOD_TAG_IDENTIFIER_T",              "tIdentifier",   desc="Identifier", mode="read-only"},
  -- Specifies which Xc unit to use 
  {"UINT32",                                "ulXcId",        desc="xC Unit", 
     editor="comboedit", editorParam={nBits=32, minValue=0, maxValue=3}}
},


----------------------------------------------------------------------------------------------
--        LED


RCX_MOD_TAG_IT_LED_T=
{
  {"RCX_MOD_TAG_IDENTIFIER_T",              "tIdentifier",   desc="Identifier", mode="read-only"},
  
  {"UINT32",                                "ulUsesResourceType", desc="Resource Type",
    editor="comboedit", editorParam={nBits=32,
    values={{name="GPIO", value=1},{name="PIO", value=2},{name="HIF PIO", value=3}}}},
    
  {"UINT32",                                "ulPinNumber",   desc="Pin Number",
    editorParam ={format="%u"}},
    
  {"UINT32",                                "ulPolarity",    desc="Polarity",
    editor="comboedit", editorParam={nBits=32,
    values={{name="normal", value=0},{name="inverted", value=1}}}}
},



--[[                   obsolete
RCX_MOD_TAG_IT_LED_T = {
  {"RCX_MOD_TAG_IDENTIFIER_T",              "tIdentifier",        mode="read-only"},
  {"UINT32",                                "ulUsesResourceType", editorParam={format="%u"}},
  {"RCX_MOD_TAG_IDENTIFIER_T",              "tUsesResourceIdentifier"},
  {"RCX_MOD_TAG_IT_LED_REGISTER_T",         "tMode"},
  {"RCX_MOD_TAG_IT_LED_REGISTER_T",         "tDirection"},
  {"RCX_MOD_TAG_IT_LED_REGISTER_T",         "tEnable"},
  {"RCX_MOD_TAG_IT_LED_REGISTER_T",         "tDisable"},
  layout = {sizer="v", {sizer="grid", "tIdentifier", 
                                       "ulUsesResourceType", 
                                       "tUsesResourceIdentifier"},
                     {sizer="h", {sizer="grid", "tMode", "tDirection"},
                                 {sizer="grid", "tEnable", "tDisable"}}},
  layout1 = {sizer="v", {sizer="grid", "tIdentifier", 
                                       "ulUsesResourceType", 
                                       "tUsesResourceIdentifier"},
                       {sizer="grid", "tMode", "tDirection", "tEnable", "tDisable"}}
	},
RCX_MOD_TAG_IT_LED_REGISTER_T = {
  {"RX_LED_VALUE_TYPE",                     "ulType"},
  {"UINT32",                                "ulReg"}, 
  {"UINT32",                                "ulValue"},
  --layout = {sizer="h", "ulType", "ulReg", "ulValue"}
	},
--]]
----------------------------------------------------------------------------------------------


--        PIO
RCX_MOD_TAG_IT_PIO_REGISTER_VALUE_T = {
  -- Value Type
  {"RX_PIO_VALUE_TYPE", "usType"},          
  --{"UINT16", "usType", editorParam={format="%u"}},          
  -- Address of Register 
  {"UINT32", "ulReg"},           
  -- Value to set 
  {"UINT32", "ulValue"},         
  layout = {sizer="h", "usType", "ulReg", "ulValue"}
},

RCX_MOD_TAG_IT_PIO_REGISTER_ONLY_T = {
  -- Value Type 
  {"RX_PIO_VALUE_TYPE", "usType"},          
  --{"UINT16", "usType", editorParam={format="%u"}},          
  -- Address of Register 
  {"UINT32", "ulReg"},           
  layout = {sizer="h", "usType", "ulReg"}
},

RCX_MOD_TAG_IT_PIO_T = {
  -- following structure entries are compatible to RX_PIO_SET_T 
  {"RCX_MOD_TAG_IDENTIFIER_T",              "tIdentifier"},
  -- Optional Register to make PIO Pin to output at startup 
  {"RCX_MOD_TAG_IT_PIO_REGISTER_VALUE_T",   "tMode"},      
  -- Optional Register to make PIO Pin to output at startup 
  {"RCX_MOD_TAG_IT_PIO_REGISTER_VALUE_T",   "tDirection"}, 
  -- PIO Register to set PIOs 
  {"RCX_MOD_TAG_IT_PIO_REGISTER_ONLY_T",    "tSet"},       
  -- PIO Register to clear PIOs 
  {"RCX_MOD_TAG_IT_PIO_REGISTER_ONLY_T",    "tClear"},    
  -- Register to get current input value of the PIOs  
  {"RCX_MOD_TAG_IT_PIO_REGISTER_ONLY_T",    "tInput"},    
  layout=  {sizer="grid", "tIdentifier",  
                      "tMode", "tDirection",
                      "tSet", "tClear", "tInput"},
},
RCX_MOD_TAG_IT_PIO_TAG_T = {
  {"RCX_MODULE_TAG_ENTRY_HEADER_T",         "tHeader"},
  {"RCX_MOD_TAG_IT_PIO_T",                  "tData"},
},

----------------------------------------------------------------------------------------------
--        GPIO
RCX_MOD_TAG_IT_GPIO_T = {
  {"RCX_MOD_TAG_IDENTIFIER_T",              "tIdentifier"},
  -- following structure entries are compatible to RX_GPIO_SET_T
  -- GPIO Number 
  {"UINT32",                                "ulGpioNum", editorParam={format="%u"}},
  -- GPIO Type
  {"UINT16",                                "usType", editorParam={format="%u"}},
  -- GPIO Polarity
  {"UINT16",                                "usPolarity", editorParam={format="%u"}},
  -- GPIO Mode 
  {"UINT16",                                "usMode", editorParam={format="%u"}},                     
  -- Counter Reference, needed when edges or levels shall be counted 
  {"UINT16",                                "usCntRef", editorParam={format="%u"}},                   
  -- Enables/Disables IRQ in the case a counter is referenced 
  {"UINT32",                                "fIrq", editorParam={format="%u"}},                       
  -- Threshold / Capture value in PWM mode 
  {"UINT32",                                "ulThresholdCapture"},         
},

}

---------------------------------------------------------------------------
-- RCX_MOD_TAG definitions.
-- paramtype = the 32 bit tag number
-- datatype: the elementary or struct data type of this tag
-- desc = a string to be displayed in the GUI
---------------------------------------------------------------------------



-- end marker
TAG_END = 0
-- tags whose number has its 31th bit set are to be ignored.
TAG_IGNORE_FLAG = 0x80000000

rcx_mod_tags = {
-- elementary type tags -> read only
memsize = 
	{paramtype = 0x800, datatype="UINT32", mode="read-only", desc="Memory Size"},
min_persistent_storage_size = 
	{paramtype = 0x801, datatype="UINT32", mode="read-only", desc="Min. Persistent Storage Size"},
min_os_version = 
	{paramtype = 0x802, datatype="rcxver", mode="read-only", desc="Min. OS Version"},
max_os_version = 
	{paramtype = 0x803, datatype="rcxver", mode="read-only", desc="Max. OS Version"},
min_chip_rev = 
	{paramtype = 0x804, datatype="UINT32", mode="read-only", desc="Min. Chip Revision"},
max_chip_rev = 
	{paramtype = 0x805, datatype="UINT32", mode="read-only", desc="Max. Chip Revision"},
num_comm_channel =
	{paramtype = 0x806, datatype="UINT32", mode="read-only", "Number of required comm channels"},
--[[
xc_alloc = 
	{paramtype = 0x806, datatype="UINT32", desc="xC allocation"},
irq_alloc= 
	{paramtype = 0x807, datatype="UINT32", desc="IRQ allocation"},
comm_channel_alloc = 
	{paramtype = 0x808, datatype="UINT32", desc="Comm. Channel allocation"},
supported_comm_channels = 
	{paramtype = 0x80a, datatype="UINT32", desc="Supported comm. Channels"},
num_tasks = 
	{paramtype = 0x80b, datatype="UINT32", desc="Number of tasks"},
--]]


-- struct tags
RCX_MOD_TAG_IT_STATIC_TASKS =
	{paramtype = 0x00001000, datatype="RCX_MOD_TAG_IT_STATIC_TASKS_T", desc="Task Group"},
RCX_MOD_TAG_IT_TIMER =
	{paramtype = 0x00001010, datatype ="RCX_MOD_TAG_IT_TIMER_T", desc="Hardware Timer"},
RCX_MOD_TAG_IT_INTERRUPT =
	{paramtype = 0x00001020, datatype ="RCX_MOD_TAG_IT_INTERRUPT_T", desc="Interrupt"},
RCX_MOD_TAG_IT_XC =
	{paramtype = 0x00001050, datatype ="RCX_MOD_TAG_IT_XC_T", desc="xC Unit"},
	
RCX_MOD_TAG_IT_LED =
	{paramtype = 0x00001040, datatype ="RCX_MOD_TAG_IT_LED_T", desc="LED"},
RCX_MOD_TAG_IT_PIO =
	{paramtype = 0x00001090, datatype ="RCX_MOD_TAG_IT_PIO_T", desc="PIO"},
RCX_MOD_TAG_IT_GPIO =
	{paramtype = 0x000010A0, datatype ="RCX_MOD_TAG_IT_GPIO_T", desc="GPIO"},
	
-- demo tags, not used in taglist.h
mac_address = 
	{paramtype=1, datatype="mac", desc="MAC Address"},
ipv4_address = 
	{paramtype=2, datatype="ipv4", desc="IP Address"},
manufacturer_name = 
	{paramtype=6, datatype="STRING", size=16, desc="Manufacturer Name"},
arbitrary_data = 
	{paramtype=7, datatype="bindata", size=64, desc="Binary Data"}
}


-- "name" was used for the html book display; could be removed
HELP_MAPPING = {
	RCX_MOD_TAG_IT_LED                  = {name="LED Tag",       file="RCX_MOD_TAG_IT_LED_T.htm"},
	RCX_MOD_TAG_IT_PIO                  = {name="PIO Tag",       file="RCX_MOD_TAG_IT_PIO_T.htm"},
	RCX_MOD_TAG_IT_GPIO                 = {name="GPIO Tag",      file="RCX_MOD_TAG_IT_GPIO_T.htm"},
	RCX_MOD_TAG_IT_STATIC_TASKS         = {name="Static Task Priorities Tag", file="RCX_MOD_TAG_IT_STATIC_TASKS_T.htm"},
	RCX_MOD_TAG_IT_TIMER                = {name="Timer Tag",     file="RCX_MOD_TAG_IT_TIMER_T.htm"},
	RCX_MOD_TAG_IT_XC                   = {name="xC Tag",        file="RCX_MOD_TAG_IT_XC_T.htm"},
	RCX_MOD_TAG_IT_INTERRUPT            = {name="Interrupt Tag", file="RCX_MOD_TAG_IT_INTERRUPT_T.htm"},
	memsize                             = {name="", file="misc_tags.htm"},
	min_persistent_storage_size         = {name="", file="misc_tags.htm"}, --anchor="#min_persistent_storage_size"},
	min_os_version                      = {name="", file="misc_tags.htm"}, --anchor="#min_os_version"},
	max_os_version                      = {name="", file="misc_tags.htm"}, --anchor="#max_os_version"},
	min_chip_rev                        = {name="", file="misc_tags.htm"}, --anchor="#min_chip_rev"},
	max_chip_rev                        = {name="", file="misc_tags.htm"}, --anchor="#max_chip_rev"},
	num_comm_channels                   = {name="", file="misc_tags.htm"}, --anchor="#num_comm_channels"},
	--[[
	xc_alloc                            = {name="", file="misc_tags.htm"}, --anchor="#xc_alloc"},
	irq_alloc                           = {name="", file="misc_tags.htm"}, --anchor="#irq_alloc"},
	comm_channel_alloc                  = {name="", file="misc_tags.htm"}, --anchor="#comm_channel_alloc"},
	supported_comm_channels             = {name="", file="misc_tags.htm"}, --anchor="#supported_comm_channels"},
	num_tasks                           = {name="", file="misc_tags.htm"}, --anchor="#num_tasks"},
	--]]
}
HELP_PATH = "../nxm_editor/nxm_editor_help" --"D:/projekt/nxm_editor_help"

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
-- The elementary data types. Each entry may contain
-- size, if the size is constant for all instances of the type
-- editor, the lua package name of the editor control
-- editorParam, parameters to pass to the editor control at instantiation
---------------------------------------------------------------------------
datatypes = {
RX_PIO_VALUE_TYPE = {size=2, editor="comboedit", editorParam={
	nBits=16, -- nBits = 8*size
	values={
		{name="no register", value=0},
		{name="active high", value=1},
		{name="active low", value=2},
		{name="absolute", value=3},
	}}},
RX_LED_VALUE_TYPE = {size=4, editor="comboedit", editorParam={
	nBits=32,
	values={
		{name="no register", value=0},
		{name="or", value=1},
		{name="and", value=2},
		{name="absolute", value=3},
	}}},
mac = {size=6, editor="macedit"},
ipv4 = {size=4, editor="ipv4edit"},
rcxver = {size=8, editor="rcxveredit"},
UINT32 = {size=4, editor="numedit"},
UINT16 = {size=2, editor="numedit", editorParam={width=16}},
UINT8 = {size=1, editor="numedit", editorParam={width=8}},
STRING = {editor="stringedit"},
bindata = {editor="hexedit"},
}


function getStructDef(strTypeName)
	return structures[strTypeName]
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
-- @return tDesc the tag definition
function getTagDescString(ulTag)
	local strKey, tDesc = getParamTypeDesc(ulTag)
	local strDesc
	if tDesc then
		strDesc = tDesc.desc or strKey
	end
	return strDesc, tDesc
end

------------------  size operators

--- Calculate the size of an elementary datatype, a tag or structure.
-- @param strType the type name/tag name/structure name
-- @return the size

function getSize(strType)
	-- datatype
	local tTypedef = datatypes[strType]
	if tTypedef then 
		return tTypedef.size
	
	-- tag
	elseif rcx_mod_tags[strType] then
		return getParamSize(strType)
	
	-- structure
	elseif structures[strType] then 
		return getStructSize(strType)

	-- unknown
	else
		error("no size for "..strType)
	end
end


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



function getStructSize(strType)
	local tStructDef = structures[strType]
	assert(tStructDef, "no definition for structure type: "..strType)
	local iSize = 0
	for _, tMemberDef in ipairs(tStructDef) do
		iSize = iSize + getStructMemberSize(tMemberDef)
	end
	return iSize
end


--- Determine the size of a struct member.
-- @param tMemberDef member entry of a struct definition
-- @return size of the member in bytes
function getStructMemberSize(tMemberDef)
	local strName, strType, iSize = tMemberDef[2], tMemberDef[1], tMemberDef.size or 0
	if iSize>0 then
		return iSize
	else 
		return getSize(strType)
	end
end


------------------------  editors

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
			print("no editor for " .. strTypeName)
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
	local params1 = tStructMemberDef.editorParam
	
	if strEditor then
		--print(strEditor)
		return strEditor, params1
	else
		local strType = tStructMemberDef[1]
		local strEditor, params2 = getEditorInfo(strType)
		if params1 and params2 then 
			-- params in the member definitions overwrite
			-- params in the type/struct definition
			for k,v in pairs(params1) do params2[k]=v end
			return strEditor, params2
		else 
			return strEditor, params1 or params2
		end
	end
end

function isReadOnly(tDef)
	return tDef.mode=="read-only"
end

function isHidden(tDef)
	return tDef.mode=="hidden"
end


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

---------------------------------------------------------------------
--        parse/construct tag list
---------------------------------------------------------------------


function uint32tobin(u)
	return string.char(bit.band(u or 0, 0xff), 
	bit.band(bit.rshift(u or 0, 8), 0xff),
	bit.band(bit.rshift(u or 0, 16), 0xff),
	bit.band(bit.rshift(u or 0, 24), 0xff))
end


--- Convert a list of parameters to binary data.
-- @param params a list of parameters. Each element is a list of 
--   ulTag, ulSize, abParVal.
-- @return the binary form
function paramsToBin(params)
	local abParblock = "" --parblock_cookie
	for _, param in ipairs(params) do
		local ulTag, iParamSize, abParamVal = param.ulTag, param.ulSize, param.abValue
		
		assert(iParamSize == abParamVal:len(),
			string.format("tag size has changed: actual = %u, correct = %u",
			abParamVal:len(), iParamSize))
		abParblock = abParblock ..
			uint32tobin(ulTag) ..
			uint32tobin(iParamSize) ..
			abParamVal
	end
	abParblock = abParblock .. uint32tobin(TAG_END) .. uint32tobin(0)
	return abParblock

end

function uint32(bin, pos)
	return bin:byte(pos+1) + 0x100* bin:byte(pos+2) + 0x10000 * bin:byte(pos+3) + 0x1000000*bin:byte(pos+4)
end

--- Tries to extract a parameter list from binary data.
-- If a well-formed parameter block is found, the parameters are extracted.
--
-- @param abBin binary data
-- @param iStartPos 0-based offset of the parameter block in the data
--
-- @return fOk, paramlist, iLen, strError. fOk is true if a well-formed 
-- parameter list was efound, false otherwise. 
-- paramlist contains whatver parameters could be extracted. Each entry is a 
-- list with the keys ulTag = the 32 bit tag number, ulSize = the size of this
-- parameter in the list (including padding), abValue = the binary value of
-- the parameter
-- len is the length of the binary data that was parsed. 
-- strError contains an error message if any parameter could not be parsed.

function binToParams(abBin, iStartPos)
	local params = {}
	local strMsg = ""
	local fOk = false
	
	local iLen, iPos = abBin:len(), iStartPos
	
	while (iPos+4 <= iLen) do
		-- tag
		local ulTag = uint32(abBin, iPos)
		iPos = iPos+4

		-- end of valid param block found
		if ulTag == TAG_END then
			fOk = true
			break
		end

		-- size
		if (iPos+4 > iLen) then
			strMsg = "length field exceeds end of data"
			break
		end
		
		local ulSize = uint32(abBin, iPos)
		iPos = iPos + 4
		
		-- get the value. the value size must not be larger than the remaining data
		if iPos + ulSize > iLen then
			strMsg = "tag value exceeds end of data: " .. ulSize
			break
		end
		local abValue = string.sub(abBin, iPos+1, iPos+ulSize)
		iPos = iPos + ulSize
		
		-- print position, size, type
		print(string.format("0x%08x, 0x%08x, 0x%08x", iPos, ulSize, ulTag))
		
		-- insert the param name and value
		table.insert(params, {
			ulTag = ulTag,
			ulSize = ulSize, -- allows to reconstruct the binary
			abValue = abValue,
		})
	end
	
	if (iPos+4>=iLen) then
		strMsg = "truncated param block?"
	end
	
	return fOk, params, iPos - iStartPos, strMsg
end


function makeEmptyParblock()
	local abParblock = ""
	for _, strTagname in ipairs(example_taglist) do
		local tPardesc = rcx_mod_tags[strTagname]
		local ulTag = tPardesc.paramtype
		assert(tPardesc, "unknown tag in example block: " .. strTagname)
		local ulSize = getSize(strTagname)
		assert(ulSize, "datatype size not found")
		print(string.format ("tag: 0x%08x size: %u  %-25s ", tPardesc.paramtype, ulSize, strTagname))
		abParblock = abParblock ..
			uint32tobin(tPardesc.paramtype) ..
			uint32tobin(ulSize) ..
			string.rep(string.char(0), ulSize)
	end
	
	--abParblock = abParblock .. uint32tobin(42) .. uint32tobin(10) .. "0123456789"
	
	abParblock = abParblock .. uint32tobin(TAG_END) .. uint32tobin(0)
	return abParblock
end

---------------------------------------------------------------------
--                split/reconstruct structures
---------------------------------------------------------------------

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
		strMemberName, strMemberType = tMemberDef[2], tMemberDef[1]
		ulMemberSize = getStructMemberSize(tMemberDef)
		abMemberValue = string.sub(abValue, iPos+1, iPos+ulMemberSize)
		iPos = iPos + ulMemberSize
		elements[index] =
			{strName = strMemberName, 
			 strType = strMemberType, 
			 ulSize = ulSize, 
			 abValue = abMemberValue}
	end
	return elements
end


--- join structure members into the whole structure.
-- @param strTypeName the structure type name
-- @param elements the names and values of the elements
-- Elements have the form {strName=..., abValue=..., ulSize=...}
-- @return the binary of the structure
function joinStructElements(strTypeName, elements)
	local bin = ""
	local strMemberName, strMemberType, ulMemberSize, abMemberValue
	local tStructDef = getStructDef(strTypeName)
	
	for index, tMemberDef in ipairs(tStructDef) do
		abMemberValue = elements[index].abValue
		
		ulMemberSize = getStructMemberSize(tMemberDef)
		assert(ulMemberSize == abMemberValue:len(),
			string.format("struct member size has changed: actual = %u, correct = %u",
			abMemberValue:len(), ulMemberSize))

		bin = bin .. abMemberValue
	end
	return bin
end

---------------------------------------------------------------------
--                           empty taglist
---------------------------------------------------------------------

example_taglist = {
"RCX_MOD_TAG_IT_STATIC_TASKS",
"RCX_MOD_TAG_IT_STATIC_TASKS",
"RCX_MOD_TAG_IT_XC",
"RCX_MOD_TAG_IT_TIMER",
"RCX_MOD_TAG_IT_INTERRUPT",
"RCX_MOD_TAG_IT_LED",
"RCX_MOD_TAG_IT_PIO",
"RCX_MOD_TAG_IT_GPIO",

"memsize",
"min_persistent_storage_size",
"min_os_version",
"max_os_version",
"min_chip_rev",
"max_chip_rev",
"num_comm_channel",

"mac_address",
"ipv4_address",
"arbitrary_data",
}
