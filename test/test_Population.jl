using Mimi
using Base.Test

include("../src/load_parameters.jl")
include("../src/Population.jl")

m = Model()
setindex(m, :time, [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200])
setindex(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])

population = addpopulation(m)

p = load_parameters(m)
p["y_year_0"] = 2008.
p["y_year"] = m.indices_values[:time]

setleftoverparameters(m, p)

run(m)

uspop2100 = m[:Population, :pop_population][8, 2]
@test uspop2100 > 400 && uspop2100 < 500
