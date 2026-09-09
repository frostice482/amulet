--- @class t.Effects
Talisman.effects = {}
--- @class t.Effects
local effects = Talisman.effects

--- @type table<string, t.Effects.Effect>
effects.list = {}
--- @type t.Effects.Effect[]
effects.listEffect = {}

local setfn = {
	[0] = function(c, a) return c * a end,
	function(c, a) return c ^ a end,
	function(c, a) return to_big(c):tetrate(a) end, --- @diagnostic disable-line
	function(c, a) return to_big(c):arrow(3, a) end --- @diagnostic disable-line
}

--- @nodiscard
--- @param init t.Effects.EffectInit
--- @param i number
function effects.createIndex(init, i)
	local e = i == 0 and 'x' or string.rep('e', i)
	local up = i == 0 and 'X' or string.rep('^', i)

	--- @type t.Effects.Effect
	local fx = {
		parameterKey = init.keyPlural,
		messageKey = e .. init.key .. '_message',
		key = e .. '_' .. init.keyPlural,
		key2 = e .. init.keyPlural,
		modKey = e:upper() .. init.key .. '_mod',

		set = setfn[i] or function (current, amount)
			return to_big(current):arrow(i, amount) --- @diagnostic disable-line
		end,
		stringify = function (amount)
			local str = up .. amount
			if init.loc then str = str .. " " .. localize(init.loc) end
			return str
		end,

		sound = init.soundFormat and init.soundFormat:format(e),
		colorKey = init.colorKey,

		setScore = init.setScore,
		effectExtra = init.effectExtra,
		effectScore = init.effectScore,
	}
	return fx, e
end

--- @nodiscard
--- @param init t.Effects.EffectInit
function effects.createHyper(init)
	--- @type t.Effects.Effect
	local fx = {
		hyper = true,
		parameterKey = init.keyPlural,
		messageKey = 'hyper' .. init.key .. '_message',
		key = 'hyper_' .. init.keyPlural,
		key2 = 'hyper' .. init.keyPlural,
		modKey = 'hyper' .. init.key .. '_mod',

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

		setScore = init.setScore,
		effectExtra = init.effectExtra,
		effectScore = init.effectScore,
	}
	return fx
end

--- @param fx t.Effects.Effect
function effects.register(fx)
	effects[fx.key] = fx
	if fx.modKey then effects[fx.modKey] = fx end
	if fx.key2 then effects[fx.key2] = fx end
	table.insert(effects.listEffect, fx)
end

--- @param init t.Effects.EffectInit
function effects.createAndRegister(init)
	for i=1, 3 do
		effects.register(effects.createIndex(init, i))
	end
	effects.register(effects.createHyper(init))
end

--- @type table<string, t.Effects.EffectInit>
effects.common = {}
effects.common.chips = {
	key = 'chip',
	keyPlural = 'chips',
	effectTableKey = 'hand_chips',
	soundFormat = 'talisman_%schip',
	colorKey = 'echips',

	setScore = function (self, amt) hand_chips = mod_chips(self.set(hand_chips, amt)) end,
	effectExtra = function (self, amt, extra) extra.hand_chips = true end,
	effectScore = function (self, amt) update_hand_text({delay = 0}, {chips = hand_chips}) end
}
--- @type t.Effects.EffectInit
effects.common.mult = {
	key = 'mult',
	keyPlural = 'mult',
	effectTableKey = 'mult',
	soundFormat = 'talisman_%smult',
	colorKey = 'emult',

	setScore = function (self, amt) mult = mod_mult(self.set(mult, amt)) end,
	effectExtra = function (self, amt, extra) extra.mult = true end,
	effectScore = function (self, amt) update_hand_text({delay = 0}, {mult = mult}) end
}

--- @type t.Effects.EffectInit
effects.common.xchips = setmetatable({ colorKey = 'CHIPS' }, { __index = effects.common.chips })

if not SMODS then effects.register(effects.createIndex(effects.common.xchips, 0)) end

effects.createAndRegister(effects.common.chips)
effects.createAndRegister(effects.common.mult)

effects.mod_sounds = {
	hyperchip_mod = 'talisman_eeechip',
	hypermult_mod = 'talisman_eeemult',
}

function effects.get_mod_sound(effect)
	for k,v in pairs(effect) do
		if effects.list[k] then return effects.list[k].sound end
		if effects.mod_sounds[k] then return effects.mod_sounds[k] end
	end
end

function effects.init_ability(ability_table, config_table)
	for i,v in ipairs(effects.listEffect) do
		local attrval = config_table[v.attrKey] or config_table[v.key] or config_table[v.key2]
		if v.hyper then
			ability_table[v.key] = type(attrval) == "table" and attrval or {0, 0}
		else
			ability_table[v.key] = attrval or 0
		end
	end
end

--- @class t.Effects.Effect: t.Effects.Common
--- @field hyper? boolean
---
--- @field parameterKey string e.g. `mult`, `chips`
--- @field key string e.g. `e_mult`, `hyper_mult`
--- @field attrKey? string e.g. `Emult`, `Hmult`; used in card's attribute setting
--- @field key2? string e.g. `emult`, `hypermult`; used in effect handlers
--- @field modKey? string e.g. `Emult_mod`, `hypermult_mod`; used in effect handlers without status text
--- @field messageKey? string e.g. `emult_message`; used in specifying effect message
---
--- @field set fun(current: t.Omega.Parsable, amount: any): any Get amount to set
--- @field stringify fun(amount: any): string Stringify amount for message, e.g. `^2 Mult`
---
--- @field sound? string
--- @field colorKey? string

--- @class t.Effects.EffectInit: t.Effects.Common
--- @field key string
--- @field keyPlural string
--- @field soundFormat? string
--- @field effectTableKey? string
--- @field loc? string
--- @field colorKey? string

--- @class t.Effects.Common
--- @field setScore fun(self: t.Effects.Effect, amt: number, effect: table)
--- @field effectExtra fun(self: t.Effects.Effect, amt: number, extras: table)
--- @field effectScore fun(self: t.Effects.Effect, amt: number)
