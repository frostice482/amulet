--- @class t.Effect
--- @field parameterKey string
--- @field messageKey string
--- @field messageType string
--- @field modKey string
--- @field set fun(current: t.Omega.Parsable, amount: any): t.Omega.Parsable
--- @field stringify fun(amount: any): string
--- @field hyper? boolean
--- @field sound? string
--- @field colorKey? string

--- @class t.EffectInit
--- @field key string
--- @field keyPlural string
--- @field soundFormat? string
--- @field effectTableKey? string
--- @field loc? string
--- @field colorKey? string

Talisman.effects = {}

--- @type table<string, t.Effect>
Talisman.effects.list = {}
local fxlist = Talisman.effects.list

local setfn = {
	[0] = function(c, a) return c * a end,
	function(c, a) return c ^ a end,
	function(c, a) return to_big(c):tetrate(a) end, --- @diagnostic disable-line
	function(c, a) return to_big(c):arrow(3, a) end --- @diagnostic disable-line
}

--- @param init t.EffectInit
--- @param i number
function Talisman.effects.registerIndex(init, i)
	local e = i == 0 and 'x' or string.rep('e', i)
	local up = i == 0 and 'X' or string.rep('^', i)

	local key = e .. '_' .. init.keyPlural
	local modkey = e:upper() .. init.key .. '_mod'

	fxlist[key] = {
		parameterKey = init.keyPlural,
		messageKey = e .. init.key .. '_message',
		messageType = key,
		modKey = modkey,
		set = setfn[i] or function (current, amount)
			return to_big(current):arrow(i, amount) --- @diagnostic disable-line
		end,
		stringify = function (amount)
			local str = up .. amount
			if init.loc then str = str .. " " .. localize(init.loc) end
			return str
		end,
		sound = init.soundFormat and init.soundFormat:format(e),
		colorKey = init.colorKey
	}
	fxlist[e .. init.keyPlural] = fxlist[key]
	fxlist[modkey] = fxlist[key]
	return fxlist[key]
end

--- @param init t.EffectInit
function Talisman.effects.registerHyper(init)
	local key = 'hyper_' .. init.keyPlural
	local modkey = 'hyper' .. init.key .. '_mod'
	fxlist[key] = {
		parameterKey = init.keyPlural,
		messageKey = 'hyper' .. init.key .. '_message',
		messageType = key,
		modKey = modkey,
		set = function (current, amount)
			return to_big(current):arrow(amount[1], amount[2]) --- @diagnostic disable-line
		end,
		stringify = function (amount)
			local str
			if amount[1] > 5 then
				str = string.format('{%s}', amount[1])
			else
				str = string.rep('^', amount[1])
			end
			str = str .. amount[2]
			if init.loc then str = str .. " " .. localize(init.loc) end
			return str
		end,
		sound = init.soundFormat and init.soundFormat:format('eee'),
		colorKey = init.colorKey,
		hyper = true
	}
	fxlist['hyper' .. init.keyPlural] = fxlist[key]
	fxlist[modkey] = fxlist[key]
	return fxlist[key]
end

--- @param init t.EffectInit
function Talisman.effects.register(init)
	for i=1, 3 do
		Talisman.effects.registerIndex(init, i)
	end
	Talisman.effects.registerHyper(init)
end

--- @class t.EffectInit
Talisman.effects.chips = {
	key = 'chip',
	keyPlural = 'chips',
	effectTableKey = 'hand_chips',
	soundFormat = 'talisman_%schip',
	colorKey = 'echips',
}

--- @class t.EffectInit
Talisman.effects.mult = {
	key = 'mult',
	keyPlural = 'mult',
	effectTableKey = 'mult',
	soundFormat = 'talisman_%smult',
	colorKey = 'emult',
}

-- xchips
-- this can just be removed now honestly
Talisman.effects.registerIndex({
	key = 'chip',
	keyPlural = 'chips',
	effectTableKey = 'hand_chips',
	soundFormat = 'talisman_%schip',
	colorKey = 'CHIPS'
}, 0)
Talisman.effects.register(Talisman.effects.chips)
Talisman.effects.register(Talisman.effects.mult)