---------------------------------------------------------------------------
-- Copyright (C) 2010 Hilscher Gesellschaft für Systemautomation mbH
--
-- Description:
--   Ttags used by netPLC I/O handler
--
--  Changes:
--    Date        Author        Description
---------------------------------------------------------------------------
-- 2015-12-18     SL            change %d to %u
-- 2013-08-27     SL            changed paths to HTML files
-- 2011-07-26     SL            replaced IEEE in analog data formats with IEC
-- 2011-07-07     SL            Fix: PIO types HIF_PIO and GPIO were swapped
-- 2011-05-11     SL            created
---------------------------------------------------------------------------

module("tagdefs_io_handler", package.seeall)

---------------------------------------------------------------------------
-- SVN Keywords
--
SVN_DATE   ="$Date$"
SVN_VERSION="$Revision$"
-- $Author$
---------------------------------------------------------------------------

require("taglist")

CONSTANTS={}
-- facility tags: netPLC I/O handler
NETPLC_IO_HANDLER_CONSTANTS = {
	-- PLC I/O image type codes for the netPLC I/O Handler facility tags
	RCX_NETPLC_IO_HANDLER_IMAGE_TYPE_NONE   = 0,
	RCX_NETPLC_IO_HANDLER_IMAGE_TYPE_INPUT  = 1,
	RCX_NETPLC_IO_HANDLER_IMAGE_TYPE_OUTPUT = 2,

	-- from rX_Config.h/RX_PERIPHERAL_TYPEtag
	RX_PERIPHERAL_TYPE_PIO                  = 25,
	RX_PERIPHERAL_TYPE_GPIO                 = 26,
	RX_PERIPHERAL_TYPE_HIFPIO               = 32,

	-- analog data format codes for the netPLC I/O Handler facility tags
	RCX_NETPLC_IO_HANDLER_FORMAT_SIGNED     = 0,   -- 16-bit signed integer
	RCX_NETPLC_IO_HANDLER_FORMAT_UNSIGNED   = 1,   -- 16-bit unsigned integer
	RCX_NETPLC_IO_HANDLER_FORMAT_IEC_S      = 2,   -- IEC signed
	RCX_NETPLC_IO_HANDLER_FORMAT_IEC_U      = 3,   -- IEC unsigned
	RCX_NETPLC_IO_HANDLER_FORMAT_S7         = 4,   -- S7
}


-- PLC I/O image type codes for the netPLC I/O Handler facility tags
NETPLC_IO_HANDLER_IMAGE_TYPES = {
	{name="None",   value=0},
	{name="Input",  value=1},
	{name="Output", value=2},
}

-- from rX_Config.h/RX_PERIPHERAL_TYPEtag
NETPLC_IO_HANDLER_PIO_TYPES = {
	{name="PIO",     value=25},
	{name="GPIO",    value=26},
	{name="HIF PIO", value=32},
}

-- analog data format codes for the netPLC I/O Handler facility tags
NETPLC_IO_HANDLER_FORMATS = {
	{name="16-bit signed integer",     value = 0},
	{name="16-bit unsigned integer",   value = 1},
	{name="IEC (signed)",              value = 2},
	{name="IEC (unsigned)",            value = 3},
	{name="S7",                        value = 4},
}


NETPLC_IO_HANDLER_TAGS = {
----------------------------------------------------------------------------------------------
-- general enable of the netPLC I/O Handler facility

RCX_TAG_NETPLC_IO_HANDLER_ENABLE_DATA_T = {
	{"UINT8", "bEnableFlag", desc="Enable I/O Handler",
		editor="checkboxedit",
		editorParam={nBits = 8, offValue = 0, onValue = 1, otherValues = true}
	},
	{"UINT8", "bReserved1", desc="Reserved1", mode = "hidden", editorParam={format="0x%02x"}},
	{"UINT8", "bReserved2", desc="Reserved2", mode = "hidden", editorParam={format="0x%02x"}},
	{"UINT8", "bReserved3", desc="Reserved3", mode = "hidden", editorParam={format="0x%02x"}},
},

----------------------------------------------------------------------------------------------
-- digital I/O configuration of the netPLC I/O Handler facility
--  UINT8  bImageType;    see RCX_NETPLC_IO_HANDLER_IMAGE_TYPE_xxx definitions above */
--  UINT8  bType;         RX_PERIPHERAL_TYPE_PIO or RX_PERIPHERAL_TYPE_HIFPIO or RX_PERIPHERAL_TYPE_GPIO */
--  UINT8  bFirstBit;     index of the first PIO or HIF-PIO or GPIO that starts the set (counting from 0) */
--  UINT8  bNumBits;      number of consecutive PIOs or HIF-PIOs or GPIOs in the set (max. 32) */
--  UINT32 ulInvertMask;  bit=1: invert I/O data bit after reading netX input register / before writing netX output register */
--  UINT32 ulImageOffset; start offset in the PLC I/O image (in bytes) */
--  UINT32 ulBitOffset;   start offset from the beginning of the first associated byte in the PLC I/O image (in bits) */

RCX_TAG_NETPLC_IO_HANDLER_DIGITAL_DATA_T = {
	{"UINT8",  "bImageType",     desc="Image Type",         editor="comboedit", editorParam={nBits=8, values = NETPLC_IO_HANDLER_IMAGE_TYPES}},
	{"UINT8",  "bType",          desc="I/O Type",           editor="comboedit", editorParam={nBits=8, values = NETPLC_IO_HANDLER_PIO_TYPES}},
	{"UINT8",  "bFirstBit",      desc="Index of First Bit", editor="numedit",   editorParam={nBits=8, format="%u"}},
	{"UINT8",  "bNumBits",       desc="Number of Bits",     editor="comboedit",   editorParam={nBits=8, format="%u", minValue=1, maxValue=32}},
	{"UINT32", "ulInvertMask",   desc="Invert Mask",        editor="numedit",   editorParam={nBits=32, format="0x%08x"}},
	{"UINT32", "ulImageOffset",  desc="Image Offset",       editor="numedit",   editorParam={nBits=32, format="%u"}},
	{"UINT32", "ulBitOffset",    desc="Bit Offset",         editor="comboedit",   editorParam={nBits=32, minValue=0, maxValue=7}},
},

----------------------------------------------------------------------------------------------
-- analog I/O configuration of the netPLC I/O Handler facility
--  UINT8  bImageType;   see RCX_NETPLC_IO_HANDLER_IMAGE_TYPE_xxx definitions above */
--  UINT8  bDevice;      converter device number (0...1) */
--  UINT8  bChannel;     channel number (0...3) */
--  UINT8  bFormat;      see RCX_NETPLC_IO_HANDLER_FORMAT_xxx definitions above */
--  UINT32 ulImageOffset;start offset in the PLC I/O image (in bytes) */
--  RCX_TAG_NETPLC_IO_HANDLER_ANALOG_DATA_T;

-- netX 500: 2 units x 4 channels
-- netX 10: 2 units x 8 channels

RCX_TAG_NETPLC_IO_HANDLER_ANALOG_DATA_T = {
	{"UINT8",  "bImageType",    desc="Image Type",              editor="comboedit", editorParam={nBits=8, values = NETPLC_IO_HANDLER_IMAGE_TYPES}},
	{"UINT8",  "bDevice",       desc="Converter Device Number", editor="comboedit", editorParam={nBits=8, minValue=0, maxValue=1}},
	{"UINT8",  "bChannel",      desc="Channel Number",          editor="comboedit", editorParam={nBits=8, minValue=0, maxValue=3}},
	{"UINT8",  "bFormat",       desc="Number Format",           editor="comboedit", editorParam={nBits=8, values = NETPLC_IO_HANDLER_FORMATS} },
	{"UINT32", "ulImageOffset", desc="Image Offset",            editor="numedit",   editorParam={nBits=32, format="%u"}},
},
}

taglist.addDataTypes(NETPLC_IO_HANDLER_TAGS)
taglist.addConstants(NETPLC_IO_HANDLER_CONSTANTS)
taglist.addTags({
RCX_TAG_NETPLC_IO_HANDLER_ENABLE =
	{paramtype = 0x10A30000, datatype = "RCX_TAG_NETPLC_IO_HANDLER_ENABLE_DATA_T",  desc="netPLC I/O Handler Enable"},
RCX_TAG_NETPLC_IO_HANDLER_DIGITAL =
	{paramtype = 0x10A30001, datatype = "RCX_TAG_NETPLC_IO_HANDLER_DIGITAL_DATA_T", desc="netPLC I/O Handler Digital"},
RCX_TAG_NETPLC_IO_HANDLER_ANALOG =
	{paramtype = 0x10A30002, datatype = "RCX_TAG_NETPLC_IO_HANDLER_ANALOG_DATA_T",  desc="netPLC I/O Handler Analog"},
})

taglist.addTagHelpPages({
    RCX_TAG_NETPLC_IO_HANDLER_ENABLE    = {file="RCX_TAG_NETPLC_IO_HANDLER_ENABLE_DATA_T.htm"},
    RCX_TAG_NETPLC_IO_HANDLER_DIGITAL   = {file="RCX_TAG_NETPLC_IO_HANDLER_DIGITAL_DATA_T.htm"},
    RCX_TAG_NETPLC_IO_HANDLER_ANALOG    = {file="RCX_TAG_NETPLC_IO_HANDLER_ANALOG_DATA_T.htm"},
})

