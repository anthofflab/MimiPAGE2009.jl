module MimiPAGE2009

using Mimi

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
    population = addpopulation(m)
    add_comp!(m, GDP)

    #Abatement Costs
    abatementcostparameters_CO2 = addabatementcostparameters(m, :CO2, policy)
    abatementcostparameters_CH4 = addabatementcostparameters(m, :CH4, policy)
    abatementcostparameters_N2O = addabatementcostparameters(m, :N2O, policy)
    abatementcostparameters_Lin = addabatementcostparameters(m, :Lin, policy)

    abatementcosts_CO2 = addabatementcosts(m, :CO2, policy)
    abatementcosts_CH4 = addabatementcosts(m, :CH4, policy)
    abatementcosts_N2O = addabatementcosts(m, :N2O, policy)
    abatementcosts_Lin = addabatementcosts(m, :Lin, policy)
    add_comp!(m, TotalAbatementCosts)

    #Adaptation Costs
    adaptationcosts_sealevel = addadaptationcosts_sealevel(m)
    adaptationcosts_economic = addadaptationcosts_economic(m)
    adaptationcosts_noneconomic = addadaptationcosts_noneconomic(m)
    add_comp!(m, TotalAdaptationCosts)

    # Impacts
    slrdamages = addslrdamages(m)
    marketdamages = addmarketdamages(m)
    nonmarketdamages = addnonmarketdamages(m)
    add_comp!(m, Discontinuity)

    # Total damages component 
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

    for allabatement in [
        (:AbatementCostParametersCO2, :AbatementCostsCO2),
        (:AbatementCostParametersCH4, :AbatementCostsCH4),
        (:AbatementCostParametersN2O, :AbatementCostsN2O),
        (:AbatementCostParametersLin, :AbatementCostsLin)]

        abatementcostparameters, abatementcosts = allabatement

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
    connect_param!(m, :TotalCosts => :period_span, :GDP => :yagg_periodspan)
    connect_param!(m, :TotalCosts => :abatement_costs_percap, :TotalAbatementCosts => :tct_per_cap_totalcostspercap) 
    connect_param!(m, :TotalCosts => :adaptation_costs_percap, :TotalAdaptationCosts => :act_percap_adaptationcosts)
    connect_param!(m, :TotalCosts => :slr_damages_percap, :SLRDamages => :isat_per_cap_SLRImpactperCapinclSaturationandAdaptation)
    connect_param!(m, :TotalCosts => :market_damages_percap, :MarketDamages => :isat_per_cap_ImpactperCapinclSaturationandAdaptation)
    connect_param!(m, :TotalCosts => :non_market_damages_percap, :NonMarketDamages => :isat_per_cap_ImpactperCapinclSaturationandAdaptation)
    connect_param!(m, :TotalCosts => :discontinuity_damages_percap, :Discontinuity => :isat_per_cap_DiscImpactperCapinclSaturation)

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

function initpage(m::Model, policy::String="policy-a")
    p = load_parameters(m, policy)
    p["y_year_0"] = 2008.
    p["y_year"] = Mimi.dim_keys(m.md, :time)
    set_leftover_params!(m, p)
end

function get_model(policy::String="policy-a")
    m = Model()
    set_dimension!(m, :time, [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200])
    set_dimension!(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])

    buildpage(m, policy)

    # next: add vector and panel example
    initpage(m, policy)

    return m
end

getpage = get_model

end
