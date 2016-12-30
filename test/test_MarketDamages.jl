using Mimi
using DataFrames

include("../src/load_parameters.jl")
include("../src/MarketDamages.jl")

m = Model()
setindex(m, :time, [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200])
setindex(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])

marketdamages=addmarketdamages(m)

marketdamages[ :rt_realizedtemperature] = ones(10,8)
marketdamages[ :rcons_per_cap_SLRRemainConsumption] = ones(10,8)
marketdamages[ :rgdp_per_cap_SLRRemainGDP] = ones(10,8)
marketdamages[ :atl_adjustedtolerableleveloftemprise] = ones(10,8)
marketdamages[ :imp_actualreduction] = ones(10,8)*0.5

p = load_parameters(m)
p["y_year_0"] = 2008.
p["y_year"] = m.indices_values[:time]
setleftoverparameters(m, p)

run(m)
