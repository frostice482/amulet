function Talisman.sanitize(obj, done)
	if not done then done = {} end
	if done[obj] then return obj end
	done[obj] = true

	for k,v in pairs(obj) do
		local t = type(v)
		if Big and Big.is(v) then
			obj[k] = v:as_table()
		elseif t == "table" then
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

function Talisman.copy_table(obj, reflist)
	if not reflist then reflist = {} end
	if type(obj) ~= 'table' then return obj end
	if Big and Big.is(obj) then return obj end
	if reflist[obj] then return reflist[obj] end

	local copy = {}
	reflist[obj] = copy
	for k, v in pairs(obj) do
		copy[Talisman.copy_table(k, reflist)] = Talisman.copy_table(v, reflist)
	end
	setmetatable(copy, Talisman.copy_table(getmetatable(obj), reflist))

	return copy
end

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

-- scan for non-transferable objects for Channel.push
-- for easier debugging

local reg = debug.getregistry()
local Channel = reg.Channel
local _push = Channel.push

local stack = {}
local refs = {}
local testch = love.thread.newChannel()

local function scantransferable(val, i)
	local t = type(val)
	if t == "nil" or t == "number" or t == "string" or t == "boolean" then
		return
	end
	if t == "userdata" then
		if not pcall(_push, testch, val) then
			error(string.format("%s: userdata is not transferable", table.concat(stack, '.', 1, i)))
		end
		testch:clear()
		return
	end
	if t == "table" then
		if refs[val] then
			error(string.format("%s: cyclic", table.concat(stack, '.', 1, i)))
		end

		refs[val] = true
		for k,v in pairs(val) do
			stack[i+1] = tostring(k)
			scantransferable(k, i+1)
			scantransferable(v, i+1)
		end
		stack[i+1] = nil
		refs[val] = nil
		return
	end

	error(string.format("%s: type %s is not transferable", table.concat(stack, '.', 1, i), t))
end

function Channel:push(obj)
	refs = {}
	scantransferable(obj, 0)
	return _push(self, obj)
end
