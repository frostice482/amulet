print("amulet: loading dev jokers")

for i,e in ipairs(Talisman.effects.listEffect) do
	SMODS.Joker{
		key = "test"..e.key,

		unlocked = true,
		discovered = true,
		alerted = true,

		blueprint_compat = true,
		eternal_compat = true,
		perishable_compat = true,

		loc_txt = {
			default = {
				name = string.format("Test: %s", e.key),
				text = {
					"{C:attention}Retriggers{} scoring cards {C:attention}#1#{} times",
					"{B:1,C:white}#2#{} for each scoring card trigger",
				}
			}
		},
		loc_vars = function(self, iq, card)
			return {
				vars = {
					card.ability.extra.retriggers,
					e.stringify(card.ability[e.key], true),
					colours = {
						Talisman.gradients.list[e.colorKey] and Talisman.gradients.list[e.colorKey].current_colour or G.C.RED
					}
				}
			}
		end,
		config = {
			extra = {
				retriggers = 3
			},
			[e.attrKey or e.key] = e.hyper and {5, 2} or 2
		},
		calculate = function(self, card, ctx)
			if ctx.repetition and ctx.cardarea == G.play then
				return {
					repetitions = card.ability.extra.retriggers
				}
			end
			if ctx.individual and ctx.cardarea == G.play then
				print(e.key, card.ability[e.key])
				return {
					[e.key2 or e.key] = card.ability[e.key]
				}
			end
		end
	}
end