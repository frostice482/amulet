local constants = require("big-num.constants")
Notations = require("big-num.notations")
BigC = copy_table(constants)

local maxn = table.maxn or function(arr)
    local total = 0
    for i, v in pairs(arr) do
        if type(i) == "number" and v ~= 0 and i > total then
            total = i
        end
    end
    return total
end

function is_big(x)
	return false
end

function is_number(x)
	return type(x) == 'number'
end

--- @return t.Omega | number
function to_big(x, sign)
	sign = sign or 1
	if is_number(x) then
		return x * sign
	elseif type(x) == "table" then
		if maxn(x) > 2 then
			return 1e309 * sign
		end
		if x[2] then
			if x[2] > 4 then return 1e309 * sign end
			local v = x[1] or 0
			for i=1, x[2] do v = 10 ^ v end
			return v * sign
		end
		return (x[1] or 0) * sign
	end
	return 0
end

function to_number(x)
	return x
end

function uncompress_big(str, sign)
	local curr = 1
	local array = {}
	for i, v in pairs(str) do
		for i2 = 1, v[2] do
			array[curr] = v[1]
			curr = curr + 1
		end
	end
	return to_big(array, y)
end

function lenient_bignum(x)
	return x
end

function clamp_bignum(x, max)
	max = max or 1e308
	x = to_number(x)
	return x > max and max or x < -max and -max or x
end

if Talisman then

function Talisman.juice(v)
	v = to_number(v) or 1
	return (G.TAROT_INTERRUPT_PULSE or type(v) ~= "number") and 0
		or v > math.huge and 10
		or v < 1 and 0
		or math.min(10, math.log(v, 1000 ))
end

function Talisman.juice_elm(e, v)
	return G.FUNCS.text_super_juice(e, Talisman.juice(v))
end

end