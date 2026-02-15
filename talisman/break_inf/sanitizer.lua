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

local function drawfix(drawable, a, b, c, d, e, f, g)
	a = to_number(a)
	b = to_number(b)
	c = to_number(c)
	d = to_number(d)
	e = to_number(e)
	f = to_number(f)
	g = to_number(g)
	return lg_draw(drawable, a, b, c, d, e, f, g)
end

function love.graphics.draw(...)
	if config.sanitize_graphics then return drawfix(...) end
	return lg_draw(...)
end

local update = Game.update
function Game:update(dt)
	local chips = self.GAME and self.GAME.chips
	if is_big(chips) then
		if chips._nan then
			self.GAME.chips = self.ARGS.prev_chips or to_big(0)
			print('Amulet: chips is nan, rolling back to ' .. tostring(self.GAME.chips))
		else
			self.ARGS.prev_chips = chips
		end
	end

	return update(self, dt)
end