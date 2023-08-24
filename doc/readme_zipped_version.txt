
Using the zip file version 
===========================

Note: the zip file version is not 100% portable since the tag list editor will 
create a config file on the system.

Running the tag list editor
---------------------------

The current directory must be the one containing serverkuh.exe.

Example:
>cd C:\Users\username\Downloads\tag_list_editor_1.5.0.3\application

>C:   (if the current drive is different)

>serverkuh.exe -c Modulator.cfg -i 0 file:../nxo_editor/test_description.xml --


Running the tagtool
-------------------

The environment variable PATH_NXOEDITOR must point to the directory the zip file has been unpacked to.
When the installer is used, this variable is set to the install directory by default.
When the portable version is used, the variable must be set manually.

Example:
>set PATH_NXOEDITOR=C:\Users\username\Desktop\dev\tle\taglist_editor\targets\tag_list_editor_v1.5.0.4-dev1-0-gd0fc06673ebc

>"%PATH_NXOEDITOR%\nxo_editor\tagtool.bat" diff original.nxi edited.nxi >patch.txt

