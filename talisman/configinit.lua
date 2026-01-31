Talisman = {
    F_NO_COROUTINE = false,
    mod_path = _mod_dir_amulet,
    ante_switch_point = 1000,

    cdataman = true,
    Amulet = true
}
Talisman.api_version = {
    major = 3,
    minor = 3
}
Talisman.current_calc = {}

Talisman.config_file = {
    disable_anims = false,
    disable_omega = false,
    debug_coroutine = false,
    big_ante = false,
    notation = "Balatro",

    enable_compat = false,
    thread_sanitize = 'modify',
    thread_sanitize_num = true,

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

Talisman.config.load()

Talisman.forced_features = {}

function Talisman.forced_features.force_omeganum()
    Talisman.forced_features.omeganum = true
    require("talisman.break_inf")
end

function Talisman.forced_features.force_bigante()
    Talisman.forced_features.bigante = true
    if G.GAME then G.GAME.round_resets.ante = to_big(G.GAME.round_resets.ante) end
end

function Talisman.has_big_ante()
    return Talisman.config_file.big_ante or Talisman.forced_features.bigante
end