using Mimi
using Base.Test

include("../src/utils/load_parameters.jl")
include("../src/components/GDP.jl")

m = Model()

set_dimension!(m, :time, convert(Vector{Float64}, [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200]))
set_dimension!(m, :region, ["EU", "USA", "OECD", "USSR", "China", "SEAsia", "Africa", "LatAmerica"])

gdp = addcomponent(m, GDP)

gdp[:pop0_initpopulation] = readpagedata(m, "data/pop0_initpopulation.csv")
gdp[:pop_population] = readpagedata(m, "test/validationdata/pop_population.csv")
gdp[:y_year] = Mimi.dim_keys(m.md, :time)
gdp[:y_year_0] = 2008.

p=load_parameters(m)
set_leftover_params!(m,p)

# run model
run(m)

# Generated data
gdp = m[:GDP, :gdp]

# Recorded data
gdp_compare = readpagedata(m, "test/validationdata/gdp.csv")

@test gdp ≈ gdp_compare rtol=100

cons_percap_consumption_0_compare = readpagedata(m, "test/validationdata/cons_percap_consumption_0.csv")
@test m[:GDP, :cons_percap_consumption_0] ≈ cons_percap_consumption_0_compare rtol=1e-2
