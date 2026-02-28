local gradlist = Talisman.gradients.list

SMODS.Gradient {
    key = "echips",
    colours = {
        HEX("41bed9"),
        HEX("5674e9"),
    },
    cycle = 4,
    update = function(self, dt)
        for i = 1, 4 do
            self[i] = gradlist.echips.current_colour[i]
        end
    end,
}

SMODS.Gradient {
    key = "emult",
    colours = {
        HEX("ff73ad"),
        HEX("db005f")
    },
    cycle = 4,
    update = function(self, dt)
        for i = 1, 4 do
            self[i] = gradlist.emult.current_colour[i]
        end
    end,
}

if Spectrallib then
    local update_exp_colours_ref = G.FUNCS.slib_update_exp_colours
    function G.FUNCS.slib_update_exp_colours(arg, ...)
        G.FUNCS.tal_update_exponential_colours(arg)
        return update_exp_colours_ref(arg, ...)
    end
end