--- @class t.IndividualEffect
--- @field parameterKey string
--- @field messageKey string
--- @field messageType string
--- @field modKey string
--- @field set fun(current: t.Omega.Parsable, amount: any): t.Omega.Parsable
--- @field stringify fun(amount: any): string

Talisman.effects = {}

--- @type table<string, t.IndividualEffect>
local fxlist = {}
Talisman.effects.list = fxlist

local types = {
	{ key = 'chip', key2 = 'chips', loc = nil },
	{ key = 'mult', key2 = 'mult', loc = 'k_mult' },
}
local setfn = {
	function(c, a) return c ^ a end,
	function(c, a) return to_big(c):tetrate(a) end,
	function(c, a) return to_big(c):arrow(3, a) end
}
for i=1, 3 do
	local e = string.rep('e', i)
	local up = string.rep('^', i)

	for j, t in ipairs(types) do
		local key = e .. '_' .. t.key2
		local modkey = e:upper() .. t.key .. '_mod'

		fxlist[key] = {
			parameterKey = t.key2,
			messageKey = e .. t.key .. '_message',
			messageType = key,
			modKey = modkey,
			set = setfn[i] or function (current, amount) return to_big(current):arrow(i, amount) end,
			stringify = function (amount)
				local str = up .. amount
				if t.loc then str = str .. " " .. localize(t.loc) end
				return str
			end
		}
		fxlist[e .. t.key2] = fxlist[key]
		fxlist[modkey] = fxlist[key]
	end
end
for i,t in ipairs(types) do
	local key = 'hyper_' .. t.key2
	local modkey = 'hyper' .. t.key .. '_mod'
	fxlist[key] = {
		parameterKey = t.key2,
		messageKey = 'hyper' .. t.key .. '_message',
		messageType = key,
		modKey = modkey,
		set = function (current, amount) return to_big(current):arrow(amount[1], amount[2]) end,
		stringify = function (amount)
			local str
			if amount[1] > 5 then
				str = string.format('{%s}', amount[1])
			else
				str = string.rep('^', amount[1])
			end
			str = str .. amount[2]
			if t.loc then str = str .. " " .. localize(t.loc) end
			return str
		end
	}
	fxlist['hyper' .. t.key2] = fxlist[key]
	fxlist[modkey] = fxlist[key]
end

function Talisman.effects.handle(effect, scored_card, key, amount, from_edition)
	local handler = Talisman.effects.list[key]
	if not handler then return end

	if effect.card then juice_card(effect.card) end

	local parameter = SMODS.Scoring_Parameters[handler.parameterKey]
	parameter:modify(handler.set(parameter.current, amount) - parameter.current)

	if not effect.remove_default_message then
		if from_edition then
			card_eval_status_text(scored_card, 'jokers', nil, percent, nil, { message = handler.stringify(amount), colour = G.C.EDITION, edition = true })
		elseif key ~= handler.modKey then
			if effect[handler.messageKey] then
				card_eval_status_text(effect.message_card or effect.juice_card or scored_card or effect.card or effect.focus, 'extra', nil, percent, nil, effect[handler.messageKey])
			else
				card_eval_status_text(effect.message_card or effect.juice_card or scored_card or effect.card or effect.focus, handler.messageType, amount, percent)
			end
		end
	end
	return true
end

local scie = SMODS.calculate_individual_effect
function SMODS.calculate_individual_effect(...)
	local ret = scie(...)
	if ret then return ret end
	return Talisman.effects.handle(...)
end

for k, v in pairs(fxlist) do
	table.insert(SMODS.scoring_parameter_keys or SMODS.calculation_keys, k)
end

-- prvent juice animations
local smce = SMODS.calculate_effect
function SMODS.calculate_effect(effect, ...)
	if Talisman.config_file.disable_anims then effect.juice_card = nil end
	return smce(effect, ...)
end