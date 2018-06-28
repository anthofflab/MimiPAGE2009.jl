using Mimi
using DataFrames
using Base.Test

include("../src/utils/load_parameters.jl")
include("../src/components/TotalAbatementCosts.jl")

m = Model()
set_dimension!(m, :time, [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200])
set_dimension!(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])

addcomponent(m, TotalAbatementCosts)

set_parameter!(m, :TotalAbatementCosts, :pop_population, readpagedata(m, "test/validationdata/pop_population.csv"))
set_parameter!(m, :TotalAbatementCosts, :tc_totalcosts_co2, readpagedata(m, "test/validationdata/tc_totalcosts_co2.csv"))
set_parameter!(m, :TotalAbatementCosts, :tc_totalcosts_ch4, readpagedata(m, "test/validationdata/tc_totalcosts_ch4.csv"))
set_parameter!(m, :TotalAbatementCosts, :tc_totalcosts_n2o, readpagedata(m, "test/validationdata/tc_totalcosts_n2o.csv"))
set_parameter!(m, :TotalAbatementCosts, :tc_totalcosts_linear, readpagedata(m, "test/validationdata/tc_totalcosts_linear.csv"))

run(m)

# Generated data
abate_cost = m[:TotalAbatementCosts, :tct_totalcosts]
abate_cost_per_cap = m[:TotalAbatementCosts, :tct_per_cap_totalcostspercap]

# Recorded data
cost_compare = readpagedata(m, "test/validationdata/tct_totalcosts.csv")
cost_cap_compare = readpagedata(m, "test/validationdata/tct_per_cap_totalcostspercap.csv")

@test abate_cost ≈ cost_compare rtol=1e-4
@test abate_cost_per_cap ≈ cost_cap_compare rtol=1e-7
