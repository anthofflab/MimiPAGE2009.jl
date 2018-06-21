using Distributions
using DataFrames
using CSVFiles

using Mimi.ScalarModelParameter

include("getpagefunction.jl")

function do_monte_carlo_runs(n=100_000)
    m = getpage()
    run(m)

    #set number of Monte Carlo runs
    nit=n

    #create vectors to hold results of Monte Carlo runs
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

    timing = @elapsed for i in 1:nit
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
        for x in m.md.external_param_conns
            # Look to see if this is a normal parameter, with the local name identical to the external name
            if Symbol(string(x.param_name)) in keys(m.md.external_params)
                # Guess that this is the intended parameter, and use it instead
                param = m.md.external_params[Symbol(string(x.param_name))]
            else
                param = x.external_param
            end

            if isa(param, ScalarModelParameter)
                #setfield!(get(m.mi).components[x.comp_name].parameters, x.param_name, param.value)
                Mimi.set_parameter_value(m.mi.components[x.comp_name], x.param_name, param.value)
            else
                #setfield!(get(m.mi).components[x.comp_name].parameters, x.param_name, param.values)
                Mimi.set_parameter_value(m.mi.components[x.comp_name], x.param_name, param.values)
            end
        end

        run(m)

        #save results of Monte Carlo runs
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

    #compile results and save output
    df=DataFrame(td=td,tpc=tpc,tac=tac,te=te,c_co2concentration=c_co2concentration,ft=ft,rt_g=rt_g,sealevel=s,rgdppercap_slr=rgdppercap_slr,rgdppercap_market=rgdppercap_market,rgdppercap_nonmarket=rgdppercap_nonmarket,rgdppercap_di=rgdppercap_disc)
    save(joinpath(@__DIR__, "../output/mimipagemontecarlooutput.csv"),df)

    return timing
end
