using Mimi
using DataFrames

include("../src/load_parameters.jl")
include("../src/TotalAdaptationCosts.jl")

m = Model()
setindex(m, :time, [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200])
setindex(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])

addtotaladaptationcosts(m)

setparameter(m, :TotalAdaptationCosts, :pop_population, ones(10,8))
setparameter(m, :TotalAdaptationCosts, :ac_adaptationcosts_economic, ones(10,8))
setparameter(m, :TotalAdaptationCosts, :ac_adaptationcosts_noneconomic, ones(10,8))
setparameter(m, :TotalAdaptationCosts, :ac_adaptationcosts_sealevelrise, ones(10,8))

p = load_parameters(m)
setleftoverparameters(m, p)

run(m)
