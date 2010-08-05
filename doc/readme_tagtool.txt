
Tagtool is a command line tool with three functionalities:
1) Print the contents of the tag list in an NXF or NXO file
2) Replace the tag list in an NXF or NXO file with another one which
   is provided as a binary file
3) Modify the tag list in an NXF or NXO file according to instructions
   which are read from a text file.

tagtool prints or manipulates the tag list in an NXF or NXO file.

Usage: 
   tagtool [help|-h]
   tagtool help_tags
   tagtool help_const
   tagtool -version
   tagtool settags [-v|-debug]  infile taglistfile outfile
   tagtool edittags [-v|-debug] infile editsfile outfile
   tagtool listtags [-v|-debug] infile 

Modes:
   settags:    Replaces the tag list
   edittags:   Assigns values to specific fields of the tag list
   listtags:   Prints a listing of the tags contained in the file
   help:       Prints this help text
   help_tags:  Prints a list of the known tags
   help_const: Prints a list of the known value constants

Flags:
   -v             enable verbose output
   -debug         enable debug output    
   
Arguments:
   infile         The NXF/NXO file to load
   editsfile      Text file containing editing instructions
   taglistfile    The new tag list in binary format
   outfile        The NXF/NXO file to write


Help
======
help, -h, /? prints the above usage information.
help_tags prints a list of the tags known to the tool.
help_const prints a list of the value constants known to the tool.   
   
listtags
=========
Prints the contents of the tag list in an NXF/NXO file. 
For the tags whose structure is known to the program, the contents are
listed. For all other tags, only the 32 bit identifier number is listed.

settags
=========
Replaces the tag list in the input file with the contents of the taglist file
and writes the result to the output file.

edittags
=========
Edits the tag list in the input file according to the instaructions in
the editsfile and writes the result to the output file.

Format of the editing instructions file:
===========================================

The file consists of one or several "edit records". 
Each record starts with a line which specifies a tag type or the device
header. The following lines can further restrict the selection and set
values in the selected tag.
The edit record is matched against all tags in the file's tag list, and the 
device header. If exactly one data structure matches the edit record, the 
value changes are performed.

The general form of an edit record is:
- one Tag specification
  Tag <ignore until colon>: TAG_NAME <The rest of the line is ignored>
- any number of additional constraints on member values
  .member_name = value
- any number of SET instructions to set member values
  SET .member_name = value

Values, especially identifier strings, may be written with or without double 
quotes.
Empty lines are ignored, and everything following a # until the end of the 
line is ignored.
  
Example:
Tag 15: RCX_MOD_TAG_IT_XC (0x00001050)
.szIdentifier = "RTE_XC1"             
SET .ulXcId = 2                   

This selects a tag with type RCX_MOD_TAG_IT_XC and the identifier string 
"RTE_XC1". If the tag list contains exactly one tag which matches this 
description, its ulXcId field is set to 2.

The device header is selected using the pseudo tag DEVICE_HEADER_V1_T
Tag : DEVICE_HEADER_V1_T
.ulStructVersion = 0x00010000 # check the structure version
SET .usDeviceClass = 123


NOTES:
==========
1)
The output of listtags is compatible with the input for edittags.
You may redirect this output to a file and edit values in this file, 
adding the "SET" command at the start of each line you change.
The file can then be used as an editing file to make changes to a 
tag list with the same structure.


2)
Some tags contain nested structures. To match or set nested values, 
the whole path from the root of the structure must be given:

Tag 2: TAG_BSL_HIF_PARAMS (0x40000001)
.ulBusType = 0x00000000
.tDpmIsaAuto.ulIfConf0 = 0x00000000
.tDpmIsaAuto.ulIfConf1 = 0x00000000
.tDpmIsaAuto.ulIoRegMode0 = 0x00000000
.tDpmIsaAuto.ulIoRegMode1 = 0x00000000
.tPci.bEnablePin = 0x00
.tPci.bPinType = 0x00
.tPci.bInvert = 0x00
.tPci.usPinNumber = 0x0000

3)
The output of listtags is an internal representation. 
Some tags contain two values in the same structure entry (e.g. a byte).
These values appear as two separate entries in the listtags output,
ans must be set separately in the input to edittags.

This is currently the case with the following tags:
TAG_BSL_HIF_PARAMS_DATA_T
TAG_BSL_SDMMC_PARAMS_DATA_T
TAG_BSL_USB_PARAMS_DATA_T
TAG_BSL_FSU_PARAMS_DATA_T

For instance, in
Tag 5: TAG_BSL_USB_PARAMS (0x40000004)
    .bEnable = 0x00000000
    .bPullupPinType = 0x00000000
    .bInvert = 0x00000000
    .usPullupPinIdx = 0x00000000

bPullupPinType and bInvert are derived from one byte in the binary data,
bPullupPinType from bits 0-6 (value range 0x00-0x7f) and 
bInvert from bit 7 (value is either 0x00 or 0x80).


Error messages related to the edits file
========================================
parse error
  The format of a line could not be recognized
  
parse error (no tag specified)
  The file must start with a line which selects a tag.
  
unknown type name <type name>
  You have misspelt the tag name, or the program does not know this tag

type <type name> has no member <member name>
  The type is known, but the type does not have a member with the given name

tried to get member of primitive type <type name>
  The path specified in a value condition or assignment is too deeply nested.  
  
Failed to parse value in match/assignment: type=<type name>  value=<value>
  The value does not have the correct type or cannot be parsed.
  If you specified a value constant, it may be spelt incorrectly.
    
edit record matches no tag
  The tag list contains no tag which has the correct type and satisfies
  the conditions specified in the edit record.

edit record matches multiple tags
  There is more than one tag which has the correct type and satisfies
  the conditions specified in the edit record.

Error while deserializing device header

  
Device header has the wrong version: <32 bit version number>
  The program knows only version 1.0
  
device header does not match
  An edit record for the device header does not match   

The file does not contain a tag list


Internal errors:
Any error messages starting with "BUG" indicate bugs in the program or the
tag structure definitions. If you have made any changes of your own, check them.
If you have not made any such changes, contact netX support.
  