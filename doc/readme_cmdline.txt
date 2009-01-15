
Using the makenxo.bat script
=============================

makenxo.bat creates an rcX loadable module in NXO format from a firmware
stack in ELF format.

Usage:
   makenxo -o OUTPUT -h HEADER [-t TAG LIST FILE] [-v] ELFFILE

Arguments:
   -o OUTPUT   Write output NO to OUTPUT
   -H HEADER   Load headers from binary file HEADER. The file must contain
                 a common header V3, usually followed by a device info block
                 and a module info block.
   -t TAGLIST  Use binary file TAGLIST as default tag list. If no tag list
                 is specified, an empty tag list is generated.
   -v          Verbose operation
   -h          This help text.

Assuming that the firmware build process generates the following files:

   - Fileheader.bin (HIL_FILE_STRIPPEDFIRMWARE_HEADER)
   - Firmware.elf
   - DefaultTagList.bin

the following command line will generate the nxo file:
c:\> makenxo -o Firmware.nxo -h Fileheader.bin -t DefaultTagList.bin Firmware.elf

or, from another batch file:
call makenxo.bat -o Firmware.nxo -h Fileheader.bin -t DefaultTagList.bin Firmware.elf
