@echo off
rem $Date$
rem $Revision$
rem $Author$

REM PATH_NXOEDITOR points to the install directory, e.g.
REM C:\Programme\Hilscher GmbH\NXO_Editor

REM path to lua.exe and the Lua/wxWidgets/wxLua DLLs
set WXLUA_BIN=%PATH_NXOEDITOR%\application

REM Lua's search path
set LUA_PATH=%PATH_NXOEDITOR%\nxo_editor\?.lua;%PATH_NXOEDITOR%\application\lua\?.lua;%PATH_NXOEDITOR%\application\lua_hilscher\?.lua

REM Development
set PATH_NXOEDITOR=d:\projekt\Muhkuh\
set WXLUA_BIN=d:\projekt\muhkuh_sf\bin
set LUA_PATH=%PATH_NXOEDITOR%\nxo_editor\?.lua;%PATH_NXOEDITOR%\lua\?.lua;%PATH_NXOEDITOR%\lua_hilscher\?.lua

REM call wxlua with the command args supplied; works only on win NT 4 and above
"%WXLUA_BIN%\lua.exe" "%PATH_NXOEDITOR%\nxo_editor\tagtool.wx.lua" %*

