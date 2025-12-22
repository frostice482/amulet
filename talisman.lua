local nativefs = require("nativefs")
local talisman_path = _mod_dir_amulet

assert(nativefs.mount(talisman_path .. '/talisman', 'talisman'), 'Amulet: Failed to mount talisman from ' .. talisman_path)
assert(nativefs.mount(talisman_path .. '/big-num', 'big-num'), 'Amulet: Failed to mount big-num from ' .. talisman_path)

Talisman = {
    mod_path = talisman_path,
    F_NO_COROUTINE = false,
    cdataman = true,
    Amulet = true
}
Talisman.current_calc = {}
Talisman.config_file = {
    disable_anims = false,
    break_infinity = "omeganum",
    notation = "Balatro"
}
Talisman.notations = {
    loc_keys = {
        "talisman_notations_hypere",
        --"talisman_notations_letter",
        "talisman_notations_array",
        --"k_ante"
    },
    filenames = {
        "Balatro",
        --"LetterNotation",
        "ArrayNotation",
        --"AnteNotation",
    }
}

Talisman.config_file_name = 'config/amulet.lua'

function Talisman.save_config()
    love.filesystem.createDirectory('config')
    love.filesystem.write(Talisman.config_file_name, STR_PACK(Talisman.config_file))
end

function Talisman.load_config()
    local conf = love.filesystem.read(Talisman.config_file_name)
    if not conf then return end
    local parsed = STR_UNPACK(conf)
    if not parsed then return end

    for k, v in pairs(parsed) do
        Talisman.config_file[k] = v
    end
end

Talisman.load_config()

local g_start_run = Game.start_run
function Game:start_run(args)
    local ret = g_start_run(self, args)
    self.GAME.round_resets.ante_disp = self.GAME.round_resets.ante_disp or number_format(self.GAME.round_resets.ante)
    return ret
end

require("talisman.localization")
require("talisman.globals")
require("talisman.card")
require("talisman.configtab")
require("talisman.noanims")
require("talisman.safety")
require("talisman.debug")
if not Talisman.config_file.disable_omega then
    require("talisman.break_inf")
end
if not Talisman.F_NO_COROUTINE then
    require("talisman.coroutine")
end
