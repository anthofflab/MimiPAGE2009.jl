using Mimi

@defcomp CO2cycle begin
    region=Index()
#outputs: exc, c, pic, re, den, cea, ce, res, stay
    c_CO2concentration=Variable(index=[time],unit="ppbv")
    pic_preindustconcCO2=Parameter(unit="ppbv")
    exc_excessconcCO2=Variable(unit="ppbv")
    c0_CO2concbaseyr=Parameter(unit="ppbv")
    renoccff_remainCO2wocarboncyclefeedback=Variable(index=[time],unit="ppbv")
    den_densityofgas=Parameter(unit="Mtonne/pbbv")
    cea_cumemissionsatm=Variable(index=[time], unit="Mtonne")
    ce_basecumemissions=Parameter(unit="Mtonne")
    res_CO2atmlifetime=Parameter(unit="year")
    stay_propemissstayatm=Parameter()
    gain_linearfeedbackofCO2= Variable(index=[time], unit="%")
    re_remainCO2= Variable(index=[time], unit= "Mtonne")
    ccf_climatecarbonfeedbackfactor= Variable(index=[time], unit= "%/degreeC")
    ccffmax_climatecarbonfeedbackmax= Parameter(unit= "%")
#...
    et_equilibriumtemperature=Variable(index=[time], unit="degreeC")
    sens_climatesensitivity= Parameter(unit="degreeC")
    ocean_climatehalflife= Parameter(unit="year")
    grt_globaltemperature= Variable(index=[time], unit="degreeC")
#inputs from Natural emissions
    nte_naturalemissions=Parameter(index=[time], unit="Mtonne/year")
    stim_biospherefdbk=Parameter(unit="Mtonne/degreeC")
#inputs from Anthropogenic emissions
    e_globalCO2emissions=Parameter(index=[time],unit="Mtonne/year")
    er_emissionsvbase=Parameter(index=[time], unit="%")
    tea_CO2emissionstoatm=Variable(index=[time], unit="Mtonne/year")
    air_CO2fractioninatm=Parameter(unit="%")
    teay_CO2emisssinceprevyr=Variable(index=[time], unit="Mtonne/year")
#part of ClimateTemperature component
    rt_realizedtemperature=Parameter(index=[time, region], unit="degreeC")
    rt_0_realizedtemperature=Parameter(index=[region], unit="degreeC")
#other
    area=Parameter(index=[region], unit="km2")
    y_year=Parameter(index=[time], unit="year")
end

function run_timestep(s::CO2cycle,t::Int64)
    v=s.Variables
    p=s.Parameters
    d=s.Dimensions

    if t==1
      # adapted from eq. 1 from Hope (2006)- excess concentration caused by humans
      # as difference between base year and pre-industrial levels
      v.exc_excessconcCO2 = p.c0_CO2concbaseyr -
        p.pic_preindustconcCO2
    end
    # eq. 2- Level of emissions remaining in the atm in base year
    #v.re_remainCO2[1]=v.exc_excessconcCO2[1]*p.den_densityofgas
    v.renoccff_remainCO2wocarboncyclefeedback[1]= v.re_remainCO2[1]/
        (1+ v.gain_linearfeedbackofCO2[t]/100)
    # eq. 3- Natural emissions stimulated by increase in global mean temp
    #if t==1
    #    v.nte_naturalemissions[t] = p.stim_biospherefdbk*sum(p.rt_realizedtempbase.*
    #        p.area)/ sum(p.area)
    #else
    #    v.nte_naturalemissions[t]= p.stim_biospherefdbk*(sum(vec(v.rt_realizedtemp[t-1,:]).*
    #        p.area)/sum(p.area))
    #end
    #PAGE09 removes eq. 3 from PAGE02
    if t==1
        v.gain_linearfeedbackofCO2[t]=v.ccf_climatecarbonfeedbackfactor[t] *
            p.rt_0_realizedtemperature[r]
    else
        v.gain_linearfeedbackofCO2[t]= min(v.ccf_climatecarbonfeedbackfactor[t]*
            p.rt_realizedtemperature[t-1,:], p.ccffmax_climatecarbonfeedbackmax)
    end
    # eq. 4- regional human emissions
    v.e_globalCO2emissions[t,r] = (v.e_humanactemissions[t,:]*v.e_humanactemissions[1, :])/100
    # eq. 5- sum regions for total
    v.e_globalCO2emissions[t] = sum(v.e_globalco2emissions[t,:])
    # eq. 6
    v.tea_CO2emissionstoatmemissionsatm[t]= (p.e_globalco2emissions[t] +
        v.nte_naturalemissions[t])* p.air_CO2fractioninatm/100
    # eq. 7- Check with Chris Hope about first time period teay_CO2emisssinceprevyr
    if t==1
        v.teay_CO2emisssinceprevyr[t]=v.tea_CO2emissionstoatm[t]
    else
        v.teay_CO2emisssinceprevyr[t]= (v.tea_CO2emissionstoatm[t]+v.tea_CO2emissionstoatm[t-1])*
            (p.y_year[t]-p.y_year[t-1])/2
    end
    # eq. 8
    if t==1
        v.cea_cumemissionsatm[t]= p.ce_basecumemissions*p.air_co2fractioninatm/100
    else
    # eq.9
        v.cea_cumemissionsatm[t]= v.cea_cumemissionsatm[t-1]+ v.teay_ematmsinceprevyr[t]
    end
    # eq. 11
    #same as for CH4, how is re[0] calculated? equation 2
    v.renoccff_remainCO2wocarboncyclefeedback[t]=p.stay_propemissstayatm *
        cea_cumuemissionsatm[t-1]* (1-exp(-(p.y_year[t]-p.y_year[t-1])/p.res_CO2atmlifetime))+
        v.renoccff_remainCO2wocarboncyclefeedback[t-1]* (1-exp(-(p.y_year[t]-p.y_year[t-1])/p.res_CO2atmlifetime))+
        p.teay_CO2emisssinceprevyr[t]*(1-exp(-(p.y_year[t]-p.y_year[t-1])/(2*p.res_CO2atmlifetime)))
    #Update from PAGE09
    v.re_remainCO2[t] =  v.renoccff_remainCO2wocarboncyclefeedback[t]*
        (1+v.gain_linearfeedbackofCO2[t]/100)
    # eq. 12 from Hope (2006)
    v.c_CO2concentration[t]= p.pic_preindustconcCO2 +
        v.exc_excessconcCO2[1] * v.re_remainCO2[t]/v.re_remainCO2[1]

end
