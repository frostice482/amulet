function Talisman.sanitize(obj, done)
	if not done then done = {} end
	if done[obj] then return obj end
	done[obj] = true

	if Big and Big.is(obj) then return obj:as_table() end
	if type(obj) ~= 'table' then return obj end

	for k,v in pairs(obj) do
		if Big and Big.is(k) then
			obj[k] = nil
			k = k:as_table()
			obj[k] = v
		else
			Talisman.sanitize(k, done)
		end

		if Big and Big.is(v) then
			obj[k] = v:as_table()
		else
			Talisman.sanitize(v, done)
		end
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
--- @field reflist? table
--- @field sanitizze? boolean
--- @field nometa? boolean

--- @param obj any
--- @param config? t.CopyTableConfig
--- @param reflist any
function Talisman.copy_table(obj, config, reflist)
	if not reflist then reflist = {} end
	if reflist[obj] then return reflist[obj] end

	if Big and Big.is(obj) then
		if config and config.sanitizze then return obj:as_table() end
		return obj
	end
	if type(obj) ~= 'table' then return obj end

	local copy = {}
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
	sanitizze = true,
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
		obj = Talisman.copy_table(obj, Talisman.copy_for_thread)
	elseif Talisman.config_file.thread_sanitize == "modify" then
		obj = Talisman.sanitize(obj)
	end
	return _push(self, obj)
end
