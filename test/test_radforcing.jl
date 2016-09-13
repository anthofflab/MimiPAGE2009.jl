using DataFrames

radforcing = readtable("../calibration/rcp85-radforcing.csv")

# Run the model
include("../src/main_model.jl")

# Pull out the particular years
rows = convert(Vector{Bool}, map(year -> in(year, m.indices_values[:time]), radforcing[:, 1]))

DataFrame(co2_estimated=m[:co2forcing, :f_CO2forcing], co2_observed=radforcing[rows, :CO2_RF])
