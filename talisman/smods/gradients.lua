local gradlist = Talisman.gradients.list

SMODS.Gradient {
    key = "echips",
    colours = {
        HEX("41bed9"),
        HEX("5674e9"),
    },
    cycle = 4,
    update = function(self, dt)
        gradlist.echips:update(dt)

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
        gradlist.emult:update(dt)

        for i = 1, 4 do
            self[i] = gradlist.emult.current_colour[i]
        end
    end,
}