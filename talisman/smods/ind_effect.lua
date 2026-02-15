function Talisman.effects.handleIndividual(effect, scored_card, key, amount, from_edition)
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
	return Talisman.effects.handleIndividual(...)
end

for k, v in pairs(Talisman.effects.list) do
	table.insert(SMODS.scoring_parameter_keys or SMODS.calculation_keys, k)
end

-- prvent juice animations
local smce = SMODS.calculate_effect
function SMODS.calculate_effect(effect, ...)
	if Talisman.config_file.disable_anims then effect.juice_card = nil end
	return smce(effect, ...)
end