---------------------------------------------------------------------------
-- Copyright (C) 2010 Hilscher Gesellschaft für Systemautomation mbH
--
-- Description:
--   Defines tags 
--   - Device ID
--   - Diagnostics and Remote Access
--   - Ethernet
--   - EDD
--   - Fiber Obptic
--   Also defines constants which may be used for the device header

--  Changes:
--    Date        Author        Description
---------------------------------------------------------------------------
-- 2012-04-03     SL            added TAG_ECS_ENABLE_BOOTSTRAP 0x30009001
-- 2012-01-19     SL            added device ID tags for ECS, S3S, PLS
-- 2011-05-12     SL            factored out from taglist.lua
---------------------------------------------------------------------------

module("tagdefs_misc", package.seeall)

---------------------------------------------------------------------------
-- SVN Keywords
--
SVN_DATE   ="$Date$"
SVN_VERSION="$Revision$"
-- $Author$
---------------------------------------------------------------------------
require("taglist")

DEVHDR_CONSTANTS = {
    -- Hardware options
    RCX_HW_ASSEMBLY_UNDEFINED             =  0x0000,
    RCX_HW_ASSEMBLY_NOT_AVAILABLE         =  0x0001,

    RCX_HW_ASSEMBLY_VALIDATION_START      =  0x0010,    -- Start of HW option validation area

    RCX_HW_ASSEMBLY_SERIAL                =  0x0010,
    RCX_HW_ASSEMBLY_ASI                   =  0x0020,
    RCX_HW_ASSEMBLY_CAN                   =  0x0030,
    RCX_HW_ASSEMBLY_DEVICENET             =  0x0040,
    RCX_HW_ASSEMBLY_PROFIBUS              =  0x0050,

    RCX_HW_ASSEMBLY_CCLINK                =  0x0070,
    RCX_HW_ASSEMBLY_ETHERNET              =  0x0080,
    RCX_HW_ASSEMBLY_ETHERNET_X_PHY        =  0x0081,
    RCX_HW_ASSEMBLY_ETHERNET_FIBRE_OPTIC  =  0x0082,

    RCX_HW_ASSEMBLY_SPI                   =  0x0090,
    RCX_HW_ASSEMBLY_IO_LINK               =  0x00A0,
    RCX_HW_ASSEMBLY_COMPONET              =  0x00B0,

    RCX_HW_ASSEMBLY_VALIDATION_END        =  0xFFEF,

    RCX_HW_ASSEMBLY_I2C_UNKNOWN           =  0xFFF4,
    RCX_HW_ASSEMBLY_SSI                   =  0xFFF5,
    RCX_HW_ASSEMBLY_SYNC                  =  0xFFF6,

    RCX_HW_ASSEMBLY_FIELDBUS              =  0xFFF8,

    RCX_HW_ASSEMBLY_TOUCH_SCREEN          =  0xFFFA,
    RCX_HW_ASSEMBLY_I2C_PIO               =  0xFFFB,
    RCX_HW_ASSEMBLY_I2C_PIO_NT            =  0xFFFC,
    RCX_HW_ASSEMBLY_PROPRIETARY           =  0xFFFD,
    RCX_HW_ASSEMBLY_NOT_CONNECTED         =  0xFFFE,
    RCX_HW_ASSEMBLY_RESERVED              =  0xFFFF,

    -- Manufacturer definition
    RCX_MANUFACTURER_UNDEFINED            =  0x0000,
    RCX_MANUFACTURER_HILSCHER_GMBH        =  0x0001,    -- Hilscher GmbH
    RCX_MANUFACTURER_HILSCHER_GMBH_MAX    =  0x00FF,    -- Hilscher GmbH max. value

    -- Production date definition
    RCX_PRODUCTION_DATE_YEAR_MASK         =  0xFF00,    -- Year offset (0..255) starting at 2000
    RCX_PRODUCTION_DATE_WEEK_MASK         =  0x00FF,    -- Week of year ( 1..52)

    -- Device class definition
    RCX_HW_DEV_CLASS_UNDEFINED            =  0x0000,
    RCX_HW_DEV_CLASS_UNCLASSIFIABLE       =  0x0001,
    RCX_HW_DEV_CLASS_CHIP_NETX_500        =  0x0002,
    RCX_HW_DEV_CLASS_CIFX                 =  0x0003,
    RCX_HW_DEV_CLASS_COMX                 =  0x0004,
    RCX_HW_DEV_CLASS_EVA_BOARD            =  0x0005,
    RCX_HW_DEV_CLASS_NETDIMM              =  0x0006,
    RCX_HW_DEV_CLASS_CHIP_NETX_100        =  0x0007,
    RCX_HW_DEV_CLASS_NETX_HMI             =  0x0008,

    RCX_HW_DEV_CLASS_NETIO_50             =  0x000A,
    RCX_HW_DEV_CLASS_NETIO_100            =  0x000B,
    RCX_HW_DEV_CLASS_CHIP_NETX_50         =  0x000C,
    RCX_HW_DEV_CLASS_GW_NETPAC            =  0x000D,
    RCX_HW_DEV_CLASS_GW_NETTAP            =  0x000E,
    RCX_HW_DEV_CLASS_NETSTICK             =  0x000F,
    RCX_HW_DEV_CLASS_NETANALYZER          =  0x0010,
    RCX_HW_DEV_CLASS_NETSWITCH            =  0x0011,
    RCX_HW_DEV_CLASS_NETLINK              =  0x0012,
    RCX_HW_DEV_CLASS_NETIC                =  0x0013,
    RCX_HW_DEV_CLASS_NPLC_C100            =  0x0014,
    RCX_HW_DEV_CLASS_NPLC_M100            =  0x0015,
    RCX_HW_DEV_CLASS_GW_NETTAP_50         =  0x0016,
    RCX_HW_DEV_CLASS_NETBRICK             =  0x0017,
    RCX_HW_DEV_CLASS_NPLC_T100            =  0x0018,
    RCX_HW_DEV_CLASS_NETLINK_PROXY        =  0x0019,

    RCX_HW_DEV_CLASS_HILSCHER_GMBH_MAX    =  0x7FFF,    -- Hilscher GmbH max. value
    RCX_HW_DEV_CLASS_OEM_DEVICE           =  0xFFFE,
}

-- Currently, device class in the device header editor is a number field,
-- where any value can be entered. Do we want to replace it with a
-- combo box where you can only select from the pre-defined values?
DEVICE_CLASS_COMBO_VALUES = {
    {name="UNDEFINED"           ,value =  0x0000},
    {name="UNCLASSIFIABLE"      ,value =  0x0001},
    {name="CHIP_NETX_500"       ,value =  0x0002},
    {name="CIFX"                ,value =  0x0003},
    {name="COMX"                ,value =  0x0004},
    {name="EVA_BOARD"           ,value =  0x0005},
    {name="NETDIMM"             ,value =  0x0006},
    {name="CHIP_NETX_100"       ,value =  0x0007},
    {name="NETX_HMI"            ,value =  0x0008},

    {name="NETIO_50"            ,value =  0x000A},
    {name="NETIO_100"           ,value =  0x000B},
    {name="CHIP_NETX_50"        ,value =  0x000C},
    {name="GW_NETPAC"           ,value =  0x000D},
    {name="GW_NETTAP"           ,value =  0x000E},
    {name="NETSTICK"            ,value =  0x000F},
    {name="NETANALYZER"         ,value =  0x0010},
    {name="NETSWITCH"           ,value =  0x0011},
    {name="NETLINK"             ,value =  0x0012},
    {name="NETIC"               ,value =  0x0013},
    {name="NPLC_C100"           ,value =  0x0014},
    {name="NPLC_M100"           ,value =  0x0015},
    {name="GW_NETTAP_50"        ,value =  0x0016},
    {name="NETBRICK"            ,value =  0x0017},
    {name="NPLC_T100"           ,value =  0x0018},
    {name="NETLINK_PROXY"       ,value =  0x0019},

    {name="OEM_DEVICE"          ,value =  0xFFFE},

}

TAG_CONSTANTS = {  
    -- EIP xC type
    EIP_XC_TYPE_DLR_2PORT_SWITCH          = 1,
    EIP_XC_TYPE_STD_2PORT_SWITCH          = 2,
    EIP_XC_TYPE_STD_ETH                   = 3,
    
	-- EIF EDD type
	-- PRELIMINARY
	RX_EIF_EDD_TYPE_VIRTUAL              =  0,          -- virtual EDD attached to TCP stack 
	RX_EIF_EDD_TYPE_STD_MAC              =  1,          -- single-port standard Ethernet interface
	RX_EIF_EDD_TYPE_2PORT_SWITCH         =  2,          -- 2-port switch 
	RX_EIF_EDD_TYPE_2PORT_HUB            =  3,          -- 2-port hub 
    
}

EIP_XC_TYPE = {
	{name="Ethernet DLR",             value=1},
	{name="Ethernet 2 port switch",   value=2},
	{name="Ethernet single port",     value=3},
}

	-- PRELIMINARY
EIF_EDD_TYPE = {
	--{name="Virtual EDD attached to TCP stack",       value=0},
	{name="Single-port standard Ethernet interface", value=1},
	{name="2-port Switch",                           value=2},
	{name="2-port Hub",                              value=3}
}

-- MMIO pin numbers for netX 50
NETX50_MMIO_NUMBERS = {}
for i=0, 39 do
	table.insert(NETX50_MMIO_NUMBERS, 
		{name=string.format("MMIO %2d", i), value = i})
end

TAG_STRUCTS = {

----------------------------------------------------------------------------------------------
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


----------------------------------------------------------------------------------------------
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

----------------------------------------------------------------------------------------------
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

----------------------------------------------------------------------------------------------
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

----------------------------------------------------------------------------------------------
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



----------------------------------------------------------------------------------------------
--  Fiber Optic Interface settings
RCX_TAG_ETHERNET_PARAMS_DATA_T = {
    {"UINT8", "bActivePortsBf", desc="Active Ports",
        editor="comboedit",
        editorParam={nBits=8,
            values={
                {name="PORT0 only",         value=1},
                {name="PORT1 only",         value=2},
                {name="PORT0 and PORT1",    value=3},
        }},
    },
    {"UINT8", "bFiberOpticMode", desc="Enable Fiber Optic Interface support",
        editor="checkboxedit",
        editorParam={nBits = 8, offValue = 0, onValue = 1, otherValues = true}
    },
    {"UINT8", "bReserved1", desc="Reserved1", mode = "hidden", editorParam={format="0x%02x"}},
    {"UINT8", "bReserved2", desc="Reserved2", mode = "hidden", editorParam={format="0x%02x"}},
},

----------------------------------------------------------------------------------------------
--  Fiber Optic Transceiver Diagnostic and Monitoring Interface settings for netX50
--  I2C SDA line 1 pin selectable via MMIO Pin number
--  I2C SDA line 2 pin selectable via MMIO Pin number
--  I2C SCL line pin selectable via MMIO Pin number


RCX_TAG_FIBER_OPTIC_IF_DMI_NETX50_PARAMS_DATA_T = {
    {"UINT8", "bSDA1PinIdx", desc="I2C SDA1 Pin Number", editor="comboedit", editorParam={nBits=8, values=NETX50_MMIO_NUMBERS}},
    {"UINT8", "bSDA2PinIdx", desc="I2C SDA2 Pin Number", editor="comboedit", editorParam={nBits=8, values=NETX50_MMIO_NUMBERS}},
    {"UINT8", "bSCLPinIdx",  desc="I2C SCL Pin Number",  editor="comboedit", editorParam={nBits=8, values=NETX50_MMIO_NUMBERS}},
    {"UINT8", "bReserved1",  desc="Reserved1",           mode = "hidden", editorParam={format="0x%02x"}},
},

----------------------------------------------------------------------------------------------
--  Fiber Optic Transceiver Diagnostic and Monitoring Interface settings for netX100/500
--  I2C SDA line is fix on pin W15
--  I2C SCL line is fix on pin W14
--  I2C Select pin is configurable
RCX_TAG_FIBER_OPTIC_IF_DMI_NETX100_PARAMS_DATA_T = {
    {"UINT8", "bSelectPinType", desc="I2C Transceiver Pin Type",
        editor="comboedit",
        editorParam={nBits=8,
            values={
                {name="None",    value=0},
                {name="GPIO",    value=1},
                {name="PIO",     value=2},
        }},
    },
    {"UINT8", "bSelectPinInvert", desc="Inverted",
        editor="checkboxedit",
        editorParam={nBits = 8, offValue = 0, onValue = 1, otherValues = true}
    },
    {"UINT8", "bSelectPinIdx", desc="Pin Number", 
        editor="numedit", editorParam={nBits=8, format="%d", minValue=0, maxValue=84}
    },
    {"UINT8", "bReserved",     desc="Reserved", mode = "hidden", editorParam={format="0x%02x"}},
    
    layout = {
    	sizer="grid",
    	"bSelectPinType",
    	"bSelectPinIdx",
    	"bSelectPinInvert"
    	}
},



----------------------------------------------------------------------------------------------
-- Product Information/Device ID tags

TAG_DP_DEVICEID_DATA_T = {
	{"UINT16", "usIdentNr", desc="Ident Number"},
},

TAG_CIP_DEVICEID_DATA_T = {
	{"UINT16", "usVendorID",    desc="Vendor ID"},
	{"UINT16", "usDeviceType",  desc="Device Type"},
	{"UINT16", "usProductCode", desc="Product Code"},
	{"UINT8",  "bMajRev",       desc="Major Revision"},
	{"UINT8",  "bMinRev",       desc="Minor Revision"},
	{"STRING", "abProductName", desc="Product Name", size=32},
},

TAG_CO_DEVICEID_DATA_T = {
	{"UINT32", "ulVendorId",            desc="Vendor ID"},
	{"UINT32", "ulProductCode",         desc="Product Code"},
	{"UINT16", "usMajRev",              desc="Major Revision"},
	{"UINT16", "usMinRev",              desc="Minor Revision"},
	{"UINT16", "usDeviceProfileNumber", desc="Device Profile Number"},
	{"UINT16", "usAdditionalInfo",      desc="Additional Info"},
},

TAG_CCL_DEVICEID_DATA_T = {
	{"UINT32", "ulVendorCode", desc="Vendor Code"},
	{"UINT32", "ulModelType",  desc="Model Type"},
	{"UINT32", "ulSwVersion",  desc="Software Version",
		editor="numedit", editorParam={nBits=32, format="%d", minValue=0, maxValue=63}
	},
},

-- note: minValue should be 1 here, but this leads to problems when entering hex numbers
TAG_PN_DEVICEID_DATA_T = {
	{"UINT32", "ulVendorId", desc="Vendor ID", editorParam={nBits=32, minValue=0, maxValue=0xfeff}},
	{"UINT32", "ulDeviceId", desc="Device ID", editorParam={nBits=32, minValue=0, maxValue=0xffff}},
},


TAG_ECS_DEVICEID_DATA_T = {
	{"UINT32", "ulVendorId",       desc="Vendor ID"},
	{"UINT32", "ulProductCode",    desc="Product Code"},
	{"UINT32", "ulRevisionNumber", desc="Revision Number"},
},


TAG_S3S_DEVICEID_DATA_T = {
	{"UINT16", "usVendorCode",       desc="Vendor Code"},
	{"STRING", "abDeviceID",         desc="Device ID",    size=256},
},


TAG_PLS_DEVICEID_DATA_T = {
	{"UINT32", "ulVendorId",       desc="Vendor ID"},
	{"UINT32", "ulProductCode",    desc="Product Code"},
	{"UINT32", "ulRevisionNumber", desc="Revision Number"},
},


----------------------------------------------------------------------------------------------
-- EIP/DLR configuration

TAG_EIP_EDD_CONFIGURATION_DATA_T = {
	{"UINT32", "ulEnableDLR",          desc="Enable DLR",
		editor="checkboxedit",
		editorParam={nBits = 32, offValue = 0, onValue = 1, otherValues = true}
	},
	{"UINT32", "ulxCType",             desc="xC Type",
		editor="comboedit", 
		editorParam={nBits=32, values = EIP_XC_TYPE},
	},
	{"UINT32", "ulSinglePortXcNumber", desc="xC Number",
		editor="comboedit", 
		editorParam={nBits=32, minValue=0, maxValue=3}
	}
} ,


----------------------------------------------------------------------------------------------
-- Ethernet Interface facility tags
-- PRELIMINARY

RCX_TAG_EIF_EDD_CONFIG_DATA_T = {
	{"UINT32", "ulEddType",       desc="EDD Type" , editor="comboedit", editorParam={nBits=32, values=EIF_EDD_TYPE}},
	{"UINT32", "ulFirstXcNumber", desc="xC number", editor="comboedit", editorParam={nBits=32, minValue=0, maxValue=3}},
},

RCX_TAG_EIF_EDD_INSTANCE_DATA_T = {
	{"UINT32", "ulEddInstanceNo",  desc="RTE channel number", editor="comboedit", editorParam={nBits=32, minValue=0, maxValue=3}},
},

TAG_ECS_ENABLE_BOOTSTRAP_DATA_T = {
	{"UINT32", "ulEnableBootstrap", desc="Enable", editor="checkboxedit", editorParam={nBits = 32, offValue = 0, onValue = 1, otherValues = true}}
}

} -- end of structure defintions



TAG_DEFS = {
-- tags assigned to protocol classes

-- Device ID tags
TAG_DP_DEVICEID  = 
    {paramtype = 0x30013000, datatype="TAG_DP_DEVICEID_DATA_T",           desc="Profibus Product Information"}, 
TAG_EIP_DEVICEID =                                                    
    {paramtype = 0x3000a000, datatype="TAG_CIP_DEVICEID_DATA_T",          desc="Ethernet/IP Product Information"}, 
TAG_DEVICENET_DEVICEID =                                                    
    {paramtype = 0x30008000, datatype="TAG_CIP_DEVICEID_DATA_T",          desc="DeviceNet Product Information"}, 
TAG_COMPONET_DEVICEID =                                                    
    {paramtype = 0x30006000, datatype="TAG_CIP_DEVICEID_DATA_T",          desc="CompoNet Product Information"}, 
TAG_CO_DEVICEID  =                                                    
    {paramtype = 0x30004000, datatype="TAG_CO_DEVICEID_DATA_T",           desc="CANopen Product Information"}, 
TAG_CCL_DEVICEID =                                                    
    {paramtype = 0x30005000, datatype="TAG_CCL_DEVICEID_DATA_T",          desc="CC-Link Product Information"}, 
TAG_PN_DEVICEID  =                                                    
    {paramtype = 0x30015000, datatype="TAG_PN_DEVICEID_DATA_T",           desc="PROFINET Product Information"}, 
TAG_ECS_DEVICEID = 
    {paramtype = 0x30009000, datatype="TAG_ECS_DEVICEID_DATA_T",          desc="EtherCAT Slave Product Information"}, 
TAG_S3S_DEVICEID = 
    {paramtype = 0x30018000, datatype="TAG_S3S_DEVICEID_DATA_T",          desc="sercos III Product Information"}, 
TAG_PLS_DEVICEID = 
    {paramtype = 0x3001a000, datatype="TAG_PLS_DEVICEID_DATA_T",          desc="POWERLINK Product Information"}, 
    
    
TAG_EIP_EDD_CONFIGURATION = 
    {paramtype = 0x3000a001, datatype="TAG_EIP_EDD_CONFIGURATION_DATA_T", desc="Ethernet/IP EDD Configuration"}, 
    
-- facility tags: netX Diagnostics and Remote Access component
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

    
-- facility tags: netX Ethernet and Fiber Optic Interface
-- This tag is assigned to the DRV_EDD facility (0x00f), but is handled 
-- by each individual realtime ethernet protocol
RCX_TAG_ETHERNET_PARAMS =
    {paramtype = 0x100f0000, datatype="RCX_TAG_ETHERNET_PARAMS_DATA_T",                   desc="Ethernet and Fiber Optic IF"},
-- The next two tags are assigned to facility 0x096
RCX_TAG_FIBER_OPTIC_IF_DMI_NETX100_PARAMS =
    {paramtype = 0x10960000, datatype="RCX_TAG_FIBER_OPTIC_IF_DMI_NETX100_PARAMS_DATA_T", desc="netX100/500 Fiber Optic DMI"},
RCX_TAG_FIBER_OPTIC_IF_DMI_NETX50_PARAMS =
    {paramtype = 0x10960001, datatype="RCX_TAG_FIBER_OPTIC_IF_DMI_NETX50_PARAMS_DATA_T",  desc="netX50 Fiber Optic DMI"},

-- facility tags: Ethernet Interface
RCX_TAG_EIF_EDD_CONFIG =
	{paramtype = 0x105D0000, datatype="RCX_TAG_EIF_EDD_CONFIG_DATA_T",   desc="Ethernet Config"},
RCX_TAG_EIF_EDD_INSTANCE =
	{paramtype = 0x105D0001, datatype="RCX_TAG_EIF_EDD_INSTANCE_DATA_T", desc="Ethernet Channel Number"},
	
-- protocol tag
TAG_ECS_ENABLE_BOOTSTRAP =
	{paramtype = 0x30009001, datatype="TAG_ECS_ENABLE_BOOTSTRAP_DATA_T", desc="EtherCAT Slave Enable Bootstrap Mode"},
}


TAG_HELP = {
    TAG_DIAG_IF_CTRL_UART               = {file="TAG_DIAG_CTRL_DATA_T.htm"},
    TAG_DIAG_IF_CTRL_USB                = {file="TAG_DIAG_CTRL_DATA_T.htm"},
    TAG_DIAG_IF_CTRL_TCP                = {file="TAG_DIAG_CTRL_DATA_T.htm"},
    TAG_DIAG_TRANSPORT_CTRL_CIFX        = {file="TAG_DIAG_CTRL_DATA_T.htm"},
    TAG_DIAG_TRANSPORT_CTRL_PACKET      = {file="TAG_DIAG_CTRL_DATA_T.htm"},

    RCX_TAG_ETHERNET_PARAMS 			  		= {file="RCX_TAG_ETHERNET_PARAMS_T.htm"},
    RCX_TAG_FIBER_OPTIC_IF_DMI_NETX50_PARAMS  	= {file="RCX_TAG_FIBER_OPTIC_IF_DMI_NETX50_PARAMS_T.htm"},
    RCX_TAG_FIBER_OPTIC_IF_DMI_NETX100_PARAMS 	= {file="RCX_TAG_FIBER_OPTIC_IF_DMI_NETX100_PARAMS_T.htm"},

    TAG_DP_DEVICEID                     = {file="TAG_DP_DEVICEID_DATA_T.htm"}, 
    TAG_EIP_DEVICEID                    = {file="TAG_CIP_DEVICEID_DATA_T.htm"}, 
    TAG_DEVICENET_DEVICEID              = {file="TAG_CIP_DEVICEID_DATA_T.htm"}, 
    TAG_COMPONET_DEVICEID               = {file="TAG_CIP_DEVICEID_DATA_T.htm"}, 
    TAG_CO_DEVICEID                     = {file="TAG_CO_DEVICEID_DATA_T.htm"}, 
    TAG_CCL_DEVICEID                    = {file="TAG_CCL_DEVICEID_DATA_T.htm"}, 
    TAG_PN_DEVICEID                     = {file="TAG_PN_DEVICEID_DATA_T.htm"}, 
    TAG_S3S_DEVICEID                    = {file="TAG_S3S_DEVICEID_DATA_T.htm"}, 
    TAG_ECS_DEVICEID                    = {file="TAG_ECS_DEVICEID_DATA_T.htm"}, 
    TAG_PLS_DEVICEID                    = {file="TAG_PLS_DEVICEID_DATA_T.htm"}, 
    
    TAG_EIP_EDD_CONFIGURATION           = {file="TAG_EIP_EDD_CONFIGURATION_DATA_T.htm"}, 
    
    RCX_TAG_EIF_EDD_CONFIG              = {file="RCX_TAG_EIF_EDD_CONFIG_DATA_T.htm"},
    RCX_TAG_EIF_EDD_INSTANCE            = {file="RCX_TAG_EIF_EDD_INSTANCE_DATA_T.htm"},
    TAG_ECS_ENABLE_BOOTSTRAP            = {file="TAG_ECS_ENABLE_BOOTSTRAP_DATA_T.htm"}, 
}



taglist.addConstants(DEVHDR_CONSTANTS)
taglist.addConstants(TAG_CONSTANTS)
taglist.addDataTypes(TAG_STRUCTS)
taglist.addTags(TAG_DEFS)
taglist.addTagHelpPages(TAG_HELP)