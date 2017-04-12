using Mimi
using Base.Test

include("../src/load_parameters.jl")
include("../src/GDP.jl")

m = Model()

setindex(m, :time, convert(Vector{Float64}, [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200]))
setindex(m, :region, ["EU", "USA", "OECD", "USSR", "China", "SEAsia", "Africa", "LatAmerica"])

gdp = addgdp(m)
gdp[:pop0_initpopulation] = readpagedata(m, "data/pop0_initpopulation.csv")
gdp[:pop_population] = readpagedata(m, "test/validationdata/pop_population.csv")
gdp[:y_year] = m.indices_values[:time]
gdp[:y_year_0] = 2008.

p=load_parameters(m)
setleftoverparameters(m,p)

# run model
run(m)

# Generated data
gdp = m[:GDP, :gdp]

# Recorded data
gdp_compare = readpagedata(m, "test/validationdata/gdp.csv")

@test_approx_eq_eps gdp gdp_compare 100

cons_percap_consumption_0_compare = readpagedata(m, "test/validationdata/cons_percap_consumption_0.csv")
@test_approx_eq_eps m[:GDP, :cons_percap_consumption_0] cons_percap_consumption_0_compare 1e-2
