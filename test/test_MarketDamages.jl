using Mimi
using DataFrames
using Base.Test

include("../src/load_parameters.jl")
include("../src/MarketDamages.jl")

m = Model()
setindex(m, :time, [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200])
setindex(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])

marketdamages = addmarketdamages(m)

marketdamages[ :isatg_impactfxnsaturation] = 28.33333
setparameter(m, :MarketDamages, :rt_realizedtemperature, readpagedata(m, "../test/validationdata/rt_realizedtemperature.csv"))
setparameter(m, :MarketDamages, :rcons_per_cap_SLRRemainConsumption, readpagedata(m,
"../test/validationdata/rcons_per_cap_SLRRemainConsumption.csv"))
setparameter(m, :MarketDamages, :rgdp_per_cap_SLRRemainGDP, readpagedata(m,
"../test/validationdata/rgdp_per_cap_SLRRemainGDP.csv"))
setparameter(m, :MarketDamages, :atl_adjustedtolerableleveloftemprise, readpagedata(m,
"../test/validationdata/atl_adjustedtolerableleveloftemprise_market.csv"))
setparameter(m, :MarketDamages, :imp_actualreduction, readpagedata(m,
"../test/validationdata/imp_actualreduction_market.csv"))


p = load_parameters(m)
p["y_year_0"] = 2008.
p["y_year"] = m.indices_values[:time]
setleftoverparameters(m, p)

run(m)

rcons_per_cap = m[:MarketDamages, :rcons_per_cap_MarketRemainConsumption]
rcons_per_cap_compare = readpagedata(m, "../test/validationdata/rcons_per_cap_MarketRemainConsumption.csv")
@test_approx_eq_eps ones(10, 8) rcons_per_cap ./ rcons_per_cap_compare .01

rgdp_per_cap = m[:MarketDamages, :rgdp_per_cap_MarketRemainGDP]
rgdp_per_cap_compare = readpagedata(m, "../test/validationdata/rgdp_per_cap_MarketRemainGDP.csv")
@test_approx_eq_eps ones(10, 8) rgdp_per_cap ./ rgdp_per_cap_compare 0.02
