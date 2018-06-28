using Mimi

@defcomp LGcycle begin
    e_globalLGemissions=Parameter(index=[time],unit="Mtonne/year")
    e_0globalLGemissions=Parameter(unit="Mtonne/year", default=557.2112715473608)
    c_LGconcentration=Variable(index=[time],unit="ppbv")
    pic_preindustconcLG=Parameter(unit="ppbv", default=0.)
    exc_excessconcLG=Variable(unit="ppbv")
    c0_LGconcbaseyr=Parameter(unit="ppbv", default=0.11)
    re_remainLG=Variable(index=[time],unit="Mtonne")
    nte_natLGemissions=Variable(index=[time],unit="Mtonne/year")
    air_LGfractioninatm=Parameter(unit="%", default=100.)
    tea_LGemissionstoatm=Variable(index=[time],unit="Mtonne/year")
    teay_LGemissionstoatm=Variable(index=[time],unit="Mtonne/t")
    y_year=Parameter(index=[time],unit="year")
    y_year_0=Parameter(unit="year")
    res_LGatmlifetime=Parameter(unit="year", default=1000.)
    den_LGdensity=Parameter(unit="Mtonne/ppbv", default=100000.)
    stim_LGemissionfeedback=Parameter(unit="Mtonne/degreeC", default=0.)
    rtl_g0_baselandtemp=Parameter(unit="degreeC", default=0.9258270139190647)
    rtl_g_landtemperature=Parameter(index=[time],unit="degreeC")
    re_remainLGbase=Variable(unit="Mtonne")

    function run_timestep(p, v, d, t)
        if t==1
            #eq.3 from Hope (2006) - natural emissions (carbon cycle) feedback, using global temperatures calculated in ClimateTemperature component
            nte0=p.stim_LGemissionfeedback*p.rtl_g0_baselandtemp
            v.nte_natLGemissions[t]=p.stim_LGemissionfeedback*p.rtl_g0_baselandtemp
            #eq.6 from Hope (2006) - emissions to atmosphere depend on the sum of natural and anthropogenic emissions
            tea0=(p.e_0globalLGemissions+nte0)*p.air_LGfractioninatm/100
            v.tea_LGemissionstoatm[t]=(p.e_globalLGemissions[t]+v.nte_natLGemissions[t])*p.air_LGfractioninatm/100
            v.teay_LGemissionstoatm[t]=(v.tea_LGemissionstoatm[t]+tea0)*(p.y_year[t]-p.y_year_0)/2
            #adapted from eq.1 in Hope(2006) - calculate excess concentration in base year
            v.exc_excessconcLG=p.c0_LGconcbaseyr-p.pic_preindustconcLG
            #Eq. 2 from Hope (2006) - base-year remaining emissions
            v.re_remainLGbase=v.exc_excessconcLG*p.den_LGdensity
            v.re_remainLG[t]=v.re_remainLGbase*exp(-(p.y_year[t]-p.y_year_0)/p.res_LGatmlifetime)+
                v.teay_LGemissionstoatm[t]*p.res_LGatmlifetime*(1-exp(-(p.y_year[t]-p.y_year_0)/p.res_LGatmlifetime))/(p.y_year[t]-p.y_year_0)
        else
            #eq.3 from Hope (2006) - natural emissions (carbon cycle) feedback, using global temperatures calculated in ClimateTemperature component
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
end
