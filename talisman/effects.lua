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

--- @param init? t.Effects.EffectInit.Sound
--- @param i t.Effects.EffectInit.SoundIndex
--- @param e string
local function formatsound(init, i, e)
	if not init then return end
	if type(init) == "string" then return init:format(e) end
	if type(init) == "table" then return init[i] end
	if type(init) == "function" then return init(i) end
end

local tmploc = {
	type = 'variable',
	key = '',
	vars = {}
}

--- @nodiscard
--- @param init t.Effects.EffectInit
--- @param i number
function effects.createIndex(init, i)
	local e = i == 0 and 'x' or string.rep('e', i)
	local up = i == 0 and 'X' or string.rep('^', i)
	local kp = init.keyPlural or init.key

	--- @type t.Effects.Effect
	local fx = {
		parameterKey = not init.noParam and kp or nil,
		messageKey = e .. init.key .. '_message',
		key = e .. '_' .. kp,
		key2 = e .. kp,
		modKey = e:upper() .. init.key .. '_mod',
		attrKey = e:upper() .. kp,

		getValue = setfn[i] or function (current, amount)
			return to_big(current):arrow(i, amount) --- @diagnostic disable-line
		end,
		stringify = function (amount, noLoc)
			local str = up .. amount
			if init.loc and not noLoc then
				tmploc.key = init.loc
				tmploc.vars[1] = str
				str = localize(tmploc)
			end
			return str
		end,

		sound = formatsound(init.sound, i, e),
		colorKey = init.colorKey,
		can = init.can,
		after = init.after,
		set = init.set
	}
	return fx, e
end

--- @nodiscard
--- @param init t.Effects.EffectInit
function effects.createHyper(init)
	local kp = init.keyPlural or init.key

	--- @type t.Effects.Effect
	local fx = {
		hyper = true,
		parameterKey = not init.noParam and kp or nil,
		messageKey = 'hyper' .. init.key .. '_message',
		key = 'hyper_' .. kp,
		key2 = 'hyper' .. kp,
		modKey = 'hyper' .. init.key .. '_mod',
		attrKey = 'H' .. kp,

		getValue = function (current, amount)
			return to_big(current):arrow(amount[1], amount[2]) --- @diagnostic disable-line
		end,
		stringify = function (amount, noLoc)
			local str
			if amount[1] > 5 then
				str = string.format('{%s}', amount[1])
			else
				str = string.rep('^', amount[1])
			end
			str = str .. amount[2]
			if init.loc and not noLoc then
				tmploc.key = init.loc
				tmploc.vars[1] = str
				str = localize(tmploc)
			end
			return str
		end,

		sound = formatsound(init.sound, 'hyper', 'eee'),
		colorKey = init.colorKey,
		can = init.can,
		after = init.after,
		set = init.set
	}
	return fx
end

--- @param fx t.Effects.Effect
function effects.register(fx)
	effects.list[fx.key] = fx
	if fx.modKey then effects.list[fx.modKey] = fx end
	if fx.key2 then effects.list[fx.key2] = fx end
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
	sound = 'talisman_%schip',
	colorKey = 'echips'
}
effects.common.mult = {
	key = 'mult',
	sound = 'talisman_%smult',
	colorKey = 'emult',
	loc = 'a_mult'
}
effects.common.score = {
	key = 'score',
	noParam = true,
	sound = 'xscore', -- missing e, ee, eee variant
	colorKey = 'escore',
	loc = 'a_score',

	can = function (self, effect, object, key, amount, from_edition) return amount ~= 1 end,
	set = function (self, effect, object, key, amount, from_edition)
		local s
		effect.remove_default_message = true
		SMODS.mod_score({
			add = self.getValue(G.GAME.chips, amount) - G.GAME.chips,
			card = effect.message_card or effect.juice_card or object or effect.card or effect.focus,
			effect = effect,
			from_edition = from_edition
		})
		effect.remove_default_message = s
	end
}
effects.common.blindsize = {
	key = 'blindsize',
	noParam = true,
	sound = {
		[0] = 'xblindsize',
		'talisman_eblindsize',
		'talisman_eeblindsize',
		'talisman_eeblindsize', -- missing eee variant
		hyper = 'talisman_eeblindsize', -- missing eee variant
	},
	colorKey = 'eblindsize',
	loc = 'a_blind_size',

	can = function (self, effect, object, key, amount, from_edition) return amount ~= 1 end,
	set = function (self, effect, object, key, amount, from_edition)
		local s
		effect.remove_default_message = true
		SMODS.mod_blind_size({
			add = self.getValue(G.GAME.blind.chips, amount) - G.GAME.blind.chips,
			card = effect.message_card or effect.juice_card or object or effect.card or effect.focus,
			effect = effect,
			from_edition = from_edition
		})
		effect.remove_default_message = s
	end
}

effects.createAndRegister(effects.common.chips)
effects.createAndRegister(effects.common.mult)
effects.createAndRegister(effects.common.score)
effects.createAndRegister(effects.common.blindsize)

if Talisman.config_file.dev then
effects.register(effects.createIndex(effects.common.blindsize, 0))
end

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
--- @field key string e.g. `e_chips`, `hyper_chips`
--- @field hyper? boolean
---
--- @field getValue fun(current: t.Omega.Parsable, amount: any): any Get amount to set
--- @field stringify fun(amount: any, noLoc?: boolean): string Stringify amount for message, e.g. `^2 Mult`
---
--- @field attrKey? string e.g. `Echips`, `Hchips`; used in setting card's attribute
--- @field parameterKey? string e.g. `mult`, `chips`; used in effect handlers modifying `SMODS.Scoring_Parameters` current value
--- @field key2? string e.g. `echips`, `hyperchips`; used in effect handlers for key aliasing
--- @field modKey? string e.g. `Echip_mod`, `hyperchip_mod`; used in effect handlers without status text
--- @field messageKey? string e.g. `echip_message`; used in effect handlers specifying effect message
---
--- @field sound? string

--- @class t.Effects.EffectInit: t.Effects.Common
--- @field key string
--- @field keyPlural? string Defaults to key
--- @field sound? t.Effects.EffectInit.Sound
--- @field loc? string Localization key in v_dictionary
--- @field noParam? boolean Should be set to true if the key is not for `SMODS.Scoring_Parameters`

--- @alias t.Effects.EffectInit.Sound string | table<any, string> | fun(i: t.Effects.EffectInit.SoundIndex): string
--- @alias t.Effects.EffectInit.SoundIndex number | 'hyper'

--- @class t.Effects.Common
--- @field colorKey? string
--- @field can? t.Effects.HandleFunc<boolean> Check if effect should be handled
--- @field set? t.Effects.HandleFunc<nil> Specify custom effect handler
--- @field after? t.Effects.HandleFunc<nil> Specify custom effect handler after message

--- @alias t.Effects.HandleFunc<R> fun(self: t.Effects.Effect, effect: table, object: table, key: string, amount: any, from_edition: boolean): R