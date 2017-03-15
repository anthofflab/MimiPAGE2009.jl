using Mimi
using DataFrames
using Base.Test

include("../src/load_parameters.jl")
include("../src/TotalAdaptationCosts.jl")

m = Model()
setindex(m, :time, [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200])
setindex(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])

addtotaladaptationcosts(m)

setparameter(m, :TotalAdaptationCosts, :pop_population, readpagedata(m, joinpath(dirname(@__FILE__), "validationdata","pop_population.csv")))
setparameter(m, :TotalAdaptationCosts, :ac_adaptationcosts_economic, readpagedata(m, joinpath(dirname(@__FILE__), "validationdata","ac_adaptationcosts_economic.csv")))
setparameter(m, :TotalAdaptationCosts, :ac_adaptationcosts_noneconomic, readpagedata(m, joinpath(dirname(@__FILE__), "validationdata","ac_adaptationcosts_noneconomic.csv")))
setparameter(m, :TotalAdaptationCosts, :ac_adaptationcosts_sealevelrise, readpagedata(m, joinpath(dirname(@__FILE__), "validationdata","ac_adaptationcosts_sealevelrise.csv")))

#p = load_parameters(m)
#setleftoverparameters(m, p)

run(m)

# Generated data
adapt_cost = m[:TotalAdaptationCosts, :act_adaptationcosts_total]
adapt_cost_per_cap = m[:TotalAdaptationCosts, :act_percap_adaptationcosts]

# Recorded data
cost_compare = readpagedata(m, joinpath(dirname(@__FILE__),
    "validationdata","act_adaptationcosts_tot.csv"))
cost_cap_compare = readpagedata(m, joinpath(dirname(@__FILE__), "validationdata","act_percap_adaptationcosts.csv"))

@test_approx_eq_eps adapt_cost cost_compare 1e3
@test_approx_eq_eps adapt_cost_per_cap cost_cap_compare 1e1
