local Notation = require("big-num.notations.notation")

local BalaNotation = {}
BalaNotation.__index = BalaNotation
BalaNotation.__tostring = function ()
    return "BalaNotation"
end
setmetatable(BalaNotation, Notation)

function BalaNotation:new()
    return setmetatable({}, BalaNotation)
end

--vanilla balatro number_format function basically
local function e_ify(num)
    --if not num then return "0" end
    if is_big(num) then
        num = num:to_number()
    end

    if (num or 0) >= 10^6 then
        local x = string.format("%.4g",num)
        local fac = math.floor(math.log(tonumber(x), 10))
        return string.format("%.3f",x/(10^fac))..'e'..fac
    end

    return string.format(num ~= math.floor(num) and (num >= 100 and "%.0f" or num >= 10 and "%.1f" or "%.2f") or "%.0f", num):reverse():gsub("(%d%d%d)", "%1,"):gsub(",$", ""):reverse()
end

--- @param l t.Omega
function BalaNotation:format(l, places)
    local arr = l:get_array()

    --The notation here is Hyper-E notation, but with lowercase E.
    if l:isNaN() then
        return "nan"
    elseif l:isInfinite() then
        return l.number > 0 and "Infinity" or "-Infinity"
    elseif l:log10() < 1000000 then
        if arr[2] == 1 then --OmegaNum
            local mantissa = 10^(arr[1]-math.floor(arr[1]))
            mantissa = math.floor(mantissa*10^places+0.5)/10^places
            local exponent = math.floor(arr[1])
            return (l.sign == -1 and "-" or "")..mantissa.."e"..e_ify(exponent)
        else
            local exponent = math.floor(math.log(arr[1],10))
            local mantissa = arr[1]/10^exponent
            mantissa = math.floor(mantissa*10^places+0.5)/10^places
            return (l.sign == -1 and "-" or "")..mantissa.."e"..e_ify(exponent)
        end
    elseif l < 1000000 then
        if arr[2] == 2 then --OmegaNum
            local mantissa = 10^(arr[1]-math.floor(arr[1]))
            mantissa = math.floor(mantissa*10^places+0.5)/10^places
            local exponent = math.floor(arr[1])
            return (l.sign == -1 and "-" or "").."e"..mantissa.."e"..e_ify(exponent)
        else
            local exponent = math.floor(math.log(arr[1],10))
            local mantissa = arr[1]/10^exponent
            mantissa = math.floor(mantissa*10^places+0.5)/10^places
            return (l.sign == -1 and "-" or "").."e"..mantissa.."e"..e_ify(exponent)
        end
    elseif arr[2] and l.asize == 2 and arr[2] <= 8 then
        --eeeeeee1.234e56789
        local mantissa = 10^(arr[1]-math.floor(arr[1]))
        mantissa = math.floor(mantissa*10^places+0.5)/10^places
        local exponent = math.floor(arr[1])
        return (l.sign == -1 and "-" or "")..string.rep("e", arr[2]-1)..mantissa.."e"..e_ify(exponent)
    elseif l.asize < 8 then
        --e12#34#56#78
        local r = (l.sign == -1 and "-e" or "e")..e_ify(math.floor(arr[1]*10^places+0.5)/10^places).."#"..e_ify(arr[2] or 1)
        for i = 3, l.asize do
            r = r.."#"..e_ify((arr[i] or 0)+1)
        end
        return r
    else
        --e12#34##5678
        return (l.sign == -1 and "-e" or "e")..e_ify(math.floor(arr[1]*10^places+0.5)/10^places).."#"..e_ify(arr[l.asize] or 0).."##"..e_ify(l.asize-2)
    end
end

return BalaNotation