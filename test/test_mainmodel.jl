using Test

Mimi.reset_compdefs()

m = getpage()
run(m)

while m[:Discontinuity,:occurdis_occurrencedummy] != [0.,0.,0.,0.,0.,0.,0.,0.,0.,1.]
    run(m)
end

#climate component
temp=m[:ClimateTemperature,:rt_g_globaltemperature]
temp_compare=readpagedata(m,"test/validationdata/rt_g_globaltemperature.csv")
@test temp ≈ temp_compare rtol=1e-4

slr=m[:SeaLevelRise,:s_sealevel]
slr_compare=readpagedata(m,"test/validationdata/s_sealevel.csv")
@test slr ≈ slr_compare rtol=1e-2

#Socio-Economics
gdp=m[:GDP,:gdp]
gdp_compare=readpagedata(m,"test/validationdata/gdp.csv")
@test gdp ≈ gdp_compare rtol=1

pop=m[:Population,:pop_population]
pop_compare=readpagedata(m,"test/validationdata/pop_population.csv")
@test pop ≈ pop_compare rtol=0.001

#Abatement Costs
abatement=m[:TotalAbatementCosts,:tct_totalcosts]
abatement_compare=readpagedata(m,"test/validationdata/tct_totalcosts.csv")
@test abatement ≈ abatement_compare rtol=1e-2

#Adaptation Costs
adaptation=m[:TotalAdaptationCosts,:act_adaptationcosts_total]
adaptation_compare=readpagedata(m, "test/validationdata/act_adaptationcosts_tot.csv")
@test adaptation ≈ adaptation_compare rtol=1e-2

#Damages
damages=m[:Discontinuity,:rcons_per_cap_DiscRemainConsumption]
damages_compare=readpagedata(m,"test/validationdata/rcons_per_cap_DiscRemainConsumption.csv")
@test damages ≈ damages_compare rtol=10
#SLR damages
slrdamages=m[:SLRDamages,:rcons_per_cap_SLRRemainConsumption]
slrdamages_compare=readpagedata(m, "test/validationdata/rcons_per_cap_SLRRemainConsumption.csv")
@test slrdamages ≈ slrdamages_compare rtol=0.1
#Market damages
mdamages=m[:MarketDamages,:rcons_per_cap_MarketRemainConsumption]
mdamages_compare=readpagedata(m,"test/validationdata/rcons_per_cap_MarketRemainConsumption.csv")
@test mdamages ≈ mdamages_compare rtol=1
#NonMarket Damages
nmdamages=m[:NonMarketDamages,:rcons_per_cap_NonMarketRemainConsumption]
nmdamages_compare=readpagedata(m,"test/validationdata/rcons_per_cap_NonMarketRemainConsumption.csv")
@test nmdamages ≈ nmdamages_compare rtol=1

te = m[:EquityWeighting, :te_totaleffect]
te_compare = 213208136.69903600
@test te ≈ te_compare rtol=1e4
