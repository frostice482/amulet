local mf = math.floor
function math.floor(x)
    if is_big(x) then return x:floor() end
    return mf(x)
end

local mc = math.ceil
function math.ceil(x)
    if is_big(x) then return x:ceil() end
    return mc(x)
end

local l10 = math.log10
function math.log10(x)
    if is_big(x) then return x:log10() end
    return l10(x)
end

local E = math.exp(1)

local log = math.log
function math.log(x, y)
	if is_big(x) then
        return not y and x:ln()
            or y == 10 and x:log10()
            or x:logBase(Big:ensureBig(y))
    end
    if y then return log(x, y) end
    return log(x)
end

function math.exp(x)
	if is_big(x) then return BigC.E:pow(x) end
    return E ^ x
end

local sqrt = math.sqrt
function math.sqrt(x)
    if is_big(x) then return x:pow(0.5) end
    return sqrt(x)
end

local old_abs = math.abs
function math.abs(x)
    if is_big(x) then return x:abs() end
    return old_abs(x)
end

local sin = math.sin
function math.sin(x)
    return sin(to_number(x))
end

local cos = math.cos
function math.cos(x)
    return cos(to_number(x))
end

--don't return a Big unless we have to - it causes nativefs to break
local max = math.max
function math.max(...)
    local list = {...}
    local max = -math.huge
    for i=1, select('#', ...) do
        if max < list[i] then max = list[i] end
    end
    return max
end

local min = math.min
function math.min(...)
    local list = {...}
    local max = math.huge
    for i=1, select('#', ...) do
        if max > list[i] then max = list[i] end
    end
    return max
end
