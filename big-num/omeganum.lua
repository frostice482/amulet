local ffi = require("ffi")
local R = require("big-num.constants")

ffi.cdef[[
struct TalismanOmega {
    uint32_t asize;
    int8_t sign;
    double number;
};
]]
local TalismanOmega = ffi.typeof("struct TalismanOmega")

--OmegaNum port by Mathguy

--- @alias t.Omega.Parsable string | number | t.Omega

--- @class t.Omega
--- @field sign number
--- @field asize number
--- @field number number
---
--- @operator add(t.Omega|number): t.Omega
--- @operator sub(t.Omega|number): t.Omega
--- @operator mul(t.Omega|number): t.Omega
--- @operator div(t.Omega|number): t.Omega
--- @operator mod(t.Omega|number): t.Omega
--- @operator pow(t.Omega|number): t.Omega
--- @operator unm(): t.Omega
local Big = {}
;(Big).array = {} -- lsp hack, assign without recognized by lsp

OmegaMeta = {
    __index = {
        m = false,
        e = false,
        array = {},
        sign = 1
    }
}

_G.Big = Big

--- constants
local MAX_SAFE_INTEGER = 9007199254740991
local MAX_E = math.log(MAX_SAFE_INTEGER, 10)
local LONG_STRING_MIN_LENGTH = 17

-- this will be populated with bignum equivalents of R's values at the end of the file
--- @type table<string, t.Omega>
local B = {}

-- prevent multiple allocation of same number at a frame
local caches = {
    --- @type table<number, t.Omega>
    list = {},
    --- @type table<number, number>
    frames = {}
}

-- prevent overrides
local type = type
local _math = math
--- @type mathlib
--- @diagnostic disable-next-line
local math = {}
for k,v in pairs(_math) do math[k] = v end

--- OmegaNum instances
--- @type table<t.Omega, number[]>
local bigs = {}
setmetatable(bigs, { __mode = 'k' })

function Big.is(instance)
    return instance and bigs[instance]
end

-- #region constructor

local function arraySizeOf(arr)
    local total = 0
    for i, v in pairs(arr) do
        if type(i) == "number" and v ~= 0 and i > total then
            total = i
        end
    end
    return total
end

--- @return t.Omega
function Big:new(arr, noNormalize)
    --- @type t.Omega
    local obj = TalismanOmega(1, 0) --- @diagnostic disable-line
    bigs[obj] = arr
    if not noNormalize then obj:normalize() end
    return obj
end

--- @return t.Omega
function Big:create(input)
    if ((type(input) == "number")) then
        local obj = caches.list[input]
        if obj then return obj end

        local obj = Big:new({input})
        if input == input then
           caches.frames[input] = (caches.frames[input] or 0) + 1
           if caches.frames[input] > 100 then
                caches.frames[input] = nil
                caches.list[input] = obj
           end
        end
        return obj
    elseif ((type(input) == "string")) then
        return Big:parse(input)
    elseif Big.is(input) then
        return input
    else
        return Big:new(input)
    end
end

--- @return t.Omega
function Big:ensureBig(input)
    if Big.is(input) then
        return input
    else
        return Big:create(input)
    end
end

function Big:_normalize()
    local b = nil
    local arr = self:get_array()
    if ((arr == nil) or (type(arr) ~= "table") or (arraySizeOf(arr) == 0)) then
        arr = {}
    end
    local asize = arraySizeOf(arr)
    if (asize == 1) and (arr[1] == 0) then
        self.sign = 1
        return self
    end
    if (asize == 1) and (arr[1] < 0) then
        self.sign = -1
        arr[1] = -arr[1]
    end
    if ((self.sign~=1) and (self.sign~=-1)) then
        if (self.sign < 0) then
            self.sign = -1;
        else
            self.sign = 1;
        end
    end
    for i, v in pairs(arr) do
        local e = arr[i] or 0;
        if (e ~= e) then
            arr={R.NaN};
            bigs[self] = arr
            return
        end
        if (e == R.POSITIVE_INFINITY) or (e == R.NEGATIVE_INFINITY) then
            arr = {R.POSITIVE_INFINITY};
            bigs[self] = arr
            return
        end
        if (i ~= 1) then
            arr[i]=math.floor(e)
        end
        --first 3 values kept because they are hardcoded in a few places
        --it also doesnt hurt memory that much to keep them anyway
        if ((e == 0)) and i > 3 then
            arr[i] = nil
        end
    end
    local doOnce = true
    while (doOnce or b) do
        b=false;
        asize = arraySizeOf(arr)
        while ((asize ~= 0) and (arr[asize]==0)) do
            arr[asize] = nil;
            b=true;
        end
        if ((arr[1] or 0) > R.MAX_DISP_INTEGER) then --modified, should make printed values easier to display
            arr[2]=(arr[2] or 0) + 1;
            arr[1]= math.log(arr[1], 10);
            b=true;
        end
        while (((arr[1] or 0) < math.log(R.MAX_DISP_INTEGER,10)) and ((arr[2] ~= nil) and (arr[2] ~= 0))) do
            arr[1] = math.pow(10,arr[1]);
            arr[2] = arr[2] - 1
            b=true;
        end
        doOnce = false;
        for i, v in pairs(arr) do
            if type(i) == "number" then
                if ((arr[i] or 0)>R.MAX_SAFE_INTEGER) then
                    arr[i+1]=(arr[i+1] or 0)+1;
                    arr[1]=arr[i]+1;
                    for j=2,i do
                        arr[j]=0;
                    end
                    b=true;
                end
            end
        end
    end
    if (arraySizeOf(arr) == 0) and #arr ~= 1 then
        arr = {0}
    end
    bigs[self] = arr
    self.asize = arraySizeOf(arr)
    return
end

function Big:normalize()
    self:_normalize()
    self.number = self:_to_number()
    return self
end

-- #endregion

-- #region booleans

function Big:isNaN()
    return self.number ~= self.number
end

function Big:isInfinite()
    local v = self:get_array()[1]
    return (v == R.POSITIVE_INFINITY) or (v == R.NEGATIVE_INFINITY)
end

function Big:isFinite()
    return (not self:isInfinite() and not self:isNaN())
end

function Big:isint()
    return math.floor(self.number) == self.number
end

-- #endregion

-- #region comparisons

local function signcomp(a, b)
    return a > b and 1 or a < b and -1 or a == b and 0 or R.NaN
end

--- @param other t.Omega.Parsable
function Big:compareTo(other)
    if not is_number(self) then self = Big:ensureBig(self) end
    if not is_number(other) then other = Big:ensureBig(other) end

    if not Big.is(self) then
        if not Big.is(other) then
            return signcomp(self, other)
        end
        return signcomp(self, other.number)
    end
    if not Big.is(other) then
        return signcomp(self.number, other)
    end

    if self.sign ~= other.sign then
        return self.sign
    end
    if self.asize ~= other.asize then
        return self.asize - other.asize
    end
    if self.asize == 1 and other.asize == 1 then
        return signcomp(self.number, other.number)
    end

    local arr = self:get_array()
    local other_arr = other:get_array()
    for i=self.asize, 1, -1 do
        local d = (arr[i] or 0) - (other_arr[i] or 0)
        if d ~= 0 then return d * self.sign end
    end
    return 0;
end

--- @param other t.Omega.Parsable
function Big:lt(other)
    return Big.compareTo(self, other) < 0
end

--- @param other t.Omega.Parsable
function Big:gt(other)
    return Big.compareTo(self, other) > 0
end

--- @param other t.Omega.Parsable
function Big:lte(other)
    return Big.compareTo(self, other) <= 0
end

--- @param other t.Omega.Parsable
function Big:gte(other)
    return Big.compareTo(self, other) >= 0
end

--- @param other t.Omega.Parsable
function Big:eq(other)
    return Big.compareTo(self, other) == 0
end

-- #endregion

--- @return t.Omega
function Big:neg()
    local x = self:clone(true);
    x.sign = x.sign * -1;
    x.number = -x.number
    return x;
end

--- @return t.Omega
function Big:abs()
    if self.sign == 1 then return self end
    return self:neg()
end

--- @param other t.Omega.Parsable
--- @return t.Omega
function Big:min(other)
    if (self:lt(other)) then
        return self
    else
        return Big:ensureBig(other)
    end
end

--- @param other t.Omega.Parsable
--- @return t.Omega
function Big:max(other)
    if (self:gt(other)) then
        return self
    else
        return Big:ensureBig(other)
    end
end

--- @return t.Omega
function Big:floor()
    if (self:isint()) then
        return self
    end
    return Big:create(math.floor(self.number));
end

--- @return t.Omega
function Big:ceil()
    if (self:isint()) then
        return self
    end
    return Big:create(math.ceil(self.number));
end

--- @param target? number[]
--- @return number[]
function Big:clone_array(target)
    if not target then target = {} end
    for i, j in pairs(self:get_array()) do
        target[i] = j
    end
    return target
end

--- @return t.Omega
--- @param sameArray? boolean
function Big:clone(sameArray)
    local n = Big:new(sameArray and self:get_array() or self:clone_array(), true)
    n.sign = self.sign
    n.asize = self.asize
    n.number = self.number
    return n
end

local c1 = {}
local c2 = {}

--- @param other t.Omega.Parsable
--- @return t.Omega
function Big:add(other)
    other = Big:ensureBig(other)

    if (self.sign==-1) then
        return self:neg():add(other:neg()):neg()
    end
    if (other.sign==-1) then
        return self:sub(other:neg());
    end
    if (self:eq(B.ZERO)) then
        return other
    end
    if (other:eq(B.ZERO)) then
        return self
    end
    if (self:isNaN() or other:isNaN() or (self:isInfinite() and other:isInfinite() and self:eq(other:neg()))) then
        return B.NaN;
    end
    if (self:isInfinite()) then
        return self
    end
    if (other:isInfinite()) then
        return other
    end

    local pw=self:min(other);
    local p=pw:get_array();
    local qw=self:max(other);
    local q=qw:get_array();

    if (p[2] == 2) and not pw:gt(B.E_MAX_SAFE_INTEGER) then
        p = pw:clone_array(c1)
        p[2] = 1
        p[1] = 10 ^ p[1]
    end
    if (q[2] == 2) and not qw:gt(B.E_MAX_SAFE_INTEGER) then
        q = qw:clone_array(c2)
        q[2] = 1
        q[1] = 10 ^ q[1]
    end

    if (qw:gt(B.E_MAX_SAFE_INTEGER) or qw:div(pw):gt(B.MAX_SAFE_INTEGER)) then
        return qw;
    elseif (q[2] == nil) or (q[2] == 0) then
        return Big:create(self.number+other.number);
    elseif (q[2]==1) then
        local a
        if (p[2] ~= nil) and (p[2] ~= 0) then
            a = p[1]
        else
            a = math.log(p[1], 10)
        end
        return Big:new({a+math.log(math.pow(10,q[1]-a)+1, 10),1});
    end

    return B.NEG_ONE;
end

--- @param other t.Omega.Parsable
--- @return t.Omega
function Big:sub(other)
    other = Big:ensureBig(other)

    if (self.sign ==-1) then
        return self:neg():sub(other:neg()):neg()
    end
    if (other.sign ==-1) then
        return self:add(other:neg())
    end
    if (self:eq(other)) then
        return B.ZERO
    end
    if (other:eq(B.ZERO)) then
        return self
    end
    if (self:isNaN() or other:isNaN() or (self:isInfinite() and other:isInfinite() and self:eq(other:neg()))) then
        return B.NaN
    end
    if (self:isInfinite()) then
        return self
    end
    if (other:isInfinite()) then
        return other:neg()
    end

    local pw=self:min(other);
    local p=pw:get_array();
    local qw=self:max(other);
    local q=qw:get_array();

    local n = other:gt(self);
    if (p[2] == 2) and not pw:gt(B.E_MAX_SAFE_INTEGER) then
        p = pw:clone_array(c1)
        p[2] = 1
        p[1] = 10 ^ p[1]
    end
    if (q[2] == 2) and not qw:gt(B.E_MAX_SAFE_INTEGER) then
        q = qw:clone_array(c2)
        q[2] = 1
        q[1] = 10 ^ q[1]
    end

    if (qw:gt(B.E_MAX_SAFE_INTEGER) or qw:div(pw):gt(B.MAX_SAFE_INTEGER)) then
        local t = qw;
        if n then t = t:neg() end
        return t
    elseif (q[2] == nil) or (q[2] == 0) then
        return Big:create(self.number-other.number);
    elseif (q[2]==1) then
        local a
        if (p[2] ~= nil) and (p[2] ~= 0) then
            a = p[1]
        else
            a = math.log(p[1], 10)
        end

        local t = Big:new({a+math.log(math.pow(10,q[1]-a)-1, 10),1});
        if n then t = t:neg() end
        return t
    end

    return B.NEG_ONE;
end

--- @param other t.Omega.Parsable
--- @return t.Omega
function Big:div(other)
    other = Big:ensureBig(other);

    if (self.sign*other.sign==-1) then
        return self:abs():div(other:abs()):neg()
    end
    if (self.sign==-1) then
        return self:abs():div(other:abs())
    end
    if (self:isNaN() or other:isNaN() or (self:isInfinite() and other:isInfinite() and self:eq(other:neg()))) then
        return B.NaN
    end
    if (other:eq(B.ZERO)) then
        return B.POSITIVE_INFINITY
    end
    if (other:eq(B.ONE)) then
        return self
    end
    if (self:eq(other)) then
        return B.ONE
    end
    if (self:isInfinite()) then
        return self
    end
    if (other:isInfinite()) then
        return B.ZERO
    end
    if (self:max(other):gt(B.EE_MAX_SAFE_INTEGER)) then
        if self:gt(other) then
            return self
        else
            return B.ZERO
        end
    end

    local n = self.number/other.number;
    if (n<=MAX_SAFE_INTEGER) then
        return Big:create(n)
    end
    local pw = B.TEN:pow(self:log10():sub(other:log10()))
    local fp = pw:floor()
    if (pw:sub(fp):lt(1e-9)) then
        return fp
    end
    return pw
end

--- @param other t.Omega.Parsable
--- @return t.Omega
function Big:mul(other)
    other = Big:ensureBig(other);

    if (self.sign*other.sign==-1) then
        return self:abs():mul(other:abs()):neg()
    end
    if (self.sign==-1) then
        return self:abs():mul(other:abs())
    end
    if (self:isNaN() or other:isNaN() or (self:isInfinite() and other:isInfinite() and self:eq(other:neg()))) then
        return B.NaN
    end
    if (other:eq(B.ZERO)) or self:eq(B.ZERO) then
        return B.ZERO
    end
    if (other:eq(B.ONE)) then
        return self
    end
    if (self:eq(B.ONE)) then
        return other
    end
    if (self:isInfinite()) then
        return self
    end
    if (other:isInfinite()) then
        return other
    end
    if (self:max(other):gt(B.EE_MAX_SAFE_INTEGER)) then
        return self:max(other)
    end

    local n = self.number*other.number
    if (n<=MAX_SAFE_INTEGER) then
        return Big:create(n)
    end
    return B.TEN:pow(self:log10():add(other:log10()));
end

--- @return t.Omega
function Big:rec()
    if (self:isNaN() or self:eq(B.ZERO)) then
        return B.NaN
    end
    if (self:abs():gt(B.B2E323)) then
        return B.ZERO
    end

    return B.ONE:div(self)
end

--- @return t.Omega
function Big:logBase(base)
    return self:log10():div(base:log10())
end

Big.log = Big.logBase

--- @return t.Omega
function Big:log10()
    if (self:lt(B.ZERO)) then
        return B.NaN
    end
    if (self:eq(B.ZERO)) then
        return B.NEGATIVE_INFINITY
    end
    if (self:lte(B.MAX_SAFE_INTEGER)) then
        return Big:create(math.log(self.number, 10))
    end
    if (not self:isFinite()) then
        return self
    end
    if (self:gt(B.TETRATED_MAX_SAFE_INTEGER)) then
        return self
    end

    local x = self:clone()
    local w = x:get_array()
    w[2] = (w[2] or 0) - 1;
    return x:normalize()
end

--- @return t.Omega
function Big:ln()
    return self:log10():div(B.E_LOG)
end

--- @param other t.Omega.Parsable
--- @return t.Omega
function Big:pow(other)
    other = Big:ensureBig(other);

    if (other:eq(B.ZERO)) then
        return B.ONE
    end
    if (other:eq(B.ONE)) then
        return self
    end
    if (other:lt(B.ZERO)) then
        return self:pow(other:neg()):rec()
    end
    if (self:lt(B.ZERO) and other:isint()) then
        if (other:mod(2):lt(B.ONE)) then
            return self:abs():pow(other)
        end
        return self:abs():pow(other):neg()
    end
    if (self:lt(B.ZERO)) then
        --return B.NaN
        --Override this interaction to always make positive numbers
        return self:abs():pow(other)
    end
    if (self:eq(B.ONE)) then
        return B.ONE
    end
    if (self:eq(B.ZERO)) then
        return B.ZERO
    end
    if (self:max(other):gt(B.TETRATED_MAX_SAFE_INTEGER)) then
        return self:max(other);
    end
    if (self:eq(10)) then
        if (other:gt(B.ZERO)) then
            other = other:clone();
            local w = other:get_array()
            w[2] = (w[2] or 0) + 1;
            other:normalize();
            return other;
        else
            return Big:create(math.pow(10,other.number));
        end
    end

    if (other:lt(B.ONE)) then
        return self:root(other:rec())
    end
    local n = math.pow(self.number,other.number)
    if (n<=MAX_SAFE_INTEGER) then
        return Big:create(n);
    end
    return B.TEN:pow(self:log10():mul(other));
end

--- @return t.Omega
function Big:exp()
    return B.E:pow(self)
end

--- @param other t.Omega.Parsable
--- @return t.Omega
function Big:root(other)
    other = Big:ensureBig(other)

    if (other:eq(B.ONE)) then
        return self
    end
    if (other:lt(B.ZERO)) then
        return self:root(other:neg()):rec()
    end
    if (other:lt(B.ONE)) then
        return self:pow(other:rec())
    end
    if (self:lt(B.ZERO) and other:isint() and other:mod(2):eq(B.ONE)) then
        return self:neg():root(other):neg()
    end
    if (self:lt(B.ZERO)) then
        return B.NaN
    end
    if (self:eq(B.ONE)) then
        return B.ONE
    end
    if (self:eq(B.ZERO)) then
        return B.ZERO
    end
    if (self:max(other):gt(B.TETRATED_MAX_SAFE_INTEGER)) then
        if self:gt(other) then
            return self
        else
            return B.ZERO
        end
    end

    return B.TEN:pow(self:log10():div(other));
end

--- @return t.Omega
function Big:slog(base)
    if base == nil then
        base = 10
    end
    base = Big:ensureBig(base)

    if (self:isNaN() or base:isNaN() or (self:isInfinite() and base:isInfinite())) then
        return B.NaN
    end
    if (self:isInfinite()) then
        return self
    end
    if (base:isInfinite()) then
        return B.ZERO
    end
    if (self:lt(B.ZERO)) then
        return Big:create(-R.ONE)
    end
    if (self:lt(B.ONE)) then
        return B.ZERO
    end
    if (self:eq(base)) then
        return B.ONE
    end
    if (base:lt(math.exp(1/R.E))) then
        local a = base:tetrate(1/0)
        if (self:eq(a)) then
            return B.POSITIVE_INFINITY
        end
        if (self:gt(a)) then
            return B.NaN
        end
    end
    if (self:max(base):gt(B.SLOGLIM)) then
        if (self:gt(base)) then
            return self;
        end
        return B.ZERO
    end
    if (self:max(base):gt(B.TETRATED_MAX_SAFE_INTEGER)) then
        if self:gt(base) then
            local x = self:clone()
            local w = x:get_array()
            w[3] = (w[3] or 0) - 1
            x:normalize()
            return x:sub(w[2])
        end
        return B.ZERO
    end

    local x = self:clone()
    local w = x:get_array()
    local r = 0
    local t = (w[2] or 0) - (base:get_array()[2] or 0)
    if (t > 3) then
        local l = t - 3
        r = r + l
        w[2] = w[2] - l
    end
    for i = 0, 99 do
        if x:lt(B.ZERO) then
            x = base:pow(x)
            r = r - 1
        elseif (x:lte(B.ONE)) then
            return Big:create(r + x.number - 1)
        else
            r = r + 1
            x = x:logBase(base)
        end
    end
    if (x:gt(10)) then
        return Big:create(r)
    end
    error('?')
end

--- @return t.Omega
function Big:tetrate(other)
    if other == 1 then return self end
    other = Big:ensureBig(other)

    local negln = nil
    if (self:isNaN() or other:isNaN()) then
        return B.NaN
    end
    if (other:isInfinite() and other.sign > 0) then
        negln = self:ln():neg()
        return negln:lambertw():div(negln)
    end
    if (other:lte(-2)) then
        return B.NaN
    end
    if (self:eq(B.ZERO)) then
        if (other:eq(B.ZERO)) then
            return B.NaN
        end
        if (other:mod(2):eq(B.ZERO)) then
            return B.ZERO
        end
        return B.ONE
    end
    if (self:eq(B.ONE)) then
        if (other:eq(-1)) then
            return B.NaN
        end
        return B.ONE
    end
    if (other:eq(-1)) then
        return B.ZERO
    end
    if other:eq(B.ZERO) then
        return B.ONE
    end
    if other:eq(B.ONE) then
        return self
    end
    if other:eq(2) then
        return self:pow(self)
    end
    if self:eq(2) then
        if other:eq(3) then
            return Big:create({16})
        end
        if other:eq(4) then
            return Big:create({65536})
        end
    end

    local m = self:max(other)
    if (m:gt(Big:create("10^^^" .. tostring(R.MAX_SAFE_INTEGER)))) then
        return m
    end
    if (m:gt(B.TETRATED_MAX_SAFE_INTEGER) or other:gt(R.MAX_SAFE_INTEGER)) then
        if (self:lt(math.exp(1/R.E))) then
            negln = self:ln():neg()
            return negln:lambertw():div(negln)
        end
        local j = self:slog(10):add(other)
        local w = j:get_array()
        w[3]=(w[3] or 0) + 1
        j:normalize()
        return j
    end
    local y = other.number
    local f = math.floor(y)
    local r = self:pow(y-f)
    local l = B.NaN
    local i = 0
    local m = B.E_MAX_SAFE_INTEGER
    while ((f ~= 0) and r:lt(m) and (i < 100)) do
        if (f > 0) then
            r = self:pow(r)
            if (l:eq(r)) then
                f = 0
                break
            end
            l = r
            f = f - 1
        else
            r = r:logBase(self)
            if (l:eq(r)) then
                f = 0
                break
            end
            l = r
            f = f + 1
        end
    end
    if ((i == 100) or self:lt(math.exp(1/R.E))) then
        f = 0
    end
    local w = r:get_array()
    w[2] = (w[2] or 0) + f
    r:normalize()
    return r;
end

local maxoparray = { __index = setmetatable({ 10e9 }, { __index = function () return 8 end }) }

--- @return t.Omega
function Big:max_for_op(arrows)
    if Big.is(arrows) then
        arrows = arrows.number
    end
    if arrows < 1 or arrows ~= arrows or arrows == R.POSITIVE_INFINITY then
        return B.NaN
    end
    if arrows == 1 then
        return B.E_MAX_SAFE_INTEGER
    end
    if arrows == 2 then
        return B.TETRATED_MAX_SAFE_INTEGER
    end

    local res = Big:new({0})
    res.asize = arrows
    bigs[res] = setmetatable({ [arrows] = R.MAX_SAFE_INTEGER - 2 }, maxoparray)
    return res
end

--- @return t.Omega
function Big:arrow(arrows, other)
    arrows = to_number(arrows)
    if arrows > 1e308 then --if too big return infinity
        return B.POSITIVE_INFINITY
    end

    if self:eq(B.ONE) then return B.ONE end
    if self:eq(B.ZERO) then return B.ZERO end

    if arrows < 0 then
        return B.NaN
    end
    if arrows == 0 then
        return self:mul(other)
    end
    if arrows == 1 then
        return self:pow(other)
    end
    if arrows == 2 then
        return self:tetrate(other)
    end

    if other < 0 then
        return B.NaN
    end
    if other == 0 then
        return B.ONE
    end
    if other == 1 then
        return self
    end
    if other == 2 and self == 2 then
        return Big:create(4)
    end

    --remove potential error from before
    local arrowint = math.floor(arrows)
    if (other == 2) then return self:arrow(arrowint - 1, self) end

    local limit_plus = Big:max_for_op(arrowint+1)
    local limit = Big:max_for_op(arrowint)
    local limit_minus = Big:max_for_op(arrowint-1)
    if (self:max(other):gt(limit_plus)) then
        return self:max(other)
    end

    local r = nil
    if (self:gt(limit) or other > B.MAX_SAFE_INTEGER) or arrows >= 350 then --just kinda chosen randomly
        if (self:gt(limit)) then
            r = self:clone()
            local w = r:get_array()
            w[arrowint + 1] = w[arrowint + 1] - 1
            if arrowint < 25000 then --arbitrary, normalisation is just extra steps when you get high enough
                r:normalize()
            end
        elseif (self:gt(limit_minus)) then
            r = Big:create(self:get_array()[arrowint])
        else
            r = B.ZERO
        end
        local j = r:add(other)
        local w = j:get_array()
        w[arrowint+1] = (w[arrowint+1] or 0) + 1
        j:normalize()
        return j
    end

    local y = Big.is(other) and other.number or other
    local f = math.floor(y)
    local arrows_m1 = arrows - 1
    local i = 0
    local m = limit_minus
    r = self:arrow(arrows_m1, y-f)
    while (f ~= 0) and r:lt(m) and (i<100) do
        if (f > 0) then
            r = self:arrow(arrows_m1, r)
            f = f - 1
        end
        i = i + 1
    end
    if (i == 100) then
        f = 0
    end
    local w = r:get_array()
    w[arrowint] = (w[arrowint] or 0) + f
    r:normalize()
    return r
end

--- @return t.Omega
function Big:mod(other)
    other = Big:ensureBig(other)
    if (other:eq(B.ZERO)) then
        return B.NaN
    end
    if (self.sign*other.sign == -1) then
        return self:abs():mod(other:abs()):neg()
    end
    if (self.sign==-1) then
        return self:abs():mod(other:abs())
    end
    return self:sub(self:div(other):floor():mul(other))
end

--- @return t.Omega
function Big:lambertw()
    local arr = self:get_array()
    if (self:isNaN()) then
        return self
    end
    if (self:lt(-0.3678794411710499)) then
        error("lambertw is unimplemented for results less than -1, sorry!")
    end
    if (self:gt(B.TETRATED_MAX_SAFE_INTEGER)) then
        return self
    end
    if (self:gt(B.EE_MAX_SAFE_INTEGER)) then
        arr[1] = arr[1] - 1
        return self
    end
    if (self:gt(B.E_MAX_SAFE_INTEGER)) then
        return Big:d_lambertw(self)
    else
        return Big:create(Big:f_lambertw(self.sign*arr[1]))
    end
end

--- @return t.Omega
function Big:f_lambertw(z)
    local tol = 1e-10
    local w = nil
    local wn = nil
    if (not Big:ensureBig(z):isFinite()) then
        return z;
    end
    if z == 0 then
        return B.ZERO;
    end
    if z == 1 then
        return B.LOMEGA
    end
    if (z < 10) then
        w = 0
    else
        w = math.log(z) - math.log(math.log(z))
    end
    for i=0,99 do
        wn = (z*math.exp(-w)+w*w)/(w+1)
        if (math.abs(wn-w)<tol*math.abs(wn)) then
            return wn
        end
        w=wn
    end
    error("Iteration failed to converge: "+z)
end

--- @return t.Omega
function Big:d_lambertw(z)
    local tol = 1e-10
    z = Big:ensureBig(z)
    local w = nil
    local ew = nil
    local wewz = nil
    local wn = nil
    if (not z:isFinite()) then
        return z
    end
    if (z == 0) then
        return B.ZERO
    end
    if (z == 1) then
        return B.LOMEGA
    end
    w = z:ln()
    for i=0, 99 do
        ew = w:neg():exp()
        wewz = w:sub(z:mul(ew))
        wn = w:sub(wewz:div(w:add(B.ONE):sub((w:add(2)):mul(wewz):div((w:mul(2):add(2))))))
        if (wn:sub(w):abs():lt(wn:abs():mul(tol))) then
            return wn
        end
        w = wn
    end
    error("Iteration failed to converge: "+z)
end

-- #region conversions

--- @return number
function Big:_to_number()
    local arr = self:get_array()
    if self.sign == -1 then return -1 * self:neg():_to_number() end

    if not arr[1] then return 0 end
    if arr[2] == nil then arr[2] = 0 end
    if arr[3] == nil then arr[3] = 0 end

    if self.asize == 1 then
        return arr[1]
    end
    if self.asize >= 2 and ((arr[2] >= 2) or (arr[2] == 1) and (arr[1] > 308)) then
        return R.POSITIVE_INFINITY;
    end
    if self.asize >= 3 and ((arr[1] >= 3) or (arr[2] >= 1) or (arr[3] >= 1)) then
        return R.POSITIVE_INFINITY;
    end
    if self.asize >= 4 and ((arr[1] > 1) or (arr[2] >= 1) or (arr[3] >= 1)) then
        for i, v in pairs(arr) do
            if arr[i] > 0 and i > 4 then
                return R.POSITIVE_INFINITY;
            end
        end
    end
    if (Big.is(arr[1])) then
        arr[1] = self.array[1].number --- @diagnostic disable-line
    end
    if (arr[2]==1) then
        return math.pow(10,arr[1]);
    end
    return arr[1];
end

function Big:to_number()
    return self.number
end

--- @class t.Omega.Low
--- @field array number[]
--- @field sign number
--- @field val number
--- @field __talisman boolean

--- @return t.Omega.Low
function Big:as_table()
    return {
        array = bigs[self],
        sign = self.sign,
        val = self:min(B.MAX_VALUE).number,
        __talisman = true
    }
end

function Big:get_array()
    return bigs[self]
end

-- #endregion

-- #region strings

local function AThousandNotation(n, places)
    local raw = string.format("%." .. places .."f", n)
    local result = ""
    local comma = string.find(raw, "%.")

    if comma == nil then
        comma = #raw
    else
        comma = comma - 1
    end

    for i = 1, #raw do
        result = result .. string.sub(raw, i, i)
        if (comma - i) % 3 == 0 and i < comma then
            result = result .. ","
        end
    end
    return result
end

--- @return string
function Big:toString()
    local arr = self:get_array()
    if (self.sign==-1) then
        return "-" .. self:abs():toString()
    end
    if (arr[1] ~= arr[1]) then
        return "NaN"
    end
    -- if (!isFinite(this.array[0])) return "Infinity";
    local s = "";
    if (self.asize>=2) then
        for i=self.asize,3,-1 do
            local q = nil
            if (i >= 6) then
                q = "{"..(i-1).."}"
            else
                q = string.rep("^", i-1)
            end
            if (arr[i] and arr[i]>1) then
                s = s .."(10" .. q .. ")^" .. AThousandNotation(arr[i], 0) .. " "
            elseif (arr[i]==1) then
                s= s .."10" .. q;
            end
        end
    end
    if (arr[2] == nil) or (arr[2] == 0) then
        if (arr[1] <= 9e9) then
            s = s .. AThousandNotation(arr[1], 2)
        else
            local exponent = math.floor(math.log(arr[1], 10))
            local mantissa = math.floor((arr[1] / (10^exponent))*100)/100
            s = s .. AThousandNotation(mantissa, 2) .. "e" .. AThousandNotation(exponent, 0)
        end
    elseif (arr[2]<3) then
        s = s .. string.rep("e", arr[2]-1) .. AThousandNotation(math.pow(10,arr[1]-math.floor(arr[1])), 2) .. "e" .. AThousandNotation(math.floor(arr[1]), 0);
    elseif (arr[2]<8) then
        s = s .. string.rep("e", arr[2]) .. AThousandNotation(arr[1], 0)
    else
        s = s .. "(10^)^" .. AThousandNotation(arr[2], 0) .. " " .. AThousandNotation(arr[1],0)
    end
    return s
end

local function log10LongString(str)
    return math.log(tonumber(string.sub(str, 1, LONG_STRING_MIN_LENGTH)), 10)+(string.len(str)- LONG_STRING_MIN_LENGTH);
end

--- @return t.Omega
function Big:parse(input)
    local t = Big:new({0})
    local arr = t:get_array()
    local negateIt = false
    while ((string.sub(input, 1, 1)=="-") or (string.sub(input, 1, 1)=="+")) do
        if (string.sub(input, 1, 1)=="-") then
            negateIt = not negateIt
        end
        input = string.sub(input, 2);
    end
    if (input=="NaN") or (input=="nan") then
        arr = {R.NaN}
        bigs[t] = arr
    elseif (input=="Infinity") or (input=="inf") then
        arr = {R.POSITIVE_INFINITY}
        bigs[t] = arr
    else
        --- @type number | number[]
        local a = 0
        --- @type number | number[]
        local b = 0
        local c = 0
        local d = 0
        local i = 0
        while (string.len(input) > 0) do
            local passTest = false
            if true then
                local j = 1
                if string.sub(input, 1, 1) == "(" then
                    j = j + 1
                end
                if (string.sub(input, j, j+1) == "10") and ((string.sub(input, j+2, j+2) == "^") or (string.sub(input, j+2, j+2) == "{")) then
                    passTest = true
                end
            end
            if (passTest) then
                if (string.sub(input, 1, 1) == "(") then
                input = string.sub(input, 2);
                end
                local arrows = -1;
                if (string.sub(input, 3, 3)=="^") then
                    arrows = 3
                    while (string.sub(input, arrows, arrows) == "^") do
                        arrows = arrows + 1
                    end
                    arrows = arrows - 3
                    a = arrows
                    b = arrows + 2;
                else
                    a = 1
                    while (string.sub(input, a, a) ~= "}") do
                        a = a + 1
                    end
                    arrows=tonumber(string.sub(input, 4, a - 1))+1;
                    b = a + 1
                end
                input = string.sub(input, b + 1);
                if (string.sub(input, 1, 1) == ")") then
                    a = 1
                    while (string.sub(input, a, a) ~= " ") do
                        a = a + 1
                    end
                    c = tonumber(string.sub(input, 3, a - 1)) or 0;
                    input = string.sub(input, a+1);
                else
                    c = 1
                end
                if (arrows==1) then
                    arr[2] = (arr[2] or 0) + c;
                elseif (arrows==2) then
                    a = arr[2] or 0;
                    b = arr[1] or 0;
                    if (b>=1e10) then
                        a = a + 1
                    end
                    if (b>=10) then
                        a = a + 1
                    end
                    arr[1]=a;
                    arr[2]=0;
                    arr[3]=(arr[3] or 0)+c;
                else
                    a=arr[arrows] or 0;
                    b=arr[arrows-1] or 0;
                    if (b>=10) then
                        a = a + 1
                    end
                    for i=1, arrows do
                        arr[i] = 0;
                    end
                    arr[1]=a;
                    arr[arrows+1] = (arr[arrows+1] or 0) + c;
                end
            else
                break
            end
        end
        a = {""} --- @diagnostic disable-line
        while (string.len(input) > 0) do
            if ((string.sub(input, 1, 1) == "e") or (string.sub(input, 1, 1) == "E")) then
                a[#a + 1] = ""
            else
                a[#a] = a[#a] .. string.sub(input, 1, 1)
            end
            input = string.sub(input, 2);
        end
        if a[#a] == "" then
            a[#a] = nil
        end
        b={arr[1],0};
        c=1;
        for i=#a, 1, -1 do
            if ((b[1] < MAX_E) and (b[2]==0)) then
                b[1] = math.pow(10,c*b[1]);
            elseif (c==-1) then
                if (b[2]==0) then
                    b[1]=math.pow(10,c*b[1]);
                elseif ((b[2]==1) and (b[1]<=308)) then
                    b[1] = math.pow(10,c*math.pow(10,b[1]));
                else
                    b[1]=0;
                end
                b[2]=0;
            else
                b[2] = b[2] + 1;
            end
            local decimalPointPos = 1;
            while ((string.sub(a[i], decimalPointPos, decimalPointPos) ~= ".") and (decimalPointPos <= #a[i])) do
                decimalPointPos = decimalPointPos + 1
            end
            if decimalPointPos == #a[i] + 1 then
                decimalPointPos = -1
            end
            local intPartLen = -1
            if (decimalPointPos == -1) then
                intPartLen = #a[i] + 1
            else
                intPartLen = decimalPointPos
            end
            if (b[2] == 0) then
                if (intPartLen - 1 >= LONG_STRING_MIN_LENGTH) then
                    b[1] = math.log10(b[1]) + log10LongString(string.sub(a[i], 1, intPartLen - 1))
                    b[2] = 1;
                elseif ((a[i] ~= nil) and (a[i] ~= "") and (tonumber(a[i]) ~= nil)) then
                    b[1] = b[1] * tonumber(a[i]);
                end
            else
                d=-1
                if (intPartLen - 1 >= LONG_STRING_MIN_LENGTH) then
                    d = log10LongString(string.sub(a[i], 1,intPartLen - 1))
                else
                    if (a[i] ~= nil) and (a[i] ~= "") and (tonumber(a[i]) ~= nil) then
                        d = math.log(tonumber(a[i]), 10)
                    else
                        d = 0
                    end
                end
                if (b[2]==1) then
                    b[1] = b[1] + d;
                elseif ((b[2]==2) and (b[1]<MAX_E+math.log(d, 10))) then
                    b[1] = b[1] + math.log(1+math.pow(10,math.log10(d)-b[0]), 10);
                end
            end
            if ((b[1]<MAX_E) and (b[2] ~= 0) and (b[2] ~= nil)) then
                b[1]=math.pow(10,b[1]);
                b[2] = b[2] - 1;
            elseif (b[1]>MAX_SAFE_INTEGER) then
                b[1] = math.log(b[1], 10);
                b[2] = b[2] + 1;
            end
        end
        arr[1]= b[1];
        arr[2]= (arr[2] or 0) + b[2];
    end
    if (negateIt) then
        t.sign = t.sign * -1
    end
    t:normalize();
    return t;
end

-- #endregion

-- #region metastuff

function OmegaMeta.__unm(b)
    return b:neg()
end

function OmegaMeta.__add(b1, b2)
    return Big:ensureBig(b1):add(b2)
end

function OmegaMeta.__sub(b1, b2)
    return Big:ensureBig(b1):sub(b2)
end

function OmegaMeta.__mul(b1, b2)
    return Big:ensureBig(b1):mul(b2)
end

function OmegaMeta.__div(b1, b2)
    return Big:ensureBig(b1):div(b2)
end

function OmegaMeta.__mod(b1, b2)
    return Big:ensureBig(b1):mod(b2)
end

function OmegaMeta.__pow(b1, b2)
    return Big:ensureBig(b1):pow(b2)
end

OmegaMeta.__le = Big.lte
OmegaMeta.__lt = Big.lt
OmegaMeta.__ge = Big.gte
OmegaMeta.__gt = Big.gt
OmegaMeta.__eq = Big.eq

function OmegaMeta.__tostring(b)
    return number_format(b)
end

function OmegaMeta.__concat(a, b)
    return tostring(a) .. tostring(b)
end

ffi.metatype(TalismanOmega, OmegaMeta)

for k,v in pairs(Big) do
    if type(v) == "function" then
        OmegaMeta.__index[k] = v --- @diagnostic disable-line
    end
end

-- #endregion

for i,v in pairs(R) do
    B[i] = Big:create(v)
    if v == v then
        caches.list[v] = B[i]
    end
end

B.LOMEGA = Big:create(0.56714329040978387299997)
B.E_LOG = B.E:log10()
B.B2E323 = Big:create("2e323")
B.SLOGLIM = Big:create("10^^^" .. R.MAX_SAFE_INTEGER)

local update = love.update
function love.update(...)
    caches.frames = {}
    return update(...)
end

return Big