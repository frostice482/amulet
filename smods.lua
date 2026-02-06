local curmod = SMODS.current_mod

if not _mod_dir_amulet then
return error(string.format([[

[!] !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! [!]

    Amulet is nested / zipped. Make sure Amulet is not installed
    one folder too deep, or if it is zipped, unzip it.

    Path: %s
    Mods folder: %s

[!] !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! [!]

    (you will be send to the sun if you report this crash message)

]], curmod and curmod.path, require "lovely".mod_dir), 0)
end

if Talisman.smods then
return error(string.format([[

[!] !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! [!]

    Dupllicate Amulet installation detected (SMODS). Remove one of them.

    Other: %s
    Current: %s

[!] !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! [!]

    (you will be send to the black hole if you report this crash message)

]], Talisman.smods.path, curmod and curmod.path), 0)
end

Talisman.smods = SMODS.current_mod

if SMODS.Atlas then
	SMODS.Atlas({
		key = "modicon",
		path = "icon.png",
		px = 27,
		py = 27
	})
end

if SMODS.Sound then
	SMODS.Sound({
		key = "xchip",
		path = "MultiplicativeChips.ogg"
	})
	SMODS.Sound({
		key = "echip",
		path = "ExponentialChips.ogg"
	})
	SMODS.Sound({
		key = "eechip",
		path = "TetrationalChips.ogg"
	})
	SMODS.Sound({
		key = "eeechip",
		path = "PentationalChips.ogg"
	})
	SMODS.Sound({
		key = "emult",
		path = "ExponentialMult.ogg"
	})
	SMODS.Sound({
		key = "eemult",
		path = "TetrationalMult.ogg"
	})
	SMODS.Sound({
		key = "eeemult",
		path = "PentationalMult.ogg"
	})
end

if curmod then
	function curmod.load_mod_config() end
	function curmod.save_mod_config() end

	curmod.config_tab = function()
		if Talisman and Talisman.config_sections then
			return Talisman.config_sections.config_tab()
		end
		return nil
	end
	curmod.description_loc_vars = function()
		return { background_colour = G.C.CLEAR, text_colour = G.C.WHITE, scale = 1.2 }
	end

	curmod.extra_tabs = function()
		return {{
			label = 'Compability',
			tab_definition_function = G.UIDEF.tal_compat_config
		}, {
			label = 'Credits',
			tab_definition_function = G.UIDEF.tal_credits
		}}
	end

	curmod.debug_info = Talisman.debug
end

if SMODS.calculate_individual_effect then
	require("talisman.smods.ind_effect")
end

if SMODS.Scoring_Calculation then
	require("talisman.smods.scoring_calc")
end

--[[SMODS.Joker{
  key = "test",
  name = "Joker Test",
  rarity = 4,
  discovered = true,
  pos = {x = 9, y = 2},
  cost = 4,
  loc_txt = {
	  name = "Stat Stick",
	  text = {
		"2 of {C:dark_edition,E:2,s:0.8}every scoring effect"
	  }
  },
  loc_vars = function(self, info_queue, center)
	return {vars = {"#","{","}"}}
  end,
  calculate = function(self, card, context)
	if context.joker_main then
		return {
		  mult_mod = 2,
		  Xmult_mod = 2,
		  Emult_mod = 2,
		  EEmult_mod = 2,
		  EEEmult_mod = 2,
		  hypermult_mod = {22, 2},
		  chip_mod = 2,
		  Xchip_mod = 2,
		  Echip_mod = 2,
		  EEchip_mod = 2,
		  EEEchip_mod = 2,
		  hyperchip_mod = {22, 2}
		}
	end
  end,
}--]]
