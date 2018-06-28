using Mimi

@defcomp ch4cycle begin
    e_globalCH4emissions=Parameter(index=[time],unit="Mtonne/year")
    e_0globalCH4emissions=Parameter(unit="Mtonne/year", default=363.00000000000006)
    c_CH4concentration=Variable(index=[time],unit="ppbv")
    pic_preindustconcCH4=Parameter(unit="ppbv", default=700.)
    exc_excessconcCH4=Variable(unit="ppbv")
    c0_CH4concbaseyr=Parameter(unit="ppbv", default=1860.)
    re_remainCH4=Variable(index=[time],unit="ppbv")
    re_remainCH4base=Variable(unit="ppbv")
    nte_natCH4emissions=Variable(index=[time],unit="Mtonne/year")
    air_CH4fractioninatm=Parameter(unit="%", default=100.)
    tea_CH4emissionstoatm=Variable(index=[time],unit="Mtonne/year")
    teay_CH4emissionstoatm=Variable(index=[time],unit="Mtonne/t")
    y_year=Parameter(index=[time],unit="year")
    y_year_0=Parameter(unit="year")
    res_CH4atmlifetime=Parameter(unit="year", default=10.5)
    den_CH4density=Parameter(unit="Mtonne/ppbv", default=2.78)
    stim_CH4emissionfeedback=Parameter(unit="Mtonne/degreeC", default=0.)
    rtl_g0_baselandtemp=Parameter(unit="degreeC", default=0.9258270139190647)
    rtl_g_landtemperature=Parameter(index=[time],unit="degreeC")

    function run_timestep(p, v, d, t)

        if t==1
            #eq.3 from Hope (2006) - natural emissions (carbon cycle) feedback, using global temperatures calculated in ClimateTemperature component
            nte_0=p.stim_CH4emissionfeedback*p.rtl_g0_baselandtemp
            v.nte_natCH4emissions[t]=p.stim_CH4emissionfeedback*p.rtl_g0_baselandtemp
            #eq.6 from Hope (2006) - emissions to atmosphere depend on the sum of natural and anthropogenic emissions
            v.tea_CH4emissionstoatm[t]=(p.e_globalCH4emissions[t]+v.nte_natCH4emissions[t])*p.air_CH4fractioninatm/100
            tea_0=(p.e_0globalCH4emissions+nte_0)*p.air_CH4fractioninatm/100
            v.teay_CH4emissionstoatm[t]=(v.tea_CH4emissionstoatm[t]+tea_0)*(p.y_year[t]-p.y_year_0)/2
            #adapted from eq.1 in Hope(2006) - calculate excess concentration in base year
            v.exc_excessconcCH4=p.c0_CH4concbaseyr-p.pic_preindustconcCH4
            #Eq. 2 from Hope (2006) - base-year remaining emissions
            v.re_remainCH4base=v.exc_excessconcCH4*p.den_CH4density
            v.re_remainCH4[t]=v.re_remainCH4base*exp(-(p.y_year[t]-p.y_year_0)/p.res_CH4atmlifetime)+
                v.teay_CH4emissionstoatm[t]*p.res_CH4atmlifetime*(1-exp(-(p.y_year[t]-p.y_year_0)/p.res_CH4atmlifetime))/(p.y_year[t]-p.y_year_0)
        else
            #eq.3 from Hope (2006) - natural emissions (carbon cycle) feedback, using global temperatures calculated in ClimateTemperature component
            #Here assume still using area-weighted average regional temperatures (i.e. land temperatures) for natural emissions feedback
            v.nte_natCH4emissions[t]=p.stim_CH4emissionfeedback*p.rtl_g_landtemperature[t-1] #askChrisHope
            #eq.6 from Hope (2006) - emissions to atmosphere depend on the sum of natural and anthropogenic emissions
            v.tea_CH4emissionstoatm[t]=(p.e_globalCH4emissions[t]+v.nte_natCH4emissions[t])*p.air_CH4fractioninatm/100
            #eq.7 from Hope (2006) - average emissions to atm over time period
            v.teay_CH4emissionstoatm[t]=(v.tea_CH4emissionstoatm[t]+v.tea_CH4emissionstoatm[t-1])*(p.y_year[t]-p.y_year[t-1])/2
            #eq.10 from Hope (2006) - remaining emissions in atmosphere
            v.re_remainCH4[t]=v.re_remainCH4[t-1]*exp(-(p.y_year[t]-p.y_year[t-1])/p.res_CH4atmlifetime)+
                v.teay_CH4emissionstoatm[t]*p.res_CH4atmlifetime*(1-exp(-(p.y_year[t]-p.y_year[t-1])/p.res_CH4atmlifetime))/(p.y_year[t]-p.y_year[t-1])
        end

        #eq.11 from Hope(2006) - CH4 concentration
        v.c_CH4concentration[t]=p.pic_preindustconcCH4+v.exc_excessconcCH4*v.re_remainCH4[t]/v.re_remainCH4base
    end
end
