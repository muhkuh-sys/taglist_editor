---------------------------------------------------------------------------
-- Copyright (C) 2010 Hilscher Gesellschaft für Systemautomation mbH
--
-- Description:
--   Tag definitions for Taglist editor
--
--  Changes:
--    Date        Author        Description
---------------------------------------------------------------------------
--  2010-08-03    SL            added functions for tagtool
--  2010-06-28    SL            added diag interface tags
--  2010-07-30    SL            serialize/deserialize, value constants
--                              support for command line tool
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

How to add a new tag:
1)
The table rcx_mod_tags contains mappings of the tag id numbers to structure definitions.
Insert an entry of the form
RCX_MOD_TAG_IT_STATIC_TASKS =
    {paramtype = 0x00001000, datatype="RCX_MOD_TAG_IT_STATIC_TASKS_T", desc="Task Group"},
where
RCX_MOD_TAG_IT_STATIC_TASKS is an internal key,
paramtype is the tag id number,
datatype is the name under which the data portion of the tag is defined in the datatypes list and
desc is a string which appears in the tag selection area in the editor.

2)
Add the structure definition to the datatypes table.
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
  nameField = "szTaskListName"
    },

where
RCX_MOD_TAG_IT_STATIC_TASKS_T is the same data type name used in the entry in rcx_mod_tags
   member type  internal name          Screen name
  {"STRING", "szTaskListName",   desc="Task List Name", size=64, mode="read-only"},

3)
Create a HTML help page for the tag and add it to the nxoeditor/help directory.
Add an entry to the HELP_MAPPING table:
    RCX_MOD_TAG_IT_STATIC_TASKS         = {file="RCX_MOD_TAG_IT_STATIC_TASKS_T.htm"},
RCX_MOD_TAG_IT_STATIC_TASKS is the key used in rcx_mod_tags.
Add the HTML page to the SVN and to the installer.


--]]


---------------------------------------------------------------------------
--   Value constants
---------------------------------------------------------------------------

CONSTANTS = {
    -- from rX_TagLists.h
    -- resource codes for LED tag
    RCX_LED_RESOURCE_TYPE_GPIO            =  1,
    RCX_LED_RESOURCE_TYPE_PIO             =  2,
    RCX_LED_RESOURCE_TYPE_HIFPIO          =  3,

    -- polarity codes for LED tag
    RCX_LED_POLARITY_NORMAL               =  0,
    RCX_LED_POLARITY_INVERTED             =  1,
    
    -- media type for TAG_BSL_MEDIUM_PARAMS     
    TAG_BSL_MEDIUM_AUTODETECT             =  0,
    TAG_BSL_MEDIUM_USERAM                 =  1,
    TAG_BSL_MEDIUM_USESERFLASH            =  2,
    TAG_BSL_MEDIUM_USEPARFLASH            =  3,
}

for i=2, 55 do
	local strKey = string.format("TSK_PRIO_%02d", i)
	CONSTANTS[strKey]=i+7
	strKey = string.format("TSK_TOK_%02d", i)
	CONSTANTS[strKey]=i+7
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
	print("Name                           Value hex/dec")
	print("----------------------------------------------")
	for i, tConst in ipairs(atSortedConstants) do
		printf("%-30s 0x%08x %d", tConst.strName, tConst.ulValue, tConst.ulValue)
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
    -- tag type codes for general tags
    --RCX_TAG_NUM_COMM_CHANNEL                    ="RCX_MOD_TAG_NUM_COMM_CHANNEL",

    -- tag type codes for NXO specific tags
    RCX_TAG_STATIC_TASKS                        ="RCX_MOD_TAG_IT_STATIC_TASKS",
    --RCX_TAG_STATIC_TASK_PARAMETER_BLOCK         ="RCX_MOD_TAG_IT_STATIC_TASK_PARAMETER_BLOCK",
    --RCX_TAG_STATIC_TASK_ENTRY                   ="RCX_MOD_TAG_IT_STATIC_TASK_ENTRY",
    RCX_TAG_TIMER                               ="RCX_MOD_TAG_IT_TIMER",
    RCX_TAG_INTERRUPT                           ="RCX_MOD_TAG_IT_INTERRUPT",
    --RCX_TAG_INTERRUPT_ENTRY                     ="RCX_MOD_TAG_IT_INTERRUPT_ENTRY",
    RCX_TAG_LED                                 ="RCX_MOD_TAG_IT_LED",
    RCX_TAG_XC                                  ="RCX_MOD_TAG_IT_XC",
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

-- for interrupt priorities
local COMBO_IRQPRIO={nBits=32, values={}}
for i=0, 31 do
    table.insert(COMBO_IRQPRIO.values, {name=string.format("%u", i), value=i})
end

-- 16-char name string
local RCX_MOD_TAG_IDENTIFIER_T = {"STRING", "szIdentifier", desc="Identifier", size=16, mode="read-only"}




structures = {
-- general tags
RCX_TAG_MEMSIZE_T =
    {{"UINT32", "ulMemSize",        mode="read-only", desc="Memory Size"}},
RCX_TAG_MIN_PERSISTENT_STORAGE_SIZE_T =
    {{"UINT32", "ulMinStorageSize", mode="read-only", desc="Min. Persistent Storage Size"}},
RCX_TAG_MIN_OS_VERSION_T =
    {{"rcxver", "ulMinOsVer",       mode="read-only", desc="Min. OS Version"}},
RCX_TAG_MAX_OS_VERSION_T =
    {{"rcxver", "ulMaxOsVer",       mode="read-only", desc="Max. OS Version"}},
RCX_TAG_MIN_CHIP_REV_T =
    {{"UINT32", "ulMinChipRev",     mode="read-only", desc="Min. Chip Revision"}},
RCX_TAG_MAX_CHIP_REV_T =
    {{"UINT32", "ulMaxChipRev",     mode="read-only", desc="Max. Chip Revision"}},
--

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
  nameField = "szTaskListName"
    },

----------------------------------------------------------------------------------------------
-- Timer

RCX_MOD_TAG_IT_TIMER_T = {
  RCX_MOD_TAG_IDENTIFIER_T,
  -- following structure entries are compatible to RX_TIMER_SET_T
  {"UINT32",                                "ulTimNum",
  desc="Timer Number", editor="comboedit", editorParam={nBits=32, minValue=0, maxValue=4}},
  nameField = "szIdentifier"
    },

----------------------------------------------------------------------------------------------
-- Interrupt

RCX_MOD_TAG_IT_INTERRUPT_T = {
  {"STRING", "szInterruptListName",    desc="Name", size=64,
  mode="read-only"},

  -- priority range used by interrupts list
  {"UINT32", "ulBaseIntPriority",      desc="Int. Priority Base",
  editor="comboedit", editorParam=COMBO_IRQPRIO},

  -- range for interrupt priorities
  {"UINT32", "ulRangeInt",             desc="Int. Priority Range",
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
  nameField = "szInterruptListName"
},


----------------------------------------------------------------------------------------------
--        xC

RCX_MOD_TAG_IT_XC_T =
{
  RCX_MOD_TAG_IDENTIFIER_T,
  -- Specifies which Xc unit to use
  {"UINT32",                                "ulXcId",        desc="xC Unit",
     editor="comboedit", editorParam={nBits=32, minValue=0, maxValue=3}},
  nameField = "szIdentifier"

},


----------------------------------------------------------------------------------------------
--        LED


RCX_MOD_TAG_IT_LED_T=
{
  RCX_MOD_TAG_IDENTIFIER_T,

  {"UINT32",                                "ulUsesResourceType", desc="Resource Type",
    editor="comboedit", editorParam={nBits=32,
    values={{name="GPIO", value=1},
            {name="PIO", value=2},
            --{name="HIF PIO", value=3}
            }}},

  {"UINT32",                                "ulPinNumber",   desc="Pin Number",
    editorParam ={format="%u"}},

  {"UINT32",                                "ulPolarity",    desc="Polarity",
    editor="comboedit", editorParam={nBits=32,
    values={{name="normal", value=0},{name="inverted", value=1}}}},
  nameField = "szIdentifier"
},





-- tags for configuration of 2nd stage loader
----------------------------------------------------------------------------------------------
--  2nd stage loader SDRAM settings

TAG_BSL_SDRAM_PARAMS_DATA_T = {
    {"UINT32", "ulGeneralCtrl", desc="General Control", editorParam={format="0x%08x"}},
    {"UINT32", "ulTimingCtrl", desc="Timing Control",  editorParam={format="0x%08x"}},
},


----------------------------------------------------------------------------------------------
--  2nd stage loader HIF/DPM settings

TAG_BSL_HIF_PARAMS_DATA_T = {
    {"UINT32", "ulBusType", desc="Bus Type",
        editor="comboedit",
        editorParam={nBits=32,
            values={
                {name="Auto", value=0},
                {name="DPM", value=1},
                {name="ISA", value=2},
                {name="PCI", value=3},
                {name="Disable ext. Bus", value=0xffffffff}
        }},
    },

    {"BSL_DPM_PARAMS_T", "tDpmIsaAuto", desc="DPM/ISA settings"},
    {"BSL_PCI_PARAMS_T", "tPci", desc="PCI settings"},
},

BSL_DPM_PARAMS_T = {
    -- DPM/ISA settings
    {"UINT32", "ulIfConf0",    desc="IF_CONF0", editorParam={format="0x%08x"}},
    {"UINT32", "ulIfConf1",    desc="IF_CONF1", editorParam={format="0x%08x"}},
    {"UINT32", "ulIoRegMode0", desc="IO_REGMODE0", editorParam={format="0x%08x"}},
    {"UINT32", "ulIoRegMode1", desc="IO_REGMODE1", editorParam={format="0x%08x"}},
},

BSL_PCI_PARAMS_T = {
    -- PCI settings
    {"UINT8", "bEnablePin", desc="Use PCI enable pin",
        editor="checkboxedit",
        editorParam={nBits = 8, offValue = 0, onValue = 1, otherValues = true}
    },

    {"UINT8", "bPinType", desc="Type of enable pin",
        offset = 1, mask = string.char(0x7f),
        editor="comboedit",
        editorParam={nBits=8,
            values={
                {name="Ignore pin",                value=0},
                {name="GPIO",                      value=1},
                {name="PIO",                       value=2},
                {name="HIFPIO",                    value=3},
        }},
    },

    {"UINT8", "bInvert", desc="Inverted",
        offset = 1, mask = string.char(0x80),
        editor="checkboxedit",
        editorParam={nBits = 8, offValue = 0, onValue = 128, otherValues = true}
    },

    {"UINT16", "usPinNumber", desc="Pin Number", editorParam={format="%u"}},
},


----------------------------------------------------------------------------------------------
--  2nd stage loader SD/MMC settings
TAG_BSL_SDMMC_PARAMS_DATA_T = {
    {"UINT8", "bEnable", desc="enable SD/MMC Support",
        editor="checkboxedit",
        editorParam={nBits = 8, offValue = 0, onValue = 1, otherValues = true}
    },

    {"UINT8", "bDetectPinType", desc="Pin Type for Card Detection",
        offset = 1, mask = string.char(0x7f),
        editor="comboedit",
        editorParam={nBits=8,
            values={
                {name="Ignore CD pin",             value=0},
                {name="GPIO",                      value=1},
                {name="PIO",                       value=2},
                {name="HIFPIO",                    value=3},
                --{name="MMIO",                      value=4},
        }},
    },

    {"UINT8", "bInvert", desc="Inverted",
        offset = 1, mask = string.char(0x80),
        editor="checkboxedit",
        editorParam={nBits = 8, offValue = 0, onValue = 128, otherValues = true}
    },

    {"UINT16", "usPinNumber", desc="Pin Number", editorParam={format="%u"}},
},

----------------------------------------------------------------------------------------------
--  2nd stage loader UART settings
TAG_BSL_UART_PARAMS_DATA_T = {
    {"UINT8", "bEnable", desc="Enable UART",
        editor="checkboxedit",
        editorParam={nBits = 8, offValue = 0, onValue = 1, otherValues = true}
    },
},

----------------------------------------------------------------------------------------------
--  2nd stage loader USB settings
TAG_BSL_USB_PARAMS_DATA_T = {
    {"UINT8", "bEnable", desc="Enable USB",
        editor="checkboxedit",
        editorParam={nBits = 8, offValue = 0, onValue = 1, otherValues = true}
    },
    {"UINT8", "bPullupPinType", desc="Pull up Pin Type",
        offset = 1, mask = string.char(0x7f),
        editor="comboedit",
        editorParam={nBits=8,
            values={
                {name="None",    value=0},
                {name="GPIO",    value=1},
                {name="PIO",     value=2},
                {name="HIFPIO",  value=3},
                --{name="MMIO",    value=4},
        }},
    },
    {"UINT8", "bInvert", desc="Inverted",
        offset = 1, mask = string.char(0x80),
        editor="checkboxedit",
        editorParam={nBits = 8, offValue = 0, onValue = 128, otherValues = true}
    },
    {"UINT16", "usPullupPinIdx", desc="Pin Number", editorParam={format="%u"}},
},

----------------------------------------------------------------------------------------------
--  2nd stage loader media settings
TAG_BSL_MEDIUM_PARAMS_DATA_T = {
    {"UINT8", "bFlash", desc="Flash Bootloader",
        editor="checkboxedit",
        editorParam={nBits = 8, offValue = 0, onValue = 1, otherValues = true}
    },

    {"UINT8", "bMediumType", desc="Destination",
        editor="comboedit",
        editorParam={nBits=8,
            values={
                {name="Auto-detect Media",value=0},
                {name="RAM Disk",         value=1},
                {name="Serial Flash",     value=2},
                {name="Parallel Flash",   value=3},
        }},
    },
},

----------------------------------------------------------------------------------------------
--  2nd stage loader ext. chip select settings


TAG_BSL_EXTSRAM_PARAMS_DATA_T = {
    {"UINT32", "ulRegVal0", desc="MEM_SRAM0_CTRL", editorParam={format="0x%08x"}},
    {"UINT32", "ulRegVal1", desc="MEM_SRAM1_CTRL", editorParam={format="0x%08x"}},
    {"UINT32", "ulRegVal2", desc="MEM_SRAM2_CTRL", editorParam={format="0x%08x"}},
    {"UINT32", "ulRegVal3", desc="MEM_SRAM3_CTRL", editorParam={format="0x%08x"}},
},

----------------------------------------------------------------------------------------------
--  2nd stage loader HW Data
--
-- unsigned char  bEnable;
-- unsigned short usManufacturer;
-- unsigned short usProductionDate;
-- unsigned short usDeviceClass;
-- unsigned char  bHwCompatibility;
-- unsigned char  bHwRevision;
-- unsigned long  ulDeviceNr;
-- unsigned long  ulSerialNr;
-- unsigned short ausHwOptions[4];

TAG_BSL_HWDATA_PARAMS_DATA_T = {
    {"UINT8", "bEnable", desc="Enable",
        editor="checkboxedit",
        editorParam={nBits = 8, offValue = 0, onValue = 1, otherValues = true}
    },
    {"UINT8", "bReserved1", desc="Reserved1", mode = "hidden", editorParam={format="0x%02x"}},
    {"UINT8", "bReserved2", desc="Reserved2", mode = "hidden", editorParam={format="0x%02x"}},
    {"UINT8", "bReserved3", desc="Reserved3", mode = "hidden", editorParam={format="0x%02x"}},

    {"UINT16", "usManufacturer", desc="Manufacturer", editorParam={format="0x%04x"}},
    -- Format: 0xyyww (year/week), byte order: ww yy
    {"UINT8", "bProdWeek", desc="Production Week", editorParam={format="%d"}},
    {"UINT8", "bProdYear", desc="Production Year", editorParam={format="%d"}},
    {"UINT16", "usDeviceClass", desc="Device Class", editorParam={format="0x%04x"}},
    {"UINT8", "bHWCompatibility", desc="HW Compatibility", editorParam={format="%d"}},
    {"UINT8", "bHWRevision", desc="HW Revision", editorParam={format="%d"}},
    {"UINT32", "ulDeviceNr", desc="Device Number", editorParam={format="%d"}},
    {"UINT32", "ulSerialNr", desc="Serial Number", editorParam={format="%d"}},
    {"UINT16", "usHwOption0", desc="HW Option 0", editorParam={format="0x%04x"}},
    {"UINT16", "usHwOption1", desc="HW Option 1", editorParam={format="0x%04x"}},
    {"UINT16", "usHwOption2", desc="HW Option 2", editorParam={format="0x%04x"}},
    {"UINT16", "usHwOption3", desc="HW Option 3", editorParam={format="0x%04x"}},

    layout={
        sizer="grid", rows=7, cols=2,
        "bEnable",          nil,
        "usManufacturer",   "bHWRevision",
        "ulDeviceNr",       "bHWCompatibility",
        "ulSerialNr",       "usHwOption0",
        "bProdWeek",        "usHwOption1",
        "bProdYear",        "usHwOption2",
        "usDeviceClass",    "usHwOption3",
    },
},

----------------------------------------------------------------------------------------------
--  2nd stage loader FSU parameters
--#define BSL_FSU_MODE_DISABLED       0x00000000
--#define BSL_FSU_MODE_ENABLE         0x00000001
--#define BSL_FSU_MODE_FOLAYOUT       0x00000002
--#define BSL_FSU_MODE_DISABLESECMEM  0x80000000
--  unsigned long ulFSUMode; /*!< Bitmask -> BSL_FSU_MODE_XXX */

TAG_BSL_FSU_PARAMS_DATA_T = {
    {"UINT32", "ulEnable", desc="Enable FSU Mode",
        offset = 0, mask = string.char(1, 0, 0, 0),
        editor="checkboxedit",
        editorParam={nBits = 32, offValue = 0, onValue = 1, otherValues = true}
    },
    {"UINT32", "ulFoLayout", desc="FO Layout",
        offset = 0, mask = string.char(2, 0, 0, 0),
        editor="checkboxedit",
        editorParam={nBits = 32, offValue = 0, onValue = 2, otherValues = true}
    },
    {"UINT32", "ulDisableSecmem", desc="Disable SecMem",
        offset = 0, mask = string.char(0, 0, 0, 0x80),
        editor="checkboxedit",
        editorParam={nBits = 32, offValue = 0, onValue = 0x80000000, otherValues = true}
    },
},


---------------------------------------------------------------------------

-- tags for netX Diagnostics and Remote Access component


-- Tag Type Code    Tag Data Length Description
-- TAG_DIAG_IF_CTRL_UART = 0x10820000    4   netX Diagnostics and Remote Access component UART interface control
-- "    interface enable flag (UINT8, 0, 1)
-- "    interface number (UINT8, 0...15)
-- "    two bytes reserved for future use

TAG_DIAG_IF_CTRL_UART_DATA_T = {
    {"UINT8", "bEnable", desc="Enable",
        editor="checkboxedit",
        editorParam={nBits = 8, offValue = 0, onValue = 1, otherValues = true}
    },
    {"UINT8", "bInterfaceNumber", desc="UART Number", mode="read-only", editorParam={format="%d"}},
    {"UINT8", "bReserved2", desc="Reserved2", mode = "hidden", editorParam={format="0x%02x"}},
    {"UINT8", "bReserved3", desc="Reserved3", mode = "hidden", editorParam={format="0x%02x"}},

    layout = {sizer="grid", "bInterfaceNumber", "bEnable"}
},


-- TAG_DIAG_IF_CTRL_USB = 0x10820001  4   netX Diagnostics and Remote Access component USB interface control
-- "    interface enable flag (UINT8, 0, 1)
-- "    interface number (UINT8, 0...15)
-- "    two bytes reserved for future use

TAG_DIAG_IF_CTRL_USB_DATA_T = {
    {"UINT8", "bEnable", desc="Enable",
        editor="checkboxedit",
        editorParam={nBits = 8, offValue = 0, onValue = 1, otherValues = true}
    },
    {"UINT8", "bInterfaceNumber", desc="USB Port Number", mode="read-only", editorParam={format="%d"}},
    {"UINT8", "bReserved2", desc="Reserved2", mode = "hidden", editorParam={format="0x%02x"}},
    {"UINT8", "bReserved3", desc="Reserved3", mode = "hidden", editorParam={format="0x%02x"}},

    layout = {sizer="grid", "bInterfaceNumber", "bEnable"}
},

-- TAG_DIAG_IF_CTRL_TCP = 0x10820002  4   netX Diagnostics and Remote Access component TCP interface control
-- "    interface enable flag (UINT8, 0, 1)
-- "    interface number (UINT8, 0...15)
-- "    TCP port number (UINT16)

TAG_DIAG_IF_CTRL_TCP_DATA_T = {
    {"UINT8", "bEnable", desc="Enable",
        editor="checkboxedit",
        editorParam={nBits = 8, offValue = 0, onValue = 1, otherValues = true}
    },
    {"UINT8", "bReserved1",   desc="Reserved1",       mode="hidden",    editorParam={format="0x%02x"}},
    {"UINT16", "usTCPPortNo", desc="TCP Port Number", mode="read-only", editorParam={format="%d"}},

    layout = {sizer="grid", "usTCPPortNo", "bEnable"}
},

-- TAG_DIAG_TRANSPORT_CTRL_CIFX = 0x10820003  4   netX Diagnostics and Remote Access component cifX transport interface control
-- "    interface enable flag (UINT8, 0, 1)
-- "    three bytes reserved for future use

TAG_DIAG_TRANSPORT_CTRL_CIFX_DATA_T = {
    {"UINT8", "bEnable", desc="Enable",
        editor="checkboxedit",
        editorParam={nBits = 8, offValue = 0, onValue = 1, otherValues = true}
    },
    {"UINT8", "bReserved1", desc="Reserved1", mode = "hidden", editorParam={format="0x%02x"}},
    {"UINT8", "bReserved2", desc="Reserved2", mode = "hidden", editorParam={format="0x%02x"}},
    {"UINT8", "bReserved3", desc="Reserved3", mode = "hidden", editorParam={format="0x%02x"}},

    layout = {sizer="grid", "bEnable"}
},

-- TAG_DIAG_TRANSPORT_CTRL_PACKET = 0x10820004  4   netX Diagnostics and Remote Access component packet transport interface control
-- "    interface enable flag (UINT8, 0, 1)
-- "    three bytes reserved for future use

TAG_DIAG_TRANSPORT_CTRL_PACKET_DATA_T = {
    {"UINT8", "bEnable", desc="Enable",
        editor="checkboxedit",
        editorParam={nBits = 8, offValue = 0, onValue = 1, otherValues = true}
    },
    {"UINT8", "bReserved1", desc="Reserved1", mode = "hidden", editorParam={format="0x%02x"}},
    {"UINT8", "bReserved2", desc="Reserved2", mode = "hidden", editorParam={format="0x%02x"}},
    {"UINT8", "bReserved3", desc="Reserved3", mode = "hidden", editorParam={format="0x%02x"}},

    layout = {sizer="grid", "bEnable"}
},





}



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

rcx_mod_tags = {
-- Firmware description tags
--

RCX_TAG_MEMSIZE =
    {paramtype = 0x800, datatype="RCX_TAG_MEMSIZE_T",          desc="Memory Size"},
RCX_TAG_MIN_PERSISTENT_STORAGE_SIZE =
    {paramtype = 0x801, datatype="RCX_TAG_MIN_PERSISTENT_STORAGE_SIZE_T", desc="Min. Storage Size"},
RCX_TAG_MIN_OS_VERSION =
    {paramtype = 0x802, datatype="RCX_TAG_MIN_OS_VERSION_T",   desc="Min. OS Version"},
RCX_TAG_MAX_OS_VERSION =
    {paramtype = 0x803, datatype="RCX_TAG_MAX_OS_VERSION_T",   desc="Max. OS Version"},
RCX_TAG_MIN_CHIP_REV =
    {paramtype = 0x804, datatype="RCX_TAG_MIN_CHIP_REV_T",     desc="Min. Chip Revision"},
RCX_TAG_MAX_CHIP_REV =
    {paramtype = 0x805, datatype="RCX_TAG_MAX_CHIP_REV_T",     desc="Max. Chip Revision"},
    



-- /* tag type codes for NXO specific tags */
-- #define RCX_TAG_STATIC_TASKS                    0x00001000
-- #define RCX_TAG_STATIC_TASK_PARAMETER_BLOCK     0x00001001  -
-- #define RCX_TAG_STATIC_TASK_ENTRY               0x00001002  -
-- #define RCX_TAG_TIMER                           0x00001010
-- #define RCX_TAG_INTERRUPT                       0x00001020
-- #define RCX_TAG_INTERRUPT_ENTRY                 0x00001022  -
-- #define RCX_TAG_UART                            0x00001030  - fehlt der noch?
-- #define RCX_TAG_LED                             0x00001040  -
-- #define RCX_TAG_XC                              0x00001050  -
-- 

-- task configuration
RCX_MOD_TAG_IT_STATIC_TASKS =
    {paramtype = 0x00001000, datatype="RCX_MOD_TAG_IT_STATIC_TASKS_T", desc="Task Group"},
RCX_MOD_TAG_IT_TIMER =
    {paramtype = 0x00001010, datatype ="RCX_MOD_TAG_IT_TIMER_T", desc="Hardware Timer"},
RCX_MOD_TAG_IT_INTERRUPT =
    {paramtype = 0x00001020, datatype ="RCX_MOD_TAG_IT_INTERRUPT_T", desc="Interrupt"},
RCX_MOD_TAG_IT_LED =
    {paramtype = 0x00001040, datatype ="RCX_MOD_TAG_IT_LED_T", desc="LED"},
RCX_MOD_TAG_IT_XC =
    {paramtype = 0x00001050, datatype ="RCX_MOD_TAG_IT_XC_T", desc="xC Unit"},


-- tags for configuration of 2nd stage loader
TAG_BSL_SDRAM_PARAMS =
    {paramtype = 0x40000000, datatype="TAG_BSL_SDRAM_PARAMS_DATA_T",          desc="SDRAM"},
TAG_BSL_HIF_PARAMS =
    {paramtype = 0x40000001, datatype="TAG_BSL_HIF_PARAMS_DATA_T",            desc="HIF/DPM"},
TAG_BSL_SDMMC_PARAMS =
    {paramtype = 0x40000002, datatype="TAG_BSL_SDMMC_PARAMS_DATA_T",          desc="SD/MMC"},
TAG_BSL_UART_PARAMS =
    {paramtype = 0x40000003, datatype="TAG_BSL_UART_PARAMS_DATA_T",           desc="UART"},
TAG_BSL_USB_PARAMS =
    {paramtype = 0x40000004, datatype="TAG_BSL_USB_PARAMS_DATA_T",            desc="USB"},
TAG_BSL_MEDIUM_PARAMS =
    {paramtype = 0x40000005, datatype="TAG_BSL_MEDIUM_PARAMS_DATA_T",         desc="BSL Media"},
TAG_BSL_EXTSRAM_PARAMS =
    {paramtype = 0x40000006, datatype="TAG_BSL_EXTSRAM_PARAMS_DATA_T",        desc="Ext. SRAM"},
TAG_BSL_HWDATA_PARAMS =
    {paramtype = 0x40000007, datatype="TAG_BSL_HWDATA_PARAMS_DATA_T",         desc="HW Data"},
TAG_BSL_FSU_PARAMS =
    {paramtype = 0x40000008, datatype="TAG_BSL_FSU_PARAMS_DATA_T",            desc="Fast Startup"},

-- tags for netX Diagnostics and Remote Access component
TAG_DIAG_IF_CTRL_UART =
    {paramtype = 0x10820000, datatype="TAG_DIAG_IF_CTRL_UART_DATA_T",          desc="UART Diagnostics Interface"},
TAG_DIAG_IF_CTRL_USB =
    {paramtype = 0x10820001, datatype="TAG_DIAG_IF_CTRL_USB_DATA_T",           desc="USB Diagnostics Interface"},
TAG_DIAG_IF_CTRL_TCP =
    {paramtype = 0x10820002, datatype="TAG_DIAG_IF_CTRL_TCP_DATA_T",           desc="TCP Diagnostics Interface"},
TAG_DIAG_TRANSPORT_CTRL_CIFX =
    {paramtype = 0x10820010, datatype="TAG_DIAG_TRANSPORT_CTRL_CIFX_DATA_T",   desc="Remote Access via cifX API"},
TAG_DIAG_TRANSPORT_CTRL_PACKET =
    {paramtype = 0x10820011, datatype="TAG_DIAG_TRANSPORT_CTRL_PACKET_DATA_T", desc="Remote Access via rcX Packets"},


}



---------------------------------------------------------------------------
--  mapping tag types to help files
---------------------------------------------------------------------------

-- "name" was used for the html book display; could be removed
HELP_MAPPING = {
    RCX_MOD_TAG_IT_LED                  = {file="RCX_MOD_TAG_IT_LED_T.htm"},
--     RCX_MOD_TAG_IT_PIO                  = {file="RCX_MOD_TAG_IT_PIO_T.htm"},
--     RCX_MOD_TAG_IT_GPIO                 = {file="RCX_MOD_TAG_IT_GPIO_T.htm"},
    RCX_MOD_TAG_IT_STATIC_TASKS         = {file="RCX_MOD_TAG_IT_STATIC_TASKS_T.htm"},
    RCX_MOD_TAG_IT_TIMER                = {file="RCX_MOD_TAG_IT_TIMER_T.htm"},
    RCX_MOD_TAG_IT_XC                   = {file="RCX_MOD_TAG_IT_XC_T.htm"},
    RCX_MOD_TAG_IT_INTERRUPT            = {file="RCX_MOD_TAG_IT_INTERRUPT_T.htm"},

    TAG_BSL_SDRAM_PARAMS                = {file="TAG_BSL_SDRAM_PARAMS_DATA_T.htm"},
    TAG_BSL_HIF_PARAMS                  = {file="TAG_BSL_HIF_PARAMS_DATA_T.htm"},
    TAG_BSL_SDMMC_PARAMS                = {file="TAG_BSL_SDMMC_PARAMS_DATA_T.htm"},
    TAG_BSL_UART_PARAMS                 = {file="TAG_BSL_UART_PARAMS_DATA_T.htm"},
    TAG_BSL_USB_PARAMS                  = {file="TAG_BSL_USB_PARAMS_DATA_T.htm"},
    TAG_BSL_MEDIUM_PARAMS               = {file="TAG_BSL_MEDIUM_PARAMS_DATA_T.htm"},
    TAG_BSL_EXTSRAM_PARAMS              = {file="TAG_BSL_EXTSRAM_PARAMS_DATA_T.htm"},
    TAG_BSL_HWDATA_PARAMS               = {file="TAG_BSL_HWDATA_PARAMS_DATA_T.htm"},
    TAG_BSL_FSU_PARAMS                  = {file="TAG_BSL_FSU_PARAMS_DATA_T.htm"},

    TAG_DIAG_IF_CTRL_UART               = {file="TAG_DIAG_CTRL_DATA_T.htm"},
    TAG_DIAG_IF_CTRL_USB                = {file="TAG_DIAG_CTRL_DATA_T.htm"},
    TAG_DIAG_IF_CTRL_TCP                = {file="TAG_DIAG_CTRL_DATA_T.htm"},
    TAG_DIAG_TRANSPORT_CTRL_CIFX        = {file="TAG_DIAG_CTRL_DATA_T.htm"},
    TAG_DIAG_TRANSPORT_CTRL_PACKET      = {file="TAG_DIAG_CTRL_DATA_T.htm"},

    RCX_TAG_MEMSIZE                     = {file="misc_tags.htm"},
    RCX_TAG_MIN_PERSISTENT_STORAGE_SIZE = {file="misc_tags.htm"},
    RCX_TAG_MIN_OS_VERSION              = {file="misc_tags.htm"},
    RCX_TAG_MAX_OS_VERSION              = {file="misc_tags.htm"},
    RCX_TAG_MIN_CHIP_REV                = {file="misc_tags.htm"},
    RCX_TAG_MAX_CHIP_REV                = {file="misc_tags.htm"},

}


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
--                   methods on tags/structures
---------------------------------------------------------------------------


function registerStructType(structname, structdef)
    structures[structname]=structdef
end


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


-- find the tag description given either
-- a key from rcx_mod_tags ("RCX_MOD_TAG_IT_STATIC_TASKS"),
-- an alternative key ("RCX_TAG_STATIC_TASKS"), or
-- the desc value from an entry of rcx_mod_tags ("Task Group")
-- RCX_MOD_TAG_IT_STATIC_TASKS =
--    {paramtype = 0x00001000, datatype="RCX_MOD_TAG_IT_STATIC_TASKS_T", desc="Task Group"},
-- alternative keys? RCX_TAG_STATIC_TASKS

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

function listKnownTags()
	-- reverse TAGNAME_ALIASES
	-- TAGNAME_ALIASES maps alternative name --> name in rcx_mod_tags,
	-- atAliases maps name in rcx_mod_tags -> alternative name
	local aastrAliases = {}
	for strAltTagname, strTagname in pairs(TAGNAME_ALIASES) do
		aastrAliases[strTagname] = aastrAliases[strTagname] or {}
		table.insert(aastrAliases[strTagname], strAltTagname)
	end

	-- sort rcx_mod_tags by tag code
	local atSortedTags = {}
	for strTagname, tTagDesc in pairs(rcx_mod_tags) do
		table.insert(atSortedTags, {
			paramtype = tTagDesc.paramtype,
			strTagname = strTagname,
			strDesc = tTagDesc.desc})
	end
	table.sort(atSortedTags, function(a,b) return a and b and a.paramtype < b.paramtype end)

	-- print
	print()
	print("Name                            Tag Id      Description")
	print("-------------------------------------------------------------------")
	for i, tTagDesc in ipairs(atSortedTags) do
		printf("%-30s (0x%08x) %s", tTagDesc.strTagname, tTagDesc.paramtype, tTagDesc.strDesc)
		local astrAliases = aastrAliases[tTagDesc.strTagname]
		if astrAliases then
			for j, strAlias in ipairs(astrAliases) do
				printf("  Alias: %s", strAlias)
			end
		end
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


function isReadOnly(tDef)
    return tDef.mode=="read-only"
end


function isHidden(tDef)
    return tDef.mode=="hidden"
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


--- Convert a list representation of a taglist to binary form.
-- The tags are padded to dword size.
-- @param params a list of tags. Each element is a list of
--   ulTag, ulSize, abParVal.
-- @return the binary taglist. If params is empty, an empty taglist
--   consisting only of the end marker is returned.
function paramsToBin(params)
    local abParblock = ""
    vbs_print("Serializing tag list")
    for _, param in ipairs(params) do
        local ulTag, ulSize, abValue = param.ulTag, param.ulSize, param.abValue
        vbs_printf("tag = 0x%08x  size=%d  value len=%d",
            ulTag, ulSize, abValue:len())
        local abTag =
            uint32tobin(ulTag) ..
            uint32tobin(ulSize) .. -- original size
            abValue ..
            string.rep(string.char(0), (4-abValue:len()) % 4)
        abParblock = abParblock .. abTag
    end

    -- append original end tag
    abParblock = abParblock .. uint32tobin(TAG_END) -- .. uint32tobin(0)
    if params.abEndGap then
        vbs_print("appending original data behind end marker")
        abParblock = abParblock .. params.abEndGap
    end
    vbs_print("Done")

    return abParblock

end

function uint32(bin, pos)
    return bin:byte(pos+1) + 0x100* bin:byte(pos+2) + 0x10000 * bin:byte(pos+3) + 0x1000000*bin:byte(pos+4)
end

--- Tries to extract a parameter list from binary data.
-- If a well-formed parameter block is found, the parameters are extracted.
-- This routine does not require a size after the end tag
--
-- @param abBin binary data
-- @param iStartPos 0-based offset of the parameter block in the data
--
-- @return fOk, paramlist, iLen, strError. fOk is true if a well-formed
-- parameter list was found, false otherwise.
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
    local ulTag, ulSize, abValue
    local ulStructSize

    vbs_print("Deserializing tag list")

    while (iPos < iLen) do
        -- get tag type
        if (iPos+4 > iLen) then
            strMsg = "Tag list truncated (in tag field)"
            break
        end

        ulTag = uint32(abBin, iPos)
        iPos = iPos+4

        -- end tag?
        if ulTag == TAG_END then
            -- list ends in end tag
            if iPos == iLen then
                fOk = true
                strMsg =
                "The tag list ends in a single zero end tag without length field."
            -- list ends in end tag + zero length indication - ok
            elseif iPos+4 == iLen and string.sub(abBin, iPos + 1) == string.char(0,0,0,0) then
                fOk = true
                params.abEndGap = string.sub(abBin, iPos + 1)
                --strMsg =
                --"Tag list contains zero length indication behind end marker."
            -- other data behind end tag - reject
            else
                strMsg =
                "Malformed/damaged tag list (End marker found inside tag list)"
            end
            break
        end

        -- get size
        if (iPos+4 > iLen) then
            strMsg = "Tag list truncated (in size field)"
            break
        end

        ulSize = uint32(abBin, iPos)
        iPos = iPos + 4

        -- print position, size, type
        vbs_printf("pos: 0x%08x, tag: 0x%08x, size: 0x%08x", iPos-8, ulTag, ulSize)

        -- if the tag is known, its value size must be either equal to the
        -- struct size, or equal to the struct size rounded up to dword size.
        ulStructSize = tagCodeToSize(ulTag)
        if ulStructSize and
            ulSize ~= ulStructSize and
            ulSize ~= ulStructSize + ((4-ulStructSize) % 4) then
            strMsg = string.format(
                "The length of a tag value does not match the data structure definition:\n"..
                "tag type = 0x%08x, tag data length = %d, required length = %d",
                --"Incorrect tag size: tag = 0x%08x, value size = %d, known size = %d",
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
        table.insert(params, {
            ulTag = ulTag,
            ulSize = ulSize, -- original size, allows to reconstruct the binary
            abValue = abValue
        })

        -- skip padding
        iPos = iPos + ((4 - iPos) % 4)

        if iPos > iLen then
            strMsg = "Tag list truncated (in padding)"
            break
        end
    end

    if not fOk and strMsg == "" then
        if ulTag ~= TAG_END then
            strMsg = "No end marker found in tag list."
        else
        -- this should never happen
            strMsg = "Unknown error in tag list."
        end
    end

    vbs_print("Done")

    return fOk, params, iPos - iStartPos, strMsg
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
	STRING = function(abValue) return abValue end,
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
        local tMember, abMemberValue
        for index, tMemberDef in ipairs(tStructDef) do
            strMemberName, strMemberType = tMemberDef[2], tMemberDef[1]

            -- get binary value
            tMember = atMembers[index]
            if fRecursive and tMember.tValue then
                abMemberValue = serialize(strMemberType, tMember.tValue, fRecursive)
                tMember.abValue = abMemberValue
            else
                abMemberValue = tMember.abValue
            end
            assert(abMemberValue,
                string.format("failed to get binary value for %s.%s", strTypeName, strMemberType))

            -- check size
            -- pad strings to the required size
            ulMemberSize = getStructMemberSize(tMemberDef)
            ulActualSize = abMemberValue:len()
            if ulActualSize<ulMemberSize and strMemberType=="STRING" then
                abMemberValue = abMemberValue .. string.rep(string.char(0), ulMemberSize - ulActualSize)
	            ulActualSize = abMemberValue:len()
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

-- fPretty = false: 
-- prints nested structure members with full member path, e.g.
--    .tDpmIsaAuto.ulIfConf0 = 0x00000000
-- fPretty = true:
-- prints nested structures enclosed in { }, e.g.
--    .tDpmIsaAuto = {
--        .ulIfConf0 = 0x00000000
--        ...
--     }

function printStructure(tStruct, strIndent, fPretty)
    strIndent = strIndent or ""
    if type(tStruct)=="table" then
        -- make format string for member names
        local iMaxNameLen = 0
        for iMember, tMember in ipairs(tStruct) do
            if isPrimitiveType(tMember.strType) and tMember.strName:len()>iMaxNameLen then 
                    iMaxNameLen = tMember.strName:len()
            end
        end
        local strNameFormat = "%-" .. tostring(iMaxNameLen) .. "s"
        
        -- print the members
        for iMember, tMember in ipairs(tStruct) do
            local strName = string.format(strNameFormat, tMember.strName)
            if isPrimitiveType(tMember.strType) then
                local strValue = primitiveTypeToString(tMember.strType, tMember.tValue)
                printf("%s.%s = %s", strIndent, strName, strValue)
            --[[
            if type(tMember.tValue)=="number" then
                printf("%s.%s = 0x%08x", strIndent, tMember.strName, tMember.tValue)
            elseif type(tMember.tValue)=="string" then
                printf("%s.%s = %s", strIndent, tMember.strName, tMember.tValue)
                --]]
            elseif type(tMember.tValue)=="table" then
                if fPretty then
                    printf("%s.%s = {",  strIndent, tMember.strName)
                    printStructure(tMember.tValue, strIndent.."    ", fPretty)
                    printf("%s }",  strIndent)
                else
                    printStructure(tMember.tValue, strIndent .. "." .. tMember.strName, fPretty)
                end
            else
                printf("%s.%s = %s(%s)", strIndent, tMember.strName, tostring(tMember.tValue), type(tMember.tValue))
            end
        end
    else
        printf("%s (string)", strIndent)
    end
end

-- Check if two structures are structurally identical, i.e. 
-- they have the same number, names and types of members.
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

-- Compare the values in two structures with the same type. 
-- Members with equal values are listed as by printStructure, 
-- members with different values are listed as 
-- SET fieldname = <value in tStruct2>
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
			local fOk, msg = printStructure(tMember1.tValue, tMember2.tValue, strIndent .. "." .. tMember2.strName, fPretty)
			if not fOk then
				return fOk, msg
			end
		else
			printf("%s.%s = %s(%s)", strIndent, tMember2.strName, tostring(tMember2.tValue), type(tMember2.tValue))
		end
	end
	return true
end
---------------------------------------------------------------------
--                       make empty taglist
---------------------------------------------------------------------


function makeEmptyParblock()
    local abParblock = ""
    for _, strTagname in ipairs(example_taglist) do
        local tPardesc = rcx_mod_tags[strTagname]
        local ulTag = tPardesc.paramtype
        assert(tPardesc, "unknown tag in example block: " .. strTagname)
        local ulSize = getSize(strTagname)
        assert(ulSize, "datatype size not found")
        vbs_printf("tag: 0x%08x size: %u  %-25s ", tPardesc.paramtype, ulSize, strTagname)
        abParblock = abParblock ..
            uint32tobin(tPardesc.paramtype) ..
            uint32tobin(ulSize) ..
            string.rep(string.char(0), ulSize + (4 - ulSize) % 4)

    end

    --abParblock = abParblock .. uint32tobin(42) .. uint32tobin(10) .. "0123456789"

    abParblock = abParblock .. uint32tobin(TAG_END) .. uint32tobin(0)
    return abParblock
end


example_taglist = {
"RCX_MOD_TAG_IT_STATIC_TASKS",
"RCX_MOD_TAG_IT_STATIC_TASKS",
"RCX_MOD_TAG_IT_XC",
"RCX_MOD_TAG_IT_TIMER",
"RCX_MOD_TAG_IT_INTERRUPT",
"RCX_MOD_TAG_IT_LED",
--"RCX_MOD_TAG_IT_PIO",
--"RCX_MOD_TAG_IT_GPIO",

"TAG_BSL_SDRAM_PARAMS",
"TAG_BSL_HIF_PARAMS",
"TAG_BSL_SDMMC_PARAMS",
"TAG_BSL_UART_PARAMS",
"TAG_BSL_USB_PARAMS",
"TAG_BSL_MEDIUM_PARAMS",
"TAG_BSL_EXTSRAM_PARAMS",
"TAG_BSL_HWDATA_PARAMS",
"TAG_BSL_FSU_PARAMS",

"TAG_DIAG_IF_CTRL_UART",
"TAG_DIAG_IF_CTRL_USB",
"TAG_DIAG_IF_CTRL_TCP",
"TAG_DIAG_TRANSPORT_CTRL_CIFX",
"TAG_DIAG_TRANSPORT_CTRL_PACKET",

"RCX_TAG_MEMSIZE",
"RCX_TAG_MIN_PERSISTENT_STORAGE_SIZE",
"RCX_TAG_MIN_OS_VERSION",
"RCX_TAG_MAX_OS_VERSION",
"RCX_TAG_MIN_CHIP_REV",
"RCX_TAG_MAX_CHIP_REV",
--"RCX_TAG_NUM_COMM_CHANNEL",


--"mac_address",
--"ipv4_address",
--"arbitrary_data",
}
