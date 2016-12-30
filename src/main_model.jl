using Mimi
include("load_parameters.jl")
include("CO2emissions.jl")
include("CO2cycle.jl")
include("CO2forcing.jl")
include("CH4emissions.jl")
include("CH4cycle.jl")
include("CH4forcing.jl")
include("N2Oemissions.jl")
include("N2Ocycle.jl")
include("N2Oforcing.jl")
include("LGemissions.jl")
include("LGcycle.jl")
include("LGforcing.jl")
include("SulphateForcing.jl")
include("TotalForcing.jl")
include("ClimateTemperature.jl")
include("SeaLevelRise.jl")
include("GDP.jl")
include("MarketDamages.jl")
include("NonMarketDamages.jl")
include("Discontinuity.jl")
include("AdaptationCosts.jl")
include("SLRDamages.jl")
include("AbatementCosts.jl")
include("TotalAbatementCosts.jl")
include("Population.jl")

m = Model()
setindex(m, :time, [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200])
setindex(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])

#add all the components
CO2emissions = addcomponent(m,co2emissions)
CO2cycle = addCO2cycle(m)
CO2forcing = addCO2forcing(m)
CH4emissions = addcomponent(m, ch4emissions)
CH4cycle = addCH4cycle(m)
CH4forcing = addCH4forcing(m)
N2Oemissions = addcomponent(m, n2oemissions)
N2Ocycle = addN2Ocycle(m)
N2Oforcing = addN2Oforcing(m)
lgemissions = addcomponent(m, LGemissions)
lgcycle = addLGcycle(m)
lgforcing = addLGforcing(m)
sulphateforcing = addsulphatecomp(m)
totalforcing = addcomponent(m, TotalForcing)
climatetemperature = addclimatetemperature(m)
sealevelrise = addSLR(m)
#Socio-Economics
population = addpopulation(m)
gdp = addgdp(m)
#Abatement Costs
abatementcosts_CO2 = addabatementcosts(m, :CO2)
abatementcosts_CH4 = addabatementcosts(m, :CH4)
abatementcosts_N2O = addabatementcosts(m, :N2O)
abatementcosts_Lin = addabatementcosts(m, :Lin)
totalabatementcosts = addtotalabatementcosts(m)
#Adaptation Costs
adaptationcosts_sealevel = addadaptationcosts_sealevel(m)
adaptationcosts_economic = addadaptationcosts_economic(m)
adaptationcosts_noneconomic = addadaptationcosts_noneconomic(m)
totaladaptationcosts = addtotaladaptationcosts(m)
# Impacts
slrdamages = addslrdamages(m)
marketdamages = addmarketdamages(m)
nonmarketdamages= addnonmarketdamages(m)
discontinuity= adddiscontinuity(m)
#Equity weighting and Total Costs
equityweighting=addequityweighting(m)

#connect parameters together
CO2cycle[:e_globalCO2emissions] = CO2emissions[:e_globalCO2emissions]
CO2cycle[:rt_g0_baseglobaltemp] = climatetemperature[:rt_g0_baseglobaltemp]
CO2cycle[:rt_g_globaltemperature] = climatetemperature[:rt_g_globaltemperature]

CO2forcing[:c_CO2concentration] = CO2cycle[:c_CO2concentration]

CH4cycle[:e_globalCH4emissions] = CH4emissions[:e_globalCH4emissions]
CH4cycle[:rtl_g0_baselandtemp] = climatetemperature[:rtl_g0_baselandtemp]
CH4cycle[:rtl_g_landtemperature] = climatetemperature[:rtl_g_landtemperature]

CH4forcing[:c_CH4concentration] = CH4cycle[:c_CH4concentration]
CH4forcing[:c_N2Oconcentration] = N2Ocycle[:c_N2Oconcentration]

N2Ocycle[:e_globalN2Oemissions] = N2Oemissions[:e_globalN2Oemissions]
N2Ocycle[:rtl_g0_baselandtemp] = climatetemperature[:rtl_g0_baselandtemp]
N2Ocycle[:rtl_g_landtemperature] = climatetemperature[:rtl_g_landtemperature]

N2Oforcing[:c_CH4concentration] = CH4cycle[:c_CH4concentration]
N2Oforcing[:c_N2Oconcentration] = N2Ocycle[:c_N2Oconcentration]

lgcycle[:e_globalLGemissions] = lgemissions[:e_globalLGemissions]
lgcycle[:rtl_g0_baselandtemp] = climatetemperature[:rtl_g0_baselandtemp]
lgcycle[:rtl_g_landtemperature] = climatetemperature[:rtl_g_landtemperature]

lgforcing[:c_LGconcentration] = lgcycle[:c_LGconcentration]

totalforcing[:f_CO2forcing] = CO2forcing[:f_CO2forcing]
totalforcing[:f_CH4forcing] = CH4forcing[:f_CH4forcing]
totalforcing[:f_N2Oforcing] = N2Oforcing[:f_N2Oforcing]
totalforcing[:f_lineargasforcing] = lgforcing[:f_LGforcing]

climatetemperature[:ft_totalforcing] = totalforcing[:ft_totalforcing]
climatetemperature[:fs_sulfateforcing] = sulphateforcing[:fs_sulphateforcing]

sealevelrise[:rt_g_globaltemperature] = climatetemperature[:rt_g_globaltemperature]

gdp[:pop_population] = population[:pop_population]

abatementcosts_CO2[:yagg] = gdp[:yagg_periodspan]
abatementcosts_CH4[:yagg] = gdp[:yagg_periodspan]
abatementcosts_N2O[:yagg] = gdp[:yagg_periodspan]
abatementcosts_Lin[:yagg] = gdp[:yagg_periodspan]

totalabatementcosts[:tc_totalcosts_co2] = abatementcosts_CO2[:tc_totalcost]
totalabatementcosts[:tc_totalcosts_n2o] = abatementcosts_N2O[:tc_totalcost]
totalabatementcosts[:tc_totalcosts_ch4] = abatementcosts_CH4[:tc_totalcost]
totalabatementcosts[:tc_totalcosts_linear] = abatementcosts_Lin[:tc_totalcost]
totalabatementcosts[:pop_population] = population[:pop_population]

adaptationcosts_economic[:gdp] = GDP[:gdp]
adaptationcosts_noneconomic[:gdp] = GDP[:gdp]
adaptationcosts_sealevel[:gdp] = GDP[:gdp]

totaladaptationcosts[:ac_adaptationcosts_economic] = adaptationcosts_economic[:ac_adaptivecosts]
totaladaptationcosts[:ac_adaptationcosts_noneconomic] = adaptationcosts_noneconomic[:ac_adaptivecosts]
totaladaptationcosts[:ac_adaptationcosts_sealevelrise] = adaptationcosts_sealevel[:ac_adaptivecosts]

slrdamages[:s_sealevel] = sealevelrise[:s_sealevel]
slrdamages[:cons_percap_consumption] = gdp[:cons_percap_consumption]
slrdamages[:tct_per_cap_totalcostspercap] = totalabatementcosts[:tct_per_cap_totalcostspercap]
slrdamages[:act_percap_adaptationcosts] = totaladaptationcosts[:act_percap_adaptationcosts]
slrdamages[:atl_adjustedtolerablelevelofsealevelrise] = adaptationcosts_sealevel[:atl_adjustedtolerablelevel]
slrdamages[:imp_actualreductionSLR] = adaptationcosts_sealevel[:imp_actualreduction]

marketdamages[:rt_realizedtemperature] = climatetemperature[:rt_realizedtemperature]
marketdamages[:rgdp_per_cap_SLRRemainGDP] = slrdamages[:rgdp_per_cap_SLRRemainGDP]
marketdamages[:rcons_per_cap_SLRRemainConsumption] = slrdamages[:rcons_per_cap_SLRRemainConsumption]
marketdamages[:atl_adjustedtolerableleveloftemprise] = adaptationcosts_economic[:atl_adjustedtolerablelevel]
marketdamages[:imp_actualreduction] = adaptationcosts_economic[:imp_actualreduction]

nonmarketdamages[:rt_realizedtemperature] = climatetemperature[:rt_realizedtemperature]
nonmarketdamages[:rgdp_per_cap_MarketRemainGDP] = marketdamages[:rgdp_per_cap_MarketRemainGDP]
nonmarketdamages[:rcons_per_cap_MarketRemainConsumption] = marketdamages[:rcons_per_cap_MarketRemainConsumption]
nonmarketdamages[:atl_adjustedtolerableleveloftemprise] = adaptationcosts_noneconomic[:atl_adjustedtolerablelevel]
monmarketdamages[:imp_actualreduction] = adaptationcosts_noneconomic[:imp_actualreduction]

discontinuity[:rgdp_per_cap_DiscRemainGDP] = nonmarketdamages[:rgdp_per_cap_NonMarketRemainGDP]
discontinuity[:rcons_per_cap_DiscRemainConsumption] = nonmarketdamages[:rcons_per_cap_NonMarketRemainConsumption]
discontinuity[:rt_g_globaltemperature] = climatetemperature[:rt_g_globaltemperature]

equityweighting[:pop_population] = population[:pop_population]
equityweighting[:tct_percap_totalcosts_total] = totalabatementcosts[:tct_per_cap_totalcostspercap]
equityweighting[:act_adaptationcosts_total] = totaladaptationcosts[:act_adaptationcosts_total]
equityweighting[:act_percap_adaptationcosts] = totaladaptationcosts[:act_percap_adaptationcosts]
equityweighting[:cons_percap_consumption] = gdp[:cons_percap_consumption]
equityweighting[:cons_percap_aftercosts] = slrdamages[:cons_percap_aftercosts]
equityweighting[:yagg_periodspan] = gdp[:yagg_periodspan]

# next: add vector and panel example
p = load_parameters(m)
p["y_year_0"] = 2008.
p["y_year"] = m.indices_values[:time]
setleftoverparameters(m, p)

run(m)
