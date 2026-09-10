local effects = Talisman.effects
effects.createAndRegister(effects.common.chips)
effects.createAndRegister(effects.common.mult)
effects.createAndRegister(effects.common.score)
effects.createAndRegister(effects.common.blindsize)

function Talisman.effects.handleIndividual(effect, scored_card, key, amount, from_edition)
	local handler = Talisman.effects.list[key]
	if not handler or (handler.can and not handler:can(effect, scored_card, key, amount, from_edition)) then return end

	if effect.card then juice_card(effect.card) end

	if handler.parameterKey then
		local parameter = SMODS.Scoring_Parameters[handler.parameterKey]
		parameter:modify(handler.getValue(parameter.current, amount) - parameter.current)
	end
	if handler.set then
		handler:set(effect, scored_card, key, amount, from_edition)
	end

	if not effect.remove_default_message then
		if from_edition then
			card_eval_status_text(scored_card, 'jokers', nil, percent, nil, {
				message = handler.stringify(amount),
				colour = G.C.EDITION,
				edition = true
			})
		elseif key ~= handler.modKey then
			local obj = effect.message_card or effect.juice_card or scored_card or effect.card or effect.focus
			if handler.messageKey and effect[handler.messageKey] then
				local msg = effect[handler.messageKey]
				if handler.processLoc then msg = handler:processLoc(msg, scored_card, effect) or msg end
				card_eval_status_text(obj, 'extra', nil, percent, nil, msg)
			else
				card_eval_status_text(obj, handler.key, amount, percent)
			end
		end
	end

	return true
end

local scie = SMODS.calculate_individual_effect
function SMODS.calculate_individual_effect(...)
	local ret = scie(...)
	if ret then return ret end
	return effects.handleIndividual(...)
end

for k, v in pairs(effects.list) do
	table.insert(SMODS.scoring_parameter_keys or SMODS.calculation_keys, k)
end
if Talisman.config_file.dev then
	print(SMODS.scoring_parameter_keys or SMODS.calculation_keys)
end

-- prvent juice animations
local smce = SMODS.calculate_effect
function SMODS.calculate_effect(effect, ...)
	if Talisman.config_file.disable_anims then effect.juice_card = nil end
	return smce(effect, ...)
end