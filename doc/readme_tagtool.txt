
Tagtool is a command line tool with three functionalities:
1) Print the contents of the tag list in an NXF or NXO file
2) Replace the tag list in an NXF or NXO file with another one which
   is provided as a binary file
3) Modify the tag list in an NXF or NXO file according to instructions
   which are read from a text file.

tagtool prints or manipulates the tag list in an NXF or NXO file

Usage: 
   tagtool settags    [-v|-debug] infile taglistfile outfile
   tagtool edit       [-v|-debug] infile editsfile outfile
   tagtool list       [-v|-debug] infile 
   tagtool diff       [-v|-debug] infile1 infile2 
   tagtool [help|-h]
   tagtool help_tags
   tagtool help_const
   tagtool -version

Modes:
   settags     Replaces the tag list
   edit        Changes values in the tag list or device header
   list        Prints the tags list and the device header
   diff        Extract changes between infile1 and infile2
   help        Prints this help text
   help_tags   Prints a list of the known tags
   help_const  Prints a list of the known value constants
   -version    Prints version information
   
Flags:
   -v          enable verbose output
   -debug      enable debug output    
   
Arguments:
   infile      The NXF/NXO file to load
   editsfile   Text file containing editing instructions
   taglistfile The new tag list in binary format
   outfile     The NXF/NXO file to write
   
Help
======
help, -h, /? prints the above usage information.
help_tags prints a list of the tags known to the tool.
help_const prints a list of the value constants known to the tool.   
   
list
=========
Prints the tag list and the device header of an NXF/NXO file. 
For the tags whose structure is known to the program, the contents are
listed. For all other tags, only the 32 bit identifier number is listed.
Currently, only device header version 1.0 is supported.

diff
=======
Compares their tag lists and device headers of two NXF/NXO files and 
prints any differences.
The two tag lists must contain the same tags in the same order. 
For any tags whose values differ, the tag from the second file is
printed as an edit record which can be used as input for the "edit" function.

Example: both files contain an xC number tag, in both files the identifier
is "RTE_XC0" and in file 2, ulXcId is 2:

Tag 14: RCX_MOD_TAG_IT_XC (0x00001050)
    .szIdentifier = RTE_XC0
SET .ulXcId       = 0x00000002

This allows you to edit a tag list using the GUI based editor, save
to a different file, extract the changes and later apply the changes to
another file.

settags
=========
Replaces the tag list in the input file with the contents of the taglist file
and writes the result to the output file.

edit
=========
Edits the tag list in the input file according to the instructions in
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
- one tag name
  TAG_NAME
  or, optionally:
  Tag <ignored until colon>: TAG_NAME <The rest of the line is ignored>
- any number of additional constraints on member values
  .member_name = value  
  ENABLED or DISABLED to check whether the tag is enabled or disabled
- any number of SET instructions to set member values
  SET .member_name = value
  SET ENABLED or SET DISABLED to set the tag to enabled or disabled

String values may be written with or without double quotes.
Numeric values may be written in decimal or hexadecimal notation.
Empty lines are ignored, and everything following a # until the end of the 
line is ignored.
  
Example:
Tag 15: RCX_MOD_TAG_IT_XC (0x00001050)
.szIdentifier = "RTE_XC1"
DISABLED
SET .ulXcId = 2                   
SET ENABLED

This selects a tag with type RCX_MOD_TAG_IT_XC which has the identifier string 
"RTE_XC1" and is currently disabled. If the tag list contains exactly one 
tag which matches this description, it is enabled and its ulXcId field is set 
to 2.


The device header is selected as follows:
DEVICE_HEADER_V1_T


How to generate the editing instructions file
===============================================
Method 1) 
Edit an NXO/NXF file using the GUI-based editor, save the result to 
another file and use the "diff" function to extract the changes.

Method 2) 
The output of the "list" function can be parsed by the "edit" function.
Redirect the output to a text file, edit the file and put "SET " at the
beginning of every line which contains a value you want to be changed. 

Method 3) 
Write it manually according to the format described above.



NOTES:
==========
1)
Some tags contain nested structures. To match or set nested values, 
the whole path from the root of the structure must be given:

Tag 2: TAG_BSL_HIF_PARAMS (0x40000001)
.ulBusType = 0x00000000
.tDpmIsaAuto.ulIfConf0    = 0x00000000
.tDpmIsaAuto.ulIfConf1    = 0x00000000
.tDpmIsaAuto.ulIoRegMode0 = 0x00000001
.tDpmIsaAuto.ulIoRegMode1 = 0x00000002
.tPci.bEnablePin  = 0x01
.tPci.bPinType    = 0x01
.tPci.bInvert     = 0x80
.tPci.usPinNumber = 0x000f

2)
The output of "list" is an internal representation. 
Some tags contain two values in the same structure entry (e.g. a byte).
These values appear as two separate entries in the output,
and must be set separately in the editing file.

This is currently the case with the following tags:
TAG_BSL_HIF_PARAMS_DATA_T
TAG_BSL_SDMMC_PARAMS_DATA_T
TAG_BSL_USB_PARAMS_DATA_T
TAG_BSL_FSU_PARAMS_DATA_T

For instance, in
Tag 5: TAG_BSL_USB_PARAMS (0x40000004)
.bEnable        = 0x01
.bPullupPinType = 0x01
.bInvert        = 0x80
.usPullupPinIdx = 0x0001

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
tag structure definitions. If you have made any changes of your own, 
check them. If you have not made any such changes, contact netX support.
