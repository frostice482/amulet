jit.off()

function copy_table(o, done)
	if type(o) ~= "table" then return o end
	done = done or {}
	if done[o] then return done[o] end

	local copy = {}
	done[o] = copy

	for k, v in pairs(o) do
		copy[copy_table(k)] = copy_table(v)
	end
	setmetatable(copy, copy_table(getmetatable(O)))

	return copy
end

require"talisman.globals"
require"big-num.omeganum"

--- @param desc string
--- @param n number
--- @param fn fun()
local function bench(desc, n, fn)
	collectgarbage("stop")

	local t = os.clock()
	local m = collectgarbage("count")
	local c = Big.created_instances

	for i=1, n do fn() end

	local td = os.clock() - t
	local md = collectgarbage("count") - m
	local cd = Big.created_instances - c

	print(string.format(
		'%10s - %7.2f ms; %6.2fMB; %6.0f inst/n; %11.2f bytes/n; %.1f ops',
		desc, td * 1000, md / 1024, cd / n, md / n * 1024, n/td
	))

	collectgarbage("collect")
	collectgarbage("restart")
end

local y = Big:create(111)
local n

bench("raw", 100000000, function() end)

n = y
bench("add", 100000, function() n = n + y end)

n = y
bench("sub", 100000, function() n = n - y end)

n = y
bench("mul", 100000, function() n = n * y end)

n = y
bench("pow", 100000, function() n = n ^ y end)

n = y
bench("tetrate", 100000, function() n = n:tetrate(4) end)

n = y
bench("arrow", 100000, function() n = n:arrow(3, 3) end)

n = Big:create(2.001)
bench("arrow2", 10, function() n = n:arrow(200, 2.001) end)
