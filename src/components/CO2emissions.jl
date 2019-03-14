@defcomp co2emissions begin
    region=Index()

    e_globalCO2emissions=Variable(index=[time],unit="Mtonne/year")
    e0_baselineCO2emissions=Parameter(index=[region],unit="Mtonne/year")
    e_regionalCO2emissions=Variable(index=[time,region],unit="Mtonne/year")
    er_CO2emissionsgrowth=Parameter(index=[time,region],unit="%")
    
    function run_timestep(p, v, d, t)

        #eq.4 in Hope (2006) - regional CO2 emissions as % change from baseline
        for r in d.region
            v.e_regionalCO2emissions[t,r]=p.er_CO2emissionsgrowth[t,r]*p.e0_baselineCO2emissions[r]/100
        end
        #eq. 5 in Hope (2006) - global CO2 emissions are sum of regional emissions
        v.e_globalCO2emissions[t]=sum(v.e_regionalCO2emissions[t,:])
    end
end