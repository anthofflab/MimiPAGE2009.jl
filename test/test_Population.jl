using Mimi
using Base.Test

include("../src/load_parameters.jl")
include("../src/Population.jl")

m = Model()
setindex(m, :time, [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200])
setindex(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])

population = addpopulation(m)
#population[:y_year_0] = 2008.
p = load_parameters(m)
p[:y_year] = m.indices_values[:time]
p[:y_year_0] = 2008.

setleftoverparameters(m, p)
#setparameter(m,:Population, :y_year_0, 2008.)

run(m)

pop = m[:Population, :pop_population]
@test !isna(m[:Population, :pop_population])

@test uspop2100 > 400 && uspop2100 < 500
