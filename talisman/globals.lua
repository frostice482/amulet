function is_big(x)
	return false
end

function is_number(x)
	return type(x) == 'number'
end

--- @return t.Omega | number
function to_big(x, y)
	if is_number(x) then
		return x * 10 ^ (y or 0)
	elseif x == nil then
		return 0
	else
		if ((#x >= 2) and ((x[2] >= 2) or (x[2] == 1) and (x[1] > 308))) then
			return 1e309
		end
		if (x[2] == 1) then
			return math.pow(10, x[1])
		end
		return x[1] * (y or 1);
	end
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