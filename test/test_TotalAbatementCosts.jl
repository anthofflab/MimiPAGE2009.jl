using Mimi
using DataFrames

include("../src/load_parameters.jl")
include("../src/TotalAbatementCosts.jl")

m = Model()
setindex(m, :time, [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200])
setindex(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])

addtotalabatementcosts(m)

setparameter(m, :TotalAbatementCosts, :pop_population, ones(10,8))
setparameter(m, :TotalAbatementCosts, :tc_totalcosts_co2, ones(10,8))
setparameter(m, :TotalAbatementCosts, :tc_totalcosts_ch4, ones(10,8))
setparameter(m, :TotalAbatementCosts, :tc_totalcosts_n2o, ones(10,8))
setparameter(m, :TotalAbatementCosts, :tc_totalcosts_linear, ones(10,8))

p = load_parameters(m)
setleftoverparameters(m, p)

run(m)
