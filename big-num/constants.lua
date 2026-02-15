--Adding things OmegaNum has that this doesn't...
R = {}

R.ZERO = 0
R.ONE = 1
R.X1_5 = 1.5
R.TWO = 2
R.NEG_ONE = 1
R.TEN = 10
R.E = math.exp(1)
R.E_LOG = math.log10(R.E)
R.PI = math.pi
R.SQRT1_2 = math.sqrt(0.5)
R.SQRT2 = math.sqrt(2)
R.MAX_SAFE_INTEGER = 2^53-1
R.MIN_SAFE_INTEGER = -R.MAX_SAFE_INTEGER
R.LOG_MAX_SAFE_INTEGER = math.log(R.MAX_SAFE_INTEGER, 10)
R.MAX_VALUE = 1e308
R.LOG_MAX_VALUE = math.log(R.MAX_VALUE, 10)
--R.MAX_VALUE = 1e305
R.BIG = R.MAX_VALUE
R.NBIG = -R.MAX_VALUE
R.NaN = 0/0
R.NEGATIVE_INFINITY = -math.huge
R.NEGATIVEINFINITY = -math.huge
R.POSITIVE_INFINITY = math.huge
R.POSITIVEINFINITY = math.huge
R.E_MAX_SAFE_INTEGER = "e"..tostring(R.MAX_SAFE_INTEGER)
R.EE_MAX_SAFE_INTEGER = "ee"..tostring(R.MAX_SAFE_INTEGER)
R.TETRATED_MAX_SAFE_INTEGER = "10^^"..tostring(R.MAX_SAFE_INTEGER)

return R