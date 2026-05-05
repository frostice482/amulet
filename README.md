# Amulet
A [Talisman](https://github.com/SpectralPack/Talisman) continuation that adds support for scoring above vanilla's limit (e308) while providing compatibility by default to most mods.

The OmegaNum used is a port of [OmegaNum.js](https://github.com/Naruyoko/OmegaNum.js/blob/master/OmegaNum.js) by [Mathguy23](https://github.com/Mathguy23).

## Installation
Amulet requires [Lovely](https://github.com/ethangreen-dev/lovely-injector) to be installed in order to be loaded by Balatro.

## API

Most Amulet APIs are backward-compatible with talisman, except mostly OmegaNum checking. Internally, Amulet's OmegaNum is cdata and not tables.

### Making incompatible with Talisman

For Amulet >= 3.5.1, simply add conflicts to your JSON file

```json
"conflicts": [ "Talisman (<=2.7)" ]
```

For Amulet >= 3.2.4, add check in your lua file

<details>
<summary>(expand for code)</summary>

```lua
if Talisman and not Talisman.Amulet then
error[[

      !!!!!!!!!!!!!!!

Talisman is not supported, use Amulet instead

Download it here: https://github.com/frostice482/amulet

      !!!!!!!!!!!!!!
]]
end
```

</details>

### OmegaNum checking

Use `is_big(thing)` or `Big.is(thing)`

### Forcing OmegaNum

Using this feature will force-enable OmegaNum and hide the option from the settings

```lua
Talisman.forced_features.force_omeganum()
```

### Forcing BigAnte

Using this feature will force-enable BigAnte and hide the option from the settings

```lua
Talisman.forced_features.force_bigante()
```
