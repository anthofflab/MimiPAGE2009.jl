using Mimi
using DataFrames

include("../src/load_parameters.jl")
include("../src/NonMarketDamages.jl")

m = Model()
setindex(m, :time, [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200])
setindex(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])

addnonmarketdamages(m)

setparameter(m, :NonMarketDamages, :rt_realizedtemperature, ones(10,8))
setparameter(m, :NonMarketDamages, :rcons_per_cap_MarketRemainConsumption, ones(10,8))
setparameter(m, :NonMarketDamages, :rgdp_per_cap_MarketRemainGDP, ones(10,8))

p = load_parameters(m)
p["y_year_0"] = 2008.
p["y_year"] = m.indices_values[:time]
setleftoverparameters(m, p)

run(m)
