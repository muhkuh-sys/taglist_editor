---------------------------------------------------------------------------
-- Copyright (C) 2010 Hilscher Gesellschaft für Systemautomation mbH
--
-- Description:
--   Tag definitions for Taglist editor
--
--  Changes:
--    Date        Author        Description
---------------------------------------------------------------------------
--  2010-06-28    SL            added diag interface tags
---------------------------------------------------------------------------
-- SVN Keywords
--
-- $Date: 2010-06-28 11:25:03 +0200 (Mo, 28 Jun 2010) $
-- $Revision: 8579 $
-- $Author: slesch $
---------------------------------------------------------------------------


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
-- The elementary data types. Each entry may contain:
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
UINT16 = {size=2, editor="numedit", editorParam={nBits=16}},
UINT8 = {size=1, editor="numedit", editorParam={nBits=8}},
STRING = {editor="stringedit"},
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
local RCX_MOD_TAG_IDENTIFIER_T = {"STRING", "tIdentifier.abName", desc="Identifier", size=16, mode="read-only"}

structures = {


--
memsize_t =
    {{"UINT32", "ulMemSize",        mode="read-only", desc="Memory Size"}},
min_persistent_storage_size_t =
    {{"UINT32", "ulMinStorageSize", mode="read-only", desc="Min. Persistent Storage Size"}},
min_os_version_t =
    {{"rcxver", "ulMinOsVer",       mode="read-only", desc="Min. OS Version"}},
max_os_version_t =
    {{"rcxver", "ulMaxOsVer",       mode="read-only", desc="Max. OS Version"}},
min_chip_rev_t =
    {{"UINT32", "ulMinChipRev",     mode="read-only", desc="Min. Chip Revision"}},
max_chip_rev_t =
    {{"UINT32", "ulMaxChipRev",     mode="read-only", desc="Max. Chip Revision"}},
num_comm_channel_t =
    {{"UINT32", "ulNumCommCh",      mode="read-only", desc="Number of required comm channels"}},
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
  nameField = "tIdentifier.abName"
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
  nameField = "tIdentifier.abName"

},


----------------------------------------------------------------------------------------------
--        LED


RCX_MOD_TAG_IT_LED_T=
{
  RCX_MOD_TAG_IDENTIFIER_T,

  {"UINT32",                                "ulUsesResourceType", desc="Resource Type",
    editor="comboedit", editorParam={nBits=32,
    values={{name="GPIO", value=1},{name="PIO", value=2},{name="HIF PIO", value=3}}}},

  {"UINT32",                                "ulPinNumber",   desc="Pin Number",
    editorParam ={format="%u"}},

  {"UINT32",                                "ulPolarity",    desc="Polarity",
    editor="comboedit", editorParam={nBits=32,
    values={{name="normal", value=0},{name="inverted", value=1}}}},
  nameField = "tIdentifier.abName"
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
  RCX_MOD_TAG_IDENTIFIER_T,
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
  nameField = "tIdentifier.abName",
  layout=  {sizer="grid", "tIdentifier.abName",
                      "tMode", "tDirection",
                      "tSet", "tClear", "tInput"},
},


----------------------------------------------------------------------------------------------
--        GPIO
RCX_MOD_TAG_IT_GPIO_T = {
  RCX_MOD_TAG_IDENTIFIER_T,
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
  nameField = "tIdentifier.abName"
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

    {"BSL_DPM_PARAMS_T", "DPM/ISA/Auto", desc="DPM/ISA settings"},
    {"BSL_PCI_PARAMS_T", "PCI", desc="PCI settings"},
    --[[
    {"BSL_DPM_PARAMS_T", "DPM/ISA/Auto", "DPM settings", offset = 4},
    {"BSL_PCI_PARAMS_T", "PCI", "PCI settings", offset = 4},

    fStructToBin = function(elements)
        local ulBusType = uint32(elements[1].abValue, 0)
        if ulBusType == 3 then
            return elements[1].abValue .. elements[3].abValue .. elements[2].abValue:sub(5, 16)
        else
            return elements[1].abValue .. elements[2].abValue
        end
    end
    --]]
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
                --{name="MMIO",                      value=4},
        }},
    },

    {"UINT8", "bInvert", desc="Inverted",
        offset = 1, mask = string.char(0x80),
        editor="checkboxedit",
        editorParam={nBits = 8, offValue = 0, onValue = 128, otherValues = true}
        --[[
        editor="comboedit",
        editorParam={nBits=8,
            values={
                {name="No", value=0},
                {name="Yes", value=128}
        }},
        --]]
    },

    {"UINT16", "usPinNumber", desc="Pin Number", editorParam={format="%u"}},
},


TAG_BSL_HIF_PARAMS_DATA_T___OLD = {
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

    -- DPM/ISA settings
    {"UINT32", "ulIfConf0",    desc="IF_CONF0 register value", editorParam={format="0x%08x"}},
    {"UINT32", "ulIfConf1",    desc="IF_CONF1 register value", editorParam={format="0x%08x"}},
    {"UINT32", "ulIoRegMode0", desc="IO_REGMODE0 register value", editorParam={format="0x%08x"}},
    {"UINT32", "ulIoRegMode1", desc="IO_REGMODE1 register value", editorParam={format="0x%08x"}},

    -- PCI settings
    -- todo: decide how to handle this!
    --[[
    {"UINT8", "bEnablePin", desc="Use PCI enable pin",
        editor="checkboxedit",
        editorParam={nBits = 8, offValue = 0, onValue = 1, otherValues = true}
    },

    {"UINT8", "bPinType", desc="Type of enable pin",
        offset = 21, mask = string.char(0x7f),
        editor="comboedit",
        editorParam={nBits=8,
            values={
                {name="Ignore pin",                value=0},
                {name="GPIO",                      value=1},
                {name="PIO",                       value=2},
                {name="HIFPIO",                    value=3},
                --{name="MMIO",                      value=4},
        }},
    },

    {"UINT8", "bInvert", desc="Inverted",
        offset = 21, mask = string.char(0x80),
        editor="comboedit",
        editorParam={nBits=8,
            values={
                {name="No", value=0},
                {name="Yes", value=128}
        }},
    },

    {"UINT16", "usPinNumber", desc="Pin Number", editorParam={format="%u"}},

    fBinToStruct = function(abBin)
        local abBusType = abBin:sub(1, 4)
        local ulBusType = uint33(abBusType, 1)
        local ab0 = uint32tobin(0)
        local abIfConf0      = ab0
        local abIfConf1      = ab0
        local abIoRegMode0   = ab0
        local abIoRegMode1   = ab0
        local abEnablePin    = string.char(0)
        local abPinType      = string.char(0)
        local abInvert       = string.char(0)
        local abPinNumber    = string.char(0, 0)

        if ulBusType == 3 then
            abEnablePin = abBin:sub(4, 4)
            abPinType = stringAnd(abBin:sub(5, 5), string.char(0x7f))
            abInvert = stringAnd(abBin:sub(5, 5), string.char(0x80))
            abPinNumber = abBin:sub(6, 7)
        else
            abIfConf0 = abBin:sub(5, 8)
            abIfConf1 = abBin:sub(9, 12)
            abIoRegMode0 = abBin:sub(13, 16)
            abIoRegMode1 = abBin:sub(17, 20)
        end

        return {
            {strName = "ulBusType",        strType = "UINT32",  ulSize = 4,  abValue = abBusType},
            {strName = "ulIfConf0",        strType = "UINT32",  ulSize = 4,  abValue = abIfConf0},
            {strName = "ulIfConf1",        strType = "UINT32",  ulSize = 4,  abValue = abIfConf1},
            {strName = "ulIoRegMode0",     strType = "UINT32",  ulSize = 4,  abValue = abIoRegMode0},
            {strName = "ulIoRegMode1",     strType = "UINT32",  ulSize = 4,  abValue = abIoRegMode1},
            {strName = "bEnablePin",       strType = "UINT8",   ulSize = 1,  abValue = abEnablePin},
            {strName = "bPinType",         strType = "UINT8",   ulSize = 1,  abValue = abPinType},
            {strName = "bInvert",          strType = "UINT8",   ulSize = 1,  abValue = abInvert},
            {strName = "usPinNumber",      strType = "UINT16",  ulSize = 2,  abValue = abPinNumber},
        }
    end,

    fBinToStruct2 = function(abBin, elements)
        local abBusType = abBin:sub(1, 4)
        local ulBusType = uint33(abBusType, 1)
        if ulBusType == 3 then
            elements[1] = uint32tobin(0)
            elements[2] = uint32tobin(0)
            elements[3] = uint32tobin(0)
            elements[4] = uint32tobin(0)
        else
            elements[5] = string.char(0)
            elements[2] = string.char(0)
            elements[3] = string.char(0)
            elements[4] = string.char(0, 0)
        end
        return elements
    end
    --]]
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
        --[[
        editor="comboedit",
        editorParam={nBits=8,
            values={
                {name="No", value=0},
                {name="Yes", value=128}
        }},
        --]]
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
        --[[
        editor="comboedit",
        editorParam={nBits=8,
            values={
                {name="No", value=0},
                {name="Yes", value=128}
        }},
        --]]
    },
    {"UINT16", "usUpllupPinIdx", desc="Pin Number", editorParam={format="%u"}},
},

----------------------------------------------------------------------------------------------
--  2nd stage loader media settings
TAG_BSL_MEDIUM_PARAMS_DATA_T = {
    {"UINT8", "´bFlash", desc="Flash Bootloader",
        editor="checkboxedit",
        editorParam={nBits = 8, offValue = 0, onValue = 1, otherValues = true}
    },

    {"UINT8", "bMediumType", desc="Destination",
        editor="comboedit",
        editorParam={nBits=8,
            values={
                {name="Auto",             value=0},
                {name="RAM Disk",         value=1},
                {name="Serial Flash",     value=2},
                {name="Parallel Flash",   value=3},
        }},
    },
},

----------------------------------------------------------------------------------------------
--  2nd stage loader ext. chip select settings
--[[
BSL_EXTRAM_CONFIG_T = {
    {"UINT8", "bWaitstates", desc="Wait States",
        editorParam={nBits=6, minValue=0, maxValue=63, format="%u"}
    },
    {"UINT8", "bPrePauseWs", desc="Setup WS",
        editor="comboedit",
        editorParam={nBits=8, minValue=0, maxValue=3}
    },
    {"UINT8", "bPostPauseWs", desc="Post Access WS",
        editor="comboedit",
        editorParam={nBits=8, minValue=0, maxValue=3}
    },
    {"UINT8", "bDataWidth", desc="Data Width",
        editor="comboedit",
        editorParam={nBits=8,
            values={
                {name="8",   value=0},
                {name="16",  value=1},
                {name="32",  value=2},
        }},
    },
    --layout = {sizer="h", "bDataWidth", "bWaitstates", "bPrePauseWs", "bPostPauseWs"}
    layout = {sizer="v",
        "bDataWidth",
        {sizer="h", "bWaitstates", "bPrePauseWs", "bPostPauseWs"}
        }
},
--]]

TAG_BSL_EXTSRAM_PARAMS_DATA_T = {
--  {"BSL_EXTRAM_CONFIG_T", "ulRegVal0", desc="MEM_SRAM0_CTRL"},
--  {"BSL_EXTRAM_CONFIG_T", "ulRegVal1", desc="MEM_SRAM1_CTRL"},
    {"UINT32", "ulRegVal0", desc="MEM_SRAM0_CTRL", editorParam={format="0x%08x"}},
    {"UINT32", "ulRegVal1", desc="MEM_SRAM1_CTRL", editorParam={format="0x%08x"}},
    {"UINT32", "ulRegVal2", desc="MEM_SRAM2_CTRL", editorParam={format="0x%08x"}},
    {"UINT32", "ulRegVal3", desc="MEM_SRAM3_CTRL", editorParam={format="0x%08x"}},
    --layout = {sizer="v", {sizer="v", "ulRegVal0", "ulRegVal1"},
    --                  {sizer="v", "ulRegVal2", "ulRegVal3"}}
},

----------------------------------------------------------------------------------------------
--  2nd stage loader HW Data
--[[
  unsigned char  bEnable;
  unsigned short usManufacturer;
  unsigned short usProductionDate;
  unsigned short usDeviceClass;
  unsigned char  bHwCompatibility;
  unsigned char  bHwRevision;
  unsigned long  ulDeviceNr;
  unsigned long  ulSerialNr;
  unsigned short ausHwOptions[4];
  --]]

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
-- elementary type tags -> read only
--
memsize =
    {paramtype = 0x800, datatype="memsize_t",          desc="Memory Size"},
min_persistent_storage_size =
    {paramtype = 0x801, datatype="min_persistent_storage_size_t", desc="Min. Storage Size"},
min_os_version =
    {paramtype = 0x802, datatype="min_os_version_t",   desc="Min. OS Version"},
max_os_version =
    {paramtype = 0x803, datatype="max_os_version_t",   desc="Max. OS Version"},
min_chip_rev =
    {paramtype = 0x804, datatype="min_chip_rev_t",     desc="Min. Chip Revision"},
max_chip_rev =
    {paramtype = 0x805, datatype="max_chip_rev_t",     desc="Max. Chip Revision"},
num_comm_channel =
    {paramtype = 0x806, datatype="num_comm_channel_t", desc="Number of channels"},
--
--[[
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
    {paramtype = 0x806, datatype="UINT32", mode="read-only", desc="Number of required comm channels"},
--
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

-- unused
mac_address =
    {paramtype=1, datatype="mac", desc="MAC Address"},
ipv4_address =
    {paramtype=2, datatype="ipv4", desc="IP Address"},
manufacturer_name =
    {paramtype=6, datatype="STRING", size=16, desc="Manufacturer Name"},
arbitrary_data =
    {paramtype=7, datatype="bindata", size=64, desc="Binary Data"}
}



---------------------------------------------------------------------------
--  mapping tag types to help files
---------------------------------------------------------------------------

-- "name" was used for the html book display; could be removed
HELP_MAPPING = {
    RCX_MOD_TAG_IT_LED                  = {name="LED Tag",       file="RCX_MOD_TAG_IT_LED_T.htm"},
    RCX_MOD_TAG_IT_PIO                  = {name="PIO Tag",       file="RCX_MOD_TAG_IT_PIO_T.htm"},
    RCX_MOD_TAG_IT_GPIO                 = {name="GPIO Tag",      file="RCX_MOD_TAG_IT_GPIO_T.htm"},
    RCX_MOD_TAG_IT_STATIC_TASKS         = {name="Static Task Priorities Tag", file="RCX_MOD_TAG_IT_STATIC_TASKS_T.htm"},
    RCX_MOD_TAG_IT_TIMER                = {name="Timer Tag",     file="RCX_MOD_TAG_IT_TIMER_T.htm"},
    RCX_MOD_TAG_IT_XC                   = {name="xC Tag",        file="RCX_MOD_TAG_IT_XC_T.htm"},
    RCX_MOD_TAG_IT_INTERRUPT            = {name="Interrupt Tag", file="RCX_MOD_TAG_IT_INTERRUPT_T.htm"},

    TAG_BSL_SDRAM_PARAMS                = {name="SDRAM",         file="TAG_BSL_SDRAM_PARAMS_DATA_T.htm"},
    TAG_BSL_HIF_PARAMS                  = {name="HIF/DPM",       file="TAG_BSL_HIF_PARAMS_DATA_T.htm"},
    TAG_BSL_SDMMC_PARAMS                = {name="SD/MMC",        file="TAG_BSL_SDMMC_PARAMS_DATA_T.htm"},
    TAG_BSL_UART_PARAMS                 = {name="UART",          file="TAG_BSL_UART_PARAMS_DATA_T.htm"},
    TAG_BSL_USB_PARAMS                  = {name="USB",           file="TAG_BSL_USB_PARAMS_DATA_T.htm"},
    TAG_BSL_MEDIUM_PARAMS               = {name="BSL media",     file="TAG_BSL_MEDIUM_PARAMS_DATA_T.htm"},
    TAG_BSL_EXTSRAM_PARAMS              = {name="ext. SRAM",     file="TAG_BSL_EXTSRAM_PARAMS_DATA_T.htm"},
    TAG_BSL_HWDATA_PARAMS               = {name="HW Data",       file="TAG_BSL_HWDATA_PARAMS_DATA_T.htm"},
    TAG_BSL_FSU_PARAMS                  = {name="FSU",           file="TAG_BSL_FSU_PARAMS_DATA_T.htm"},
    
    TAG_DIAG_IF_CTRL_UART               = {name="",              file="TAG_DIAG_CTRL_DATA_T.htm"},
    TAG_DIAG_IF_CTRL_USB                = {name="",              file="TAG_DIAG_CTRL_DATA_T.htm"},
    TAG_DIAG_IF_CTRL_TCP                = {name="",              file="TAG_DIAG_CTRL_DATA_T.htm"},
    TAG_DIAG_TRANSPORT_CTRL_CIFX        = {name="",              file="TAG_DIAG_CTRL_DATA_T.htm"},
    TAG_DIAG_TRANSPORT_CTRL_PACKET      = {name="",              file="TAG_DIAG_CTRL_DATA_T.htm"},
    
    memsize                             = {name="", file="misc_tags.htm"},
    num_comm_channel                    = {name="", file="misc_tags.htm"}, --anchor="#min_persistent_storage_size"},
    min_persistent_storage_size         = {name="", file="misc_tags.htm"}, --anchor="#min_persistent_storage_size"},
    min_os_version                      = {name="", file="misc_tags.htm"}, --anchor="#min_os_version"},
    max_os_version                      = {name="", file="misc_tags.htm"}, --anchor="#max_os_version"},
    min_chip_rev                        = {name="", file="misc_tags.htm"}, --anchor="#min_chip_rev"},
    max_chip_rev                        = {name="", file="misc_tags.htm"}, --anchor="#max_chip_rev"},
    num_comm_channels                   = {name="", file="misc_tags.htm"}, --anchor="#num_comm_channels"},

    --[[  unused
    xc_alloc                            = {name="", file="misc_tags.htm"}, --anchor="#xc_alloc"},
    irq_alloc                           = {name="", file="misc_tags.htm"}, --anchor="#irq_alloc"},
    comm_channel_alloc                  = {name="", file="misc_tags.htm"}, --anchor="#comm_channel_alloc"},
    supported_comm_channels             = {name="", file="misc_tags.htm"}, --anchor="#supported_comm_channels"},
    num_tasks                           = {name="", file="misc_tags.htm"}, --anchor="#num_tasks"},
    --]]
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
--[[
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
--]]

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
    for _, param in ipairs(params) do
        local ulTag, ulSize, abValue = param.ulTag, param.ulSize, param.abValue
        print(string.format("tag = 0x%08x  size=%d  value len=%d",
            ulTag, ulSize, abValue:len()))
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
        print("appending original data behind end marker")
        abParblock = abParblock .. params.abEndGap
    end

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
        print(string.format("pos: 0x%08x, tag: 0x%08x, size: 0x%08x", iPos-8, ulTag, ulSize))

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

    return fOk, params, iPos - iStartPos, strMsg
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
        print(string.format ("tag: 0x%08x size: %u  %-25s ", tPardesc.paramtype, ulSize, strTagname))
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
"RCX_MOD_TAG_IT_PIO",
"RCX_MOD_TAG_IT_GPIO",

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
