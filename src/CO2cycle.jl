using Mimi

@defcomp co2cycle begin
    e_globalCO2emissions=Parameter(index=[time],unit="Mtonne/year")
    c_CO2concentration=Variable(index=[time],unit="ppbv")
    pic_preindustconcCO2=Parameter(unit="ppbv")
    exc_excessconcCO2=Variable(unit="ppbv")
    c0_CO2concbaseyr=Parameter(unit="ppbv")
    re_remainCO2=Variable(index=[time],unit="ppbv")
    re_remainCO2base=Variable(unit="ppbv")
    renoccf_remainCO2wocc=Variable(index=[time],unit="ppbv")
    air_CO2fractioninatm=Parameter(unit="%")
    stay_fractionCO2emissionsinatm=Parameter(unit="none")#Check with Chris Hope - in input values this number is given as %, but in description this is described as a fraction
    tea_CO2emissionstoatm=Variable(index=[time],unit="Mtonne/year")
    teay_CO2emissionstoatm=Variable(index=[time],unit="Mtonne/t")
    ccf_CO2feedback=Parameter(unit="%/degreeC")
    ccfmax_maxCO2feedback=Parameter(unit="%")
    cea_cumCO2emissionsatm=Variable(index=[time],unit="Mtonne")
    ce_0_basecumCO2emissions=Parameter(unit="Mtonne")
    y_year=Parameter(index=[time],unit="year")
    y_year_0=Parameter(unit="year")
    res_CO2atmlifetime=Parameter(unit="year")
    den_CO2density=Parameter(unit="Mtonne/ppbv")
    rt_g0_baseglobaltemp=Parameter(index=[1],unit="degreeC")
    rt_g_globaltemperature=Parameter(index=[time],unit="degreeC")
end

function run_timestep(s::co2cycle,t::Int64)
    v=s.Variables
    p=s.Parameters

    if t==1
        #CO2 emissions gain calculated based on PAGE 2009
        gain=p.ccf_CO2feedback*p.rt_g0_baseglobaltemp[1]
        #eq.6 from Hope (2006) - emissions to atmosphere depend on the sum of natural and anthropogenic emissions
        v.tea_CO2emissionstoatm[t]=(p.e_globalCO2emissions[t])*p.air_CO2fractioninatm/100
        #unclear how calculated in first time period - assume emissions from period 1 are used. Check with Chris Hope.
        v.teay_CO2emissionstoatm[t]=v.tea_CO2emissionstoatm[t]
        #adapted from eq.1 in Hope(2006) - calculate excess concentration in base year
        v.exc_excessconcCO2=p.c0_CO2concbaseyr-p.pic_preindustconcCO2
        #Eq. 2 from Hope (2006) - base-year remaining emissions
        v.re_remainCO2base=v.exc_excessconcCO2*p.den_CO2density
        #PAGE 2009 initial remaining emissions without CO2 feedback
        renoccf0_remainCO2wocc=v.re_remainCO2base/(1+gain/100)
        #eq. 8 from Hope (2006) - baseline cumulative emissions to atmosphere
        ceabase=p.ce_0_basecumCO2emissions*p.air_CO2fractioninatm/100
        #eq.9 from Hope(2006) - cumulative emissions in atmosphere
        v.cea_cumCO2emissionsatm[t]=ceabase+v.teay_CO2emissionstoatm[t]
        #eq.11 from Hope (2006) - anthropogenic remaining emissions
        v.renoccf_remainCO2wocc[t]=p.stay_fractionCO2emissionsinatm*ceabase*(1-exp(-(p.y_year[t]-p.y_year_0)/p.res_CO2atmlifetime))+renoccf0_remainCO2wocc*exp(-(p.y_year[t]-p.y_year_0)/p.res_CO2atmlifetime)+v.teay_CO2emissionstoatm[t]*exp(-(p.y_year[t]-p.y_year_0)/(2*p.res_CO2atmlifetime))
        #Hope 2009 - remaining emissions with CO2 feedback
        v.re_remainCO2[t]=v.renoccf_remainCO2wocc[t]*(1+gain)/100
    else
        #CO2 emissions gain calculated based on PAGE 2009
        gain=min(p.ccf_CO2feedback*p.rt_g_globaltemperature[t-1],p.ccfmax_maxCO2feedback)
        #eq.6 from Hope (2006) - emissions to atmosphere depend on the sum of natural and anthropogenic emissions
        v.tea_CO2emissionstoatm[t]=(p.e_globalCO2emissions[t])*p.air_CO2fractioninatm/100
        #eq.7 from Hope (2006) - total emissions over time period
        v.teay_CO2emissionstoatm[t]=(v.tea_CO2emissionstoatm[t]+v.tea_CO2emissionstoatm[t-1])*(p.y_year[t]-p.y_year[t-1])/2
        #eq.9 from Hope(2006) - cumulative emissions in atmosphere
        v.cea_cumCO2emissionsatm[t]=v.cea_cumCO2emissionsatm[t-1]+v.teay_CO2emissionstoatm[t]
        #eq.11 from Hope (2006) - anthropogenic remaining emissions
        v.renoccf_remainCO2wocc[t]=p.stay_fractionCO2emissionsinatm*v.cea_cumCO2emissionsatm[t-1]*(1-exp(-(p.y_year[t]-p.y_year[t-1])/p.res_CO2atmlifetime))+v.renoccf_remainCO2wocc[t-1]*exp(-(p.y_year[t]-p.y_year[t-1])/p.res_CO2atmlifetime)+v.teay_CO2emissionstoatm[t]*exp(-(p.y_year[t]-p.y_year[t-1])/(2*p.res_CO2atmlifetime))
        #Hope 2009 - remaining emissions with CO2 feedback
        v.re_remainCO2[t]=v.renoccf_remainCO2wocc[t]*(1+gain)/100
    end
    #eq.11 from Hope(2006) - CO2 concentration
    v.c_CO2concentration[t]=p.pic_preindustconcCO2+v.exc_excessconcCO2*v.re_remainCO2[t]/v.re_remainCO2base
end

function addCO2cycle(model::Model)
    co2cycle = addcomponent(model, CO2cycle)

    co2cycle[:pic_preindustconcCO2] = 278000.
    co2cycle[:den_CO2density] = 7.8
    co2cycle[:stay_fractionCO2emissionsinatm] = 0.3 #Check with Chris Hope - this is described as a fraction (and is not divided by 100 in the equation) but is given as 30% in the documentation
    co2cycle[:c0_co2concbaseyr] = 395000.
    co2cycle[:ce_0_basecumCO2emissions] = 2050000.
    co2cycle[:res_CO2atmlifetime] = 73.33
    co2cycle[:ccf_CO2feedback] = 9.67
    co2cycle[:ccfmax_maxCO2feedback] = 53.33
    co2cycle[:air_CO2fractioninatm] = 62.00

    co2cycle
end
