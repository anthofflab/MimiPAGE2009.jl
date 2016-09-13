using DataFrames

radforcing = readtable("../calibration/rcp85-radforcing.csv")

# Pull out the particular years
rows = convert(Vector{Bool}, map(year -> in(year, m.indices_values[:time]), radforcing[:, 1]))

# Run the model
include("../src/main_model.jl")

DataFrame(co2_estimated=m[:co2forcing, :f_CO2forcing], co2_observed=radforcing[rows, :CO2_RF])
