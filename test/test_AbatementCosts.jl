using Mimi
using DataFrames
using Test

m = page_model()
include("../src/components/AbatementCosts.jl")

addabatementcosts(m, :CO2)
addabatementcosts(m, :CH4)
addabatementcosts(m, :N2O)
addabatementcosts(m, :Lin)

set_param!(m, :AbatementCostsCO2, :yagg, readpagedata(m,"test/validationdata/yagg_periodspan.csv"))
set_param!(m, :AbatementCostsCH4, :yagg, readpagedata(m,"test/validationdata/yagg_periodspan.csv"))
set_param!(m, :AbatementCostsN2O, :yagg, readpagedata(m,"test/validationdata/yagg_periodspan.csv"))
set_param!(m, :AbatementCostsLin, :yagg, readpagedata(m,"test/validationdata/yagg_periodspan.csv"))

p = load_parameters(m)
p["y_year_0"] = 2008.
p["y_year"] = Mimi.dim_keys(m.md, :time)
set_leftover_params!(m, p)

run(m)

@test !isnan(m[:AbatementCostsCO2, :tc_totalcost][10, 5])
@test !isnan(m[:AbatementCostsCH4, :tc_totalcost][10, 5])
@test !isnan(m[:AbatementCostsN2O, :tc_totalcost][10, 5])
@test !isnan(m[:AbatementCostsLin, :tc_totalcost][10, 5])

#compare output to validation data
tc_compare_co2=readpagedata(m, "test/validationdata/tc_totalcosts_co2.csv")
tc_compare_ch4=readpagedata(m, "test/validationdata/tc_totalcosts_ch4.csv")
tc_compare_n2o=readpagedata(m, "test/validationdata/tc_totalcosts_n2o.csv")
tc_compare_lin=readpagedata(m, "test/validationdata/tc_totalcosts_linear.csv")

zc_compare_co2=readpagedata(m, "test/validationdata/zc_zerocostemissionsCO2.csv")
zc_compare_ch4=readpagedata(m, "test/validationdata/zc_zerocostemissionsCH4.csv")
zc_compare_n2o=readpagedata(m, "test/validationdata/zc_zerocostemissionsN2O.csv")
zc_compare_lin=readpagedata(m, "test/validationdata/zc_zerocostemissionsLG.csv")


@test m[:AbatementCostsCO2, :tc_totalcost] ≈ tc_compare_co2 rtol=1e-2
@test m[:AbatementCostsCH4, :tc_totalcost] ≈ tc_compare_ch4 rtol=1e-2
@test m[:AbatementCostsN2O, :tc_totalcost] ≈ tc_compare_n2o rtol=1e-2
@test m[:AbatementCostsLin, :tc_totalcost] ≈ tc_compare_lin rtol=1e-2

@test m[:AbatementCostsCO2, :zc_zerocostemissions] ≈ zc_compare_co2 rtol=1e-2
@test m[:AbatementCostsCH4, :zc_zerocostemissions] ≈ zc_compare_ch4 rtol=1e-3
@test m[:AbatementCostsN2O, :zc_zerocostemissions] ≈ zc_compare_n2o rtol=1e-3
@test m[:AbatementCostsLin, :zc_zerocostemissions] ≈ zc_compare_lin rtol=1e-3
