@echo off
REM Build an nxo file. 
REM Usage:
REM makenxo -H headers.bin [-t taglist.bin] -o out.nxm in.elf

@echo off
REM Muhkuh directory
set NX_ROOT=D:\projekt\muhkuh_sf

REM path to lua.exe and the Lua/wxWidgets/wxLua DLLs
set WXLUA_BIN=%NX_ROOT%\bin

REM path to the bootwizard scripts
set LUA_DIR=D:\projekt\Muhkuh\nxo_editor

REM Lua's search path
set LUA_PATH=%LUA_DIR%\?.lua;%NX_ROOT%\bin\lua\?.lua;%NX_ROOT%\bin\lua_hilscher\?.lua

REM call wxlua with the command args supplied; works only on win NT 4 and above
"%WXLUA_BIN%\lua.exe" "%LUA_DIR%\nxomaker.wx.lua" %*
