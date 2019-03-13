
using DataFrames
using Test

m = page_model()
include("../src/components/TotalAbatementCosts.jl")

add_comp!(m, TotalAbatementCosts)

set_param!(m, :TotalAbatementCosts, :pop_population, readpagedata(m, "test/validationdata/pop_population.csv"))
set_param!(m, :TotalAbatementCosts, :tc_totalcosts_co2, readpagedata(m, "test/validationdata/tc_totalcosts_co2.csv"))
set_param!(m, :TotalAbatementCosts, :tc_totalcosts_ch4, readpagedata(m, "test/validationdata/tc_totalcosts_ch4.csv"))
set_param!(m, :TotalAbatementCosts, :tc_totalcosts_n2o, readpagedata(m, "test/validationdata/tc_totalcosts_n2o.csv"))
set_param!(m, :TotalAbatementCosts, :tc_totalcosts_linear, readpagedata(m, "test/validationdata/tc_totalcosts_linear.csv"))

run(m)

# Generated data
abate_cost = m[:TotalAbatementCosts, :tct_totalcosts]
abate_cost_per_cap = m[:TotalAbatementCosts, :tct_per_cap_totalcostspercap]

# Recorded data
cost_compare = readpagedata(m, "test/validationdata/tct_totalcosts.csv")
cost_cap_compare = readpagedata(m, "test/validationdata/tct_per_cap_totalcostspercap.csv")

@test abate_cost ≈ cost_compare rtol=1e-4
@test abate_cost_per_cap ≈ cost_cap_compare rtol=1e-7
