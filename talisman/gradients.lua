--- @class t.Gradient
--- @field key string
--- @field current_colour [number, number, number, number]
--- @field colours [number, number, number, number][]
--- @field cycle number
--- @field update fun(self: t.Gradient, dt: number)

--- @class t.GradientInit
--- @field key string
--- @field colours [number, number, number, number][]
--- @field cycle number
--- @field update fun(self: t.Gradient, dt: number)

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
        cycle = init.cycle,
        update = init.update,
    }
    G.C[init.key] = gradlist[init.key].current_colour
    return gradlist[init.key]
end

local slib = SMODS and SMODS.Mods and (SMODS.Mods.Spectrallib or {}).can_load
local function update_exp_colour(self, _)
    if slib then
        for i = 1, 4 do
            self.current_colour[i] = SMODS.Gradients["slib_" .. self.key]
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
    },
    cycle = 4,
    update = update_exp_colour,
}

Talisman.gradients.register {
    key = "emult",
    colours = {
        HEX("ff73ad"),
        HEX("db005f")
    },
    cycle = 4,
    update = update_exp_colour,
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