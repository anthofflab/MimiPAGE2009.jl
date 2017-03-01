using Mimi
using Base.Test

include("../src/load_parameters.jl")
include("../src/Population.jl")

m = Model()
setindex(m, :time, convert(Vector{Float64}, [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200]))
setindex(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])

population = addpopulation(m)
population[:y_year_0] = 2008.
population[:y_year] = m.indices_values[:time]

p = load_parameters(m)

setleftoverparameters(m, p)
#setparameter(m,:Population, :y_year_0, 2008.)

run(m)

# Generated data
pop = m[:Population, :pop_population]

# Recorded data
pop_compare = readpagedata(m, "validationdata/pop_population.csv")

@test_approx_eq_eps pop pop_compare 1e-3
