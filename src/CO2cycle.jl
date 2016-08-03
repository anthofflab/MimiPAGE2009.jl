using Mimi

@defcomp co2cycle begin
    region=Index()

    e_globalco2emissions=Parameter(index=[time],unit="Mtonne")
    c_co2concentration=Variable(index=[time],unit="ppbv")
    pic_preindustconcCO2=Parameter(unit="ppbv")
    exc_excessconcCO2=Variable(unit="ppbv")
    c0_co2concbaseyr=Parameter(unit="ppbv")
    re_remainCO2=Variable(index=[time],unit="ppbv")
    den_CO2density=Parameter(unit="Mtonne/pbbv")
    cea_cumuemissionsatm=Variable(index=[time], unit="Mtonne")
    ce_cumuemissions=Variable(index=[time], unit="Mtonne")
    res_halflifeatmres=Parameter(unit="year")
    stay_propemissstayatm=Parameter()

    nte_naturalemissions=Variable(index=[time], unit="Mtonne")
    stim_biospherefdbk=Parameter(unit="Mtonne/degreeC")
    rt_realizedtemp=Parameter(index=[time, region], unit="degreeC")
    rt_realizedtempbase=Parameter(index=[region], unit="degreeC")
    area_area=Parameter(index=[region], unit="km2")
    er_emissionsvbase=Parameter(index=[time], unit="%")
    tea_totemissionsatm=Parameter(index=[time], unit="Mtonne")
    air_emissionsintoatm=Parameter(unit="%")
    teay_ematmsinceprevyr=Parameter(index=[time], unit="Mtonne")
    y_analysisyr=Parameter(index=[time], unit="year")

end

function run_timestep(s::co2cycle,t::Int64)
    v=s.Variables
    p=s.Parameters
    d=s.Dimensions

    if t==1
      # adapted from eq. 1 from Hope (2006)- excess concentration caused by humans
      # as difference between base year and pre-industrial levels
      v.exc_excessconcCO2 = p.c0_co2concbaseyr - p.pic_preindustconcCO2
    end
    # eq. 2- Level of emissions remaining in the atm in base year
    v.re_remainCO2[1]=v.exc_excessconcCO2[1]*p.den_CO2density
    # eq. 3- Natural emissions stimulated by increase in global mean temp
    if t==1
        v.nte_naturalemissions[t] = p.stim_biospherefdbk*sum(p.rt_realizedtempbase.*
            p.area_area)/ sum(p.area_area)
    else
        v.nte_naturalemissions[t]= p.stim_biospherefdbk*(sum(vec(v.rt_realizedtemp[t-1,:]).*
            p.area_area)/sum(p.area_area))
    end
    ##need to make these regional...
    ##or are they a different component such as methane and SF(6)
    # eq. 4- regional human emissions
    v.e_globalco2emissions[t,r] = (v.e_humanactemissions[t]*v.e_humanactemissions[1])/100
    # eq. 5- sum regions for total
    v.e_globalco2emissions[t] = sum(v.e_globalco2emissions[t,r])
    # eq. 6
    v.tea_totemissionsatm[t]= (v.e_globalco2emissions[t]+v.nte_naturalemissions[t])*
        p.air_emissionsintoatm/100
    # eq. 7
    v.teay_ematmsinceprevyr[t]= (v.tea_totemissionsatm[t]+v.tea_totemissionsatm[t-1])*
        (p.y_analysisyr[t]-p.y_analysisyr[t-1])/2
    # eq. 8
    # eq. 9
    # eq. 10
    # eq. 11
    v.re_remainCO2[t]=
    # eq. 12 from Hope (2006)
    v.c_co2concentration[t]= p.pic_preindustconcCO2 +
      v.exc_excessconcCO2 * v.re_remainCO2[t]/v.re_remainCO2[1]
end

function addCO2cycle(model::Model)
    co2cycle = addcomponent(model, CO2cycle)

    co2cycle[:pic_preindustconcCO2] = 278000.
    co2cycle[:den_CO2density] = 2.78
    co2cycle[:stay_propemissstayatm] = 30.
    co2cycle[:c0_co2concbaseyr] = 395000.
    co2cycle[:ce_cumuemissions] = 2050000.

    co2cycle
end
