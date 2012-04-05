---------------------------------------------------------------------------
-- Copyright (C) 2010 Hilscher Gesellschaft für Systemautomation mbH
--
-- Description:
--   Defines tags used by 2nd Stage Loader
--
--  Changes:
--    Date        Author        Description
---------------------------------------------------------------------------
-- 2012-03-28     SL            added TAG_BSL_SERFLASH_PARAMS
-- 2011-06-01     SL            added TAG_BSL_BACKUP_POS_PARAMS
-- 2011-05-12     SL            factored out from taglist.lua
---------------------------------------------------------------------------

module("tagdefs_bsl", package.seeall)

---------------------------------------------------------------------------
-- SVN Keywords
--
SVN_DATE   ="$Date$"
SVN_VERSION="$Revision$"
-- $Author$
---------------------------------------------------------------------------
require("taglist")

-- MMIO flags
MMIO_FLAGS = {
    {name="No Inversion",             value = 0x00},
    {name="Output Inversion",         value = 0x01},
    {name="Input Inversion",          value = 0x02},
    {name="Input + Output Inversion", value = 0x03},
}


-- MMIO function codes for netX 10
NETX10_MMIO_CONFIG = {
    {name="XM0_IO0",       value = 0x00},
    {name="XM0_IO1",       value = 0x01},
    {name="XM0_IO2",       value = 0x02},
    {name="XM0_IO3",       value = 0x03},
    {name="XM0_IO4",       value = 0x04},
    {name="XM0_IO5",       value = 0x05},
    {name="XM0_RX",        value = 0x06},
    {name="GPIO0",         value = 0x07},
    {name="GPIO1",         value = 0x08},
    {name="GPIO2",         value = 0x09},
    {name="GPIO3",         value = 0x0A},
    {name="GPIO4",         value = 0x0B},
    {name="GPIO5",         value = 0x0C},
    {name="GPIO6",         value = 0x0D},
    {name="GPIO7",         value = 0x0E},
    {name="PHY0_LED0",     value = 0x0F},
    {name="PHY0_LED1",     value = 0x10},
    {name="PHY0_LED2",     value = 0x11},
    {name="PHY0_LED3",     value = 0x12},
    {name="SPI0_CS1N",     value = 0x13},
    {name="SPI0_CS2N",     value = 0x14},
    {name="SPI1_CLK",      value = 0x15},
    {name="SPI1_CS0N",     value = 0x16},
    {name="SPI1_CS1N",     value = 0x17},
    {name="SPI1_CS2N",     value = 0x18},
    {name="SPI1_MISO",     value = 0x19},
    {name="SPI1_MOSI",     value = 0x1A},
    {name="I2C_SCL",       value = 0x1B},
    {name="I2C_SDA",       value = 0x1C},
    {name="UART0_CTSn",    value = 0x1D},
    {name="UART0_RTSn",    value = 0x1E},
    {name="UART0_RXD",     value = 0x1F},
    {name="UART0_TXD",     value = 0x20},
    {name="UART1_CTSn",    value = 0x21},
    {name="UART1_RTSn",    value = 0x22},
    {name="UART1_RXD",     value = 0x23},
    {name="UART1_TXD",     value = 0x24},
    {name="PWM_FAILURE_N", value = 0x25},
    {name="POS_ENC0_A",    value = 0x26},
    {name="POS_ENC0_B",    value = 0x27},
    {name="POS_ENC0_N",    value = 0x28},
    {name="POS_ENC1_A",    value = 0x29},
    {name="POS_ENC1_B",    value = 0x2A},
    {name="POS_ENC1_N",    value = 0x2B},
    {name="POS_MP0",       value = 0x2C},
    {name="POS_MP1",       value = 0x2D},
    {name="IO_LINK0_IN",   value = 0x2E},
    {name="IO_LINK0_OUT",  value = 0x2F},
    {name="IO_LINK0_OE",   value = 0x30},
    {name="IO_LINK1_IN",   value = 0x31},
    {name="IO_LINK1_OUT",  value = 0x32},
    {name="IO_LINK1_OE",   value = 0x33},
    {name="IO_LINK2_IN",   value = 0x34},
    {name="IO_LINK2_OUT",  value = 0x35},
    {name="IO_LINK2_OE",   value = 0x36},
    {name="IO_LINK3_IN",   value = 0x37},
    {name="IO_LINK3_OUT",  value = 0x38},
    {name="IO_LINK3_OE",   value = 0x39},
    {name="PIO",           value = 0x3F},
}


-- MMIO function codes for netX 50
NETX50_MMIO_CONFIG = {
    {name="XM0_IO0",            value = 0x00},
    {name="XM0_IO1",            value = 0x01},
    {name="XM0_IO2",            value = 0x02},
    {name="XM0_IO3",            value = 0x03},
    {name="XM0_IO4",            value = 0x04},
    {name="XM0_IO5",            value = 0x05},
    {name="XM0_RX",             value = 0x06},
    {name="XM0_TX_OE",          value = 0x07},
    {name="XM0_TX_OUT",         value = 0x08},
    {name="XM1_IO0",            value = 0x09},
    {name="XM1_IO1",            value = 0x0A},
    {name="XM1_IO2",            value = 0x0B},
    {name="XM1_IO3",            value = 0x0C},
    {name="XM1_IO4",            value = 0x0D},
    {name="XM1_IO5",            value = 0x0E},
    {name="XM1_RX",             value = 0x0F},
    {name="XM1_TX_OE",          value = 0x10},
    {name="XM1_TX_OUT",         value = 0x11},
    {name="GPIO0",              value = 0x12},
    {name="GPIO1",              value = 0x13},
    {name="GPIO2",              value = 0x14},
    {name="GPIO3",              value = 0x15},
    {name="GPIO4",              value = 0x16},
    {name="GPIO5",              value = 0x17},
    {name="GPIO6",              value = 0x18},
    {name="GPIO7",              value = 0x19},
    {name="GPIO8",              value = 0x1A},
    {name="GPIO9",              value = 0x1B},
    {name="GPIO10",             value = 0x1C},
    {name="GPIO11",             value = 0x1D},
    {name="GPIO12",             value = 0x1E},
    {name="GPIO13",             value = 0x1F},
    {name="GPIO14",             value = 0x20},
    {name="GPIO15",             value = 0x21},
    {name="GPIO16",             value = 0x22},
    {name="GPIO17",             value = 0x23},
    {name="GPIO18",             value = 0x24},
    {name="GPIO19",             value = 0x25},
    {name="GPIO20",             value = 0x26},
    {name="GPIO21",             value = 0x27},
    {name="GPIO22",             value = 0x28},
    {name="GPIO23",             value = 0x29},
    {name="GPIO24",             value = 0x2A},
    {name="GPIO25",             value = 0x2B},
    {name="GPIO26",             value = 0x2C},
    {name="GPIO27",             value = 0x2D},
    {name="GPIO28",             value = 0x2E},
    {name="GPIO29",             value = 0x2F},
    {name="GPIO30",             value = 0x30},
    {name="GPIO31",             value = 0x31},
    {name="PHY0_LED0",          value = 0x32},
    {name="PHY0_LED1",          value = 0x33},
    {name="PHY0_LED2",          value = 0x34},
    {name="PHY0_LED3",          value = 0x35},
    {name="PHY1_LED0",          value = 0x36},
    {name="PHY1_LED1",          value = 0x37},
    {name="PHY1_LED2",          value = 0x38},
    {name="PHY1_LED3",          value = 0x39},
    {name="MII_MDC",            value = 0x3A},
    {name="MII_MDIO",           value = 0x3B},
    {name="MII0_COL",           value = 0x3C},
    {name="MII0_CRS",           value = 0x3D},
    {name="MII0_LED0",          value = 0x3E},
    {name="MII0_LED1",          value = 0x3F},
    {name="MII0_LED2",          value = 0x40},
    {name="MII0_LED3",          value = 0x41},
    {name="MII0_RXCLK",         value = 0x42},
    {name="MII0_RXD0",          value = 0x43},
    {name="MII0_RXD1",          value = 0x44},
    {name="MII0_RXD2",          value = 0x45},
    {name="MII0_RXD3",          value = 0x46},
    {name="MII0_RXDV",          value = 0x47},
    {name="MII0_RXER",          value = 0x48},
    {name="MII0_TXCLK",         value = 0x49},
    {name="MII0_TXD0",          value = 0x4A},
    {name="MII0_TXD1",          value = 0x4B},
    {name="MII0_TXD2",          value = 0x4C},
    {name="MII0_TXD3",          value = 0x4D},
    {name="MII0_TXEN",          value = 0x4E},
    {name="MII0_TXER",          value = 0x4F},
    {name="MII1_COL",           value = 0x50},
    {name="MII1_CRS",           value = 0x51},
    {name="MII1_LED0",          value = 0x52},
    {name="MII1_LED1",          value = 0x53},
    {name="MII1_LED2",          value = 0x54},
    {name="MII1_LED3",          value = 0x55},
    {name="MII1_RXCLK",         value = 0x56},
    {name="MII1_RXD0",          value = 0x57},
    {name="MII1_RXD1",          value = 0x58},
    {name="MII1_RXD2",          value = 0x59},
    {name="MII1_RXD3",          value = 0x5A},
    {name="MII1_RXDV",          value = 0x5B},
    {name="MII1_RXER",          value = 0x5C},
    {name="MII1_TXCLK",         value = 0x5D},
    {name="MII1_TXD0",          value = 0x5E},
    {name="MII1_TXD1",          value = 0x5F},
    {name="MII1_TXD2",          value = 0x60},
    {name="MII1_TXD3",          value = 0x61},
    {name="MII1_TXEN",          value = 0x62},
    {name="MII1_TXER",          value = 0x63},
    {name="PIO0",               value = 0x64},
    {name="PIO1",               value = 0x65},
    {name="PIO2",               value = 0x66},
    {name="PIO3",               value = 0x67},
    {name="PIO4",               value = 0x68},
    {name="PIO5",               value = 0x69},
    {name="PIO6",               value = 0x6A},
    {name="PIO7",               value = 0x6B},
    {name="SPI0_CS2N",          value = 0x6C},
    {name="SPI1_CLK",           value = 0x6D},
    {name="SPI1_CS0N",          value = 0x6E},
    {name="SPI1_CS1N",          value = 0x6F},
    {name="SPI1_CS2N",          value = 0x70},
    {name="SPI1_MISO",          value = 0x71},
    {name="SPI1_MOSI",          value = 0x72},
    {name="I2C_SCL_MMIO",       value = 0x73},
    {name="I2C_SDA_MMIO",       value = 0x74},
    {name="XC_SAMPLE0",         value = 0x75},
    {name="XC_SAMPLE1",         value = 0x76},
    {name="XC_TRIGGER0",        value = 0x77},
    {name="XC_TRIGGER1",        value = 0x78},
    {name="UART0_CTS",          value = 0x79},
    {name="UART0_RTS",          value = 0x7A},
    {name="UART0_RXD",          value = 0x7B},
    {name="UART0_TXD",          value = 0x7C},
    {name="UART1_CTS",          value = 0x7D},
    {name="UART1_RTS",          value = 0x7E},
    {name="UART1_RXD",          value = 0x7F},
    {name="UART1_TXD",          value = 0x80},
    {name="UART2_CTS",          value = 0x81},
    {name="UART2_RTS",          value = 0x82},
    {name="UART2_RXD",          value = 0x83},
    {name="UART2_TXD",          value = 0x84},
    {name="USB_ID_DIG",         value = 0x85},
    {name="USB_ID_PULLUP_CTRL", value = 0x86},
    {name="USB_RPD_ENA",        value = 0x87},
    {name="USB_RPU_ENA",        value = 0x88},
    {name="CCD_DATA0",          value = 0x89},
    {name="CCD_DATA1",          value = 0x8A},
    {name="CCD_DATA2",          value = 0x8B},
    {name="CCD_DATA3",          value = 0x8C},
    {name="CCD_DATA4",          value = 0x8D},
    {name="CCD_DATA5",          value = 0x8E},
    {name="CCD_DATA6",          value = 0x8F},
    {name="CCD_DATA7",          value = 0x90},
    {name="CCD_PIXCLK",         value = 0x91},
    {name="CCD_LINE_VALID",     value = 0x92},
    {name="CCD_FRAME_VALID",    value = 0x93},
    {name="INPUT",              value = 0xFF},
}


-- add MMIO config constants
for _, e in ipairs(NETX10_MMIO_CONFIG) do
   taglist.addConstant("MMIO_CONFIG_NETX10_" .. e.name, e.value)
end

for _, e in ipairs(NETX50_MMIO_CONFIG) do
   taglist.addConstant("MMIO_CONFIG_NETX50_" .. e.name, e.value)
end

-- medium type for TAG_BSL_MEDIUM_PARAMS
BSL_DEST_MEDIUM = {
	{name="Auto-detect Media",value=0},
	{name="RAM Disk",         value=1},
	{name="Serial Flash",     value=2},
	{name="Parallel Flash",   value=3},
	{name="SQI Flash",        value=4},    
}

   
BSL_DEST_MEDIUM_CONSTANTS = {
    TAG_BSL_MEDIUM_AUTODETECT             =  0,
    TAG_BSL_MEDIUM_USERAM                 =  1,
    TAG_BSL_MEDIUM_USESERFLASH            =  2,
    TAG_BSL_MEDIUM_USEPARFLASH            =  3,
    TAG_BSL_MEDIUM_USESQIROM              =  4,
}

-- media type for TAG_BSL_BACKUP_POS_PARAMS
BSL_BACKUP_MEDIUM_CONSTANTS = {
	BSL_BACKUP_POS_MEDIUM_DISABLED  = 0,
	BSL_BACKUP_POS_MEDIUM_SERFLASH  = 1,
	BSL_BACKUP_POS_MEDIUM_PARFLASH  = 2,
}

BSL_BACKUP_MEDIUM = {
	{name="Disabled",         value=0},
	{name="Serial Flash",     value=1},
	{name="Parallel Flash",   value=2},
}
 
taglist.addConstants(BSL_DEST_MEDIUM_CONSTANTS)
taglist.addConstants(BSL_BACKUP_MEDIUM_CONSTANTS)


INITCMD_LENGTH_VALUES={
     nBits=8,
     values={
       {name="Disabled",  value=0},
       {name="1 bytes", value=1},
       {name="2 bytes", value=2},
       {name="3 bytes", value=3}
     } }

CHIP_ERASE_CMD_LENGTH_VALUES={
     nBits=8,
     values={
       {name="Disabled",  value=0},
       {name="1 bytes", value=1},
       {name="2 bytes", value=2},
       {name="3 bytes", value=3},
       {name="4 bytes", value=4}
     } }

ID_CMD_LENGTH_VALUES={
     nBits=8,
     values={
       {name="0 bytes",  value=0},
       {name="1 bytes", value=1},
       {name="2 bytes", value=2},
       {name="3 bytes", value=3},
       {name="4 bytes", value=4},
       {name="5 bytes", value=5},
       {name="6 bytes", value=6},
       {name="7 bytes", value=7},
       {name="8 bytes", value=8},
       {name="9 bytes", value=9},
     } }


BSL_TAGS={
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
                {name="Disabled", value=0xffffffff}
        }},
    },

    {"BSL_DPM_PARAMS_T", "tDpm", desc="DPM settings"},
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
--  2nd stage loader HIF/DPM settings for netX 10

TAG_BSL_HIF_NETX10_PARAMS_DATA_T =
{
  {
    "UINT32", "ulBusType", desc="Bus Type",
    editor="comboedit",
    editorParam=
    {
      nBits=32,
      values=
      {
        {name="Auto", value=0},
        {name="DPM", value=1},
        {name="Disabled", value=0xffffffff}
      }
    },
  },
  {"UINT32", "ulHifIoCfg",        desc="I/O Configuration"},
  {"UINT32", "ulDpmCfg0",         desc="DPM Configuration Register 0"},
  {"UINT32", "ulDpm_addr_cfg",    desc="DPM Address"},
  {"UINT32", "ulDpm_timing_cfg",  desc="DPM Timing"},
  {"UINT32", "ulDpm_rdy_cfg",     desc="DPM Ready Configuration"},
  {"UINT32", "ulDpm_misc_cfg",    desc="Miscellaneous DPM Configuration"},
  {"UINT32", "ulDpm_io_cfg_misc", desc="Miscellaneous DPM I/O Configuration"},
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
        editorParam={nBits=8, values=BSL_DEST_MEDIUM}
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
--#define BSL_FSU_MODE_DISABLESECMEM  0x80000000
--  unsigned long ulFSUMode; /*!< Bitmask -> BSL_FSU_MODE_XXX */


TAG_BSL_FSU_PARAMS_DATA_T = {
    {"UINT32", "ulEnable", desc="Enable FSU Mode",
        offset = 0, mask = string.char(1, 0, 0, 0),
        editor="checkboxedit",
        editorParam={nBits = 32, offValue = 0, onValue = 1, otherValues = true}
    },
    {"UINT32", "ulPinning", desc="MMIO Pin Layout",
        offset = 0, mask = string.char(0xfe, 0, 0, 0),
        editor="comboedit",
        editorParam={nBits = 32, values={
          {name="0 (Standard)", value=0},
          {name="1 (Fiberoptic ready)", value=2},
          {name="2 (Fiberoptic ready)", value=4},
        }}
    },

    {"UINT32", "ulDisableSecmem", desc="Disable SecMem",
        offset = 0, mask = string.char(0, 0, 0, 0x80),
        editor="checkboxedit",
        editorParam={nBits = 32, offValue = 0, onValue = 0x80000000, otherValues = true}
    },
},



----------------------------------------------------------------------------------------------
--  2nd stage loader MMIO parameters for netX 50
MMIO_PIN_NETX50_T = {
    {"UINT8", "bConfig", desc="Function", editor="comboedit", editorParam={nBits=8, values = NETX50_MMIO_CONFIG}},
    {"UINT8", "bFlags", desc="Flags", editor="comboedit", editorParam={nBits=8, values = MMIO_FLAGS}},

    layout={
        sizer="grid", rows=1, cols=2,
        "bConfig",    "bFlags",
    },
},

TAG_BSL_MMIO_NETX50_PARAMS_DATA_T= {
    {"MMIO_PIN_NETX50_T", "atMMIOCfg[0]",   desc="MMIO 0"},
    {"MMIO_PIN_NETX50_T", "atMMIOCfg[1]",   desc="MMIO 1"},
    {"MMIO_PIN_NETX50_T", "atMMIOCfg[2]",   desc="MMIO 2"},
    {"MMIO_PIN_NETX50_T", "atMMIOCfg[3]",   desc="MMIO 3"},
    {"MMIO_PIN_NETX50_T", "atMMIOCfg[4]",   desc="MMIO 4"},
    {"MMIO_PIN_NETX50_T", "atMMIOCfg[5]",   desc="MMIO 5"},
    {"MMIO_PIN_NETX50_T", "atMMIOCfg[6]",   desc="MMIO 6"},
    {"MMIO_PIN_NETX50_T", "atMMIOCfg[7]",   desc="MMIO 7"},
    {"MMIO_PIN_NETX50_T", "atMMIOCfg[8]",   desc="MMIO 8"},
    {"MMIO_PIN_NETX50_T", "atMMIOCfg[9]",   desc="MMIO 9"},
    {"MMIO_PIN_NETX50_T", "atMMIOCfg[10]",  desc="MMIO 10"},
    {"MMIO_PIN_NETX50_T", "atMMIOCfg[11]",  desc="MMIO 11"},
    {"MMIO_PIN_NETX50_T", "atMMIOCfg[12]",  desc="MMIO 12"},
    {"MMIO_PIN_NETX50_T", "atMMIOCfg[13]",  desc="MMIO 13"},
    {"MMIO_PIN_NETX50_T", "atMMIOCfg[14]",  desc="MMIO 14"},
    {"MMIO_PIN_NETX50_T", "atMMIOCfg[15]",  desc="MMIO 15"},
    {"MMIO_PIN_NETX50_T", "atMMIOCfg[16]",  desc="MMIO 16"},
    {"MMIO_PIN_NETX50_T", "atMMIOCfg[17]",  desc="MMIO 17"},
    {"MMIO_PIN_NETX50_T", "atMMIOCfg[18]",  desc="MMIO 18"},
    {"MMIO_PIN_NETX50_T", "atMMIOCfg[19]",  desc="MMIO 19"},
    {"MMIO_PIN_NETX50_T", "atMMIOCfg[20]",  desc="MMIO 20"},
    {"MMIO_PIN_NETX50_T", "atMMIOCfg[21]",  desc="MMIO 21"},
    {"MMIO_PIN_NETX50_T", "atMMIOCfg[22]",  desc="MMIO 22"},
    {"MMIO_PIN_NETX50_T", "atMMIOCfg[23]",  desc="MMIO 23"},
    {"MMIO_PIN_NETX50_T", "atMMIOCfg[24]",  desc="MMIO 24"},
    {"MMIO_PIN_NETX50_T", "atMMIOCfg[25]",  desc="MMIO 25"},
    {"MMIO_PIN_NETX50_T", "atMMIOCfg[26]",  desc="MMIO 26"},
    {"MMIO_PIN_NETX50_T", "atMMIOCfg[27]",  desc="MMIO 27"},
    {"MMIO_PIN_NETX50_T", "atMMIOCfg[28]",  desc="MMIO 28"},
    {"MMIO_PIN_NETX50_T", "atMMIOCfg[29]",  desc="MMIO 29"},
    {"MMIO_PIN_NETX50_T", "atMMIOCfg[30]",  desc="MMIO 30"},
    {"MMIO_PIN_NETX50_T", "atMMIOCfg[31]",  desc="MMIO 31"},
    {"MMIO_PIN_NETX50_T", "atMMIOCfg[32]",  desc="MMIO 32"},
    {"MMIO_PIN_NETX50_T", "atMMIOCfg[33]",  desc="MMIO 33"},
    {"MMIO_PIN_NETX50_T", "atMMIOCfg[34]",  desc="MMIO 34"},
    {"MMIO_PIN_NETX50_T", "atMMIOCfg[35]",  desc="MMIO 35"},
    {"MMIO_PIN_NETX50_T", "atMMIOCfg[36]",  desc="MMIO 36"},
    {"MMIO_PIN_NETX50_T", "atMMIOCfg[37]",  desc="MMIO 37"},
    {"MMIO_PIN_NETX50_T", "atMMIOCfg[38]",  desc="MMIO 38"},
    {"MMIO_PIN_NETX50_T", "atMMIOCfg[39]",  desc="MMIO 39"},
},

----------------------------------------------------------------------------------------------
--  2nd stage loader MMIO parameters for netX 10
MMIO_PIN_NETX10_T = {
    {"UINT8", "bConfig", desc="Function", editor="comboedit", editorParam={nBits=8, values = NETX10_MMIO_CONFIG}},
    {"UINT8", "bFlags", desc="Flags", editor="comboedit", editorParam={nBits=8, values = MMIO_FLAGS}},

    layout={
        sizer="grid", rows=1, cols=2,
        "bConfig",    "bFlags",
    },
},

TAG_BSL_MMIO_NETX10_PARAMS_DATA_T = {
    {"MMIO_PIN_NETX10_T", "atMMIOCfg[0]",   desc="MMIO 0"},
    {"MMIO_PIN_NETX10_T", "atMMIOCfg[1]",   desc="MMIO 1"},
    {"MMIO_PIN_NETX10_T", "atMMIOCfg[2]",   desc="MMIO 2"},
    {"MMIO_PIN_NETX10_T", "atMMIOCfg[3]",   desc="MMIO 3"},
    {"MMIO_PIN_NETX10_T", "atMMIOCfg[4]",   desc="MMIO 4"},
    {"MMIO_PIN_NETX10_T", "atMMIOCfg[5]",   desc="MMIO 5"},
    {"MMIO_PIN_NETX10_T", "atMMIOCfg[6]",   desc="MMIO 6"},
    {"MMIO_PIN_NETX10_T", "atMMIOCfg[7]",   desc="MMIO 7"},
    {"MMIO_PIN_NETX10_T", "atMMIOCfg[8]",   desc="MMIO 8"},
    {"MMIO_PIN_NETX10_T", "atMMIOCfg[9]",   desc="MMIO 9"},
    {"MMIO_PIN_NETX10_T", "atMMIOCfg[10]",  desc="MMIO 10"},
    {"MMIO_PIN_NETX10_T", "atMMIOCfg[11]",  desc="MMIO 11"},
    {"MMIO_PIN_NETX10_T", "atMMIOCfg[12]",  desc="MMIO 12"},
    {"MMIO_PIN_NETX10_T", "atMMIOCfg[13]",  desc="MMIO 13"},
    {"MMIO_PIN_NETX10_T", "atMMIOCfg[14]",  desc="MMIO 14"},
    {"MMIO_PIN_NETX10_T", "atMMIOCfg[15]",  desc="MMIO 15"},
    {"MMIO_PIN_NETX10_T", "atMMIOCfg[16]",  desc="MMIO 16"},
    {"MMIO_PIN_NETX10_T", "atMMIOCfg[17]",  desc="MMIO 17"},
    {"MMIO_PIN_NETX10_T", "atMMIOCfg[18]",  desc="MMIO 18"},
    {"MMIO_PIN_NETX10_T", "atMMIOCfg[19]",  desc="MMIO 19"},
    {"MMIO_PIN_NETX10_T", "atMMIOCfg[20]",  desc="MMIO 20"},
    {"MMIO_PIN_NETX10_T", "atMMIOCfg[21]",  desc="MMIO 21"},
    {"MMIO_PIN_NETX10_T", "atMMIOCfg[22]",  desc="MMIO 22"},
    {"MMIO_PIN_NETX10_T", "atMMIOCfg[23]",  desc="MMIO 23"},
},


----------------------------------------------------------------------------------------------
--  2nd stage loader USB descriptor


TAG_BSL_USB_DESCR_PARAMS_DATA_T =
{
  {"UINT8",  "bCustomSettings",   desc="Custom Settings", editor="checkboxedit", editorParam={onValue=1, offValue=0, otherValues=true, nBits=8}},
  {"UINT8",  "bDeviceClass",      desc="Device Class", mode = "hidden"},
  {"UINT8",  "bSubClass",         desc="Subclass", mode = "hidden"},
  {"UINT8",  "bProtocol",         desc="Protocol", mode = "hidden"},
  {"UINT16", "usVendorId",        desc="Vendor ID"},
  {"UINT16", "usProductId",       desc="Product ID"},
  {"UINT16", "usReleaseNr",       desc="Release Number"},
  {"UINT8",  "bCharacteristics",  desc="Characteristics", editor="comboedit", editorParam={
     nBits=8,
     values={
       {name="Self-powered",                 value=0x80+0x40},
       {name="Bus-powered",                  value=0x80},
       {name="Self-powered, remote wakeup",  value=0x80+0x40+0x20},
       {name="Bus-powered, remote wakeup",   value=0x80+0x20},
     }}},
  {"UINT8",  "bMaxPower",         desc="Maximum Power", editor="numedit", editorParam={nBits=8, format="%d", minValue=0, maxValue=250}},
  {"STRING", "szVendor",          desc="Vendor Name", size=16},
  {"STRING", "szProduct",         desc="Product Name", size=16},
  {"STRING", "szSerial",          desc="Serial Number", size=16},
},



----------------------------------------------------------------------------------------------
--  2nd stage loader disk position settings

TAG_BSL_DISK_POS_PARAMS_DATA_T =
{
  {"UINT32", "ulOffset", desc="Offset"},
  {"UINT32", "ulSize",   desc="Size"},
},


----------------------------------------------------------------------------------------------
--  2nd stage loader backup partition settings

TAG_BSL_BACKUP_POS_PARAMS_DATA_T =
{
    {"UINT8",  "bMedium", desc="Medium",
        editor="comboedit", 
        editorParam={nBits=8, values=BSL_BACKUP_MEDIUM}
    },
    {"UINT8",  "bReserved0", mode = "hidden"},
    {"UINT8",  "bReserved1", mode = "hidden"},
    {"UINT8",  "bReserved2", mode = "hidden"},
    {"UINT32", "ulOffset", desc="Offset"},
    {"UINT32", "ulSize",   desc="Size"},
},



----------------------------------------------------------------------------------------------
--  2nd stage loader custom serial flash settings

TAG_BSL_SERFLASH_PARAMS_DATA_T = {
	{"UINT8",   "bUseCustomFlash",        desc="Enable",                                   editor="checkboxedit", editorParam={nBits=8, onValue=1, offValue=0, otherValues=true}},
	{"STRING",  "szName",                 desc="Name",                             size=16},
	{"UINT32",  "ulSize",                 desc="Chip size",                                editor="numedit", editorParam={nBits=32, format="0x%08x"}},
	{"UINT32",  "ulClock",                desc="Maximum speed in kHz",                     editor="numedit", editorParam={nBits=32, format="%d"}    },
	{"UINT32",  "ulPageSize",             desc="Bytes per Page",                           editor="numedit", editorParam={nBits=32, format="%d"}    },
	{"UINT32",  "ulSectorPages",          desc="Pages per Sector",                         editor="numedit", editorParam={nBits=32, format="%d"}    },
	{"UINT8",   "bAdrMode",               desc="Addressing mode",                          editor="comboedit", editorParam={
     nBits=8,
     values={
       {name="Linear",  value=0},
       {name="Shifted", value=1},
     } } },
	{"UINT8",   "bReadOpcode",            desc="Opcode for 'continuous array read'",       editor="numedit", editorParam={nBits=8, format="0x%x"}   },
	{"UINT8",   "bReadOpcodeDCBytes",     desc="Don't care bytes",                         editor="numedit", editorParam={nBits=8, format="%d"}     },
	{"UINT8",   "bWriteEnableOpcode",     desc="Opcode for 'write enable' command",        editor="numedit", editorParam={nBits=8, format="%d"}     },
	{"UINT8",   "bErasePageOpcode",       desc="Opcode for 'erase page'",                  editor="numedit", editorParam={nBits=8, format="0x%x"}   },
	{"UINT8",   "bEraseSectorOpcode",     desc="Opcode for 'erase sector'",                editor="numedit", editorParam={nBits=8, format="0x%x"}   },
	
	{"UINT8",   "bEraseChipCmdLen",       desc="Erase Chip Command Length",                editor="comboedit", editorParam=CHIP_ERASE_CMD_LENGTH_VALUES}, -- editor="numedit", editorParam={nBits=8, format="0x%x"}   },
	{"bindata", "abEraseChipCmd",         desc="Erase Chip Command",               size=4, editor="hexedit", editorParam = {addrFormat="", bytesPerLine = 4, byteSeparatorChar = " ", showAscii = false, multiLine = false}},
	
	{"UINT8",   "bPageProgOpcode",        desc="Opcode for 'page program'",                editor="numedit", editorParam={nBits=8, format="0x%x"}   },
	{"UINT8",   "bBufferFill",            desc="Opcode for 'fill buffer with data'",       editor="numedit", editorParam={nBits=8, format="0x%x"}   },
	{"UINT8",   "bBufferWriteOpcode",     desc="Opcode for 'write buffer to flash'",       editor="numedit", editorParam={nBits=8, format="0x%x"}   },
	{"UINT8",   "bEraseAndPageProgOpcode",desc="Opcode for 'page erase and program'",        editor="numedit", editorParam={nBits=8, format="0x%x"}   },
	{"UINT8",   "bReadStatusOpcode",      desc="Opcode for 'read status register'",        editor="numedit", editorParam={nBits=8, format="0x%x"}   },
	{"UINT8",   "bStatusReadyMask",       desc="Bit mask for 'device busy'",               editor="numedit", editorParam={nBits=8, format="0x%x"}   },
	{"UINT8",   "bStatusReadyValue",      desc="XOR value for 'device busy'",              editor="numedit", editorParam={nBits=8, format="0x%x"}   },
	
	{"UINT8",   "bInitCmd0_length",       desc="First Init Command Length",                editor="comboedit", editorParam=INITCMD_LENGTH_VALUES}, -- editor="numedit", editorParam={nBits=8, format="0x%x"}},
	{"bindata", "abInitCmd0",             desc="First Init Command ",              size=3, editor="hexedit", editorParam = {addrFormat="", bytesPerLine = 3, byteSeparatorChar = " ", showAscii = false, multiLine = false}},
	{"UINT8",   "bInitCmd1_length",       desc="Second Init Command Length",               editor="comboedit", editorParam=INITCMD_LENGTH_VALUES}, -- editor="numedit", editorParam={nBits=8, format="0x%x"}},
	{"bindata", "abInitCmd1",             desc="Second Init Command",              size=3, editor="hexedit", editorParam = {addrFormat="", bytesPerLine = 3, byteSeparatorChar = " ", showAscii = false, multiLine = false}},
	
	{"UINT8",   "bIdLength",              desc="ID Sequence Length",                       editor="comboedit", editorParam=ID_CMD_LENGTH_VALUES}, -- editor="numedit", editorParam={nBits=8, format="%d"}     },
	{"bindata", "abIdSend",               desc="ID command",                       size=9, editor="hexedit", editorParam = {addrFormat="", bytesPerLine = 9, byteSeparatorChar = " ", showAscii = false, multiLine = false}},
	{"bindata", "abIdMask",               desc="ID mask",                          size=9, editor="hexedit", editorParam = {addrFormat="", bytesPerLine = 9, byteSeparatorChar = " ", showAscii = false, multiLine = false}},
	{"bindata", "abIdMagic",              desc="ID compare",                       size=9, editor="hexedit", editorParam = {addrFormat="", bytesPerLine = 9, byteSeparatorChar = " ", showAscii = false, multiLine = false}},
	
	--{"UINT32",  "ulFeatures",             desc="Special Features",                         editor="numedit", editorParam={nBits=32, format="0x%x"}    },
	{"UINT32",  "ulFeatures",             desc="Special Features: Quad SPI",  mask=string.char(1,0,0,0),  editor="checkboxedit", editorParam={nBits=32, onValue=1, offValue=0} },
},

}


taglist.addDataTypes(BSL_TAGS)

taglist.addTags({
-- Second Stage Loader tags
TAG_BSL_SDRAM_PARAMS =
    {paramtype = 0x40000000, datatype="TAG_BSL_SDRAM_PARAMS_DATA_T",          desc="SDRAM"},
TAG_BSL_HIF_PARAMS =
    {paramtype = 0x40000001, datatype="TAG_BSL_HIF_PARAMS_DATA_T",            desc="netX 50/100/500 HIF/DPM"},
TAG_BSL_SDMMC_PARAMS =
    {paramtype = 0x40000002, datatype="TAG_BSL_SDMMC_PARAMS_DATA_T",          desc="SD/MMC"},
TAG_BSL_UART_PARAMS =
    {paramtype = 0x40000003, datatype="TAG_BSL_UART_PARAMS_DATA_T",           desc="UART"},
TAG_BSL_USB_PARAMS =
    {paramtype = 0x40000004, datatype="TAG_BSL_USB_PARAMS_DATA_T",            desc="USB"},
TAG_BSL_MEDIUM_PARAMS =
    {paramtype = 0x40000005, datatype="TAG_BSL_MEDIUM_PARAMS_DATA_T",         desc="BSL Medium"},
TAG_BSL_EXTSRAM_PARAMS =
    {paramtype = 0x40000006, datatype="TAG_BSL_EXTSRAM_PARAMS_DATA_T",        desc="Ext. SRAM"},
TAG_BSL_HWDATA_PARAMS =
    {paramtype = 0x40000007, datatype="TAG_BSL_HWDATA_PARAMS_DATA_T",         desc="HW Data"},
TAG_BSL_FSU_PARAMS =
    {paramtype = 0x40000008, datatype="TAG_BSL_FSU_PARAMS_DATA_T",            desc="Fast Startup"},
TAG_BSL_MMIO_NETX50_PARAMS =
    {paramtype = 0x40000009, datatype="TAG_BSL_MMIO_NETX50_PARAMS_DATA_T",    desc="netX 50 MMIO"},
TAG_BSL_MMIO_NETX10_PARAMS =
    {paramtype = 0x4000000A, datatype="TAG_BSL_MMIO_NETX10_PARAMS_DATA_T",    desc="netX 10 MMIO"},
TAG_BSL_HIF_NETX10_PARAMS =
    {paramtype = 0x4000000B, datatype="TAG_BSL_HIF_NETX10_PARAMS_DATA_T",     desc="netX 10 HIF/DPM"},
TAG_BSL_USB_DESCR_PARAMS =
    {paramtype = 0x4000000C, datatype="TAG_BSL_USB_DESCR_PARAMS_DATA_T",      desc="USB Descriptor"},
TAG_BSL_DISK_POS_PARAMS =
    {paramtype = 0x4000000D, datatype="TAG_BSL_DISK_POS_PARAMS_DATA_T",       desc="Disk Position"},
TAG_BSL_BACKUP_POS_PARAMS =
    {paramtype = 0x4000000e, datatype="TAG_BSL_BACKUP_POS_PARAMS_DATA_T",     desc="Backup Partition"},
TAG_BSL_SERFLASH_PARAMS =
    {paramtype = 0x40000011, datatype="TAG_BSL_SERFLASH_PARAMS_DATA_T",       desc="Custom Serial Flash"},
})

taglist.addTagHelpPages({
    TAG_BSL_SDRAM_PARAMS                = {file="TAG_BSL_SDRAM_PARAMS_DATA_T.htm"},
    TAG_BSL_HIF_PARAMS                  = {file="TAG_BSL_HIF_PARAMS_DATA_T.htm"},
    TAG_BSL_SDMMC_PARAMS                = {file="TAG_BSL_SDMMC_PARAMS_DATA_T.htm"},
    TAG_BSL_UART_PARAMS                 = {file="TAG_BSL_UART_PARAMS_DATA_T.htm"},
    TAG_BSL_USB_PARAMS                  = {file="TAG_BSL_USB_PARAMS_DATA_T.htm"},
    TAG_BSL_MEDIUM_PARAMS               = {file="TAG_BSL_MEDIUM_PARAMS_DATA_T.htm"},
    TAG_BSL_EXTSRAM_PARAMS              = {file="TAG_BSL_EXTSRAM_PARAMS_DATA_T.htm"},
    TAG_BSL_HWDATA_PARAMS               = {file="TAG_BSL_HWDATA_PARAMS_DATA_T.htm"},
    TAG_BSL_FSU_PARAMS                  = {file="TAG_BSL_FSU_PARAMS_DATA_T.htm"},
    TAG_BSL_MMIO_NETX50_PARAMS          = {file="TAG_BSL_MMIO_NETX50_PARAMS_DATA_T.htm"},
    TAG_BSL_MMIO_NETX10_PARAMS          = {file="TAG_BSL_MMIO_NETX10_PARAMS_DATA_T.htm"},
    TAG_BSL_HIF_NETX10_PARAMS           = {file="TAG_BSL_HIF_NETX10_PARAMS_DATA_T.htm"},
    TAG_BSL_USB_DESCR_PARAMS            = {file="TAG_BSL_USB_DESCR_PARAMS_DATA_T.htm"},
    TAG_BSL_DISK_POS_PARAMS             = {file="TAG_BSL_DISK_POS_PARAMS_DATA_T.htm"},
    TAG_BSL_BACKUP_POS_PARAMS           = {file="TAG_BSL_BACKUP_POS_PARAMS_DATA_T.htm"},
    TAG_BSL_SERFLASH_PARAMS             = {file="TAG_BSL_SERFLASH_PARAMS_DATA_T.htm"},
})


     