using Mimi
using DataFrames
using Base.Test

include("../src/load_parameters.jl")
include("../src/AbatementCosts.jl")

m = Model()
setindex(m, :time, [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200])
setindex(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])

addabatementcosts(m, :CO2)
addabatementcosts(m, :CH4)
addabatementcosts(m, :N2O)
addabatementcosts(m, :Lin)

setparameter(m, :AbatementCostsCO2, :bau_businessasusualemissions, ones(10,8))
setparameter(m, :AbatementCostsCH4, :bau_businessasusualemissions, ones(10,8))
setparameter(m, :AbatementCostsN2O, :bau_businessasusualemissions, ones(10,8))
setparameter(m, :AbatementCostsLin, :bau_businessasusualemissions, ones(10,8))
setparameter(m, :AbatementCostsCO2, :yagg, ones(10))
setparameter(m, :AbatementCostsCH4, :yagg, ones(10))
setparameter(m, :AbatementCostsN2O, :yagg, ones(10))
setparameter(m, :AbatementCostsLin, :yagg, ones(10))

p = load_parameters(m)
p["y_year_0"] = 2008.
p["y_year"] = m.indices_values[:time]
setleftoverparameters(m, p)

run(m)

@test !isna(m[:AbatementCostsCO2, :tc_totalcost][10, 5])
@test !isna(m[:AbatementCostsCH4, :tc_totalcost][10, 5])
@test !isna(m[:AbatementCostsN2O, :tc_totalcost][10, 5])
@test !isna(m[:AbatementCostsLin, :tc_totalcost][10, 5])
