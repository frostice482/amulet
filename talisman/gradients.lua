--- @class t.Gradients
Talisman.gradients = {}
--- @class t.Gradients
local grad = Talisman.gradients

--- @type table<string, t.Gradients.Gradient>
grad.list = {}
local gradlist = grad.list

function grad.register(init)
    assert(init.key)
    gradlist[init.key] = {
        key = init.key,
        colours = init.colours,
        current_colour = HEX("000000"), -- placeholder value
        cycle = init.cycle or 4,
        update = init.update or grad.default_update,
    }
    G.C[init.key] = gradlist[init.key].current_colour
    return gradlist[init.key]
end

--- @param self t.Gradients.Gradient
function grad.default_update(self, _)
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

grad.register {
    key = "echips",
    colours = {
        HEX("41bed9"),
        HEX("5674e9"),
    }
}

grad.register {
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
	for k, _ in pairs(grad.list) do
        G.ARGS.LOC_COLOURS[k:lower()] = G.C[k]
    end
	return lc(_c, _default, ...)
end

--- @class t.Gradients.Gradient
--- @field key string
--- @field current_colour [number, number, number, number]
--- @field colours [number, number, number, number][]
--- @field cycle number
--- @field update fun(self: t.Gradients.Gradient, dt: number)

--- @class t.Gradients.GradientInit
--- @field key string
--- @field colours [number, number, number, number][]
--- @field cycle? number
--- @field update? fun(self: t.Gradients.Gradient, dt: number)
