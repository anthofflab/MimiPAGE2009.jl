using Mimi

@defcomp LGcycle begin
    e_globalLGemissions=Parameter(index=[time],unit="Mtonne/year")
    c_LGconcentration=Variable(index=[time],unit="ppbv")
    pic_preindustconcLG=Parameter(unit="ppbv")
    exc_excessconcLG=Variable(unit="ppbv")
    c0_LGconcbaseyr=Parameter(unit="ppbv")
    re_remainLG=Variable(index=[time],unit="Mtonne")
    nte_natLGemissions=Variable(index=[time],unit="Mtonne/year")
    air_LGfractioninatm=Parameter(unit="%")
    tea_LGemissionstoatm=Variable(index=[time],unit="Mtonne/year")
    teay_LGemissionstoatm=Variable(index=[time],unit="Mtonne/t")
    y_year=Parameter(index=[time],unit="year")
    y_year_0=Parameter(unit="year")
    res_LGatmlifetime=Parameter(unit="year")
    den_LGdensity=Parameter(unit="Mtonne/ppbv")
    stim_LGemissionfeedback=Parameter(unit="Mtonne/degreeC")
    rtl_g0_baselandtemp=Parameter(index=[1],unit="degreeC")
    rtl_g_landtemperature=Parameter(index=[time],unit="degreeC")
    re_remainLGbase=Variable(unit="Mtonne")
end

function run_timestep(s::LGcycle,t::Int64)
    v=s.Variables
    p=s.Parameters

    if t==1
        #eq.3 from Hope (2006) - natural emissions (carbon cycle) feedback, using global temperatures calculated in ClimateTemperature component
        v.nte_natLGemissions[t]=p.stim_LGemissionfeedback*p.rtl_g0_baselandtemp[1]
        #eq.6 from Hope (2006) - emissions to atmosphere depend on the sum of natural and anthropogenic emissions
        v.tea_LGemissionstoatm[t]=(p.e_globalLGemissions[t]+v.nte_natLGemissions[t])*p.air_LGfractioninatm/100
        #Check with Chris Hope - unclear how calculated in first time period - assume emissions from period 1 are used
        v.teay_LGemissionstoatm[t]=v.tea_LGemissionstoatm[t]
        #adapted from eq.1 in Hope(2006) - calculate excess concentration in base year
        v.exc_excessconcLG=p.c0_LGconcbaseyr-p.pic_preindustconcLG
        #Eq. 2 from Hope (2006) - base-year remaining emissions
        v.re_remainLGbase=v.exc_excessconcLG*p.den_LGdensity
        v.re_remainLG[t]=v.re_remainLGbase*exp(-(p.y_year[t]-p.y_year_0)/p.res_LGatmlifetime)+
            v.teay_LGemissionstoatm[t]*p.res_LGatmlifetime*(1-exp(-(p.y_year[t]-p.y_year_0)/p.res_LGatmlifetime))/(p.y_year[t]-p.y_year_0)
    else
        #eq.3 from Hope (2006) - natural emissions (carbon cycle) feedback, using global temperatures calculated in ClimateTemperature component
        #Check with Chris Hope - in Hope 2006, natural emissions depend on area-weighted average regional temperatures. Hope 2009 also has ocean and global temperatures.
        #Here assume still using area-weighted average regional temperatures (i.e. land temperatures) for natural emissions feedback
        v.nte_natLGemissions[t]=p.stim_LGemissionfeedback*p.rtl_g_landtemperature[t-1]
        #eq.6 from Hope (2006) - emissions to atmosphere depend on the sum of natural and anthropogenic emissions
        v.tea_LGemissionstoatm[t]=(p.e_globalLGemissions[t]+v.nte_natLGemissions[t])*p.air_LGfractioninatm/100
        #eq.7 from Hope (2006) - average emissions to atm over time period
        v.teay_LGemissionstoatm[t]=(v.tea_LGemissionstoatm[t]+v.tea_LGemissionstoatm[t-1])*(p.y_year[t]-p.y_year[t-1])/2
        #eq.10 from Hope (2006) - remaining emissions in atmosphere
        v.re_remainLG[t]=v.re_remainLG[t-1]*exp(-(p.y_year[t]-p.y_year[t-1])/p.res_LGatmlifetime)+
            v.teay_LGemissionstoatm[t]*p.res_LGatmlifetime*(1-exp(-(p.y_year[t]-p.y_year[t-1])/p.res_LGatmlifetime))/(p.y_year[t]-p.y_year[t-1])
    end

#eq.11 from Hope(2006) - LG concentration
    v.c_LGconcentration[t]=p.pic_preindustconcLG+v.exc_excessconcLG*v.re_remainLG[t]/v.re_remainLGbase

end

function addLGcycle(model::Model)
    lgcyclecomp = addcomponent(model, LGcycle)

    lgcyclecomp[:pic_preindustconcLG] = 0.
    lgcyclecomp[:den_LGdensity] = 100000.
    lgcyclecomp[:stim_LGemissionfeedback] = 0.
    lgcyclecomp[:air_LGfractioninatm] = 100.
    lgcyclecomp[:res_LGatmlifetime] = 1000.
    lgcyclecomp[:c0_LGconcbaseyr] = 0.11

    return lgcyclecomp
end
