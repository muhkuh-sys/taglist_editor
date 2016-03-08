module("muhkuh_cli_init", package.seeall)

-- Set the search path for LUA plugins.
package.cpath = package.cpath .. ";lua_plugins/?.so;lua_plugins/?.dll"

-- Set the search path for LUA modules.
package.path = package.path .. ";lua/?.lua;lua/?/init.lua"

-- Load the common modules for a CLI environment.
require("muhkuh")

-- This string is appended to all paths in the function "load_from_working_folder".
_G.__MUHKUH_WORKING_FOLDER = ""
