local ffi = require("ffi")
ffi.cdef[[int PHYSFS_mount(const char* dir, const char* mountPoint, int appendToPath)]]
local tinymount = (pcall(function() return ffi.C.PHYSFS_mount end) and ffi.C or ffi.load("love")).PHYSFS_mount

local talisman_path = _mod_dir_amulet
assert(tinymount(talisman_path .. '/talisman', 'talisman', 0) ~= 0, 'Amulet: Failed to mount talisman from ' .. talisman_path)
assert(tinymount(talisman_path .. '/big-num', 'big-num', 0) ~= 0, 'Amulet: Failed to mount big-num from ' .. talisman_path)

local tal_ok, tal_c_err = pcall(require, "talisman.configinit")
if not tal_ok then
local msg = [[

Amulet failed to load (sanity check failed). You might want to check your installation.
Debug info:
 - amulet folder: %s
 - mods folder: %s
 - working dir: %s
 - stat.type for talisman folder: %s
 - directory listing for talisman folder: [%s]

%s
]]
error(msg:format(
    _mod_dir_amulet,
    require("lovely").mod_dir,
    NFS and NFS.getWorkingDirectory() or "?",
    love.filesystem.getInfo("talisman") and love.filesystem.getInfo("talisman").type or "?",
    table.concat(love.filesystem.getDirectoryItems("talisman"), '; '),
    tal_c_err
), 0)
end

require("talisman.configinit")
require("talisman.effects")
require("talisman.globals")
require("talisman.localization")
require("talisman.configtab")
require("talisman.noanims")
require("talisman.gradients")
require("talisman.sanitizer")
require("talisman.debug")
if not Talisman.config_file.disable_omega then
    require("talisman.break_inf")
end
if not Talisman.F_NO_COROUTINE then
    require("talisman.coroutine")
end
