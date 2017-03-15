using Mimi
using Base.Test

include("../src/load_parameters.jl")
include("../src/GDP.jl")

m = Model()

setindex(m, :time,  [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200])
setindex(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])

population = addpopulation(m)
gdp = addgdp(m)
gdp[:pop_population_0] = readpagedata("data/pop0_initpopulation.csv")
gdp[:pop_population] = population[:pop_population]

p=load_parameters(m)
p["y_year"]=m.indices_values[:time]
p["y_year_0"] = 2008.
setleftoverparameters(m,p)

# run model
run(m)

m[:GDP, :gdp]

cons_percap_consumption_0_compare = readpagedata(m, "test/validationdata/cons_percap_consumption_0.csv")
@test_approx_eq_eps m[:GDP, :cons_percap_consumption_0] cons_percap_consumption_0_compare 1e-6

