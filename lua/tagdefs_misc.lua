---------------------------------------------------------------------------
-- Copyright (C) 2013 Hilscher Gesellschaft für Systemautomation mbH
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
-- 2024-08-28     SL            added HIL_TAG_EIP_FILE_OBJECT_ENABLE_DISABLE 0x3000A006
-- 2024-03-18     SL            added HIL_TAG_LWIP_AMOUNT_SOCKET_API_MULTICAST_GROUPS   0x10e90003
-- 2023-11-15     MBO           added HIL_TAG_EIP_TIMESYNC_ENABLE_DISABLE 0x3000A005
-- 2023-09-20     MBO           added HIL_TAG_EIP_RESOURCES 0x3000A004
-- 2023-09-01     SL            added HIL_TAG_DEVICENET_CAN_SAMPLING 0x30008001
-- 2023-08-22     SL            added HIL_TAG_ECS_EOE_MODE      0x30009006
-- 2023-04-19     SL            added HIL_TAG_NF_PN_IOL_PROFILE_CFG_FLAGS 0x10e00006
-- 2023-04-19     SL            added HIL_TAG_HTTPS_PORT_CONFIG 0x10920001
-- 2023-04-18     SL            renamed RCX_TAG_SERVX_PORT_NUMBER 
--                              to HIL_TAG_HTTP_PORT_CONFIG
-- 2022-09-07     SL            added HIL_TAG_PROFINET_CONTROLLER_QUANTITIES 0x30015004
-- 2021-05-28     SL            added HIL_TAG_NF_SWAP_COM_LEDS  0x10e00005
-- 2021-04-28     SL            added HIL_TAG_LWIP_QUANTITY_STRUCTURE 0x10e90002
--                              added HIL_TAG_NF_GEN_DIAG_RESOURCES   0x10e00001
--                              added HIL_TAG_NF_PROFI_ENERGY_MODES   0x10e00002
--                              added HIL_TAG_NF_PN_IOL_PROFILE_PADDING 0x10e00003
--                              added HIL_TAG_NF_PN_IOL_PROFILE_DIO_IN_IOLM 0x10e00004
-- 2019-11-01     SL            added HIL_TAG_LWIP_NETIDENT_BEHAVIOUR 0x10e90001
--                              added HIL_TAG_LWIP_PORTS_FOR_IP_ZERO  0x10e90000
-- 2019-08-06     SL            added TAG_ECM_ENI_BUS_STATE     0x30009005
-- 2017-10-12     SL            added TAG_PROFINET_FEATURES_V2  0x30015002
--                     TAG_PROFINET_SYSTEM_REDUNDANCY_FEATURES  0x30015003
-- 2016-05-31     SL            added TAG_EIP_DLR_PROTOCOL      0x3000a002
-- 2015-12-18     SL            change %d to %u
-- 2014-11-06     SL            updated TAG_PROFINET_FEATURES_DATA_T
-- 2014-10-30     SL            added RCX_TAG_PROFINET_FEATURES 0x30015001
-- 2013-10-31     SL            updated RCX_TAG_ETHERNET_PARAMS 0x100f0000: 
--                              enable Fiber optic for ports 0/1 individually 
-- 2013-06-25     SL            GUI configuration for TAG_TCP_PORT_NUMBERS
--                              TAG_TCP_PORT_NUMBERS enabled
-- 2013-06-14     SL            added TAG_TCP_PORT_NUMBERS 0x30019000 
--                              (disabled, not for general use)
-- 2012-10-31     SL            added RCX_TAG_SERVX_PORT_NUMBER 0x10920001
--                                    TAG_ECS_SELECT_SOE_COE    0x30009002
--                                    TAG_ECS_CONFIG_EOE        0x30009003
--                                    TAG_ECS_MBX_SIZE          0x30009004
-- 2012-09-27     SL            added RCX_TAG_EIF_NDIS_ENABLE   0x105D0002
-- 2012-04-03     SL            added TAG_ECS_ENABLE_BOOTSTRAP  0x30009001
-- 2012-01-19     SL            added device ID tags for ECS, S3S, PLS
-- 2011-05-12     SL            factored out from taglist.lua
---------------------------------------------------------------------------

module("tagdefs_misc", package.seeall)

---------------------------------------------------------------------------
-- SVN Keywords
--
SVN_DATE   ="$Date: 2015-12-18 12:49:29 +0100 (Fr, 18 Dez 2015) $"
SVN_VERSION="$Revision: 17333 $"
-- $Author: slesch $
---------------------------------------------------------------------------
require("taglist")

---------------------------------------------------------------------------
-------------------------  Constants --------------------------------------
---------------------------------------------------------------------------


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

	-- ECS Select SoE or CoE
	ECS_STACK_VARIANT_COE = 0,
	ECS_STACK_VARIANT_SOE = 1,

	-- ECS EoE Config
	ECS_EOE_MODE_DISABLED = 0,
	ECS_EOE_MODE_TCPIP    = 1,
	ECS_EOE_MODE_RAW      = 2,

	-- ECS EoE Config (0x30009006)
	HIL_TAG_ECS_EOE_MODE_INTERNAL   = 0,
	HIL_TAG_ECS_EOE_MODE_EXTERNAL   = 1,

	-- ECS Mailbox Size
	ECS_MBX_SIZE_128_128 = 0,
	ECS_MBX_SIZE_268_268 = 1,
	ECS_MBX_SIZE_332_332 = 2,
	ECS_MBX_SIZE_396_396 = 3,
	ECS_MBX_SIZE_524_524 = 4,
--	ECS_MBX_SIZE_780_780 = 5,

	-- Ethernet Params Fiberoptic Mode on/off
	RCX_TAG_ETHERNET_FIBEROPTICMODE_OFF      = 0,
	RCX_TAG_ETHERNET_FIBEROPTICMODE_ON       = 1,
	RCX_TAG_ETHERNET_FIBEROPTICMODE_PORT0_ON = 2,
	RCX_TAG_ETHERNET_FIBEROPTICMODE_PORT1_ON = 3,

	-- EtherCAT Master Target bus state for ENI files on ChannelInit
	HIL_TAG_ECM_ENI_BUS_STATE_OFF = 0,
	HIL_TAG_ECM_ENI_BUS_STATE_ON  = 1,
	
	-- netFIELD PROFINET IO-Link profile submodule padding
	HIL_TAG_NF_PN_IOL_PROFILE_PADDING_PADMODE_UNALIGNMENT     = 0,
	HIL_TAG_NF_PN_IOL_PROFILE_PADDING_PADMODE_2BYTE_ALIGNMENT = 1,
	HIL_TAG_NF_PN_IOL_PROFILE_PADDING_PADMODE_4BYTE_ALIGNMENT = 2,
	
	-- netFIELD PROFINET IO-Link profile DIO in IOLM
	HIL_TAG_NF_PN_IOL_PROFILE_DIO_IN_IOLM_DISABLED  =  0,
	HIL_TAG_NF_PN_IOL_PROFILE_DIO_IN_IOLM_ENABLED   =  1,
	
	-- netFIELD PROFINET IO-Link profile Configuration Flags
	HIL_TAG_NF_PN_IOL_PROFILE_CFG_FLAGS_DIO_IN_IOLM_DISABLED =  0,
	HIL_TAG_NF_PN_IOL_PROFILE_CFG_FLAGS_DIO_IN_IOLM_ENABLED  =  1,
	HIL_TAG_NF_PN_IOL_PROFILE_CFG_FLAGS_DIAG_ENABLED         =  0,
	HIL_TAG_NF_PN_IOL_PROFILE_CFG_FLAGS_DIAG_DISABLED        =  1,
	HIL_TAG_NF_PN_IOL_PROFILE_CFG_FLAGS_PA_ENABLED           =  0,
	HIL_TAG_NF_PN_IOL_PROFILE_CFG_FLAGS_PA_DISABLED          =  1,
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

ECS_STACK_VARIANT = {
	{name="CoE", value=0},
	{name="SoE", value=1},
}

ECS_EOE_MODE = {
	{name = "EoE disabled",                     value = 0},
	{name = "EoE (TCP/IP mode) enabled",        value = 1},
	{name = "EoE (Raw Ethernet mode) enabled",  value = 2},
}

ECS_MBX_SIZE = {
	{name = "128 bytes RX / 128 bytes TX", value = 0},
	{name = "268 bytes RX / 268 bytes TX", value = 1},
	{name = "332 bytes RX / 332 bytes TX", value = 2},
	{name = "396 bytes RX / 396 bytes TX", value = 3},
	{name = "524 bytes RX / 524 bytes TX", value = 4},
--	{name = "780 bytes RX / 780 bytes TX", value = 5},
}

ECM_ENI_BUS_STATE = {
	{name = "Off", value = 0},
	{name = "On",  value = 1},
}

ECS_EOE_MODE_2 = {
	{name = "EoE address is assigned to 1st chassis (LWIP)", value = 0},
	{name = "EoE address is assigned to NDIS interface",     value = 1},
}



-- MMIO pin numbers for netX 50
NETX50_MMIO_NUMBERS = {}
for i=0, 39 do
	table.insert(NETX50_MMIO_NUMBERS,
		{name=string.format("MMIO %2d", i), value = i})
end



---------------------------------------------------------------------------
----------------------  Structure definitions  ----------------------------
---------------------------------------------------------------------------


TAG_STRUCTS = {

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
		editor="numedit", editorParam={nBits=32, format="%u", minValue=0, maxValue=63}
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
-- CAN Sample point

HIL_TAG_DEVICENET_CAN_SAMPLING_DATA_T = {
    {"UINT8", "bEnableAlternativeSamplePointTimings",
        desc="Enable Alternative Sample Point Timings",
        editor="checkboxedit",
        editorParam={nBits = 8, offValue = 0, onValue = 1, otherValues = true},
    },
    {"UINT8", "bReserved1",        desc="Reserved1",     mode = "hidden"},
    {"UINT8", "bReserved2",        desc="Reserved2",     mode = "hidden"},
    {"UINT8", "bReserved3",        desc="Reserved3",     mode = "hidden"},
},


----------------------------------------------------------------------------------------------
-- Resource dimensioning of EIP stack
HIL_TAG_EIP_RESOURCES_DATA_T = {
    {"UINT16", "usMaxUserServices",             desc="Max. supported CIP services the host can register",
       editor="numedit",  editorParam={nBits=16, format="%u", minValue=0, maxValue=1024}
    },
    {"UINT16", "usMaxUserObjects",             desc="Max. CIP objects the host can register",
       editor="numedit",  editorParam={nBits=16, format="%u", minValue=0, maxValue=1024}
    },
    {"UINT16", "usMaxAdapterAssemblyInstance",       desc="Max. Assembly Instances the host can register",
       editor="numedit",  editorParam={nBits=16, format="%u", minValue=0, maxValue=1024}
    },
    {"UINT16", "usAssemblyDataMemPoolSize",  desc="Assembly object data mempool size",
       editor="numedit",  editorParam={nBits=16, format="%u", minValue=0, maxValue=65535}
    },
    {"UINT16", "usAssemblyMetaMemPoolSize",   desc="Assembly object meta mempool size",
       editor="numedit",  editorParam={nBits=16, format="%u", minValue=0, maxValue=65535}
    },
    {"UINT8", "bMaxUdpQueueElements",   desc="UDP Encap receive queue depth",
       editor="numedit",  editorParam={nBits=8, format="%u", minValue=0, maxValue=255}
    },
    {"UINT8", "bMaxIoQueueElements",   desc="UDP I/O receive queue depth",
       editor="numedit",  editorParam={nBits=8, format="%u", minValue=0, maxValue=255}
    },
    {"UINT16",  "usMaxTcpConnections",           desc="Max. TCP connections/sockets.",
       editor="numedit",  editorParam={nBits=16, format="%u", minValue=0, maxValue=1024}
    },
    {"UINT8",  "bMaxTcpQueueElements",           desc="Per socket TCP frame queues depth",
       editor="numedit",  editorParam={nBits=8, format="%u", minValue=0, maxValue=255}
    },
    {"UINT8",  "bPad0", desc="Pad byte", mode = "hidden"},
    {"UINT16",  "usMaxIoConnections",           desc="Overall max. I/O connections",
       editor="numedit",  editorParam={nBits=16, format="%u", minValue=0, maxValue=1024}
    },
    {"UINT16",  "usMaxTargetIoConnections",           desc="Max. parallel CL0/1 connections",
       editor="numedit",  editorParam={nBits=16, format="%u", minValue=0, maxValue=1024}
    },
    {"UINT16",  "usMaxTargetCl3Connections",           desc="Max. parallel CL3 connections",
       editor="numedit",  editorParam={nBits=16, format="%u", minValue=0, maxValue=1024}
    },
    {"UINT16",  "usMaxTargetUcmmConnections",           desc="Max. parallel UCMM requests",
       editor="numedit",  editorParam={nBits=16, format="%u", minValue=0, maxValue=1024}
    },
    {"UINT8",  "bMaxPdcInstance",           desc="Max. PDC instances",
       editor="numedit",  editorParam={nBits=8, format="%u", minValue=0, maxValue=255}
    },
    {"UINT8",  "bPad1", desc="Pad byte", mode = "hidden"},
    {"UINT16",  "usPdcMemPoolSize",           desc="PDC object mempool size",
      editor="numedit",  editorParam={nBits=16, format="%u", minValue=0, maxValue=65535}
    },

    {"UINT16",  "usReserved1",           desc="reserved",                mode = "hidden"},
    {"UINT16",  "usReserved2",           desc="reserved",                mode = "hidden"},
    {"UINT16",  "usReserved3",           desc="reserved",                mode = "hidden"},
    {"UINT16",  "usReserved4",           desc="reserved",                mode = "hidden"},
},

----------------------------------------------------------------------------------------------
-- Ethernet/IP Timesync object enabled/disabled (statically)
HIL_TAG_EIP_TIMESYNC_ENABLE_DISABLE_DATA_T = {
    {"UINT8", "bRegisterTimesyncObject", desc="Enable CIP Sync",
       editor="checkboxedit",
       editorParam={nBits=8, offValue=0, onValue=1, otherValues = true}
    },
},


----------------------------------------------------------------------------------------------
-- CIP File Object Enable/Disable
HIL_TAG_EIP_FILE_OBJECT_ENABLE_DISABLE_DATA_T = {
    {"UINT32", "ulEnableFileObject", desc="Enable CIP File Object",
       editor="checkboxedit",
       editorParam={nBits=32, offValue=0, onValue=1, otherValues = true}
    },
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
-- EIP/DLR configuration
TAG_EIP_DLR_PROTOCOL_DATA_T = {
	{"UINT32", "ulEnableDLR",          desc="Enable DLR",
		editor="checkboxedit",
		editorParam={nBits = 32, offValue = 0, onValue = 1, otherValues = true}
	},
} ,


----------------------------------------------------------------------------------------------
-- EtherCAT protocol tags

TAG_ECS_ENABLE_BOOTSTRAP_DATA_T = {
	{"UINT32", "ulEnableBootstrap", desc="Enable", editor="checkboxedit", editorParam={nBits = 32, offValue = 0, onValue = 1, otherValues = true}}
},

TAG_ECS_SELECT_SOE_COE_DATA_T = {
	{"UINT32", "ulECSStackVariant", desc="Stack Variant", editor="comboedit",  editorParam={nBits=32, values = ECS_STACK_VARIANT}}
},

TAG_ECS_CONFIG_EOE_DATA_T = {
	{"UINT32", "ulEoEMode", desc="EoE Mode", editor="comboedit",  editorParam={nBits=32, values = ECS_EOE_MODE}}
},

TAG_ECS_MBX_SIZE_DATA_T = {
	{"UINT32", "ulMbxSize", desc="Mailbox Size", editor="comboedit",  editorParam={nBits=32, values = ECS_MBX_SIZE}}
},

TAG_ECM_ENI_BUS_STATE_DATA_T = {
	{"UINT32", "ulTargetBusState", desc="Target Bus State", editor="comboedit",  editorParam={nBits=32, values = ECM_ENI_BUS_STATE}}
},

HIL_TAG_ECS_EOE_MODE_DATA_T = {
	{"UINT32", "ulEoEMode", desc="EoE Mode", editor="comboedit",  editorParam={nBits=32, values = ECS_EOE_MODE_2}}
},
----------------------------------------------------------------------------------------------
-- TCP Port Numbers 
TAG_TCP_PORT_NUMBERS_DATA_T = {
	{"UINT32", "ulPortStart",                   desc="TCP/UDP Port Range (First Port)", editor="numedit", editorParam={nBits=32, format="%u", minValue=0,    maxValue=0xefff}},
	{"UINT32", "ulPortEnd",                     desc="TCP/UDP Port Range (Last Port)",  editor="numedit", editorParam={nBits=32, format="%u", minValue=0,    maxValue=0xefff}},
	{"UINT32", "ulNumberOfProtocolStackPorts",  desc="Number of Protocol Stack Ports", 
	                                                                mode = "read-only", editor="numedit", editorParam={nBits=32, format="%u", minValue=0,    maxValue=20}},
	{"UINT32", "ulNumberOfUserPorts",           desc="Number of Additional Ports",      editor="numedit", editorParam={nBits=32, format="%u", minValue=0,    maxValue=20}},
	{"UINT16", "ausPortList_0",                 desc="Port 1",                          editor="numedit", editorParam={nBits=16, format="%u", minValue=0,    maxValue=65535}},
	{"UINT16", "ausPortList_1",                 desc="Port 2",                          editor="numedit", editorParam={nBits=16, format="%u", minValue=0,    maxValue=65535}},
	{"UINT16", "ausPortList_2",                 desc="Port 3",                          editor="numedit", editorParam={nBits=16, format="%u", minValue=0,    maxValue=65535}},
	{"UINT16", "ausPortList_3",                 desc="Port 4",                          editor="numedit", editorParam={nBits=16, format="%u", minValue=0,    maxValue=65535}},
	{"UINT16", "ausPortList_4",                 desc="Port 5",                          editor="numedit", editorParam={nBits=16, format="%u", minValue=0,    maxValue=65535}},
	{"UINT16", "ausPortList_5",                 desc="Port 6",                          editor="numedit", editorParam={nBits=16, format="%u", minValue=0,    maxValue=65535}},
	{"UINT16", "ausPortList_6",                 desc="Port 7",                          editor="numedit", editorParam={nBits=16, format="%u", minValue=0,    maxValue=65535}},
	{"UINT16", "ausPortList_7",                 desc="Port 8",                          editor="numedit", editorParam={nBits=16, format="%u", minValue=0,    maxValue=65535}},
	{"UINT16", "ausPortList_8",                 desc="Port 9",                          editor="numedit", editorParam={nBits=16, format="%u", minValue=0,    maxValue=65535}},
	{"UINT16", "ausPortList_9",                 desc="Port 10",                         editor="numedit", editorParam={nBits=16, format="%u", minValue=0,    maxValue=65535}},
	{"UINT16", "ausPortList_10",                desc="Port 11",                         editor="numedit", editorParam={nBits=16, format="%u", minValue=0,    maxValue=65535}},
	{"UINT16", "ausPortList_11",                desc="Port 12",                         editor="numedit", editorParam={nBits=16, format="%u", minValue=0,    maxValue=65535}},
	{"UINT16", "ausPortList_12",                desc="Port 13",                         editor="numedit", editorParam={nBits=16, format="%u", minValue=0,    maxValue=65535}},
	{"UINT16", "ausPortList_13",                desc="Port 14",                         editor="numedit", editorParam={nBits=16, format="%u", minValue=0,    maxValue=65535}},
	{"UINT16", "ausPortList_14",                desc="Port 15",                         editor="numedit", editorParam={nBits=16, format="%u", minValue=0,    maxValue=65535}},
	{"UINT16", "ausPortList_15",                desc="Port 16",                         editor="numedit", editorParam={nBits=16, format="%u", minValue=0,    maxValue=65535}},
	{"UINT16", "ausPortList_16",                desc="Port 17",                         editor="numedit", editorParam={nBits=16, format="%u", minValue=0,    maxValue=65535}},
	{"UINT16", "ausPortList_17",                desc="Port 18",                         editor="numedit", editorParam={nBits=16, format="%u", minValue=0,    maxValue=65535}},
	{"UINT16", "ausPortList_18",                desc="Port 19",                         editor="numedit", editorParam={nBits=16, format="%u", minValue=0,    maxValue=65535}},
	{"UINT16", "ausPortList_19",                desc="Port 20",                         editor="numedit", editorParam={nBits=16, format="%u", minValue=0,    maxValue=65535}},

	layout = {
		sizer = "v",
		{
			sizer = "v", box = "Port Range",
			"ulPortStart",  
			"ulPortEnd",    
		},
		{
			sizer = "v", box = "Additional Ports",
			
			{
				sizer="grid", cols = 1, 
				"ulNumberOfProtocolStackPorts",  
				"ulNumberOfUserPorts",    
			},
			{
				sizer="grid", cols = 2,
				"ausPortList_0",  "ausPortList_1",  "ausPortList_2", "ausPortList_3",  
				"ausPortList_4",  "ausPortList_5",  "ausPortList_6", "ausPortList_7",  
				"ausPortList_8",  "ausPortList_9",  "ausPortList_10", "ausPortList_11", 
				"ausPortList_12", "ausPortList_13", "ausPortList_14", "ausPortList_15", 
				"ausPortList_16", "ausPortList_17", "ausPortList_18", "ausPortList_19", 
			}
		}
	},
	
	-- Disable the first ulNumberOfProtocolStackPorts entries of ausPortList in the GUI.
	configureGui = function(tStruct, tStructedit)
		local ulNumPorts = tStruct.ulNumberOfProtocolStackPorts
		if ulNumPorts >=0 and ulNumPorts <= 20 then
			for i = 0, ulNumPorts-1 do
				tStructedit:DisableElement("ausPortList_" .. i)
			end
		end
	end,
},


----------------------------------------------------------------------------------------------
-- Profinet protocol tags

-- typedef struct
-- {
--   uint8_t      bNumAdditionalIoAR;     /* 0: only 1 cyclic Profinet connection is possible, allowed values 0 - 4, refer to PNS API Manual for details */
--   uint8_t      bIoSupervisorSupported; /* 0: IO Supervisor communication is not accepted by firmware / 1: IO Supervisor communication is accepted by firmware */
--   uint8_t      bIRTSupported;          /* 0: IRT communication is not accepted by firmware / 1: IRT communication is accepted by firmware */
--   uint8_t      bReserved;
--   uint16_t     usMinDeviceInterval;    /* the MinDeviceInterval according to GSDML file of the product (allowed values: Power of two in range [8 - 4096]) */
--   uint8_t      abReserved[2];
-- } RCX_TAG_PROFINET_FEATURES_DATA_T;

TAG_PROFINET_FEATURES_DATA_T = {
    {"UINT8",  "bNumAdditionalIoAR",         desc = "Number of additional IO Connections (ARs)",
        editor="comboedit",
        editorParam={nBits=8,
            values={
                {name="0",    value=0},
                {name="1",    value=1},
                {name="2",    value=2},
                {name="3",    value=3},
    } } },
    {"UINT8",  "bIoSupervisorSupported",     desc = "IO Supervisor communication accepted",
        editor="checkboxedit",
        editorParam={nBits = 8, offValue = 0, onValue = 1, otherValues = true}
    },
    {"UINT8",  "bIRTSupported",              desc = "IRT Communication accepted",
        editor="checkboxedit",
        editorParam={nBits = 8, offValue = 0, onValue = 1, otherValues = true}
    },
    {"UINT8",  "bReserved",                  desc = "reserved",                              mode = "hidden",   },
    {"UINT16", "usMinDeviceInterval",        desc = "MinDeviceInterval",
        editor="comboedit",
        editorParam={nBits=16,
            values={
                {name="8",      value=8},
                {name="16",     value=16},
                {name="32",     value=32},
                {name="64",     value=64},
                {name="128",    value=128},
                {name="256",    value=256},
                {name="512",    value=512},
                {name="1024",   value=1024},
                {name="2048",   value=2048},
                {name="4096",   value=4096},
                
        } } },
    {"UINT8",  "abReserved1",                desc = "reserved",                              mode = "hidden",   },
    {"UINT8",  "abReserved2",                desc = "reserved",                              mode = "hidden",   },
},



----------------------------------------------------------------------------------------------
-- typedef struct HIL_TAG_PROFINET_FEATURES_V2_DATA_Ttag
-- {
--   uint16_t  usNumSubmodules;     /** Maximum number of user submodules supported by the product. Allowed values [1, 1000] */
--   uint8_t   bRPCBufferSize;      /* Minimum size of RPC buffers in KB. Allowed values [4, 64]. */ 
--   uint8_t   bNumAdditionalIOAR;  /** Number of additional IO ARs available for Shared Device and SystemRedundancy. Nonzero value enables additional IO connections. For allowed values refer to PNS API Manual for details */
--   uint8_t   bNumImplicitAR;      /** Number of implicit ARs used for Read Implicit Services. Allowed values [1, 8]. */
--   uint8_t   bNumDAAR;            /** Number of parallel Device Access ARs supported by device. Allowed values [0, 1]. */  
--   uint16_t  usNumSubmDiagnosis;  /** Maximum number of diagnosis entries generated by application. Allowed values [0, 1000] */
-- } HIL_TAG_PROFINET_FEATURES_V2_DATA_T;

TAG_PROFINET_FEATURES_V2_DATA_T = {
    {"UINT16", "usNumSubmodules",      desc = "Number of configurable submodules", 
        editor="numedit",  editorParam={nBits=16, format="%u", minValue=0, maxValue=1000} -- actual minValue: 1
    }, 
    {"UINT8", "bRPCBufferSize",        desc = "Minimum size of each RPC buffer in KB", 
        editor="numedit",  editorParam={nBits=8, format="%u", minValue=0,  maxValue=64} -- actual minValue: 4
    },
    {"UINT8",  "bNumAdditionalIoAR",   desc = "Number of additional IO Connections (ARs)",
        editor="comboedit", editorParam={nBits=8,  minValue = 0, maxValue = 7} 
    },    
    {"UINT8",  "bNumImplicitAR",       desc = "Number of parallel Read Implicit Requests",
        editor="comboedit", editorParam={nBits=8,  minValue = 1, maxValue = 8} 
    },
    {"UINT8",  "bNumDAAR",             desc = "Number of parallel DeviceAccess ARs",
        editor="comboedit", editorParam={nBits=8,  minValue = 0, maxValue = 1} 
    },
    {"UINT16",  "usNumSubmDiagnosis",  desc = "Number of available diagnosis buffers", 
        editor="numedit",  editorParam={nBits=16, format="%u", minValue=0, maxValue=1000}
    },
},

----------------------------------------------------------------------------------------------
-- typedef struct HIL_TAG_PROFINET_SYSTEM_REDUNDANCY_FEATURES_DATA_Ttag
-- {
--   uint8_t  bNumberOfARSets;/** Number of AR Sets supported by the device. Set to non-zero value to allow SR type connections. Allowed values [0, 1]. */
--   uint8_t  abPadding[3];   /** 32Bits alignment */
-- } HIL_TAG_PROFINET_SYSTEM_REDUNDANCY_FEATURES_DATA_T;


TAG_PROFINET_SYSTEM_REDUNDANCY_FEATURES_DATA_T = {
    {"UINT8",  "bNumberOfARSets",       desc="Number of parallel ARSets", 
        editor="comboedit", editorParam={nBits=8,  minValue = 0, maxValue = 1} 
    },
    {"UINT8",  "abPadding0",           desc="reserved",                mode = "hidden"},
    {"UINT8",  "abPadding1",           desc="reserved",                mode = "hidden"},
    {"UINT8",  "abPadding2",           desc="reserved",                mode = "hidden"},

}, 

----------------------------------------------------------------------------------------------
-- typedef struct
-- {
--   uint16_t     usNumIOAR;               /** Number of parallel IO ARs. Allowed values [1, 128] */
--   uint16_t     usNumDAAR;               /** Number of parallel Device Access ARs. Allowed values [0, 1] */
--   uint16_t     usNumSubmodules;         /** Maximum number of submodules over all IO ARs. Allowed values [32, 2048] */
--   uint16_t     usParamRecordStorage;    /** Available GSD parameter record storage per AR in KB. Allowed values [4, 256] */
--   uint16_t     usNumARVendorBlocks;     /** Number of ARVendorBlocks over all IO ARs. Allowed values [1, 512] */
--   uint16_t     usSizeARVendorBlock;     /** Size per ARVendrBlock in byte. Allowed values [128, 4096] */
--   uint16_t     usSizeApplRpcBuffer;     /** Size of single application service RPC buffer in KB. Allowed values [4, 256] */
--   uint8_t      abPadding[2];            /** 32Bits alignment */
-- } HIL_TAG_PROFINET_CONTROLLER_QUANTITIES_DATA_T;


TAG_PROFINET_CONTROLLER_QUANTITIES_DATA_T = {
    {"UINT16", "usNumIOAR",             desc="Number of IO Connections (ARs)",  
       editor="numedit",  editorParam={nBits=16, format="%u", minValue=0, maxValue=128} -- actual Range: 1-128
    },
    {"UINT16", "usNumDAAR",             desc="Number of parallel Device Access ARs",
       editor="numedit",  editorParam={nBits=16, format="%u", minValue=0, maxValue=1} 
    },
    {"UINT16", "usNumSubmodules",       desc="Number of submodules",
       editor="numedit",  editorParam={nBits=16, format="%u", minValue=0, maxValue=2048} -- actual Range: 32-2048
    },
    {"UINT16", "usParamRecordStorage",  desc="GSD parameter record storage size", 
       editor="numedit",  editorParam={nBits=16, format="%u", minValue=0, maxValue=256} -- actual Range: 4-256
    },
    {"UINT16", "usNumARVendorBlocks",   desc="Number of ARVendorBlocks", 
       editor="numedit",  editorParam={nBits=16, format="%u", minValue=0, maxValue=512} -- actual Range: 1-512
    },
    {"UINT16", "usSizeARVendorBlock",   desc="ARVendorBlock storage size", 
       editor="numedit",  editorParam={nBits=16, format="%u", minValue=0, maxValue=4096} -- actual Range: 128-4096
    },
    {"UINT16", "usSizeApplRpcBuffer",   desc="Size for acyclic application Read/Write requests", 
       editor="numedit",  editorParam={nBits=16, format="%u", minValue=0, maxValue=256} -- actual Range: 4-256
    },
    {"UINT8",  "abPadding0",           desc="reserved",                mode = "hidden"},
    {"UINT8",  "abPadding1",           desc="reserved",                mode = "hidden"},
}, 


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
    {"UINT8", "bInterfaceNumber", desc="UART Number", mode="read-only", editorParam={format="%u"}},
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
    {"UINT8", "bInterfaceNumber", desc="USB Port Number", mode="read-only", editorParam={format="%u"}},
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
    {"UINT16", "usTCPPortNo", desc="TCP Port Number", mode="read-only", editorParam={format="%u"}},

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
                {name="Port 0 only",         value=1},
                {name="Port 1 only",         value=2},
                {name="Port 0 and Port 1",   value=3},
        }},
    },
    {"UINT8", "bFiberOpticMode", desc="Enable Fiber Optic Interface support",
        editor="comboedit",
        editorParam={nBits=8,
            values={
                {name="Off",                value=0},
                {name="Port 0 only",        value=2},
                {name="Port 1 only",        value=3},
                {name="Port 0 and Port 1",  value=1},
        }},
--        editor="checkboxedit",
--        editorParam={nBits = 8, offValue = 0, onValue = 1, otherValues = true}
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
        editor="numedit", editorParam={nBits=8, format="%u", minValue=0, maxValue=84}
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
-- Ethernet Interface facility tags

RCX_TAG_EIF_EDD_CONFIG_DATA_T = {
	{"UINT32", "ulEddType",       desc="EDD Type" , editor="comboedit", editorParam={nBits=32, values=EIF_EDD_TYPE}},
	{"UINT32", "ulFirstXcNumber", desc="xC number", editor="comboedit", editorParam={nBits=32, minValue=0, maxValue=3}},
},

RCX_TAG_EIF_EDD_INSTANCE_DATA_T = {
	{"UINT32", "ulEddInstanceNo",  desc="RTE channel number", editor="comboedit", editorParam={nBits=32, minValue=0, maxValue=3}},
},

RCX_TAG_EIF_NDIS_ENABLE_DATA_T = {
	{"UINT32", "ulNDISEnable",  desc="Enable NDIS Support", editor="checkboxedit", editorParam={nBits = 32, offValue = 0, onValue = 1, otherValues = true}}
},



----------------------------------------------------------------------------------------------
-- servX facility tags

HIL_TAG_HTTP_PORT_CONFIG_DATA_T = {
	{"UINT16", "usPort",  desc="Web server (HTTP) Port Number", editor="numedit", editorParam={nBits=16, format="%u"}}
},

HIL_TAG_HTTPS_PORT_CONFIG_DATA_T = {
	{"UINT16", "usPort",                desc="Web server (HTTPS) Port Number", editor="numedit",   editorParam={nBits=16, format="%u"}},
	{"UINT8",  "bCertificateHandling",  desc="Certificate Handling",           editor="comboedit", editorParam={nBits=8, minValue=0, maxValue=2}},
    {"UINT8",  "bReserved",             desc="Reserved",     mode = "hidden"},
},




----------------------------------------------------------------------------------------------
-- LWIP Ports for usage with IP 0.0.0.0

HIL_TAG_LWIP_PORTS_FOR_IP_ZERO_DATA_T = {
    {"UINT16", "usPort0",  desc="Port 0", editor="numedit", editorParam ={nBits=16, format="%u", minValue=0, maxValue=65535}},
    {"UINT16", "usPort1",  desc="Port 1", editor="numedit", editorParam ={nBits=16, format="%u", minValue=0, maxValue=65535}},
},


----------------------------------------------------------------------------------------------
-- LWIP netident behaviour

HIL_TAG_LWIP_NETIDENT_BEHAVIOUR_DATA_T = {
    {"UINT8", "bNetidentEnable",         desc="Enable netident",         
        editor="checkboxedit",
        editorParam={nBits = 8, offValue = 0, onValue = 1, otherValues = true}
    },
    {"UINT8", "bReserved1",        desc="Reserved1",     mode = "hidden"},
    {"UINT8", "bReserved2",        desc="Reserved2",     mode = "hidden"},
    {"UINT8", "bReserved3",        desc="Reserved3",     mode = "hidden"},
},



----------------------------------------------------------------------------------------------
-- Socket API quantity structure

HIL_TAG_LWIP_QUANTITY_STRUCTURE_DATA_T = {
    {"UINT8", "bNumberDpmSocketServices",
        desc="Number of Socket API Services at DPM level",
        editor="numedit", 
        editorParam={nBits=8, format="%u", minValue=1, maxValue=8}
    },
    {"UINT8", "bNumberSockets",
        desc="Number of sockets for Socket API usage",
        editor="numedit", 
        editorParam={nBits=8, format="%u", minValue=1, maxValue=64}
    },
    {"UINT8", "bReserved1",        desc="Reserved1",     mode = "hidden"},
    {"UINT8", "bReserved2",        desc="Reserved2",     mode = "hidden"},
},


----------------------------------------------------------------------------------------------
-- Socket API IP Multicast Group configuration

HIL_TAG_LWIP_AMOUNT_SOCKET_API_MULTICAST_GROUPS_DATA_T = {
    {"UINT32", "ulNumberIpMulticastsForSocketServices",
        desc="Number of IP Multicast groups for socket services",
        editor="numedit", 
        editorParam={nBits=32, format="%u", minValue=0, maxValue=65535}
    },
}, 

----------------------------------------------------------------------------------------------
-- Generic Diagnosis Ressources

HIL_TAG_NF_GEN_DIAG_RESOURCES_DATA_T = {
    {"UINT16", "usNumOfDiagnosisInstances",
        desc="Number of additional netPROXY Generic Diagnosis instances",
        editor="comboedit",
        editorParam={nBits= 16,
            values={
            {name="32", value=32},
            {name="40", value=40},
            {name="48", value=48},
            {name="56", value=56},
            {name="64", value=64},
            {name="72", value=72},
            {name="80", value=80},
            {name="88", value=88},
            {name="96", value=96},
            {name="104", value=104},
            {name="112", value=112},
            {name="120", value=120},
            {name="128", value=128},
            {name="136", value=136},
            {name="144", value=144},
            {name="152", value=152},
            {name="160", value=160},
            {name="168", value=168},
            {name="176", value=176},
            {name="184", value=184},
            {name="192", value=192},
            {name="200", value=200},
            {name="208", value=208},
            {name="216", value=216},
            {name="224", value=224},
            {name="232", value=232},
            {name="240", value=240},
            {name="248", value=248},
            {name="256", value=256}
        }},
    },
},


----------------------------------------------------------------------------------------------
-- PROFIenergy Support
HIL_TAG_NF_PROFI_ENERGY_MODES_DATA_T = {
    {"UINT8", "bPROFIenergyMode",
        desc="PROFIenergy support",
        editor="comboedit",
        editorParam={nBits= 8,
            values={
            {name="PROFIenergy disabled", value=0},
            {name="PROFIenergy enabled with 1 modes", value=1},
            {name="PROFIenergy enabled with 2 modes", value=2},
            {name="PROFIenergy enabled with 3 modes", value=3},
            {name="PROFIenergy enabled with 4 modes", value=4},
            {name="PROFIenergy enabled with 5 modes", value=5},
            {name="PROFIenergy enabled with 6 modes", value=6},
            {name="PROFIenergy enabled with 7 modes", value=7},
            {name="PROFIenergy enabled with 8 modes", value=8},
        }},
    },
    {"UINT8", "bReserved1",        desc="Reserved1",     mode = "hidden"},
    {"UINT8", "bReserved2",        desc="Reserved2",     mode = "hidden"},
    {"UINT8", "bReserved3",        desc="Reserved3",     mode = "hidden"},
},


----------------------------------------------------------------------------------------------
-- PROFINET IO-Link Profile Submodule padding

HIL_TAG_NF_PN_IOL_PROFILE_PADDING_DATA_T = {
    {"UINT8", "bProfilePaddingMode",
        desc="Padding Mode",
        editor="comboedit",
        editorParam={nBits= 8,
            values={
            {name="No padding",                    value=0},
            {name="Padding for 2 bytes alignment", value=1},
            {name="Padding for 4 bytes alignment", value=2},
        }},
    },
    {"UINT8", "bReserved1",        desc="Reserved1",     mode = "hidden"},
    {"UINT8", "bReserved2",        desc="Reserved2",     mode = "hidden"},
    {"UINT8", "bReserved3",        desc="Reserved3",     mode = "hidden"},
},

----------------------------------------------------------------------------------------------
-- PROFINET IO-Link Profile Pin4 DIO in IOLM Submodule

HIL_TAG_NF_PN_IOL_PROFILE_DIO_IN_IOLM_DATA_T = {
    {"UINT8", "bDioInIolm",
        desc="Location of Pin4 DIO Data",
        editor="comboedit",
        editorParam={nBits= 8,
            values={
            {name="Regular profile DI/DO submodules", value=0},
            {name="IOLM Submodule",                   value=1},
        }},
    },
    {"UINT8", "bReserved1",        desc="Reserved1",     mode = "hidden"},
    {"UINT8", "bReserved2",        desc="Reserved2",     mode = "hidden"},
    {"UINT8", "bReserved3",        desc="Reserved3",     mode = "hidden"},
},

----------------------------------------------------------------------------------------------
-- Swap COM0 and COM1 LEDs

HIL_TAG_NF_SWAP_COM_LEDS_DATA_T = {
    {"UINT8", "bSwapComLeds",
        desc="Swap COM LEDs",
        editor="checkboxedit",
        editorParam={nBits = 8, offValue = 0, onValue = 1, otherValues = true},
    },
    {"UINT8", "bReserved1",        desc="Reserved1",     mode = "hidden"},
    {"UINT8", "bReserved2",        desc="Reserved2",     mode = "hidden"},
    {"UINT8", "bReserved3",        desc="Reserved3",     mode = "hidden"},
},



----------------------------------------------------------------------------------------------
HIL_TAG_NF_PN_IOL_PROFILE_CFG_FLAGS_DATA_T = {
    {"UINT8", "bDioInIolm",   desc="Pin4 DIO data in IOLM Submodule", 
        editor="comboedit", editorParam={nBits=8, values={
                {name="Disabled",    value=0},
                {name="Enabled",     value=1},
    } } },
    {"UINT8", "bDisableDiag", desc="General mapping of IO-Link events into PROFINET diagnosis", 
        editor="comboedit", editorParam={nBits=8, values={
                {name="Enabled",      value=0},
                {name="Disabled",     value=1},
    } } },
    {"UINT8", "bDisablePA",   desc="General mapping of IO-Link events into PROFINET process alarms", 
        editor="comboedit", editorParam={nBits=8, values={
                {name="Enabled",      value=0},
                {name="Disabled",     value=1},
    } } },
    {"UINT8", "bReserved",    desc="Reserved", mode = "hidden" },
},


} -- end of structure defintions

---------------------------------------------------------------------------
-----------------------  Tag definitions  ---------------------------------
---------------------------------------------------------------------------


TAG_DEFS = {

-- protocol tags: Device ID
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

HIL_TAG_DEVICENET_CAN_SAMPLING =
    {paramtype = 0x30008001, datatype="HIL_TAG_DEVICENET_CAN_SAMPLING_DATA_T", desc="CAN Sample point"},
 
-- protocol tag: EIP EDD Config
TAG_EIP_EDD_CONFIGURATION =
    {paramtype = 0x3000a001, datatype="TAG_EIP_EDD_CONFIGURATION_DATA_T", desc="Ethernet/IP EDD Configuration"},

TAG_EIP_DLR_PROTOCOL =
    {paramtype = 0x3000a002, datatype="TAG_EIP_DLR_PROTOCOL_DATA_T",      desc="DLR Protocol"},
    
HIL_TAG_EIP_RESOURCES =
	{paramtype = 0x3000A004, datatype="HIL_TAG_EIP_RESOURCES_DATA_T",       desc="EtherNet/IP Resource Dimensions"},

HIL_TAG_EIP_TIMESYNC_ENABLE_DISABLE =
	{paramtype = 0x3000A005, datatype="HIL_TAG_EIP_TIMESYNC_ENABLE_DISABLE_DATA_T", desc="CIP Sync support"},

HIL_TAG_EIP_FILE_OBJECT_ENABLE_DISABLE =
	{paramtype = 0x3000A006, datatype="HIL_TAG_EIP_FILE_OBJECT_ENABLE_DISABLE_DATA_T", desc="CIP File Object Support"},

-- protocol tags: EtherCAT Slave
TAG_ECS_ENABLE_BOOTSTRAP =
	{paramtype = 0x30009001, datatype="TAG_ECS_ENABLE_BOOTSTRAP_DATA_T", desc="EtherCAT Slave Enable Bootstrap Mode"},
TAG_ECS_SELECT_SOE_COE =
	{paramtype = 0x30009002, datatype="TAG_ECS_SELECT_SOE_COE_DATA_T",    desc="EtherCAT Slave Stack Variant"},
TAG_ECS_CONFIG_EOE =
	{paramtype = 0x30009003, datatype="TAG_ECS_CONFIG_EOE_DATA_T",        desc="EtherCAT Slave EoE Mode"},
TAG_ECS_MBX_SIZE =
	{paramtype = 0x30009004, datatype="TAG_ECS_MBX_SIZE_DATA_T",          desc="EtherCAT Slave Mailbox Size"},
TAG_ECM_ENI_BUS_STATE =
	{paramtype = 0x30009005, datatype="TAG_ECM_ENI_BUS_STATE_DATA_T",     desc="EtherCAT Master bus state for ENI"},
HIL_TAG_ECS_EOE_MODE =
	{paramtype = 0x30009006, datatype="HIL_TAG_ECS_EOE_MODE_DATA_T",      desc="EtherCAT Slave EoE Mode"},
	
TAG_PROFINET_FEATURES = 
	{paramtype = 0x30015001, datatype="TAG_PROFINET_FEATURES_DATA_T",                    desc="Profinet Features"},
TAG_PROFINET_FEATURES_V2 = 
	{paramtype = 0x30015002, datatype="TAG_PROFINET_FEATURES_V2_DATA_T",                 desc="Profinet Features V2"},
TAG_PROFINET_SYSTEM_REDUNDANCY_FEATURES = 
	{paramtype = 0x30015003, datatype="TAG_PROFINET_SYSTEM_REDUNDANCY_FEATURES_DATA_T",  desc="Profinet SystemRedundancy"},
TAG_PROFINET_CONTROLLER_QUANTITIES = 
	{paramtype = 0x30015004, datatype="TAG_PROFINET_CONTROLLER_QUANTITIES_DATA_T",  desc="Profinet Controller Settings"},
	
TAG_TCP_PORT_NUMBERS =
	{paramtype = 0x30019000, datatype="TAG_TCP_PORT_NUMBERS_DATA_T",      desc="Ethernet Interface TCP Port Numbers"},
	
	

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
RCX_TAG_EIF_NDIS_ENABLE =
	{paramtype = 0x105D0002, datatype="RCX_TAG_EIF_NDIS_ENABLE_DATA_T",  desc="Ethernet NDIS Support"},

-- facility tag: servX web server
HIL_TAG_HTTP_PORT_CONFIG =
	{paramtype = 0x10920000, datatype="HIL_TAG_HTTP_PORT_CONFIG_DATA_T", desc="Web Server (HTTP) Configuration"},

HIL_TAG_HTTPS_PORT_CONFIG =
	{paramtype = 0x10920001, datatype="HIL_TAG_HTTPS_PORT_CONFIG_DATA_T", desc="Web Server (HTTPS) Configuration"},

HIL_TAG_NF_GEN_DIAG_RESOURCES =
	{paramtype = 0x10e00001, datatype="HIL_TAG_NF_GEN_DIAG_RESOURCES_DATA_T", desc="Generic Diagnosis Ressources"},

HIL_TAG_NF_PROFI_ENERGY_MODES =
	{paramtype = 0x10e00002, datatype="HIL_TAG_NF_PROFI_ENERGY_MODES_DATA_T", desc="PROFIenergy Support"},

HIL_TAG_NF_PN_IOL_PROFILE_PADDING =
	{paramtype = 0x10e00003, datatype="HIL_TAG_NF_PN_IOL_PROFILE_PADDING_DATA_T", desc="PROFINET IO-Link Profile Submodule Padding"},

HIL_TAG_NF_PN_IOL_PROFILE_DIO_IN_IOLM =
	{paramtype = 0x10e00004, datatype="HIL_TAG_NF_PN_IOL_PROFILE_DIO_IN_IOLM_DATA_T", desc="PROFINET IO-Link Profile Pin4 DIO in IOLM Submodule"},

HIL_TAG_NF_SWAP_COM_LEDS =
	{paramtype = 0x10e00005, datatype="HIL_TAG_NF_SWAP_COM_LEDS_DATA_T", desc="Swap COM LEDs"},

HIL_TAG_NF_PN_IOL_PROFILE_CFG_FLAGS = 
	{paramtype = 0x10e00006, datatype="HIL_TAG_NF_PN_IOL_PROFILE_CFG_FLAGS_DATA_T", desc="netFIELD PROFINET IO-Link Profile Configuration Flags"},


HIL_TAG_LWIP_PORTS_FOR_IP_ZERO = 
	{paramtype = 0x10e90000, datatype="HIL_TAG_LWIP_PORTS_FOR_IP_ZERO_DATA_T", desc="LWIP Ports for IP 0.0.0.0"},
    -- todo: Tag ID anpassen
HIL_TAG_LWIP_NETIDENT_BEHAVIOUR = 
	{paramtype = 0x10e90001, datatype="HIL_TAG_LWIP_NETIDENT_BEHAVIOUR_DATA_T", desc="LWIP netident behaviour"},
HIL_TAG_LWIP_QUANTITY_STRUCTURE = 
	{paramtype = 0x10e90002, datatype="HIL_TAG_LWIP_QUANTITY_STRUCTURE_DATA_T", desc="Socket API Quantity Structure"},
HIL_TAG_LWIP_AMOUNT_SOCKET_API_MULTICAST_GROUPS = 
	{paramtype = 0x10e90003, datatype="HIL_TAG_LWIP_AMOUNT_SOCKET_API_MULTICAST_GROUPS_DATA_T", desc="Socket API IP Multicast Group configuration"},

}



---------------------------------------------------------------------------
---------------------------   Help    -------------------------------------
---------------------------------------------------------------------------


TAG_HELP = {

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

    HIL_TAG_DEVICENET_CAN_SAMPLING      = {file="HIL_TAG_DEVICENET_CAN_SAMPLING_DATA_T.htm"},
    
    TAG_EIP_EDD_CONFIGURATION           = {file="TAG_EIP_EDD_CONFIGURATION_DATA_T.htm"},
    TAG_EIP_DLR_PROTOCOL                = {file="TAG_EIP_DLR_PROTOCOL.htm"},
    HIL_TAG_EIP_RESOURCES               = {file="HIL_TAG_EIP_RESOURCES_DATA_T.htm"},
    HIL_TAG_EIP_TIMESYNC_ENABLE_DISABLE = {file="HIL_TAG_EIP_TIMESYNC_ENABLE_DISABLE_DATA_T.htm"},
    HIL_TAG_EIP_FILE_OBJECT_ENABLE_DISABLE = {file="HIL_TAG_EIP_FILE_OBJECT_ENABLE_DISABLE_DATA_T.htm"},
    
    TAG_ECS_ENABLE_BOOTSTRAP            = {file="TAG_ECS_ENABLE_BOOTSTRAP_DATA_T.htm"},
    TAG_ECS_SELECT_SOE_COE              = {file="TAG_ECS_SELECT_SOE_COE_DATA_T.htm"},
    TAG_ECS_CONFIG_EOE                  = {file="TAG_ECS_CONFIG_EOE_DATA_T.htm"},
    TAG_ECS_MBX_SIZE                    = {file="TAG_ECS_MBX_SIZE_DATA_T.htm"},
    TAG_ECM_ENI_BUS_STATE               = {file="TAG_ECM_ENI_BUS_STATE_DATA_T.htm"},
    HIL_TAG_ECS_EOE_MODE                = {file="HIL_TAG_ECS_EOE_MODE_DATA_T.htm"},

    TAG_TCP_PORT_NUMBERS                = {file="TAG_TCP_PORT_NUMBERS_DATA_T.htm"},

    TAG_PROFINET_FEATURES                     = {file="TAG_PROFINET_FEATURES_DATA_T.htm"},
    TAG_PROFINET_FEATURES_V2                  = {file="TAG_PROFINET_FEATURES_V2_DATA_T.htm"},
    TAG_PROFINET_SYSTEM_REDUNDANCY_FEATURES   = {file="TAG_PROFINET_SYSTEM_REDUNDANCY_FEATURES_DATA_T.htm"},
    TAG_PROFINET_CONTROLLER_QUANTITIES    = {file="TAG_PROFINET_CONTROLLER_QUANTITIES_DATA_T.htm"},

    TAG_DIAG_IF_CTRL_UART               = {file="TAG_DIAG_CTRL_DATA_T.htm"},
    TAG_DIAG_IF_CTRL_USB                = {file="TAG_DIAG_CTRL_DATA_T.htm"},
    TAG_DIAG_IF_CTRL_TCP                = {file="TAG_DIAG_CTRL_DATA_T.htm"},
    TAG_DIAG_TRANSPORT_CTRL_CIFX        = {file="TAG_DIAG_CTRL_DATA_T.htm"},
    TAG_DIAG_TRANSPORT_CTRL_PACKET      = {file="TAG_DIAG_CTRL_DATA_T.htm"},

    RCX_TAG_ETHERNET_PARAMS                     = {file="RCX_TAG_ETHERNET_PARAMS_T.htm"},
    RCX_TAG_FIBER_OPTIC_IF_DMI_NETX50_PARAMS    = {file="RCX_TAG_FIBER_OPTIC_IF_DMI_NETX50_PARAMS_T.htm"},
    RCX_TAG_FIBER_OPTIC_IF_DMI_NETX100_PARAMS   = {file="RCX_TAG_FIBER_OPTIC_IF_DMI_NETX100_PARAMS_T.htm"},

    RCX_TAG_EIF_EDD_CONFIG              = {file="RCX_TAG_EIF_EDD_CONFIG_DATA_T.htm"},
    RCX_TAG_EIF_EDD_INSTANCE            = {file="RCX_TAG_EIF_EDD_INSTANCE_DATA_T.htm"},
    RCX_TAG_EIF_NDIS_ENABLE             = {file="RCX_TAG_EIF_NDIS_ENABLE_DATA_T.htm"},

    HIL_TAG_HTTP_PORT_CONFIG            = {file="HIL_TAG_HTTP_PORT_CONFIG_DATA_T.htm"},
    HIL_TAG_HTTPS_PORT_CONFIG           = {file="HIL_TAG_HTTPS_PORT_CONFIG_DATA_T.htm"},

    HIL_TAG_NF_GEN_DIAG_RESOURCES       = {file="HIL_TAG_NF_GEN_DIAG_RESOURCES_DATA_T.htm"},
    HIL_TAG_NF_PROFI_ENERGY_MODES       = {file="HIL_TAG_NF_PROFI_ENERGY_MODES_DATA_T.htm"},
    HIL_TAG_NF_PN_IOL_PROFILE_PADDING   = {file="HIL_TAG_NF_PN_IOL_PROFILE_PADDING_DATA_T.htm"},
    HIL_TAG_NF_PN_IOL_PROFILE_DIO_IN_IOLM   = {file="HIL_TAG_NF_PN_IOL_PROFILE_DIO_IN_IOLM_DATA_T.htm"},
    HIL_TAG_NF_SWAP_COM_LEDS            = {file="HIL_TAG_NF_SWAP_COM_LEDS_DATA_T.htm"},
    HIL_TAG_NF_PN_IOL_PROFILE_CFG_FLAGS = {file="HIL_TAG_NF_PN_IOL_PROFILE_CFG_FLAGS_DATA_T.htm"},

    HIL_TAG_LWIP_PORTS_FOR_IP_ZERO      = {file="HIL_TAG_LWIP_PORTS_FOR_IP_ZERO_DATA_T.htm"},
    HIL_TAG_LWIP_NETIDENT_BEHAVIOUR     = {file="HIL_TAG_LWIP_NETIDENT_BEHAVIOUR_DATA_T.htm"},
    HIL_TAG_LWIP_QUANTITY_STRUCTURE     = {file="HIL_TAG_LWIP_QUANTITY_STRUCTURE_DATA_T.htm"},
    HIL_TAG_LWIP_AMOUNT_SOCKET_API_MULTICAST_GROUPS = 
                                          {file="HIL_TAG_LWIP_AMOUNT_SOCKET_API_MULTICAST_GROUPS_DATA_T.htm"},

}



taglist.addConstants(DEVHDR_CONSTANTS)
taglist.addConstants(TAG_CONSTANTS)
taglist.addDataTypes(TAG_STRUCTS)
taglist.addTags(TAG_DEFS)
taglist.addTagHelpPages(TAG_HELP)