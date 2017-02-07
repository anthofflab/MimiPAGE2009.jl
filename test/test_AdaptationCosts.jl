using Mimi
using DataFrames
using Base.Test

include("../src/load_parameters.jl")
include("../src/AdaptationCosts.jl")

m = Model()
setindex(m, :time, [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200])
setindex(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])

adaptationcosts_noneconomic = addadaptationcosts_noneconomic(m)
adaptationcosts_economic = addadaptationcosts_economic(m)
adaptationcosts_sealevel = addadaptationcosts_sealevel(m)

p = load_parameters(m)
p["y_year_0"] = 2008.
p["y_year"] = m.indices_values[:time]
p["gdp"] = transpose(repmat(readpagedata(m, "../data/gdp_0.csv"), 1, 10))
setleftoverparameters(m, p)

run(m)

@test !isna(m[:AdaptiveCostsNonEconomic, :ac_adaptivecosts][10, 5])
@test !isna(m[:AdaptiveCostsEconomic, :ac_adaptivecosts][10, 5])
@test !isna(m[:AdaptiveCostsSeaLevel, :ac_adaptivecosts][10, 5])
