--- @class t.Gradient
--- @field key string
--- @field current_colour [number, number, number, number]
--- @field colours [number, number, number, number][]
--- @field cycle number
--- @field update fun(self: t.Gradient, dt: number)

--- @class t.GradientInit
--- @field key string
--- @field colours [number, number, number, number][]
--- @field cycle? number
--- @field update? fun(self: t.Gradient, dt: number)

Talisman.gradients = {}
--- @type table<string, t.Gradient>
Talisman.gradients.list = {}
local gradlist = Talisman.gradients.list

function Talisman.gradients.register(init)
    assert(init.key)
    gradlist[init.key] = {
        key = init.key,
        colours = init.colours,
        current_colour = HEX("000000"), -- placeholder value
        cycle = init.cycle or 4,
        update = init.update or Talisman.gradients.default_update,
    }
    G.C[init.key] = gradlist[init.key].current_colour
    return gradlist[init.key]
end

--- @param self t.Gradient
function Talisman.gradients.default_update(self, _)
    if Spectrallib and SMODS then
        for i = 1, 4 do
            self.current_colour[i] = SMODS.Gradients["slib_" .. self.key][i]
        end
        return
    end

    local opt = Talisman.config_file.exponential_colours
    if opt == 1 then
        local interp = math.cos(G.TIMERS.REAL * 2 * math.pi / self.cycle) * 0.5 + 0.5
        for i = 1, 4 do
            self.current_colour[i] = self.colours[1][i] * (1-interp) + self.colours[2][i] * interp
        end
    elseif opt == 2 then
        for i = 1, 4 do
            self.current_colour[i] = G.C.DARK_EDITION[i]
        end
    end
end

Talisman.gradients.register {
    key = "echips",
    colours = {
        HEX("41bed9"),
        HEX("5674e9"),
    }
}

Talisman.gradients.register {
    key = "emult",
    colours = {
        HEX("ff73ad"),
        HEX("db005f")
    }
}

local lc = loc_colour
function loc_colour(_c, _default, ...)
	if not G.ARGS.LOC_COLOURS then
		lc()
	end
	for k, _ in pairs(Talisman.gradients.list) do
        G.ARGS.LOC_COLOURS[k:lower()] = G.C[k]
    end
	return lc(_c, _default, ...)
end