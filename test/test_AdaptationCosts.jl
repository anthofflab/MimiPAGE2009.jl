using Mimi
using DataFrames

include("../src/load_parameters.jl")
include("../src/AdaptationCosts.jl")

m = Model()
setindex(m, :time, [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200])
setindex(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])

adaptationcosts_noneconomic = addadaptationcosts_noneconomic(m)
adaptationcosts_noneconomic[:atl_adjustedtolerablelevel] = zeros(10, 8)
adaptationcosts_noneconomic[:imp_adaptedimpacts] = zeros(10, 8)

p = load_parameters(m)
p["y_year_0"] = 2008.
p["y_year"] = m.indices_values[:time]
p["gdp"] = transpose(repmat(readpagedata(m, "../data/gdp_0.csv"), 1, 10))
setleftoverparameters(m, p)

run(m)
