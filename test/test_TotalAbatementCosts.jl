using Mimi
using DataFrames
using Base.Test

include("../src/load_parameters.jl")
include("../src/TotalAbatementCosts.jl")

m = Model()
setindex(m, :time, [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200])
setindex(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])

addtotalabatementcosts(m)

setparameter(m, :TotalAbatementCosts, :pop_population, readpagedata(m, joinpath(dirname(@__FILE__), "validationdata","pop_population.csv")))
setparameter(m, :TotalAbatementCosts, :tc_totalcosts_co2, readpagedata(m, joinpath(dirname(@__FILE__), "validationdata","tc_totalcosts_co2.csv")))
setparameter(m, :TotalAbatementCosts, :tc_totalcosts_ch4, readpagedata(m, joinpath(dirname(@__FILE__), "validationdata","tc_totalcosts_ch4.csv")))
setparameter(m, :TotalAbatementCosts, :tc_totalcosts_n2o, readpagedata(m, joinpath(dirname(@__FILE__), "validationdata","tc_totalcosts_n2o.csv")))
setparameter(m, :TotalAbatementCosts, :tc_totalcosts_linear, readpagedata(m, joinpath(dirname(@__FILE__), "validationdata","tc_totalcosts_linear.csv")))

p = load_parameters(m)
setleftoverparameters(m, p)

run(m)

# Generated data
abate_cost = m[:TotalAbatementCosts, :tct_totalcosts]
abate_cost_per_cap = m[:TotalAbatementCosts, :tct_per_cap_totalcostspercap]

# Recorded data
cost_compare = readpagedata(m, joinpath(dirname(@__FILE__), "validationdata","tct_totalcosts.csv"))
cost_cap_compare = readpagedata(m, joinpath(dirname(@__FILE__),"validationdata","tct_per_cap_totalcostspercap.csv"))

@test_approx_eq_eps abate_cost cost_compare 1e-6
@test_approx_eq_eps abate_cost_per_cap cost_cap_compare 1e-6

# Need total costs csv
# Need to review total costs per cap csv
