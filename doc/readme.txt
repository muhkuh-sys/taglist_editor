NXO Editor - an NXO build tool and tag list editor.
==================================================

NXO Editor allows you to construct an option module (.nxo) file,
and to edit the tag list in an NXO, NXF, NXD, NXL or NXB file.

(c) Hilscher GmbH 2009.
Please send feedback, questions and bug reports to SLesch@hilscher.com



Screen layout:
================

 -------------------------------------
|      |  Editing   |                 |
| Tag  |  area for  |  Help for       |
| List |  selected  |  selected tag   |
|      |   Tag      |                 |
 -------------------|                 |
|                   |                 |
|   Load/Save       |                 |
|                   |                 |
 -------------------------------------
 Quit   (x) show help
 
 
 
Building an NXO file using the editor:
=======================================

The standard layout of an NXO file according to "netX File Header Structure V3.0"
consists of the following three parts:

- a binary file containing the following headers:
  common header v3
  device info block
  module info block
- an ELF file containing the firmware (no headers or tag list)
- a binary file containing the tag list

You can load these components into the editor and save them as an NXO,
or use the command line script 'makenxo.bat'




Editing tag lists:
==================

- Load a binary tag list file or an NX* file.

- The list of tags contained in the file is shown on the left hand side. 
  Click on the tag names to view or edit their contents. On the right 
  hand side, an explanation of the currently selected tag is shown.

  There may be several tags of the same type (e.g. task groups). In
  this case, the tags have different name strings which show up in the 
  "Identifier" field.

  If you change task priority or task token settings, always set both to 
  the same value.

- Save the tag list or the NX* file.




Notes on file structure:
==========================

The default layout of an NX* file is as follows:

Common Header V3
fields:
0                  +-------------------------+
                   |                         |
                   |        headers          |
                   |                         |
ulHeaderLength     +-------------------------+
                   |                         |
ulDataOffset       +-------------------------+
                   |                         |
                   |  Data/Executable/ELF    |
                   |                         |
ulDataOffset       +-------------------------+
  +ulDataSize      |                         |
ulTagListOffset    +-------------------------+
                   |                         |
                   |       Tag List          |
                   |                         |
ulTagListOffset    +-------------------------+
  + ulTagListSize  |                         |
end of file        +-------------------------+


The gaps following the header, data and tag list are usually 
0-3 alignment bytes. An NXO file built from these parts using 
the editor will have this layout. 

The common header v3, however, allows a more flexible structure:
- The tag list portion may be placed before the data/ELF
- The gap areas may contain additional data.
- There may be extra data between the end mark of the tag list and its
  ending as indicated by ulTagListSize.

When loading an NX* file, three variants of the layout are recognized:
header - data/ELF - tag list
header - tag list - data/ELF
header - data/ELF
  
The editor will preserve the gap data if you open an NXO/NXF file and
only edit its tag list. If you load a header/elf/tag list from a file, the gap
data following this section is replaced by 0-3 alignment bytes.

If the tag list is located in front of the data AND ulTagListMaxSize is
different from 0, the tag list is padded to the maximum size.

When a header or tag list binary is loaded, 
ulTagListSizeMax is set to max(ulTagListSizeMax, size of tag list)


Consistency checks when loading an NX* file:
=============================================

The file will be rejected if:
- the common header version is below 3
- any of the offsets and sizes is outside of the file, or any of the 
  sections overlap
- the tag list can't be parsed
- the tag list does not contain the end marker


The editor will open a file and display a warning if:
- the file type as indicated by the magic cookie at the start of the file 
  is not a known type (NXF/NXO/NXD/NXL/NXB)
- any of the checksums in the boot header/common header are incorrect
- the common header version is above 3
- the tag list contains extraneous data between the end marker and
  ulTagListSize


  
  
A note on priority/token base and range:
========================================

The base and range values have to fulfill the following condition:
base + range -  1 <= max. value
For instance, if the task priority range is 2, the base priority must 
be set to a value less than 55, since 55 is the highest value.
The current tag list editor does not enforce this condition.
