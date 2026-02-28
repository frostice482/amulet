if not SMODS then --- @diagnostic disable-line
    local createOptionsRef = create_UIBox_options
    function create_UIBox_options()
        local contents = createOptionsRef()
        local m = UIBox_button({
            minw = 5,
            button = "talismanMenu",
            label = {
                "Amulet"
            },
            colour = G.C.GOLD
        })
        table.insert(contents.nodes[1].nodes[1].nodes[1].nodes, m)
        return contents
    end
end

---@class t.ConfigSection
Talisman.config_sections = {}
---@class t.ConfigSection
local conf = Talisman.config_sections

conf.notations = {
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

function conf.title()
    return {
        n = G.UIT.R,
        config = { align = "cm" },
        nodes = {
            { n = G.UIT.T, config = { text = localize("tal_feature_select"), scale = 0.4 } }
        }
    }
end

--- @param refval string
--- @param title? string | boolean
--- @param tooltip? string | boolean
--- @param cb? fun(val: boolean)
function conf.create_toggle(refval, title, tooltip, cb)
    title = title == true and 'tal_'..refval or title or nil
    tooltip = tooltip == true and title..'_warning' or tooltip or nil

    local ui = create_toggle({
        label = title and localize(title), --- @diagnostic disable-line
        ref_table = Talisman.config_file,
        ref_value = refval,
        callback = function(arg)
            if cb then cb(arg) end
            Talisman.config.save()
            Talisman.update_debug()
        end,
    })
    if tooltip then
        ui.config.on_demand_tooltip = { text = localize(tooltip) } --- @diagnostic disable-line
    end
    return ui
end

function conf.disable_anim()
    return conf.create_toggle("disable_anims", true)
end

function conf.disable_omega()
    if Talisman.forced_features.omeganum then return end
    return conf.create_toggle("disable_omega", true, nil, function (val)
        if val == false then
            require("talisman.break_inf")
        end
    end)
end

function conf.notation()
    local b = to_big(1e20)
    if not (Big and Notations and is_big(b)) then return { n = G.UIT.R } end

    local ex = b:tetrate(1e20) --- @diagnostic disable-line
    local opts = {}
    for i,loc in ipairs(conf.notations.loc_keys) do
        opts[i] = string.format('%s (%s)', localize(loc), Notations[conf.notations.filenames[i]]:format(ex, 3))
    end

    return create_option_cycle({
        label = localize("talisman_notation"),
        options = opts,
        current_option = get_index(conf.notations.filenames, Talisman.config_file.notation or 'Balatro') or 1,
        w = 6,
        scale = 0.8,
        text_scale = 0.5,
        opt_callback = 'tal_update_notation'
    })
end

conf.exponential_colour_options = {
    "tal_exp_colour_default",
    "tal_exp_colour_classic"
}
function conf.exponential_colours()
    -- defer to spectrallib's option
    if Spectrallib then
        return Spectrallib.config_opts.exponential_colours()
    else
        local opts = {}
        for _, str in ipairs(conf.exponential_colour_options) do
            opts[#opts+1] = localize(str)
        end

        return create_option_cycle({
            label = localize("tal_exp_colours"),
            scale = 0.8,
            w = 6,
            options = opts,
            opt_callback = "tal_update_exponential_colours",
            current_option = Talisman.config_file.exponential_colours,
        })
    end
end

function conf.big_ante()
    if Talisman.forced_features.bigante then return end
    return conf.create_toggle("big_ante", true, true, function (val)
        if val then
            Talisman.big_ante.enable()
        else
            Talisman.big_ante.disable()
        end
    end)
end

function conf.debug_coroutine()
    return conf.create_toggle("debug_coroutine", true, true)
end

conf.array = {
    conf.disable_anim,
    conf.disable_omega,
    conf.debug_coroutine,
    conf.big_ante,
    conf.notation,
    conf.exponential_colours,
}

---@class t.ConfigSection.Compat
conf.compat = {}

conf.compat.thread_sanitations = { 'modify', 'copy', 'noop' }

function conf.compat.thread_sanitize()
    return create_option_cycle({
        label = localize("tal_thread_sanitation"),
        options = conf.compat.thread_sanitations,
        current_option = get_index(conf.compat.thread_sanitations, Talisman.config_file.thread_sanitize or 'modify') or 1,
        scale = 0.8,
        text_scale = 0.5,
        opt_callback = 'tal_update_thread_sanitize',
        on_demand_tooltip = { text = localize("tal_thread_sanitation_warning") }
    })
end

function conf.compat.thread_sanitize_num()
    return conf.create_toggle("thread_sanitize_num", true)
end

function conf.compat.type_compat()
    return conf.create_toggle("enable_compat", true, true)
end

function conf.compat.sanitize_graphics()
    return conf.create_toggle("sanitize_graphics", true)
end

conf.compat.array = {
    conf.compat.thread_sanitize,
    conf.compat.thread_sanitize_num,
    conf.compat.sanitize_graphics,
    conf.compat.type_compat,
}

conf.ui_base = {
    emboss = 0.05,
    minh = 6,
    r = 0.1,
    minw = 10,
    align = "cm",
    padding = 0.2,
    colour = G.C.BLACK
}

function conf.generate_tab(array)
    local nodes = {}
    for i,v in ipairs(array) do
        local n = v(nodes)
        if n then
            table.insert(nodes, n)
        end
    end
    return {
        n = G.UIT.ROOT,
        config = conf.ui_base,
        nodes = nodes
    }
end

function conf.config_tab()
    return conf.generate_tab(conf.array)
end

function conf.compat.config_tab()
    return conf.generate_tab(conf.compat.array)
end

function conf.credits_tab()
    return {
        n = G.UIT.ROOT,
        config = conf.ui_base,
        nodes = {
            { n = G.UIT.R, nodes = {{ n = G.UIT.T, config = { text = "Amulet devs:", scale = 0.4 } }}, config = { padding = 0.1 } },
            { n = G.UIT.R, nodes = {{ n = G.UIT.T, config = { text = "- frostice482", scale = 0.4 } }} },

            { n = G.UIT.R, nodes = {{ n = G.UIT.T, config = { text = "Talisman devs:", scale = 0.4 } }}, config = { padding = 0.1 } },
            { n = G.UIT.R, nodes = {{ n = G.UIT.T, config = { text = "- MathIsFun_", scale = 0.4 } }} },
            { n = G.UIT.R, nodes = {{ n = G.UIT.T, config = { text = "- Mathguy24", scale = 0.4 } }} },
            { n = G.UIT.R, nodes = {{ n = G.UIT.T, config = { text = "- jenwalter666", scale = 0.4 } }} },
            { n = G.UIT.R, nodes = {{ n = G.UIT.T, config = { text = "- cg-223", scale = 0.4 } }} },
            { n = G.UIT.R, nodes = {{ n = G.UIT.T, config = { text = "- lord.ruby", scale = 0.4 } }} },
        }
    }
end

function G.FUNCS.talismanMenu(e)
    local tabs = create_tabs({
        snap_to_nav = true,
        tabs = {{
            label = "Amulet",
            chosen = true,
            tab_definition_function = conf.config_tab
        },{
            label = "Compat",
            tab_definition_function = conf.compat.config_tab
        },{
            label = "Credits",
            tab_definition_function = conf.credits_tab
        }}
    })
    G.FUNCS.overlay_menu {
        definition = create_UIBox_generic_options({
            back_func = "options",
            contents = { tabs }
        }),
        config = { offset = { x = 0, y = 10 } }
    }
end

function G.FUNCS.tal_update_notation(arg)
    Talisman.config_file.notation = conf.notations.filenames[arg.to_key]
    Talisman.config.save()
    Talisman.update_debug()
end

function G.FUNCS.tal_update_exponential_colours(arg)
    -- safeguarding against spectrallib adding new options further down the line
    Talisman.config_file.exponential_colours = math.min(arg.to_key, #conf.exponential_colour_options)
    Talisman.config.save()
    Talisman.update_debug()
end

function G.FUNCS.tal_update_thread_sanitize(arg)
    Talisman.config_file.thread_sanitize = conf.compat.thread_sanitations[arg.to_key]
    Talisman.config.save()
    Talisman.update_debug()
end

G.UIDEF.tal_credits = conf.credits_tab
G.UIDEF.tal_compat_config = conf.compat.config_tab
