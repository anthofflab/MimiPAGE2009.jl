using Distributions
using DataFrames
using RCall

using Mimi.ScalarModelParameter

include("getpagefunction.jl")
m = getpage()
run(m)

nit=1000;
td=zeros(nit);
tpc=zeros(nit);
tac=zeros(nit);
te=zeros(nit);
ft=zeros(nit);
rt_g=zeros(nit);
s=zeros(nit);
c_co2concentration=zeros(nit);
rgdppercap_slr=zeros(nit);
rgdppercap_market=zeros(nit);
rgdppercap_nonmarket=zeros(nit);
rgdppercap_disc=zeros(nit);

for i in 1:nit
    # Randomize all components with random parameters
    randomizeCO2cycle(m)
    randomizesulphatecomp(m)
    randomizeclimatetemperature(m)
    randomizeSLR(m)
    randomizegdp(m)
    randomizemarketdamages(m)
    randomizenonmarketdamages(m)
    randomizeslrdamages(m)
    randomizediscontinuity(m)
    randomizeequityweighting(m)
    randomizeabatementcosts(m)
    randomizeadaptationcosts(m)

    # Update all parameters
    for x in m.external_parameter_connections
        # Look to see if this is a normal parameter, with the local name identical to the external name
        if Symbol(lowercase(string(x.param_name))) in keys(m.external_parameters)
            # Guess that this is the intended parameter, and use it instead
            param = m.external_parameters[Symbol(lowercase(string(x.param_name)))]
        else
            param = x.external_parameter
        end
        if isa(param, ScalarModelParameter)
            setfield!(get(m.mi).components[x.component_name].Parameters, x.param_name, param.value)
        else
            setfield!(get(m.mi).components[x.component_name].Parameters, x.param_name, param.values)
        end
    end

    run(m)

    td[i]=m[:EquityWeighting,:td_totaldiscountedimpacts]
    tpc[i]=m[:EquityWeighting,:tpc_totalaggregatedcosts]
    tac[i]=m[:EquityWeighting,:tac_totaladaptationcosts]
    te[i]=m[:EquityWeighting,:te_totaleffect]
    c_co2concentration[i]=m[:co2cycle,:c_CO2concentration][10]
    ft[i]=m[:TotalForcing,:ft_totalforcing][10]
    rt_g[i]=m[:ClimateTemperature,:rt_g_globaltemperature][10]
    s[i]=m[:SeaLevelRise,:s_sealevel][10]
    rgdppercap_slr[i]=m[:SLRDamages,:rgdp_per_cap_SLRRemainGDP][10,8]
    rgdppercap_market[i]=m[:MarketDamages,:rgdp_per_cap_MarketRemainGDP][10,8]
    rgdppercap_nonmarket[i]=m[:NonMarketDamages,:rgdp_per_cap_NonMarketRemainGDP][10,8]
    rgdppercap_disc[i]=m[:Discontinuity,:rgdp_per_cap_NonMarketRemainGDP][10,8]
end

df=DataFrame(td=td,tpc=tpc,tac=tac,te=te,c_co2concentration=c_co2concentration,ft=ft,rt_g=rt_g,sealevel=s,rgdppercap_slr=rgdppercap_slr,rgdppercap_market=rgdppercap_market,rgdppercap_nonmarket=rgdppercap_nonmarket,rgdppercap_di=rgdppercap_disc)

writetable("../test/validationdata/mimipagemontecarlooutput.csv",df)
#make plots of output Distributions
R"x11()"
R"par(mfrow=c(2,2))"
for i in 1:4
    R"hist($df[,$i]/1e9,main=c('Total Damages','Total Abatement Costs','Total Adaptation Costs','Total Effect')[$i],xlab='Billions of Dollars',col=c('darkslategray1','navyblue','deepskyblue3','dodgerblue4')[$i])"
    R"abline(v=quantile($df[,$i]/1e9,probs=c(0.05,0.95)),lty=2)"
end
