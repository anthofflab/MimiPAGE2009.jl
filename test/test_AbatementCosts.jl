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

setparameter(m, :AbatementCostsCO2, :yagg, [1.5,5.50,10,10,10,17.5,25,37.5,50,75])
setparameter(m, :AbatementCostsCH4, :yagg, [1.5,5.50,10,10,10,17.5,25,37.5,50,75])
setparameter(m, :AbatementCostsN2O, :yagg, [1.5,5.50,10,10,10,17.5,25,37.5,50,75])
setparameter(m, :AbatementCostsLin, :yagg, [1.5,5.50,10,10,10,17.5,25,37.5,50,75])

p = load_parameters(m)
p["y_year_0"] = 2008.
p["y_year"] = m.indices_values[:time]
setleftoverparameters(m, p)

run(m)

@test !isna(m[:AbatementCostsCO2, :tc_totalcost][10, 5])
@test !isna(m[:AbatementCostsCH4, :tc_totalcost][10, 5])
@test !isna(m[:AbatementCostsN2O, :tc_totalcost][10, 5])
@test !isna(m[:AbatementCostsLin, :tc_totalcost][10, 5])

#compare output to validation data
tc_compare_co2=readpagedata(m, "test/validationdata/tc_totalcosts_co2.csv")
tc_compare_ch4=readpagedata(m, "test/validationdata/tc_totalcosts_ch4.csv")
tc_compare_n2o=readpagedata(m, "test/validationdata/tc_totalcosts_n2o.csv")
tc_compare_lin=readpagedata(m, "test/validationdata/tc_totalcosts_linear.csv")

zc_compare_co2=readpagedata(m, "test/validationdata/zc_zerocostemissionsCO2.csv")
zc_compare_ch4=readpagedata(m, "test/validationdata/zc_zerocostemissionsCH4.csv")
zc_compare_n2o=readpagedata(m, "test/validationdata/zc_zerocostemissionsN2O.csv")
zc_compare_lin=readpagedata(m, "test/validationdata/zc_zerocostemissionsLG.csv")


@test_approx_eq_eps m[:AbatementCostsCO2, :tc_totalcost] tc_compare_co2 1
@test_approx_eq_eps m[:AbatementCostsCH4, :tc_totalcost] tc_compare_ch4 1e-3
@test_approx_eq_eps m[:AbatementCostsN2O, :tc_totalcost] tc_compare_n2o 1e-3
@test_approx_eq_eps m[:AbatementCostsLin, :tc_totalcost] tc_compare_lin 1e-3

@test_approx_eq_eps m[:AbatementCostsCO2, :zc_zerocostemissions] zc_compare_co2 1e-2
@test_approx_eq_eps m[:AbatementCostsCH4, :zc_zerocostemissions] zc_compare_ch4 1e-2
@test_approx_eq_eps m[:AbatementCostsN2O, :zc_zerocostemissions] zc_compare_n2o 1e-2
@test_approx_eq_eps m[:AbatementCostsLin, :zc_zerocostemissions] zc_compare_lin 1e-2
