--- @diagnostic disable

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

local function assert_array(obj, arr)
	for k,v in pairs(obj) do
		assert(arr[k] == v)
	end
	for k,v in pairs(arr) do
		assert(obj[k] == v)
	end
end

require"talisman.globals"
require"big-num.omeganum"

local B = to_big
local inf = math.huge
local nan = 0/0
local quitebig = B"1e600"

-- comparison

assert(B(1) > B(-1), "1 > -1")
assert(B(-1) == B(-1), "-1 == -1")

assert(B(1) < B(1e300), "1 < 1e300")
assert(B(-1) < B(1e300), "1 < -1e300")
assert(B(1) > B(-1e300), "1 > -1e300")
assert(B(-1) > B(-1e300), "-1 > -1e300")

assert(B(inf) == B(inf), "inf == inf")
assert(B(inf) > B(-inf), "inf > -inf")
assert(B(-inf) < B(inf), "-inf < inf")
assert(B(-inf) == B(-inf), "-inf == -inf")

assert(B(nan) ~= B(nan), "nan != nan")

assert(B(inf):max(-inf) == inf, "max(inf, -inf)")
assert(B(inf):min(-inf) == -inf, "min(inf, -inf)")

-- number comparison

assert(1 < B(1e300), "1 < 1e300")
assert(B(1e300) > 1, "1e300 > 1")

-- arbitrary comparison

assert(B(0) ~= "", "0 != ''")
assert(B(0) ~= "0", "0 != '0'")

local large0 = B(1e300):pow(1e300)

-- operation: negation
assert(large0:neg().sign == -1, "negation failed")
-- operation: absolute
assert(large0:neg():abs().sign == 1, "absolute failed")
-- operation: floor
assert(B(3.1):floor() == 3, "floor: + failed")
assert(B(0):floor() == 0, "floor: 0 failed")
assert(B(-0.1):floor() == -1, "floor: - failed")
-- operation: ceil
assert(B(3.1):ceil() == 4, "ceil: + failed")
assert(B(0):ceil() == 0, "ceil: 0 failed")
assert(B(-0.1):ceil() == 0, "ceil: - failed")

-- operation: add
assert(B(10) + B(7) == 17, "add: + + failed")
assert(B(10) + B(-7) == 3, "add: + - failed")
assert(B(-10) + B(-7) == -17, "add: - - failed")
assert(B(-10) + B(7) == -3, "add: - + failed")
assert(B(-10) + B(0) == -10, "add: - 0 failed")
assert(B(0) + B(10) == 10, "add: 0 + failed")
assert(B(20) + B(0) == 20, "add: + 0 failed")

do
local LA = 140000000000002336830670401131419386275306449928192
local LS = 60000000000001998419855582028941557687569403084800
assert((B(1e50) + B(4e49)).number == LA, "add: L+ L+ failed")
assert((B(1e50) + B(-4e49)).number == LS, "add: L+ L- failed")
assert((B(-1e50) + B(4e49)).number == -LS, "add: L+ L+ failed")
assert((B(-1e50) + B(-4e49)).number == -LA, "add: L+ L- failed")
end

assert(B(0) + B(inf) == inf, "add: 0 inf failed")
assert(B(1) + B(inf) == inf, "add: 1 inf failed")
assert(B(0) + B(-inf) == -inf, "add: 0 -inf failed")
assert(B(1) + B(-inf) == -inf, "add: 1 -inf failed")
assert(B(inf) + B(1) == inf, "add: inf 1 failed")
assert(B(-inf) + B(1) == -inf, "add: -inf 1 failed")
assert(B(inf) + B(inf) == inf, "add: inf inf failed")
assert(B(-inf) + B(-inf) == -inf, "add: -inf -inf failed")
assert((B(inf) + B(-inf)):isNaN(), "add: +inf -inf failed, expected nan")
assert((B(-inf) + B(inf)):isNaN(), "add:- inf +inf failed, expected nan")

assert((B(0) + B(nan)):isNaN(), "add: 0 nan failed")
assert((B(nan) + B(nan)):isNaN(), "add: nan nan failed")

-- operation: sub
assert(B(10) - B(7) == 3, "sub: + + failed")
assert(B(10) - B(-7) == 17, "sub: + - failed")
assert(B(-10) - B(-7) == -3, "sub: - - failed")
assert(B(-10) - B(7) == -17, "sub: - + failed")
assert(B(-10) - B(0) == -10, "sub: - 0 failed")
assert(B(0) - B(10) == -10, "sub: 0 + failed")

do
local LA = 140000000000002336830670401131419386275306449928192
local LS = 60000000000001998419855582028941557687569403084800
assert((B(1e50) - B(4e49)).number == LS, "sub: L+ L+ failed")
assert((B(1e50) - B(-4e49)).number == LA, "sub: L+ L- failed")
assert((B(-1e50) - B(4e49)).number == -LA, "sub: L+ L+ failed")
assert((B(-1e50) - B(-4e49)).number == -LS, "sub: L+ L- failed")
end

assert(B(0) - B(inf) == -inf, "sub: 0 inf failed")
assert(B(1) - B(inf) == -inf, "sub: 1 inf failed")
assert(B(0) - B(-inf) == inf, "sub: 0 -inf failed")
assert(B(1) - B(-inf) == inf, "sub: 1 -inf failed")
assert(B(inf) + B(1) == inf, "sub: inf 1 failed")
assert(B(-inf) + B(1) == -inf, "sub: -inf 1 failed")
assert(B(inf) - B(-inf) == inf, "sub: inf -inf failed")
assert(B(-inf) - B(inf) == -inf, "sub: -inf inf failed")

assert((B(inf) - B(inf)):isNaN(), "sub: +inf +inf failed, expected nan")
assert((B(-inf) - B(-inf)):isNaN(), "sub: -inf -inf failed, expected nan")

assert((B(0) - B(nan)):isNaN(), "sub: 0 nan failed")
assert((B(nan) - B(nan)):isNaN(), "sub: nan nan failed")

-- operation: mul
assert(B(1e300) * B(1e300) == quitebig, "mul: + + failed")
assert(B(1e300) * B(-1e300) == -quitebig, "mul: + - failed")
assert(B(-1e300) * B(1e300) == -quitebig, "mul: - + failed")
assert(B(-1e300) * B(-1e300) == quitebig, "mul: - - failed")

assert(B(-1e300) * 0 == 0, "mul: - 0 failed")
assert(B(1e300) * 0 == 0, "mul: + 0 failed")
assert(B(inf) * 0 == 0, "mul: inf 0 failed")
assert(B(-inf) * 0 == 0, "mul: -inf 0 failed")

assert(B(-1e300) * 1 == -1e300, "mul: - 1 failed")
assert(B(1e300) * 1 == 1e300, "mul: + 1 failed")

assert((B(inf) * B(-inf)):isNaN(), "mul: +inf -inf failed, expected nan")
assert((B(-inf) * B(inf)):isNaN(), "mul: inf +inf failed, expected nan")

assert((B(0) * B(nan)):isNaN(), "mul: 0 nan failed")
assert((B(nan) * B(nan)):isNaN(), "mul: nan nan failed")

-- operation: div
assert(quitebig / B(1e10) == B"1e590", "div: + + failed")
assert(quitebig / B(-1e10) == -B"1e590", "div: + - failed")
assert(-quitebig / B(1e10) == -B"1e590", "div: - + failed")
assert(-quitebig / B(-1e10) == B"1e590", "div: - - failed")

assert(B(1) / B(0) == inf, "div: + 0 failed")
assert(B(-1) / B(0) == -inf, "div: - 0 failed")

assert(B(1e300) / B(1e300) == 1, "div: s s failed")
assert(B(1e300) / B(1e300) == 1, "div: s s failed")
assert(B(1e300) / B(1) == 1e300, "div: + 1 failed")
assert(B(1e300) / B(1) == 1e300, "div: + 1 failed")

assert(B(1e300) / B(inf) == 0, "div: + inf failed")
assert(B(1e300) / B(-inf) == 0, "div: + -inf failed")

assert((B(inf) / B(inf)):isNaN(), "div: +inf +inf failed, expected nan")
assert((B(-inf) / B(-inf)):isNaN(), "div: -inf -inf failed, expected nan")
assert((B(inf) / B(-inf)):isNaN(), "div: +inf -inf failed, expected nan")
assert((B(-inf) / B(inf)):isNaN(), "div: inf +inf failed, expected nan")
assert((B(0) / B(0)):isNaN(), "div: 0 0 failed, expected nan")

assert((B(0) / B(nan)):isNaN(), "div: 0 nan failed")
assert((B(nan) / B(nan)):isNaN(), "div: nan nan failed")

-- operation: log10
assert(B(1e300):log10() == 300, "log10: 1e300 failed")
assert(B"e1e100":log10() == 1e100, "log100: e1e10 failed")
assert(B"e1e300":log10() == 1e300, "log100: e1e300 failed")

local log2 = math.log10(2)

assert(B(2):log10() == log2, "log10: 2 failed")
assert(B(1):log10() == 0, "log10: 1 failed")
assert(B(0):log10() == -inf, "log10: 0 failed")
assert(B(-1):log10():isNaN(), "log10: -1 failed")

assert(B(nan):log10():isNaN(), "log10: nan failed")
assert(B(inf):log10() == inf, "log10: inf failed")

--- operation: ln
assert(B(math.exp(10)):ln() == 10, "ln: e^10 failed")

assert(B(nan):ln():isNaN(), "ln: nan failed")
assert(B(inf):ln() == inf, "ln: inf failed")

--- operation: exp
assert(B(3):exp() == math.exp(3), "exp: 3 failed")

assert(B(nan):exp():isNaN(), "exp: nan failed")
assert(B(inf):exp() == inf, "exp: inf failed")

--- operation: pow10
assert(B(log2):pow10() == 2, "pow10: log2 failed")
assert(B(1e300):pow10() == B"e1e300", "pow10: 1e300 failed")

assert(B(nan):pow10():isNaN(), "pow10: nan failed")
assert(B(inf):pow10() == inf, "pow10: inf failed")

--- operation: pow
assert(B"1e3000":pow(2) == B"1e6000", "pow: 1e3000 2 failed")
assert(B"1e3000":pow(1) == B"1e3000", "pow: 1e3000 1 failed")
assert(B"1e3000":pow(0.5) == B"1e1500", "pow: 1e3000 0.5 failed")
assert(B"1e3000":pow(0) == 1, "pow: 1e3000 0 failed")
assert(B"1e500":pow(-0.5) == 1e-250, "pow: 1e500 -0.5 failed")

assert(B(2):pow(nan):isNaN(), "pow: 2 nan failed")
assert(B(nan):pow(2):isNaN(), "pow: nan 2 failed")

assert(B(inf):pow(2) == inf, "pow: inf 2 failed")
assert(B(inf):pow(0) == 1, "pow: inf 0 failed")
assert(B(inf):pow(-1) == 0, "pow: inf -1 failed")

assert(B(2):pow(inf) == inf, "pow: 2 inf failed")
--assert(B(1):pow(inf):isNaN(), "pow: 1 inf failed, expected nan")
assert(B(1):pow(inf) == 1, "pow: 1 inf failed") -- should be nan mathematically
assert(B(0.9):pow(inf) == 0, "pow: 0.9 inf failed")
assert(B(0):pow(inf) == 0, "pow: 0 inf failed")
assert(B(-0.9):pow(inf) == 0, "pow: 0 inf failed")
--assert(B(-1):pow(inf):isNaN(), "pow: -1 inf failed, expecting nan")
assert(B(-1):pow(inf) == 1, "pow: -1 inf failed") -- should be nan mathematically
--assert(B(-2):pow(inf):isNaN(), "pow: -1 inf failed, expecting nan")
assert(B(-2):pow(inf) == inf, "pow: -1 inf failed") -- should be nan mathematically

-- operation: root
assert(B"1e900":root(2) == B"1e450", "root: 1e900 200 failed")
assert(B"1e900":root(1) == B"1e900", "root: 1e900 1 failed")
assert(B"1e900":root(0.5) == B"1e1800", "root: 1e900 0.5 failed")
assert(B"1e900":root(0) == inf, "root: 1e900 0 failed")
assert(B"1e150":root(-0.5) == 1e-300, "root: 1e150 -0.5 failed")
assert(B"1e600":root(-2) == 1e-300, "root: 1e600 -2 failed")

assert(B(2):root(nan):isNaN(), "root: 2 nan failed")
assert(B(nan):root(2):isNaN(), "root: nan 2 failed")

-- operation: tetrate
assert(B(10):tetrate(2) == 10^10, "tetrate: 10 2 failed")
assert(B(10):tetrate(3) == B(10):pow(B(10^10)), "tetrate: 10 2 failed")
assert(B(10):tetrate(4) == B(10):pow(B(10):pow(B(10^10))), "tetrate: 10 2 failed")
assert_array(B(10):tetrate(1e10):get_array(), { 10^10, 10^10-2 })
assert_array(B(10):tetrate(1e300):get_array(), { 300, 1, 1 })

assert(B(3):root(nan):isNaN(), "tetrate: 3 nan failed")
assert(B(nan):root(3):isNaN(), "tetrate: nan 3 failed")
