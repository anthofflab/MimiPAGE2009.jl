@defcomp co2cycle begin
    e_globalCO2emissions = Parameter(index=[time], unit="Mtonne/year")
    e0_globalCO2emissions = Parameter(unit="Mtonne/year", default=38191.0315797948)
    c_CO2concentration = Variable(index=[time], unit="ppbv")
    pic_preindustconcCO2 = Parameter(unit="ppbv", default=278000.)
    exc_excessconcCO2 = Variable(unit="ppbv")
    c0_CO2concbaseyr = Parameter(unit="ppbv", default=395000.)
    re_remainCO2 = Variable(index=[time], unit="Mtonne")
    re_remainCO2base = Variable(unit="Mtonne")
    renoccf_remainCO2wocc = Variable(index=[time], unit="Mtonne")
    air_CO2fractioninatm = Parameter(unit="%", default=62.00)
    stay_fractionCO2emissionsinatm = Parameter(default=0.3)
    tea_CO2emissionstoatm = Variable(index=[time], unit="Mtonne/year")
    teay_CO2emissionstoatm = Variable(index=[time], unit="Mtonne/t")
    ccf_CO2feedback = Parameter(unit="%/degreeC", default=9.66666666666667)
    ccfmax_maxCO2feedback = Parameter(unit="%", default=53.3333333333333)
    cea_cumCO2emissionsatm = Variable(index=[time], unit="Mtonne")
    ce_0_basecumCO2emissions = Parameter(unit="Mtonne", default=2050000.)
    y_year = Parameter(index=[time], unit="year")
    y_year_0 = Parameter(unit="year")
    res_CO2atmlifetime = Parameter(unit="year", default=73.3333333333333)
    den_CO2density = Parameter(unit="Mtonne/ppbv", default=7.8)
    rt_g0_baseglobaltemp = Parameter(unit="degreeC", default=0.735309967925382)
    rt_g_globaltemperature = Parameter(index=[time], unit="degreeC")

    function run_timestep(p, v, d, t)

        if is_first(t)
            #CO2 emissions gain calculated based on PAGE 2009
            gain = p.ccf_CO2feedback * p.rt_g0_baseglobaltemp
            #eq.6 from Hope (2006) - emissions to atmosphere depend on the sum of natural and anthropogenic emissions
            tea0 = p.e0_globalCO2emissions * p.air_CO2fractioninatm / 100
            v.tea_CO2emissionstoatm[t] = (p.e_globalCO2emissions[t]) * p.air_CO2fractioninatm / 100
            v.teay_CO2emissionstoatm[t] = (v.tea_CO2emissionstoatm[t] + tea0) * (p.y_year[t] - p.y_year_0) / 2
            #adapted from eq.1 in Hope(2006) - calculate excess concentration in base year
            v.exc_excessconcCO2 = p.c0_CO2concbaseyr - p.pic_preindustconcCO2
            #Eq. 2 from Hope (2006) - base-year remaining emissions
            v.re_remainCO2base = v.exc_excessconcCO2 * p.den_CO2density
            #PAGE 2009 initial remaining emissions without CO2 feedback
            renoccf0_remainCO2wocc = v.re_remainCO2base / (1 + gain / 100)
            #eq. 8 from Hope (2006) - baseline cumulative emissions to atmosphere
            ceabase = p.ce_0_basecumCO2emissions * p.air_CO2fractioninatm / 100
            #eq.9 from Hope(2006) - cumulative emissions in atmosphere
            v.cea_cumCO2emissionsatm[t] = ceabase + v.teay_CO2emissionstoatm[t]
            #eq.11 from Hope (2006) - anthropogenic remaining emissions
            v.renoccf_remainCO2wocc[t] = p.stay_fractionCO2emissionsinatm * ceabase *
                                         (1 - exp(-(p.y_year[t] - p.y_year_0) /
                                                  p.res_CO2atmlifetime)) + renoccf0_remainCO2wocc *
                                                                           exp(-(p.y_year[t] - p.y_year_0) / p.res_CO2atmlifetime) +
                                         v.teay_CO2emissionstoatm[t] * exp(-(p.y_year[t] - p.y_year_0) /
                                                                           (2 * p.res_CO2atmlifetime))
            #Hope 2009 - remaining emissions with CO2 feedback
            v.re_remainCO2[t] = v.renoccf_remainCO2wocc[t] * (1 + gain / 100)
        else
            #CO2 emissions gain calculated based on PAGE 2009
            gain = min(p.ccf_CO2feedback * p.rt_g_globaltemperature[t-1], p.ccfmax_maxCO2feedback)
            #eq.6 from Hope (2006) - emissions to atmosphere depend on the sum of natural and anthropogenic emissions
            v.tea_CO2emissionstoatm[t] = (p.e_globalCO2emissions[t]) * p.air_CO2fractioninatm / 100
            #eq.7 from Hope (2006) - total emissions over time period
            v.teay_CO2emissionstoatm[t] = (v.tea_CO2emissionstoatm[t] + v.tea_CO2emissionstoatm[t-1]) *
                                          (p.y_year[t] - p.y_year[t-1]) / 2
            #eq.9 from Hope(2006) - cumulative emissions in atmosphere
            v.cea_cumCO2emissionsatm[t] = v.cea_cumCO2emissionsatm[t-1] + v.teay_CO2emissionstoatm[t]
            #eq.11 from Hope (2006) - anthropogenic remaining emissions
            v.renoccf_remainCO2wocc[t] = p.stay_fractionCO2emissionsinatm * v.cea_cumCO2emissionsatm[t-1] *
                                         (1 - exp(-(p.y_year[t] - p.y_year[t-1]) /
                                                  p.res_CO2atmlifetime)) + v.renoccf_remainCO2wocc[t-1] *
                                                                           exp(-(p.y_year[t] - p.y_year[t-1]) / p.res_CO2atmlifetime) +
                                         v.teay_CO2emissionstoatm[t] * exp(-(p.y_year[t] - p.y_year[t-1]) /
                                                                           (2 * p.res_CO2atmlifetime))
            #Hope 2009 - remaining emissions with CO2 feedback
            v.re_remainCO2[t] = v.renoccf_remainCO2wocc[t] * (1 + gain / 100)
        end
        #eq.11 from Hope(2006) - CO2 concentration
        v.c_CO2concentration[t] = p.pic_preindustconcCO2 + v.exc_excessconcCO2 * v.re_remainCO2[t] / v.re_remainCO2base
    end
end
