
using DataFrames
using Test

m = test_page_model()

for gas in [:CO2, :CH4, :N2O, :Lin]
    MimiPAGE2009.addabatementcostparameters(m, gas)
    MimiPAGE2009.addabatementcosts(m, gas)

    comp_name1 = Symbol("AbatementCostParameters$gas")
    comp_name2 = Symbol("AbatementCosts$gas")

    connect_param!(m, comp_name1 => :cbe_absoluteemissionreductions, comp_name2 => :cbe_absoluteemissionreductions)
        
    connect_param!(m, comp_name2 => :zc_zerocostemissions, comp_name1 => :zc_zerocostemissions)
    connect_param!(m, comp_name2 => :q0_absolutecutbacksatnegativecost, comp_name1 => :q0_absolutecutbacksatnegativecost)
    connect_param!(m, comp_name2 => :blo, comp_name1 => :blo)
    connect_param!(m, comp_name2 => :alo, comp_name1 => :alo)
    connect_param!(m, comp_name2 => :bhi, comp_name1 => :bhi)
    connect_param!(m, comp_name2 => :ahi, comp_name1 => :ahi)

end

set_param!(m, :yagg, readpagedata(m,"test/validationdata/yagg_periodspan.csv"))

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

@test m[:AbatementCostParametersCO2, :zc_zerocostemissions] ≈ zc_compare_co2 rtol=1e-2
@test m[:AbatementCostParametersCH4, :zc_zerocostemissions] ≈ zc_compare_ch4 rtol=1e-3
@test m[:AbatementCostParametersN2O, :zc_zerocostemissions] ≈ zc_compare_n2o rtol=1e-3
@test m[:AbatementCostParametersLin, :zc_zerocostemissions] ≈ zc_compare_lin rtol=1e-3
