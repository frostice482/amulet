local curmod = SMODS.current_mod

-- patch check
if not _mod_dir_amulet then

-- loaded on disabled
if curmod.disabled then
local cause, step
if curmod.lovelyIgnored then
	cause = 'lovelyignored'
	step = string.format('Go to Mods/%s and delete .lovelyignore', curmod.blacklist_name)
end
if curmod.blacklisted then
	cause = 'blacklisted'
	step = string.format('Go to Mods/lovely/blacklist.txt and remove "%s" line', curmod.blacklist_name)
end

return error(string.format([[

Amulet is loaded by SMODS in a disabled state (%s). This is likely related to SMODS bug #1434.
You have a few options to fix this issue:
- Remove Amulet from the mods folder
- Disable / remove mods that requires Amulet
- Enable Amulet again: %s

]], cause, step), 0)

end

return error(string.format([[

[!] !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! [!]

	Amulet is nested / zipped. Make sure Amulet is not installed
	one folder too deep, or if it is zipped, unzip it.

	Path: %s
	Mods folder: %s

[!] !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! [!]

	(you will be sent to the sun if you report this crash message)

]], curmod.path, require "lovely".mod_dir), 0)
end

-- duplicate check
if Talisman.smods then
return error(string.format([[

[!] !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! [!]

    Dupllicate Amulet installation detected (SMODS). Remove one of them.

    Other: %s
    Current: %s

[!] !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! [!]

    (you will be sent to the black hole if you report this crash message)

]], Talisman.smods.path, curmod.path), 0)
end

Talisman.smods = SMODS.current_mod

--[[
For mod developers: PLEASE if you're checking for Talisman, DON'T do
```
if SMODS.Mods["Talisman"] and SMODS.Mods["Talisman"].can_load then
```
This breaks compat with a mod that provides Talisman (e.g. Amulet of course)
but PLEASE do
```
if Talisman then
```
]]
if not SMODS.Mods.Talisman then
	SMODS.Mods.Talisman = {
		can_load = true,
		meta_mod = true
	}
end

SMODS.Atlas({
	key = "modicon",
	path = "icon.png",
	px = 27,
	py = 27
})


SMODS.Sound({ key = "xchip", path = "chips/x.ogg" })
SMODS.Sound({ key = "echip", path = "chips/e.ogg" })
SMODS.Sound({ key = "eechip", path = "chips/ee.ogg" })
SMODS.Sound({ key = "eeechip", path = "chips/eee.ogg" })
SMODS.Sound({ key = "emult", path = "mult/e.ogg" })
SMODS.Sound({ key = "eemult", path = "mult/ee.ogg" })
SMODS.Sound({ key = "eeemult", path = "mult/eee.ogg" })
SMODS.Sound({ key = "eblindsize", path = "blindsize/e.ogg" })
SMODS.Sound({ key = "eeblindsize", path = "blindsize/ee.ogg" })
SMODS.Sound({ key = "eeeblindsize", path = "blindsize/eee.ogg" })

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
		label = 'Compatibility',
		tab_definition_function = G.UIDEF.tal_compat_config
	}, {
		label = 'Credits',
		tab_definition_function = G.UIDEF.tal_credits
	}}
end

curmod.debug_info = Talisman.debug

require("talisman.smods.ind_effect")
require("talisman.smods.scoring_calc")
require("talisman.smods.gradients")
if Talisman.config_file.dev then
	require("talisman.smods.test")
end
