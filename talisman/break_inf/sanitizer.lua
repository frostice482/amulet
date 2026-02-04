local sanitizer = Talisman.sanitizer

-- wow...
local _t = type
function type(v)
    return Talisman.config_file.enable_compat and Big and Big.is(v) and "table" or _t(v)
end

local copy_table_hook = copy_table
function copy_table(v)
	if not Talisman.config_file.enable_compat or not Big then return copy_table_hook(v) end
	return Talisman.sanitizer.copy_table(v)
end

local reg = debug.getregistry()

local Channel = reg.Channel
local channel_push = Channel.push

function Channel:push(obj)
	if Talisman.config_file.thread_sanitize == "copy" then
		obj = Talisman.sanitizer.copy_table(obj, Talisman.config_file.thread_sanitize_num and sanitizer.copy_for_thread_num or sanitizer.copy_for_thread)
	elseif Talisman.config_file.thread_sanitize == "modify" then
		obj = Talisman.sanitizer.sanitize(obj, Talisman.config_file.thread_sanitize_num)
	end
	return channel_push(self, obj)
end

local Shader = reg.Shader
local shader_send = Shader.send

function Shader:send(name, a, ...)
	return shader_send(self, name, sanitizer.sanitize(a, true), ...)
end

local lg_translate = love.graphics.translate
function love.graphics.translate(x, y)
	return lg_translate(to_number(x), to_number(y))
end

local lg_rotate = love.graphics.rotate
function love.graphics.rotate(a)
	return lg_rotate(to_number(a))
end

local lg_draw = love.graphics.draw
function love.graphics.draw(drawable, x, y, r, ...)
	return lg_draw(drawable, to_number(x), to_number(y), to_number(r), ...)
end
