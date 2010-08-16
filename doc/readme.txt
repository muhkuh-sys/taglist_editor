netX Tag list Editor - a tag list editor and NXO build tool
============================================================

This tool has three purposes:
- Editing the configuration tag lists used in rcX loadable modules (.nxo),
  firmware files (.nxf) and the 2nd stage loader (.bin).
- Editing the device header 
- You can construct a option module file from its basic components.


(c) Hilscher GmbH 2010.



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
 Quit   (x) show help  Clear  Edit device header
 
 
 
Building an NXO file using the editor:
=======================================

The standard layout of an NXO file according to "netX File Header Structure 
V3.0" consists of the following three parts:

- a binary file containing the following headers:
  common header v3
  device info block
  module info block
- an ELF file containing the firmware (no headers or tag list)
- a binary file containing the tag list

1) Click the "Clear" button to reset the editor to the initial state.
2) Load the header binary, ELF file and tag list.
3) Edit the tag list if desired.
4) Save as an NXO file.

You can load these components into the editor and save them as an NXO,
Alternatively, you can use the command line script 'makenxo.bat'.




Editing tag lists:
==================

- Load a binary tag list file or an NXF/NXO/2nd stage loader file.

- The list of tags contained in the file is shown on the left hand side. 
  Click on the tag names to view or edit their contents. On the right 
  hand side, an explanation of the currently selected tag is shown.

  There may be several tags of the same type (e.g. task groups). In
  this case, the tags have different name strings which show up in the 
  "Identifier" field.

  If you change task priority or task token settings, always set both to 
  the same value.

- Save the tag list or the NXF/NXO/2nd stage loader file.




Notes on file structure:
==========================

The layout of an NXF/NXO/2nd stage loader file is as follows:

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


The common header v3, however, allows a more flexible structure:
- The tag list portion may be placed before the data/ELF
- The gap areas may contain additional data.
- There may be extra data between the end mark of the tag list and its
  ending as indicated by ulTagListSize.

Three variants of the layout are recognized:
1) header - data/ELF - tag list
2) header - data/ELF
3) header - tag list - data/ELF (used only by the 2nd stage loader)
An NXO file built in the editor will have layout 1) or 2).

The gaps following the header, data and tag list are usually 
0-3 alignment bytes, but may contain additional data.
The editor will preserve the gap data, as long as you only edit the tag list.
If you load another tag list, the gap data is adjusted to fit the new size.



Consistency checks when loading an NX* file:
=============================================

The file will be rejected if:
- the file type as indicated by the magic cookie at the start of the file 
  is not a known type (NXF/NXO/NXD/NXL/NXB),
- the common header version is below 3,
- any offset or size entry in the common header exceeds the file size, 
  or any of the sections overlap,
- the tag list can't be parsed,
- the length of a tag value does not match the editor's structure definition,
- the tag list contains additional data behind the end marker.

The editor will accept the file and display a warning if:
- any of the checksums in the boot header/common header are incorrect,
- the common header version is higher than 3.0,

The end of a tag list is normally marked with the end tag (0) and length 0,
that is, eight zero bytes. If 
- the tag list contains an end tag (0) without length indication or
- the tag list does not have an end marker (ends directly after a tag)
the editor will display a warning, and, if the memory layout of the file
(TagListSizeMax) allows it, offer to correct the end marker.


  
A note on priority/token base and range:
========================================

The base and range values have to fulfill the following condition:
base + range - 1 <= max. value
For instance, if the task priority range is 2, the base priority must 
be set to a value less than 55, since 55 is the highest value.
The current tag list editor does not enforce this condition.



Loading a new Tag list into an opened NXF/NXO file
====================================================

When a new tag list is loaded and the common header field ulTagListSizeMax is >0,
the new tag list is only accepted if its size fits into ulTagListSizeMax. Also, 
if the tag list is located before the data section (as in a 2nd Stage Loader),
it is only accepted if the size fits into the range defined by 
ulDataStartOffset - ulTagListStartOffset.

If the tag list is located at the end of the NXF/NXO file, the gap data 
following the tag list will be replaced by 0-3 alignment bytes.
If the tag list is located before the data section, the gap data will be
grown or shrunk to fit the size of the new tag list.



Editing the device header
==========================

Whenever a file containing a device header is loaded, the "Edit Device Header"
button opens an editor which allows you to view the header and change some of 
its fields. You can also save the header as a binary file or load it from a 
file.

