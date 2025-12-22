-- "Borrowed" from Trance
local function load_file_with_fallback2(file, fallback)
    local success, result = pcall(function() return assert(love.filesystem.load(file))() end)
    if success then return result end

    local fallback_success, fallback_result = pcall(function() return assert(love.filesystem.load(fallback))() end)
    if fallback_success then return fallback_result end
end

local init_loc = init_localization
function init_localization()
	local res = load_file_with_fallback2(
		"talisman/localization/" .. (G.SETTINGS.language or "en-us") .. ".lua",
		"talisman/localization/en-us.lua"
	)
	if res then
		for k, v in pairs(res) do
			if k ~= "descriptions" then
				G.localization.misc.dictionary[k] = v
			end
			-- todo error messages(?)
			G.localization.misc.dictionary[k] = v
		end
	end
	return init_loc()
end
