using Base.Test

# Include the model, in all its completeness
include("../src/main_model.jl")
while m[:Discontinuity,:occurdis_occurrencedummy] != [0.,0.,0.,0.,0.,0.,0.,0.,0.,1.]
    run(m)
end

#climate component
temp=m[:ClimateTemperature,:rt_g_globaltemperature]
temp_compare=readpagedata(m,"test/validationdata/rt_g_globaltemperature.csv")
@test_approx_eq_eps temp temp_compare 1e-4

slr=m[:SeaLevelRise,:s_sealevel]
slr_compare=readpagedata(m,"test/validationdata/s_sealevel.csv")
@test_approx_eq_eps slr slr_compare 1e-2

#Socio-Economics
gdp=m[:GDP,:gdp]
gdp_compare=readpagedata(m,"test/validationdata/gdp.csv")
@test_approx_eq_eps gdp gdp_compare 1

pop=m[:Population,:pop_population]
pop_compare=readpagedata(m,"test/validationdata/pop_population.csv")
@test_approx_eq_eps pop pop_compare 0.001

#Abatemet Costs
abatement=m[:TotalAbatementCosts,:tct_totalcosts]
abatement_compare=readpagedata(m,"test/validationdata/tct_totalcosts.csv")
@test_approx_eq_eps abatement abatement_compare 1e-2

#Adaptation Costs
adaptation=m[:TotalAdaptationCosts,:act_adaptationcosts_total]
adaptation_compare=readpagedata(m, "test/validationdata/act_adaptationcosts_tot.csv")
@test_approx_eq_eps adaptation adaptation_compare 1e-2

#Damages
damages=m[:Discontinuity,:rcons_per_cap_DiscRemainConsumption]
damages_compare=readpagedata(m,"test/validationdata/rcons_per_cap_DiscRemainConsumption.csv")
@test_approx_eq_eps damages damages_compare 10
#SLR damages
slrdamages=m[:SLRDamages,:rcons_per_cap_SLRRemainConsumption]
slrdamages_compare=readpagedata(m, "test/validationdata/rcons_per_cap_SLRRemainConsumption.csv")
@test_approx_eq_eps slrdamages slrdamages_compare 0.1
#Market damages
mdamages=m[:MarketDamages,:rcons_per_cap_MarketRemainConsumption]
mdamages_comare=readpagedata(m,"test/validationdata/rcons_per_cap_MarketRemainConsumption.csv")
@test_approx_eq_eps mdamages mdamages_comare 1
#NonMarket Damages
nmdamages=m[:NonMarketDamages,:rcons_per_cap_NonMarketRemainConsumption]
nmdamages_comare=readpagedata(m,"test/validationdata/rcons_per_cap_NonMarketRemainConsumption.csv")
@test_approx_eq_eps nmdamages nmdamages_comare 10

te = m[:EquityWeighting, :te_totaleffect]
te_compare = 213208136.69903600
@test_approx_eq_eps te te_compare 1e4
