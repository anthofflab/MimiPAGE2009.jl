using Mimi
using DataFrames

include("../src/load_parameters.jl")
include("../src/NonMarketDamages.jl")

m = Model()
setindex(m, :time, [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200])
setindex(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])

addnonmarketdamages(m)

setparameter(m, :NonMarketDamages, :rt_realizedtemperature, readtable("data/er_N2Oemissionsgrowth.csv"))
setparameter(m, :NonMarketDamages, :rcons_per_cap_MarketRemainConsumption, readtable("data/er_N2Oemissionsgrowth.csv"))
setparameter(m, :NonMarketDamages, :rgdp_per_cap_MarketRemainGDP, )

p = load_parameters(m)
p["y_year_0"] = 2008.
p["y_year"] = m.indices_values[:time]
setleftoverparameters(m, p)

run(m)
