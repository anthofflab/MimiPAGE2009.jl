
using DataFrames
using Test
include("../src/components/AbatementCostParameters.jl")
include("../src/components/AbatementCosts.jl")

m = test_page_model()

add_shared_param!(m, :yagg, readpagedata(m,"test/validationdata/yagg_periodspan.csv"), dims=[:time])
add_shared_param!(m, :y_year, Mimi.dim_keys(m.md, :time), dims=[:time])

p = load_parameters(m)
add_shared_param!(m, :emitf_uncertaintyinBAUemissfactor, p[:shared][:emitf_uncertaintyinBAUemissfactor], dims=[:region])
add_shared_param!(m, :q0f_negativecostpercentagefactor, p[:shared][:q0f_negativecostpercentagefactor], dims=[:region])
add_shared_param!(m, :cmaxf_maxcostfactor, p[:shared][:cmaxf_maxcostfactor], dims=[:region])

for gas in [:CO2, :CH4, :N2O, :Lin]

    comp_name1 = Symbol("AbatementCostParameters$gas")
    comp_name2 = Symbol("AbatementCosts$gas")

    add_comp!(m, AbatementCostParameters, comp_name1)
    add_comp!(m, AbatementCosts, comp_name2)

    MimiPAGE2009.update_params_abatementcostparameters!(m, gas)

    # connect the components together
    connect_param!(m, comp_name1 => :cbe_absoluteemissionreductions, comp_name2 => :cbe_absoluteemissionreductions)
    connect_param!(m, comp_name2 => :zc_zerocostemissions, comp_name1 => :zc_zerocostemissions)
    connect_param!(m, comp_name2 => :q0_absolutecutbacksatnegativecost, comp_name1 => :q0_absolutecutbacksatnegativecost)
    connect_param!(m, comp_name2 => :blo, comp_name1 => :blo)
    connect_param!(m, comp_name2 => :alo, comp_name1 => :alo)
    connect_param!(m, comp_name2 => :bhi, comp_name1 => :bhi)
    connect_param!(m, comp_name2 => :ahi, comp_name1 => :ahi)

    # connect to shared model parameters common across gases
    connect_param!(m, comp_name1, :yagg, :yagg)
    connect_param!(m, comp_name1, :y_year, :y_year)
    connect_param!(m, comp_name1, :emitf_uncertaintyinBAUemissfactor, :emitf_uncertaintyinBAUemissfactor)
    connect_param!(m, comp_name1, :q0f_negativecostpercentagefactor, :q0f_negativecostpercentagefactor)
    connect_param!(m, comp_name1, :cmaxf_maxcostfactor, :cmaxf_maxcostfactor)

end

# connect to shared model parameters specific to each gas
add_shared_param!(m, :e0_baselineCO2emissions, p[:shared][:e0_baselineCO2emissions], dims=[:region])
connect_param!(m, :AbatementCostParametersCO2, :e0_baselineemissions, :e0_baselineCO2emissions)
connect_param!(m, :AbatementCostsCO2, :e0_baselineemissions, :e0_baselineCO2emissions)

add_shared_param!(m, :e0_baselineCH4emissions, p[:shared][:e0_baselineCH4emissions], dims=[:region])
connect_param!(m, :AbatementCostParametersCH4, :e0_baselineemissions, :e0_baselineCH4emissions)
connect_param!(m, :AbatementCostsCH4, :e0_baselineemissions, :e0_baselineCH4emissions)

add_shared_param!(m, :e0_baselineN2Oemissions, p[:shared][:e0_baselineN2Oemissions], dims=[:region])
connect_param!(m, :AbatementCostParametersN2O, :e0_baselineemissions, :e0_baselineN2Oemissions)
connect_param!(m, :AbatementCostsN2O, :e0_baselineemissions, :e0_baselineN2Oemissions)

add_shared_param!(m, :e0_baselineLGemissions, p[:shared][:e0_baselineLGemissions], dims=[:region])
connect_param!(m, :AbatementCostParametersLin, :e0_baselineemissions, :e0_baselineLGemissions)
connect_param!(m, :AbatementCostsLin, :e0_baselineemissions, :e0_baselineLGemissions)

# update more parameters 
update_param!(m, :AbatementCostsCO2, :er_emissionsgrowth, p[:shared][:er_CO2emissionsgrowth])
update_param!(m, :AbatementCostsCH4, :er_emissionsgrowth, p[:shared][:er_CH4emissionsgrowth])
update_param!(m, :AbatementCostsN2O, :er_emissionsgrowth, p[:shared][:er_N2Oemissionsgrowth])
update_param!(m, :AbatementCostsLin, :er_emissionsgrowth, p[:shared][:er_LGemissionsgrowth])

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
