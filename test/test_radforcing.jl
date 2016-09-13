using DataFrames

radforcing = readtable(joinpath(dirname(@__FILE__), "..", "calibration", "rcp85-radforcing.csv"))

# Run the model
include("../src/main_model.jl")

# Pull out the particular years
rows = convert(Vector{Bool}, map(year -> in(year, m.indices_values[:time]), radforcing[:, 1]))

# CO2
DataFrame(co2_estimated=m[:co2forcing, :f_CO2forcing], co2_observed=radforcing[rows, :CO2_RF])

# CH4
DataFrame(ch4_estimated=m[:ch4forcing, :f_CH4forcing], ch4_observed=radforcing[rows, :CH4_RF])

# N2O
DataFrame(n2o_estimated=m[:n2oforcing, :f_N2Oforcing], n2o_observed=radforcing[rows, :N2O_RF])
