--- @class t.Effects
Talisman.effects = {}
--- @class t.Effects
local effects = Talisman.effects

--- @type table<string, t.Effects.Effect>
effects.list = {}
--- @type t.Effects.Effect[]
effects.listEffect = {}
--- @type t.Effects.Effect[]
effects.listScoring = {}

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

--- @param init t.Effects.EffectInit
--- @param t t.Effects.EffectGeneric
function effects.applyGeneric(init, t, prefix)
	local kp = init.keyPlural or init.key
	t.parameterKey = not init.noParam and kp or nil
	t.messageKey = prefix .. init.key .. '_message'
	t.key = prefix .. '_' .. kp
	t.key2 = prefix .. kp

	t.colorKey = init.colorKey
	t.scoreFunc = init.scoreFormat and init.scoreFormat:format(prefix)
	t.can = init.can
	t.after = init.after
	t.set = init.set
end

--- @nodiscard
--- @param init t.Effects.EffectInit
--- @param i number
function effects.createIndex(init, i)
	local e = i == 0 and 'x' or string.rep('e', i)
	local up = i == 0 and 'X' or string.rep('^', i)
	local kp = init.keyPlural or init.key

	local fx = {
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
	}
	effects.applyGeneric(init, fx, e)
	return fx, e
end

--- @nodiscard
--- @param init t.Effects.EffectInit
function effects.createHyper(init)
	local kp = init.keyPlural or init.key

	local fx = {
		hyper = true,
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
	}
	effects.applyGeneric(init, fx, 'hyper')
	return fx
end

function effects.create_ability_get_func(attr)
	--- @param card balatro.Card
	return function(card)
		local val = card.ability[attr]
		--return not (card.debuff or card.ability.set == 'Joker' and val == 1) and val or 0
		return not (card.debuff or card.ability.set == 'Joker') and val or 1
	end
end

function effects.create_ability_get_func_hyper(attr)
	--local t = {0, 0}
	local t = {1, 1}
	--- @param card balatro.Card
	return function(card)
		local val = card.ability[attr]
		--return not (card.debuff or card.ability.set == 'Joker' or type(val) ~= 'table' or val[1] == 1 and val[2] == 1) and val or t
		return not (card.debuff or card.ability.set == 'Joker' or type(val) ~= 'table') and val or t
	end
end

--- @param fx t.Effects.Effect
function effects.register(fx)
	effects.list[fx.key] = fx
	if fx.modKey then effects.list[fx.modKey] = fx end
	if fx.key2 then effects.list[fx.key2] = fx end
	table.insert(effects.listEffect, fx)

	if fx.scoreFunc then
		Card[fx.scoreFunc] = fx.hyper and effects.create_ability_get_func_hyper(fx.key) or effects.create_ability_get_func(fx.key)
		table.insert(effects.listScoring, fx)
	end
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
	scoreFormat = 'get_chip_%s_bonus',
	sound = 'talisman_%schip',
	colorKey = 'echips',
}
effects.common.mult = {
	key = 'mult',
	scoreFormat = 'get_chip_%s_mult',
	sound = 'talisman_%smult',
	colorKey = 'emult',
	loc = 'a_mult',
}
effects.common.score = {
	key = 'score',
	scoreFormat = 'get_bonus_%s_score',
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
	scoreFormat = 'get_bonus_%s_blind_size',
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

function effects.evaluate_scoring_card(card, return_table)
	if card.debuff or card.ability.set == 'Joker' then return end
	for i,score in ipairs(effects.listScoring) do
		local vv = card[score.scoreFunc](card)
		if not score.hyper then
			if vv ~= 0 and vv ~= 1 then
				return_table[score.key] = vv
			end
		else
			if vv[2] ~= 0 and vv[2] ~= 1 then
				return_table[score.key] = vv
			end
		end
	end
end

--- @class t.Effects.EffectGeneric: t.Effects.EffectCommon
--- @field key string e.g. `e_chips`, `hyper_chips`
--- @field scoreFunc? string e.g. `get_chip_e_bonus`; defines a method in Card with this name and use the function for scoring cards
--- @field parameterKey? string e.g. `mult`, `chips`; used in effect handlers modifying `SMODS.Scoring_Parameters` current value
--- @field key2? string e.g. `echips`, `hyperchips`; used in effect handlers for key aliasing
--- @field messageKey? string e.g. `echip_message`; used in effect handlers specifying effect message

--- @class t.Effects.Effect: t.Effects.EffectGeneric
--- @field hyper? boolean
--- @field attrKey? string e.g. `Echips`, `Hchips`; used in setting card's attribute
--- @field modKey? string e.g. `Echip_mod`, `hyperchip_mod`; used in effect handlers without status text
--- @field getValue fun(current: t.Omega.Parsable, amount: any): any Get amount to set
--- @field stringify fun(amount: any, noLoc?: boolean): string Stringify amount for message, e.g. `^2 Mult`
--- @field sound? string

--- @class t.Effects.EffectInit: t.Effects.EffectCommon
--- @field key string
--- @field keyPlural? string Defaults to key
--- @field sound? t.Effects.EffectInit.Sound
--- @field scoreFormat? string e.g. `get_chip_%s_bonus`
--- @field loc? string Localization key in v_dictionary
--- @field noParam? boolean Should be set to true if the key is not for `SMODS.Scoring_Parameters`

--- @alias t.Effects.EffectInit.Sound string | table<any, string> | fun(i: t.Effects.EffectInit.SoundIndex): string
--- @alias t.Effects.EffectInit.SoundIndex number | 'hyper'

--- @class t.Effects.EffectCommon
--- @field colorKey? string
--- @field can? t.Effects.HandleFunc<boolean> Check if effect should be handled
--- @field set? t.Effects.HandleFunc<nil> Specify custom effect handler
--- @field after? t.Effects.HandleFunc<nil> Specify custom effect handler after message

--- @alias t.Effects.HandleFunc<R> fun(self: t.Effects.Effect, effect: table, object: table, key: string, amount: any, from_edition: boolean): R
