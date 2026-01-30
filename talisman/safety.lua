function Talisman.sanitize(obj, tonum, done)
	if not Big then return end
	if Big.is(obj) then
		return tonum and obj.number or obj:as_table()
	end
	if type(obj) ~= 'table' then return obj end

	if not done then done = {} end
	if done[obj] then return obj end
	done[obj] = true

	for k,v in pairs(obj) do
		if Big and Big.is(k) then
			obj[k] = nil
			k = tonum and k.number or k:as_table()
			obj[k] = v
		else
			Talisman.sanitize(k, tonum, done)
		end

		obj[k] = Talisman.sanitize(v, tonum, done)
	end

	return obj
end

function Talisman.create_unpack_env()
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
function Talisman.copy_table(obj, config, reflist)
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
		copy[Talisman.copy_table(k, config, reflist)] = Talisman.copy_table(v, config, reflist)
	end
	if not (config and config.nometa) then
		setmetatable(copy, Talisman.copy_table(getmetatable(obj), config, reflist))
	end

	return copy
end

--- @type t.CopyTableConfig
Talisman.copy_for_thread = {
	sanitize = true,
	nometa = true
}

--- @type t.CopyTableConfig
Talisman.copy_for_thread_num = {
	sanitize = true,
	sanitizeToNumber = true,
	nometa = true
}

local copy_table_hook = copy_table
function copy_table(v)
	if not Talisman.config_file.enable_compat or not Big then return copy_table_hook(v) end
	return Talisman.copy_table(v)
end

function STR_UNPACK(str)
	local env = Talisman.create_unpack_env()
	local chunk = assert(load(str, '=[temp:str_unpack]', 'bt', env))
	setfenv(chunk, env)
	return chunk()
end

local reg = debug.getregistry()
local Channel = reg.Channel
local _push = Channel.push

function Channel:push(obj)
	if Talisman.config_file.thread_sanitize == "copy" then
		obj = Talisman.copy_table(obj, Talisman.config_file.thread_sanitize_num and Talisman.copy_for_thread_num or Talisman.copy_for_thread)
	elseif Talisman.config_file.thread_sanitize == "modify" then
		obj = Talisman.sanitize(obj, Talisman.config_file.thread_sanitize_num)
	end
	return _push(self, obj)
end
