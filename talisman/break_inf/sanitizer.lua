local sanitizer = Talisman.sanitizer
local config = Talisman.config_file

-- wow...
local _t = type
function type(v)
    return Talisman.config_file.enable_compat and Big and Big.is(v) and "table" or _t(v)
end

local copy_table_hook = copy_table
function copy_table(v)
	if not Talisman.config_file.enable_compat or not Big then return copy_table_hook(v) end
	return sanitizer.copy_table(v)
end

local reg = debug.getregistry()

local Channel = reg.Channel
local channel_push = Channel.push

function Channel:push(obj)
	if config.thread_sanitize == "copy" then
		obj = sanitizer.copy_table(obj, config.thread_sanitize_num and sanitizer.copy_for_thread_num or sanitizer.copy_for_thread)
	elseif config.thread_sanitize == "modify" then
		obj = sanitizer.sanitize(obj, config.thread_sanitize_num)
	end
	return channel_push(self, obj)
end

local Shader = reg.Shader
local shader_send = Shader.send

function Shader:send(name, arg, ...)
	if config.sanitize_graphics then arg = sanitizer.sanitize(arg, true) end
	return shader_send(self, name, arg, ...)
end

local lg_translate = love.graphics.translate
function love.graphics.translate(x, y)
	if config.sanitize_graphics then x, y = to_number(x), to_number(y) end
	return lg_translate(x, y)
end

local lg_rotate = love.graphics.rotate
function love.graphics.rotate(a)
	if config.sanitize_graphics then a = to_number(a) end
	return lg_rotate(a)
end

local lg_draw = love.graphics.draw
function love.graphics.draw(drawable, x, y, r, ...)
	if config.sanitize_graphics then x, y, r = to_number(x), to_number(y), to_number(r) end
	return lg_draw(drawable, x, y, r, ...)
end
