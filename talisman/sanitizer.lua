---@class t.Sanitizer
Talisman.sanitizer = {}
---@class t.Sanitizer
local sanitizer = Talisman.sanitizer

function sanitizer.sanitize(obj, tonum, done)
	if not Big then return end
	if Big.is(obj) then
		return tonum and obj.number or obj:as_table()
	end
	if type(obj) ~= 'table' then return obj end

	if not done then done = {} end
	if done[obj] then return obj end
	done[obj] = true

	local keyswap = {}

	for k,v in pairs(obj) do
		if Big and Big.is(k) then
			table.insert(keyswap, k)
		else
			sanitizer.sanitize(k, tonum, done)
		end
		obj[k] = sanitizer.sanitize(v, tonum, done)
	end

	for i,k in ipairs(keyswap) do
		local nk = tonum and k.number or k:as_table()
		local v = obj[k]
		obj[k] = nil
		obj[nk] = v
	end

	return obj
end

function sanitizer.create_unpack_env()
	return {
		Big = Big,
		OmegaMeta = OmegaMeta,
		to_big = to_big,
		uncompress_big = uncompress_big,
		inf = 1.79769e308,
	}
end

--- @class t.CopyTableConfig
--- @field sanitize? boolean
--- @field sanitizeToNumber? boolean
--- @field nometa? boolean

--- @param obj any
--- @param config? t.CopyTableConfig
--- @param reflist any
function sanitizer.copy_table(obj, config, reflist)
	if Big and Big.is(obj) then
		if not (config and config.sanitize) then return obj end
		if config.sanitizeToNumber then return obj.number end
		return obj:as_table()
	end
	if type(obj) ~= 'table' then return obj end

	local copy = {}
	if not reflist then reflist = {} end
	if reflist[obj] then return reflist[obj] end
	reflist[obj] = copy

	for k, v in pairs(obj) do
		copy[sanitizer.copy_table(k, config, reflist)] = sanitizer.copy_table(v, config, reflist)
	end
	if not (config and config.nometa) then
		setmetatable(copy, sanitizer.copy_table(getmetatable(obj), config, reflist))
	end

	return copy
end

--- @type t.CopyTableConfig
sanitizer.copy_for_thread = {
	sanitize = true,
	nometa = true
}

--- @type t.CopyTableConfig
sanitizer.copy_for_thread_num = {
	sanitize = true,
	sanitizeToNumber = true,
	nometa = true
}

function STR_UNPACK(str)
	local env = sanitizer.create_unpack_env()
	local chunk = assert(load(str, '=[temp:str_unpack]', 'bt', env))
	setfenv(chunk, env)
	return chunk()
end
