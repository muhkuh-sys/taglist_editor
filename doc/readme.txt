NXO Editor - an NXO build tool and tag list editor.
==================================================

NXO Editor allows you to construct and manipulate option module (.nxo) files
and to edit the tag list included in the nxo file.

(c) Hilscher GmbH 2009.
Please send feedback, questions and bug reports to SLesch@hilscher.com



Screen layout:
================

---------------------------------------
|      |  Editing   |                 |
| Tag  |  area for  |  Help for       |
| List |  selected  |  selected tag   |
|      |   Tag      |                 |
--------------------|                 |
|                   |                 |
|   Load/Save       |                 |
|                   |                 |
---------------------------------------
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



Editing the tag list
====================
- Load a binary tag list file or an NXO file.

- The list of tags contained in the file is shown on the left hand side. 
  Click on the tag names to view or edit their contents. On the right 
  hand side, an explanation of the currently selected tag is shown.

  There may be several tags of the same type (e.g. task groups). In
  this case, the tags have different name strings which show up in the 
  "Identifier" field.

  If you change task priority or task token settings, always set both to 
  the same value.

- Save the tag list or the NXO file.



Limitations:
===============
The editor can only handle NXO files, not NXF files.

The editor can only write NXO files with the default layout, which is 
headers - ELF - tag list. Since the common header V3 contains offset and length
information for both the ELF file and the tag list, an NXO file can be constructed 
which contains additional data, or the tag list before the ELF file. 
The editor will read such files, but silently discard the additional data, 
and write them back in the default layout when saving.

A note on priority/token base and range:
========================================
The base and range values have to fulfill the following condition:
base + range -  1 <= max. value
For instance, if the task priority range is 2, the base priority must 
be set to a value less than 55, since 55 is the highest value.
The current tag list editor does not enforce this condition.
