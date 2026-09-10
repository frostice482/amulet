local gradlist = Talisman.gradients.list

for k,v in pairs(gradlist) do
    SMODS.Gradient {
        key = v.key,
        colours = v.colours,
        cycle = 4,
        update = function(self, dt)
            for i = 1, 4 do
                self[i] = v.current_colour[i]
            end
        end,
    }
end

if Spectrallib then
    local update_exp_colours_ref = G.FUNCS.slib_update_exp_colours
    function G.FUNCS.slib_update_exp_colours(arg, ...)
        G.FUNCS.tal_update_exponential_colours(arg)
        return update_exp_colours_ref(arg, ...)
    end
end