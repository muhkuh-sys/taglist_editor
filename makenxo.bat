@echo off
rem $Date$
rem $Revision$
rem $Author$

REM Build an nxo file. 
REM Usage:
REM makenxo -H headers.bin [-t taglist.bin] -o out.nxm in.elf

REM PATH_NXOEDITOR contains the install directory, e.g.
REM C:\Programme\Hilscher GmbH\NXO_Editor

REM path to lua.exe and the Lua/wxWidgets/wxLua DLLs
set WXLUA_BIN=%PATH_NXOEDITOR%\application

REM path to the scripts
set LUA_DIR=%PATH_NXOEDITOR%\nxo_editor

REM Lua's search path
set LUA_PATH=%LUA_DIR%\?.lua;%PATH_NXOEDITOR%\application\lua\?.lua;%PATH_NXOEDITOR%\application\lua_hilscher\?.lua

REM call wxlua with the command args supplied; works only on win NT 4 and above
"%WXLUA_BIN%\lua.exe" "%LUA_DIR%\nxomaker.wx.lua" %*

