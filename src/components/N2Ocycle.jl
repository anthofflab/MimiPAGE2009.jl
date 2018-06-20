using Mimi

@defcomp n2ocycle begin
    e_globalN2Oemissions=Parameter(index=[time],unit="Mtonne/year")
    e_0globalN2Oemissions=Parameter(unit="Mtonne/year")
    c_N2Oconcentration=Variable(index=[time],unit="ppbv")
    pic_preindustconcN2O=Parameter(unit="ppbv")
    exc_excessconcN2O=Variable(unit="ppbv")
    c0_N2Oconcbaseyr=Parameter(unit="ppbv")
    re_remainN2O=Variable(index=[time],unit="Mtonne")
    re_remainN2Obase=Variable(unit="Mtonne")
    nte_natN2Oemissions=Variable(index=[time],unit="Mtonne/year")
    air_N2Ofractioninatm=Parameter(unit="%")
    tea_N2Oemissionstoatm=Variable(index=[time],unit="Mtonne/year")
    teay_N2Oemissionstoatm=Variable(index=[time],unit="Mtonne/t")
    y_year=Parameter(index=[time],unit="year")
    y_year_0=Parameter(unit="year")
    res_N2Oatmlifetime=Parameter(unit="year")
    den_N2Odensity=Parameter(unit="Mtonne/ppbv")
    stim_N2Oemissionfeedback=Parameter(unit="Mtonne/degreeC")
    rtl_g0_baselandtemp=Parameter(unit="degreeC")
    rtl_g_landtemperature=Parameter(index=[time],unit="degreeC")

    function run_timestep(p, v, d, t)
        #note that Hope (2009) states that Equations 1-12 for methane also apply to N2O

        if t==1
            #eq.3 from Hope (2006) - natural emissions feedback, using global temperatures calculated in ClimateTemperature component
            nte_0=p.stim_N2Oemissionfeedback*p.rtl_g0_baselandtemp
            v.nte_natN2Oemissions[t]=p.stim_N2Oemissionfeedback*p.rtl_g0_baselandtemp
            #eq.6 from Hope (2006) - emissions to atmosphere depend on the sum of natural and anthropogenic emissions
            v.tea_N2Oemissionstoatm[t]=(p.e_globalN2Oemissions[t]+v.nte_natN2Oemissions[t])*p.air_N2Ofractioninatm/100
            tea_0=(p.e_0globalN2Oemissions+nte_0)*p.air_N2Ofractioninatm/100
            v.teay_N2Oemissionstoatm[t]=(v.tea_N2Oemissionstoatm[t]+tea_0)*(p.y_year[t]-p.y_year_0)/2
            #adapted from eq.1 in Hope(2006) - calculate excess concentration in base year
            v.exc_excessconcN2O=p.c0_N2Oconcbaseyr-p.pic_preindustconcN2O
            #Eq. 2 from Hope (2006) - base-year remaining emissions
            v.re_remainN2Obase=v.exc_excessconcN2O*p.den_N2Odensity
            v.re_remainN2O[t]=v.re_remainN2Obase*exp(-(p.y_year[t]-p.y_year_0)/p.res_N2Oatmlifetime)+
                v.teay_N2Oemissionstoatm[t]*p.res_N2Oatmlifetime*(1-exp(-(p.y_year[t]-p.y_year_0)/p.res_N2Oatmlifetime))/(p.y_year[t]-p.y_year_0)
        else
            #eq.3 from Hope (2006) - natural emissions (carbon cycle) feedback, using global temperatures calculated in ClimateTemperature component
            #Here assume still using area-weighted average regional temperatures (i.e. land temperatures) for natural emissions feedback
            v.nte_natN2Oemissions[t]=p.stim_N2Oemissionfeedback*p.rtl_g_landtemperature[t-1]
            #eq.6 from Hope (2006) - emissions to atmosphere depend on the sum of natural and anthropogenic emissions
            v.tea_N2Oemissionstoatm[t]=(p.e_globalN2Oemissions[t]+v.nte_natN2Oemissions[t])*p.air_N2Ofractioninatm/100
            #eq.7 from Hope (2006) - average emissions to atm over time period
            v.teay_N2Oemissionstoatm[t]=(v.tea_N2Oemissionstoatm[t]+v.tea_N2Oemissionstoatm[t-1])*(p.y_year[t]-p.y_year[t-1])/2
            #eq.10 from Hope (2006) - remaining emissions in atmosphere
            v.re_remainN2O[t]=v.re_remainN2O[t-1]*exp(-(p.y_year[t]-p.y_year[t-1])/p.res_N2Oatmlifetime)+
                v.teay_N2Oemissionstoatm[t]*p.res_N2Oatmlifetime*(1-exp(-(p.y_year[t]-p.y_year[t-1])/p.res_N2Oatmlifetime))/(p.y_year[t]-p.y_year[t-1])
        end

        #eq.11 from Hope(2006) - N2O concentration
        v.c_N2Oconcentration[t]=p.pic_preindustconcN2O+v.exc_excessconcN2O*v.re_remainN2O[t]/v.re_remainN2Obase

    end
end

function addN2Ocycle(model::Model)
    n2ocyclecomp = addcomponent(model, n2ocycle)

    n2ocyclecomp[:pic_preindustconcN2O] = 270.
    n2ocyclecomp[:den_N2Odensity] = 7.8
    n2ocyclecomp[:stim_N2Oemissionfeedback] = 0.
    n2ocyclecomp[:air_N2Ofractioninatm] = 100.
    n2ocyclecomp[:res_N2Oatmlifetime] = 114.
    n2ocyclecomp[:c0_N2Oconcbaseyr] = 322.
    n2ocyclecomp[:rtl_g0_baselandtemp] = 0.9258270139190647
    n2ocyclecomp[:e_0globalN2Oemissions] = 11.046520000000001

    n2ocyclecomp
end
