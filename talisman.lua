local ffi = require("ffi")
ffi.cdef[[int PHYSFS_mount(const char* dir, const char* mountPoint, int appendToPath)]]
local tinymount = (pcall(function() return ffi.C.PHYSFS_mount end) and ffi.C or ffi.load("love")).PHYSFS_mount

local talisman_path = _mod_dir_amulet
assert(tinymount(talisman_path .. '/talisman', 'talisman', 0) ~= 0, 'Amulet: Failed to mount talisman from ' .. talisman_path)
assert(tinymount(talisman_path .. '/big-num', 'big-num', 0) ~= 0, 'Amulet: Failed to mount big-num from ' .. talisman_path)

require("talisman.configinit")
require("talisman.globals")
require("talisman.localization")
require("talisman.card")
require("talisman.configtab")
require("talisman.noanims")
require("talisman.sanitizer")
require("talisman.debug")
if not Talisman.config_file.disable_omega then
    require("talisman.break_inf")
end
if not Talisman.F_NO_COROUTINE then
    require("talisman.coroutine")
end
