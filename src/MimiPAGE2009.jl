module MimiPAGE2009

using Mimi

import Random

export getpage

include("utils/load_parameters.jl")
include("utils/mctools.jl")

include("mcs.jl")

include("compute_scc.jl")

include("components/CO2emissions.jl")
include("components/CO2cycle.jl")
include("components/CO2forcing.jl")
include("components/CH4emissions.jl")
include("components/CH4cycle.jl")
include("components/CH4forcing.jl")
include("components/N2Oemissions.jl")
include("components/N2Ocycle.jl")
include("components/N2Oforcing.jl")
include("components/LGemissions.jl")
include("components/LGcycle.jl")
include("components/LGforcing.jl")
include("components/SulphateForcing.jl")
include("components/TotalForcing.jl")
include("components/ClimateTemperature.jl")
include("components/SeaLevelRise.jl")
include("components/GDP.jl")
include("components/MarketDamages.jl")
include("components/NonMarketDamages.jl")
include("components/Discontinuity.jl")
include("components/AdaptationCosts.jl")
include("components/SLRDamages.jl")
include("components/AbatementCostParameters.jl")
include("components/AbatementCosts.jl")
include("components/TotalAbatementCosts.jl")
include("components/TotalAdaptationCosts.jl")
include("components/Population.jl")
include("components/TotalCosts.jl")
include("components/EquityWeighting.jl")

"""
    buildpage(m::Mode,; policy::String="policy-a")

Build the PAGE 2009 model structure.
"""
function buildpage(m::Model, policy::String="policy-a")

    #add all the components
    add_comp!(m, co2emissions)
    add_comp!(m, co2cycle)
    add_comp!(m, co2forcing)
    add_comp!(m, ch4emissions)
    add_comp!(m, ch4cycle)
    add_comp!(m, ch4forcing)
    add_comp!(m, n2oemissions)
    add_comp!(m, n2ocycle)
    add_comp!(m, n2oforcing)
    add_comp!(m, LGemissions)
    add_comp!(m, LGcycle)
    add_comp!(m, LGforcing)
    add_comp!(m, SulphateForcing)
    add_comp!(m, TotalForcing)
    add_comp!(m, ClimateTemperature)
    add_comp!(m, SeaLevelRise)

    #Socio-Economics
    addpopulation(m)
    add_comp!(m, GDP)

    #Abatement Costs
    addabatementcostparameters(m, :CO2, policy)
    addabatementcostparameters(m, :CH4, policy)
    addabatementcostparameters(m, :N2O, policy)
    addabatementcostparameters(m, :Lin, policy)

    addabatementcosts(m, :CO2, policy)
    addabatementcosts(m, :CH4, policy)
    addabatementcosts(m, :N2O, policy)
    addabatementcosts(m, :Lin, policy)

    add_comp!(m, TotalAbatementCosts)

    #Adaptation Costs
    addadaptationcosts_sealevel(m)
    addadaptationcosts_economic(m)
    addadaptationcosts_noneconomic(m)
    add_comp!(m, TotalAdaptationCosts)

    # Impacts
    addslrdamages(m)
    addmarketdamages(m)
    addnonmarketdamages(m)
    add_comp!(m, Discontinuity)

    # Total costs component 
    add_comp!(m, TotalCosts)

    #Equity weighting and Total Costs
    add_comp!(m, EquityWeighting)

    #connect parameters together
    connect_param!(m, :co2cycle => :e_globalCO2emissions, :co2emissions => :e_globalCO2emissions)
    connect_param!(m, :co2cycle => :rt_g0_baseglobaltemp, :ClimateTemperature => :rt_g0_baseglobaltemp)
    connect_param!(m, :co2cycle => :rt_g_globaltemperature, :ClimateTemperature => :rt_g_globaltemperature)
    
    connect_param!(m, :co2forcing => :c_CO2concentration, :co2cycle => :c_CO2concentration)    

    connect_param!(m, :ch4cycle => :e_globalCH4emissions, :ch4emissions => :e_globalCH4emissions)
    connect_param!(m, :ch4cycle => :rtl_g0_baselandtemp, :ClimateTemperature => :rtl_g0_baselandtemp)
    connect_param!(m, :ch4cycle => :rtl_g_landtemperature, :ClimateTemperature => :rtl_g_landtemperature)
    
    connect_param!(m, :ch4forcing => :c_CH4concentration, :ch4cycle => :c_CH4concentration)
    connect_param!(m, :ch4forcing => :c_N2Oconcentration, :n2ocycle => :c_N2Oconcentration)    

    connect_param!(m, :n2ocycle => :e_globalN2Oemissions, :n2oemissions => :e_globalN2Oemissions)
    connect_param!(m, :n2ocycle => :rtl_g0_baselandtemp, :ClimateTemperature => :rtl_g0_baselandtemp)
    connect_param!(m, :n2ocycle => :rtl_g_landtemperature, :ClimateTemperature => :rtl_g_landtemperature)
    
    connect_param!(m, :n2oforcing => :c_CH4concentration, :ch4cycle => :c_CH4concentration)
    connect_param!(m, :n2oforcing => :c_N2Oconcentration, :n2ocycle => :c_N2Oconcentration)    

    connect_param!(m, :LGcycle => :e_globalLGemissions, :LGemissions => :e_globalLGemissions)
    connect_param!(m, :LGcycle => :rtl_g0_baselandtemp, :ClimateTemperature => :rtl_g0_baselandtemp)
    connect_param!(m, :LGcycle => :rtl_g_landtemperature, :ClimateTemperature => :rtl_g_landtemperature)
    
    connect_param!(m, :LGforcing => :c_LGconcentration, :LGcycle => :c_LGconcentration)
    
    connect_param!(m, :TotalForcing => :f_CO2forcing, :co2forcing => :f_CO2forcing)
    connect_param!(m, :TotalForcing => :f_CH4forcing, :ch4forcing => :f_CH4forcing)
    connect_param!(m, :TotalForcing => :f_N2Oforcing, :n2oforcing => :f_N2Oforcing)
    connect_param!(m, :TotalForcing => :f_lineargasforcing, :LGforcing => :f_LGforcing)
    
    connect_param!(m, :ClimateTemperature => :ft_totalforcing, :TotalForcing => :ft_totalforcing)
    connect_param!(m, :ClimateTemperature => :fs_sulfateforcing, :SulphateForcing => :fs_sulphateforcing)
    
    connect_param!(m, :SeaLevelRise => :rt_g_globaltemperature, :ClimateTemperature => :rt_g_globaltemperature)

    connect_param!(m, :GDP => :pop_population, :Population => :pop_population)

    for (abatementcostparameters, abatementcosts) in [
            (:AbatementCostParametersCO2, :AbatementCostsCO2),
            (:AbatementCostParametersCH4, :AbatementCostsCH4),
            (:AbatementCostParametersN2O, :AbatementCostsN2O),
            (:AbatementCostParametersLin, :AbatementCostsLin)
        ]

        connect_param!(m, abatementcostparameters => :yagg, :GDP => :yagg_periodspan)
        connect_param!(m, abatementcostparameters => :cbe_absoluteemissionreductions, abatementcosts => :cbe_absoluteemissionreductions)

        connect_param!(m, abatementcosts => :zc_zerocostemissions, abatementcostparameters => :zc_zerocostemissions)
        connect_param!(m, abatementcosts => :q0_absolutecutbacksatnegativecost, abatementcostparameters => :q0_absolutecutbacksatnegativecost)
        connect_param!(m, abatementcosts => :blo, abatementcostparameters => :blo)
        connect_param!(m, abatementcosts => :alo, abatementcostparameters => :alo)
        connect_param!(m, abatementcosts => :bhi, abatementcostparameters => :bhi)
        connect_param!(m, abatementcosts => :ahi, abatementcostparameters => :ahi)

    end

    connect_param!(m, :TotalAbatementCosts => :tc_totalcosts_co2, :AbatementCostsCO2 => :tc_totalcost)
    connect_param!(m, :TotalAbatementCosts => :tc_totalcosts_n2o, :AbatementCostsN2O => :tc_totalcost)
    connect_param!(m, :TotalAbatementCosts => :tc_totalcosts_ch4, :AbatementCostsCH4 => :tc_totalcost)
    connect_param!(m, :TotalAbatementCosts => :tc_totalcosts_linear, :AbatementCostsLin => :tc_totalcost)
    connect_param!(m, :TotalAbatementCosts => :pop_population, :Population => :pop_population)

    connect_param!(m, :AdaptiveCostsEconomic => :gdp, :GDP => :gdp)
    connect_param!(m, :AdaptiveCostsNonEconomic => :gdp, :GDP => :gdp)
    connect_param!(m, :AdaptiveCostsSeaLevel => :gdp, :GDP => :gdp)

    connect_param!(m, :TotalAdaptationCosts => :ac_adaptationcosts_economic, :AdaptiveCostsEconomic => :ac_adaptivecosts)
    connect_param!(m, :TotalAdaptationCosts => :ac_adaptationcosts_noneconomic, :AdaptiveCostsNonEconomic => :ac_adaptivecosts)
    connect_param!(m, :TotalAdaptationCosts => :ac_adaptationcosts_sealevelrise, :AdaptiveCostsSeaLevel => :ac_adaptivecosts)
    connect_param!(m, :TotalAdaptationCosts => :pop_population, :Population => :pop_population)

    connect_param!(m, :SLRDamages => :s_sealevel, :SeaLevelRise => :s_sealevel)
    connect_param!(m, :SLRDamages => :cons_percap_consumption, :GDP => :cons_percap_consumption)
    connect_param!(m, :SLRDamages => :tct_per_cap_totalcostspercap, :TotalAbatementCosts => :tct_per_cap_totalcostspercap) 
    connect_param!(m, :SLRDamages => :act_percap_adaptationcosts, :TotalAdaptationCosts => :act_percap_adaptationcosts)
    connect_param!(m, :SLRDamages => :atl_adjustedtolerablelevelofsealevelrise, :AdaptiveCostsSeaLevel => :atl_adjustedtolerablelevel, ignoreunits=true)
    connect_param!(m, :SLRDamages => :imp_actualreductionSLR, :AdaptiveCostsSeaLevel => :imp_adaptedimpacts)
    connect_param!(m, :SLRDamages => :isatg_impactfxnsaturation, :GDP => :isatg_impactfxnsaturation)

    connect_param!(m, :MarketDamages => :rtl_realizedtemperature, :ClimateTemperature => :rtl_realizedtemperature)
    connect_param!(m, :MarketDamages => :rgdp_per_cap_SLRRemainGDP, :SLRDamages => :rgdp_per_cap_SLRRemainGDP)
    connect_param!(m, :MarketDamages => :rcons_per_cap_SLRRemainConsumption, :SLRDamages => :rcons_per_cap_SLRRemainConsumption)
    connect_param!(m, :MarketDamages => :atl_adjustedtolerableleveloftemprise, :AdaptiveCostsEconomic => :atl_adjustedtolerablelevel, ignoreunits=true)
    connect_param!(m, :MarketDamages => :imp_actualreduction, :AdaptiveCostsEconomic => :imp_adaptedimpacts)
    connect_param!(m, :MarketDamages => :isatg_impactfxnsaturation, :GDP => :isatg_impactfxnsaturation)

    connect_param!(m, :NonMarketDamages => :rtl_realizedtemperature, :ClimateTemperature => :rtl_realizedtemperature)
    connect_param!(m, :NonMarketDamages => :rgdp_per_cap_MarketRemainGDP, :MarketDamages => :rgdp_per_cap_MarketRemainGDP)
    connect_param!(m, :NonMarketDamages => :rcons_per_cap_MarketRemainConsumption, :MarketDamages => :rcons_per_cap_MarketRemainConsumption)
    connect_param!(m, :NonMarketDamages =>:atl_adjustedtolerableleveloftemprise, :AdaptiveCostsNonEconomic =>:atl_adjustedtolerablelevel, ignoreunits=true)
    connect_param!(m, :NonMarketDamages => :imp_actualreduction, :AdaptiveCostsNonEconomic => :imp_adaptedimpacts)
    connect_param!(m, :NonMarketDamages => :isatg_impactfxnsaturation, :GDP => :isatg_impactfxnsaturation)

    connect_param!(m, :Discontinuity => :rgdp_per_cap_NonMarketRemainGDP, :NonMarketDamages => :rgdp_per_cap_NonMarketRemainGDP)
    connect_param!(m, :Discontinuity => :rt_g_globaltemperature, :ClimateTemperature => :rt_g_globaltemperature)
    connect_param!(m, :Discontinuity => :rgdp_per_cap_NonMarketRemainGDP, :NonMarketDamages => :rgdp_per_cap_NonMarketRemainGDP)
    connect_param!(m, :Discontinuity => :rcons_per_cap_NonMarketRemainConsumption, :NonMarketDamages => :rcons_per_cap_NonMarketRemainConsumption)
    connect_param!(m, :Discontinuity => :isatg_saturationmodification, :GDP => :isatg_impactfxnsaturation)

    connect_param!(m, :TotalCosts => :population, :Population => :pop_population)
    connect_param!(m, :TotalCosts => :period_length, :GDP => :yagg_periodspan)
    connect_param!(m, :TotalCosts => :abatement_costs_percap_peryear, :TotalAbatementCosts => :tct_per_cap_totalcostspercap) 
    connect_param!(m, :TotalCosts => :adaptation_costs_percap_peryear, :TotalAdaptationCosts => :act_percap_adaptationcosts)
    connect_param!(m, :TotalCosts => :slr_damages_percap_peryear, :SLRDamages => :isat_per_cap_SLRImpactperCapinclSaturationandAdaptation)
    connect_param!(m, :TotalCosts => :market_damages_percap_peryear, :MarketDamages => :isat_per_cap_ImpactperCapinclSaturationandAdaptation)
    connect_param!(m, :TotalCosts => :non_market_damages_percap_peryear, :NonMarketDamages => :isat_per_cap_ImpactperCapinclSaturationandAdaptation)
    connect_param!(m, :TotalCosts => :discontinuity_damages_percap_peryear, :Discontinuity => :isat_per_cap_DiscImpactperCapinclSaturation)

    connect_param!(m, :EquityWeighting => :pop_population, :Population => :pop_population)
    connect_param!(m, :EquityWeighting => :tct_percap_totalcosts_total, :TotalAbatementCosts => :tct_per_cap_totalcostspercap)
    connect_param!(m, :EquityWeighting => :act_adaptationcosts_total, :TotalAdaptationCosts => :act_adaptationcosts_total)
    connect_param!(m, :EquityWeighting => :act_percap_adaptationcosts, :TotalAdaptationCosts => :act_percap_adaptationcosts)
    connect_param!(m, :EquityWeighting => :cons_percap_consumption, :GDP => :cons_percap_consumption)
    connect_param!(m, :EquityWeighting => :cons_percap_consumption_0, :GDP => :cons_percap_consumption_0)
    connect_param!(m, :EquityWeighting => :cons_percap_aftercosts, :SLRDamages => :cons_percap_aftercosts)
    connect_param!(m, :EquityWeighting => :rcons_percap_dis, :Discontinuity => :rcons_per_cap_DiscRemainConsumption)
    connect_param!(m, :EquityWeighting => :yagg_periodspan, :GDP => :yagg_periodspan)

    return m
end

"""
    initpage(m::Model, policy::String="policy-a")

Initialize the PAGE 2009 model by: 
* Adding shared parameters and connecting component parameters to link params in different components to the same value.
* Updating all parameter values that are not set.
"""
function initpage(m::Model, policy::String="policy-a")

    # STEP 1. Load Non-Scalar Parameter values from files
    # * :shared => (parameter_name => default_value) for parameters shared in the model
    # * :unshared => ((component_name, parameter_name) => default_value) for component specific parameters that are not shared
    p = load_parameters(m, policy=policy)

    # STEP 3. Set scalar and non-scalar shared parameters such that these will 
    # now be linked to the same shared parameter. The non-scalar shared parameters 
    # are loaded from files and placed in p[:shared] during load_parameters.
    # * for convenience later, name shared model parameter same as the component 
    # parameters, but this is not required could give a unique name *
    add_shared_page_params!(m, p[:shared])

    # Step 4. Set the leftover ie. unset unshared parameters - this will set any 
    # parameters that are not set (1) explicitly or (2) by default
    update_leftover_params!(m, p[:unshared])

end

"""
    add_shared_page_params!(m::Model, p_shared::Dict)

Add shared parameters, some hardcoded (scalars) and sone loaded from file into 
Dictionary p_shared (nonscalar) such that these will now be linked to the same 
shared parameter - for convenience later, name model parameter same as the component 
parameters, but this is not required and could give a unique name.
"""
function add_shared_page_params!(m::Model, p_shared::Dict)

    ##
    ## SCALAR parameters not loaded from files but instead hard coded here 
    ##

    # AbatementCostParameters components
    add_shared_param!(m, :q0propmult_cutbacksatnegativecostinfinalyear, .733333333333333334)
    add_shared_param!(m, :qmax_minus_q0propmult_maxcutbacksatpositivecostinfinalyear, 1.2666666666666666)
    add_shared_param!(m, :c0mult_mostnegativecostinfinalyear, .8333333333333334)
    add_shared_param!(m, :curve_below_curvatureofMACcurvebelowzerocost, .5)
    add_shared_param!(m, :curve_above_curvatureofMACcurveabovezerocost, .4)
    add_shared_param!(m, :cross_experiencecrossoverratio, .2)
    add_shared_param!(m, :learn_learningrate, .2)
    add_shared_param!(m, :automult_autonomoustechchange, .65)
    add_shared_param!(m, :equity_prop_equityweightsproportion, 1.)

    for paramname in [:q0propmult_cutbacksatnegativecostinfinalyear,
                        :qmax_minus_q0propmult_maxcutbacksatpositivecostinfinalyear,
                        :c0mult_mostnegativecostinfinalyear,
                        :curve_below_curvatureofMACcurvebelowzerocost,
                        :curve_above_curvatureofMACcurveabovezerocost,
                        :cross_experiencecrossoverratio,
                        :learn_learningrate,
                        :automult_autonomoustechchange,
                        :equity_prop_equityweightsproportion]

        connect_param!(m, :AbatementCostParametersCO2, paramname, paramname)
        connect_param!(m, :AbatementCostParametersCH4, paramname, paramname)
        connect_param!(m, :AbatementCostParametersN2O, paramname, paramname)
        connect_param!(m, :AbatementCostParametersLin, paramname, paramname)
    end

    # AdaptiveCost components
    add_shared_param!(m, :automult_autonomouschange, 0.65)
    for compname in [:AdaptiveCostsSeaLevel, :AdaptiveCostsEconomic, :AdaptiveCostsNonEconomic]
        connect_param!(m, compname, :automult_autonomouschange, :automult_autonomouschange)
    end

    # Years
    add_shared_param!(m, :y_year, Mimi.dim_keys(m.md, :time), dims=[:time])
    for compname in [:ch4cycle, :ClimateTemperature, :co2cycle, :n2ocycle, :LGcycle, 
                        :SeaLevelRise, :Population, :GDP, 
                        :AbatementCostParametersCO2, :AbatementCostParametersCH4, 
                        :AbatementCostParametersN2O, :AbatementCostParametersLin,
                        :AdaptiveCostsSeaLevel, :AdaptiveCostsEconomic, :AdaptiveCostsNonEconomic,
                        :SLRDamages, :MarketDamages, :NonMarketDamages,
                        :Discontinuity, :EquityWeighting]
        connect_param!(m, compname, :y_year, :y_year)
    end

    add_shared_param!(m, :y_year_0, 2008.)
    for compname in [:ch4cycle, :ClimateTemperature, :co2cycle, :n2ocycle, :LGcycle, 
                        :SeaLevelRise, :Population, :GDP, 
                        :AbatementCostParametersCO2, :AbatementCostParametersCH4, 
                        :AbatementCostParametersN2O, :AbatementCostParametersLin,
                        :AdaptiveCostsSeaLevel, :AdaptiveCostsEconomic, :AdaptiveCostsNonEconomic,
                        :SLRDamages, :Discontinuity, :EquityWeighting]
        connect_param!(m, compname, :y_year_0, :y_year_0)
    end

    # Others 
    add_shared_param!(m, :save_savingsrate, 15.)  #pp33 PAGE09 documentation, "savings rate".
    for compname in [:GDP, :MarketDamages, :NonMarketDamages, :SLRDamages]
        connect_param!(m, compname, :save_savingsrate, :save_savingsrate)
    end

    add_shared_param!(m, :tcal_CalibrationTemp, 3.)
    connect_param!(m, :MarketDamages, :tcal_CalibrationTemp, :tcal_CalibrationTemp)
    connect_param!(m, :NonMarketDamages, :tcal_CalibrationTemp, :tcal_CalibrationTemp)

    ## 
    ## NON-SCALAR parameters loaded from file
    ##

    add_shared_param!(m, :area, p_shared[:area], dims=[:region])
    connect_param!(m, :ClimateTemperature, :area, :area)
    connect_param!(m, :SulphateForcing, :area, :area)

    # e0 parameters - baseline emissions
    add_shared_param!(m, :e0_baselineCO2emissions, p_shared[:e0_baselineCO2emissions], dims=[:region])
    connect_param!(m, :co2emissions, :e0_baselineCO2emissions, :e0_baselineCO2emissions)
    connect_param!(m, :AbatementCostParametersCO2, :e0_baselineemissions, :e0_baselineCO2emissions)
    connect_param!(m, :AbatementCostsCO2, :e0_baselineemissions, :e0_baselineCO2emissions)

    add_shared_param!(m, :e0_baselineCH4emissions, p_shared[:e0_baselineCH4emissions], dims=[:region])
    connect_param!(m, :ch4emissions, :e0_baselineCH4emissions, :e0_baselineCH4emissions)
    connect_param!(m, :AbatementCostParametersCH4, :e0_baselineemissions, :e0_baselineCH4emissions)
    connect_param!(m, :AbatementCostsCH4, :e0_baselineemissions, :e0_baselineCH4emissions)

    add_shared_param!(m, :e0_baselineN2Oemissions, p_shared[:e0_baselineN2Oemissions], dims=[:region])
    connect_param!(m, :n2oemissions, :e0_baselineN2Oemissions, :e0_baselineN2Oemissions)
    connect_param!(m, :AbatementCostParametersN2O, :e0_baselineemissions, :e0_baselineN2Oemissions)
    connect_param!(m, :AbatementCostsN2O, :e0_baselineemissions, :e0_baselineN2Oemissions)

    add_shared_param!(m, :e0_baselineLGemissions, p_shared[:e0_baselineLGemissions], dims=[:region])
    connect_param!(m, :LGemissions, :e0_baselineLGemissions, :e0_baselineLGemissions)
    connect_param!(m, :AbatementCostParametersLin, :e0_baselineemissions, :e0_baselineLGemissions)
    connect_param!(m, :AbatementCostsLin, :e0_baselineemissions, :e0_baselineLGemissions)

    # er parameters - emissions growth
    add_shared_param!(m, :er_CO2emissionsgrowth, p_shared[:er_CO2emissionsgrowth], dims=[:time, :region])
    connect_param!(m, :AbatementCostsCO2, :er_emissionsgrowth, :er_CO2emissionsgrowth)
    connect_param!(m, :co2emissions, :er_CO2emissionsgrowth, :er_CO2emissionsgrowth)

    add_shared_param!(m, :er_CH4emissionsgrowth, p_shared[:er_CH4emissionsgrowth], dims=[:time, :region])
    connect_param!(m, :AbatementCostsCH4, :er_emissionsgrowth, :er_CH4emissionsgrowth)
    connect_param!(m, :ch4emissions, :er_CH4emissionsgrowth, :er_CH4emissionsgrowth)

    add_shared_param!(m, :er_N2Oemissionsgrowth, p_shared[:er_N2Oemissionsgrowth], dims=[:time, :region])
    connect_param!(m, :AbatementCostsN2O, :er_emissionsgrowth, :er_N2Oemissionsgrowth)
    connect_param!(m, :n2oemissions, :er_N2Oemissionsgrowth, :er_N2Oemissionsgrowth)

    add_shared_param!(m, :er_LGemissionsgrowth, p_shared[:er_LGemissionsgrowth], dims=[:time, :region])
    connect_param!(m, :AbatementCostsLin, :er_emissionsgrowth, :er_LGemissionsgrowth)
    connect_param!(m, :LGemissions, :er_LGemissionsgrowth, :er_LGemissionsgrowth)

    #impmax parameters - maximum impact
    add_shared_param!(m, :impmax_sealevel, p_shared[:impmax_sealevel], dims=[:region])
    connect_param!(m, :AdaptiveCostsSeaLevel, :impmax_maximumadaptivecapacity, :impmax_sealevel)
    connect_param!(m, :SLRDamages, :impmax_maxSLRforadaptpolicySLR, :impmax_sealevel, ignoreunits=true) # ignore units because AdaptiveCostsSeaLevel has generic unit "driver"

    add_shared_param!(m, :impmax_economic, p_shared[:impmax_economic], dims=[:region])
    connect_param!(m, :AdaptiveCostsEconomic, :impmax_maximumadaptivecapacity, :impmax_economic)
    connect_param!(m, :MarketDamages, :impmax_maxtempriseforadaptpolicyM, :impmax_economic, ignoreunits=true) # ignore units because AdaptiveCostsSeaLevel has generic unit "driver"

    add_shared_param!(m, :impmax_noneconomic, p_shared[:impmax_noneconomic], dims=[:region])
    connect_param!(m, :AdaptiveCostsNonEconomic, :impmax_maximumadaptivecapacity, :impmax_noneconomic)
    connect_param!(m, :NonMarketDamages, :impmax_maxtempriseforadaptpolicyNM, :impmax_noneconomic, ignoreunits=true) # ignore units because AdaptiveCostsSeaLevel has generic unit "driver"

    # population and gdp
    add_shared_param!(m, :popgrw_populationgrowth, p_shared[:popgrw_populationgrowth], dims=[:time, :region])
    connect_param!(m, :Population, :popgrw_populationgrowth, :popgrw_populationgrowth)
    connect_param!(m, :EquityWeighting, :popgrw_populationgrowth, :popgrw_populationgrowth)

    add_shared_param!(m, :pop0_initpopulation, p_shared[:pop0_initpopulation], dims=[:region])
    connect_param!(m, :Population, :pop0_initpopulation, :pop0_initpopulation)
    connect_param!(m, :GDP, :pop0_initpopulation, :pop0_initpopulation)

    add_shared_param!(m, :grw_gdpgrowthrate, p_shared[:grw_gdpgrowthrate], dims=[:time, :region])
    connect_param!(m, :GDP, :grw_gdpgrowthrate, :grw_gdpgrowthrate)
    connect_param!(m, :EquityWeighting, :grw_gdpgrowthrate, :grw_gdpgrowthrate)

    # AbatementCostParameters
    add_shared_param!(m, :emitf_uncertaintyinBAUemissfactor, p_shared[:emitf_uncertaintyinBAUemissfactor], dims=[:region])
    for compname in [:AbatementCostParametersCO2, :AbatementCostParametersCH4, :AbatementCostParametersN2O, :AbatementCostParametersLin]
        connect_param!(m, compname, :emitf_uncertaintyinBAUemissfactor, :emitf_uncertaintyinBAUemissfactor)
    end

    add_shared_param!(m, :q0f_negativecostpercentagefactor, p_shared[:q0f_negativecostpercentagefactor], dims=[:region])
    for compname in [:AbatementCostParametersCO2, :AbatementCostParametersCH4, :AbatementCostParametersN2O, :AbatementCostParametersLin]
        connect_param!(m, compname, :q0f_negativecostpercentagefactor, :q0f_negativecostpercentagefactor)
    end

    add_shared_param!(m, :cmaxf_maxcostfactor, p_shared[:cmaxf_maxcostfactor], dims=[:region])
    for compname in [:AbatementCostParametersCO2, :AbatementCostParametersCH4, :AbatementCostParametersN2O, :AbatementCostParametersLin]
        connect_param!(m, compname, :cmaxf_maxcostfactor, :cmaxf_maxcostfactor)
    end
    
    # Adaptation Costs
    add_shared_param!(m, :cf_costregional, p_shared[:cf_costregional], dims=[:region])
    for compname in [:AdaptiveCostsSeaLevel, :AdaptiveCostsEconomic, :AdaptiveCostsNonEconomic]
        connect_param!(m, compname, :cf_costregional, :cf_costregional)
    end

    # Damages
    add_shared_param!(m, :wincf_weightsfactor, p_shared[:wincf_weightsfactor], dims=[:region])
    for compname in [:Discontinuity, :MarketDamages, :NonMarketDamages, :SLRDamages]
        connect_param!(m, compname, :wincf_weightsfactor, :wincf_weightsfactor)
    end

end

function get_model(policy::String="policy-a")
    m = Model()
    set_dimension!(m, :time, [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200])
    set_dimension!(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])

    buildpage(m, policy)

    initpage(m, policy)

    return m
end

getpage = get_model

end
