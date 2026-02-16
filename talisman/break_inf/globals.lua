local constants = require("big-num.constants")
Big = require("big-num.omeganum")
Notations = require("big-num.notations")
BigC = copy_table(constants)

is_big = Big.is

function is_number(x)
	if type(x) == 'number' then return true end
	if is_big(x) then return true end
	return false
end

--- @return t.Omega | number
function to_big(x, y)
	return Big:create(x, y)
end

function to_number(x)
	return Big.is(x) and x.number or x
end

function lenient_bignum(x)
    if not x or type(x) == "number" then return x end
    if x < constants.BIG and x > constants.NBIG then return x:to_number() end
    return x
end

for k,v in pairs(BigC) do
    BigC[k] = Big:create(v)
end
BigC.E_MAX_SAFE_INTEGER = Big:create(constants.E_MAX_SAFE_INTEGER)
