using Mimi
using DataFrames
using Base.Test

include("../src/utils/load_parameters.jl")
include("../src/components/TotalAdaptationCosts.jl")

m = Model()
setindex(m, :time, [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200])
setindex(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])

addtotaladaptationcosts(m)

setparameter(m, :TotalAdaptationCosts, :pop_population, readpagedata(m, "test/validationdata/pop_population.csv"))
setparameter(m, :TotalAdaptationCosts, :ac_adaptationcosts_economic, readpagedata(m, "test/validationdata/ac_adaptationcosts_economic.csv"))
setparameter(m, :TotalAdaptationCosts, :ac_adaptationcosts_noneconomic, readpagedata(m, "test/validationdata/ac_adaptationcosts_noneconomic.csv"))
setparameter(m, :TotalAdaptationCosts, :ac_adaptationcosts_sealevelrise, readpagedata(m, "test/validationdata/ac_adaptationcosts_sealevelrise.csv"))

run(m)

# Generated data
adapt_cost = m[:TotalAdaptationCosts, :act_adaptationcosts_total]
adapt_cost_per_cap = m[:TotalAdaptationCosts, :act_percap_adaptationcosts]

# Recorded data
cost_compare = readpagedata(m, "test/validationdata/act_adaptationcosts_tot.csv")
cost_cap_compare = readpagedata(m, "test/validationdata/act_percap_adaptationcosts.csv")

@test adapt_cost ≈ cost_compare rtol=1e-3
@test adapt_cost_per_cap ≈ cost_cap_compare rtol=1e-6
