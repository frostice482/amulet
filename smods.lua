Talisman.smods = SMODS.current_mod
local curmod = SMODS.current_mod
assert(_mod_dir_amulet, string.format("Amulet is nested.\nPath: %s\nMods directory: %s", curmod and curmod.path, require "lovely".mod_dir))

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
		path = "MultiplicativeChips.wav"
	})
	SMODS.Sound({
		key = "echip",
		path = "ExponentialChips.wav"
	})
	SMODS.Sound({
		key = "eechip",
		path = "TetrationalChips.wav"
	})
	SMODS.Sound({
		key = "eeechip",
		path = "PentationalChips.wav"
	})
	SMODS.Sound({
		key = "emult",
		path = "ExponentialMult.wav"
	})
	SMODS.Sound({
		key = "eemult",
		path = "TetrationalMult.wav"
	})
	SMODS.Sound({
		key = "eeemult",
		path = "PentationalMult.wav"
	})
end

if curmod then
	function curmod.load_mod_config() end
	function curmod.save_mod_config() end

	curmod.config_tab = function()
		if Talisman and Talisman.config_tab then
			return Talisman.config_tab()
		end
		return nil
	end
	curmod.description_loc_vars = function()
		return { background_colour = G.C.CLEAR, text_colour = G.C.WHITE, scale = 1.2 }
	end

	curmod.extra_tabs = function()
		return {
			{
				label = 'Credits',
				tab_definition_function = G.UIDEF.tal_credits
			}
		}
	end

	curmod.debug_info = {}
end

if SMODS.calculate_individual_effect then
	require("talisman.smods.ind_effect")
end

if SMODS.Scoring_Calculation then
	require("talisman.smods.scoring_calc")
end

-- check to_big overrides
local mainmenu = G.main_menu
function G:main_menu()
	if to_big ~= Talisman.to_big then
		local f = debug.getinfo(to_big, "S")
		curmod.debug_info["To big override"] = string.format("%s:%s-%s", f.source, f.linedefined, f.lastlinedefined)
	end

    return mainmenu(self)
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
