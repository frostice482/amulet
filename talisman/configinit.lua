Talisman = {
    F_NO_COROUTINE = false,
    mod_path = _mod_dir_amulet,

    ante_switch_point = 1000000,
    flame_max = 1e100, -- Maximum flame intensity
    flame_decay = 25000, -- Maximum flame real intensity when intensity is switched to 0
    flame_dt_max = 131, -- Maximum flame deltatime (seconds)

    cdataman = true,
    Amulet = true
}
Talisman.api_version = {
    major = 3,
    minor = 4
}
Talisman.current_calc = {}
Talisman.debug = {}

Talisman.config_file = {
    disable_anims = false,
    disable_omega = false,
    debug_coroutine = false,
    big_ante = false,
    notation = "Balatro",

    enable_compat = false,
    thread_sanitize = 'modify',
    thread_sanitize_num = true,
    sanitize_graphics = false,

    break_infinity = "omeganum", -- unused
}

Talisman.config = { file_name = 'config/amulet.lua' }

function Talisman.config.save()
    love.filesystem.createDirectory('config')
    love.filesystem.write(Talisman.config.file_name, STR_PACK(Talisman.config_file))
end

function Talisman.config.load()
    local conf = love.filesystem.read(Talisman.config.file_name)
    if not conf then return end
    local parsed = STR_UNPACK(conf)
    if not parsed then return end

    for k, v in pairs(parsed) do
        Talisman.config_file[k] = v
    end
end

Talisman.forced_features = {}

function Talisman.forced_features.force_omeganum()
    Talisman.forced_features.omeganum = true
    require("talisman.break_inf")
    Talisman.debug.omeganum_forced = 'yes'
end

function Talisman.forced_features.force_bigante()
    Talisman.big_ante.enable()
    Talisman.forced_features.bigante = true
    Talisman.debug.bigante_forced = 'yes'
end

Talisman.big_ante = {}

function Talisman.big_ante.has()
    return Talisman.config_file.big_ante or Talisman.forced_features.bigante
end

function Talisman.big_ante.enable()
    if G.GAME then G.GAME.round_resets.ante = to_big(G.GAME.round_resets.ante) end
    Talisman.debug.bigante = 'on'
end

function Talisman.big_ante.disable()
    if G.GAME then G.GAME.round_resets.ante = math.min(math.max(to_number(G.GAME.round_resets.ante), -1e308), 1e308) end
    Talisman.debug.bigante = nil
end

function Talisman.update_debug()
    Talisman.debug.omeganum = not Big and 'no' or nil
    Talisman.debug.type_compat = Talisman.config_file.enable_compat and 'yes' or nil
    Talisman.debug.thread_fix = Talisman.config_file.thread_sanitize
    Talisman.debug.thread_fix_num = Talisman.config_file.thread_sanitize_num and 'yes' or 'no'
    Talisman.debug.gfx_fix = Talisman.config_file.sanitize_graphics and 'yes' or nin
end

Talisman.config.load()
Talisman.update_debug()
