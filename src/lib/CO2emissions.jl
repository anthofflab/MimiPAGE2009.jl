using Mimi

@defcomp co2emissions begin
    region=Index()

    e_globalco2emissions=Variable(index=[time],unit="Mtonne/year")
    e0_baselineco2emissions=Parameter(index=[region],unit="Mtonne/year")
    e_regionalco2emissions=Variable(index=[time,region],unit="Mtonne/year")
    er_CO2emissionsgrowth=Parameter(index=[time,region],unit="%")
end

function run_timestep(s::ch4emissions,t::Int64)
    v=s.Variables
    p=s.Parameters
    d=s.Dimensions

    #eq.4 in Hope (2006) - regional CH4 emissions as % change from baseline
    for r in d.regions
        v.e_regionalco2emissions[t,r]=p.er_CO2emissionsgrowth[t,r]*p.e0_baselineco2emissions[r]/100
    end

    #eq. 5 in Hope (2006) - global CH4 emissions are sum of regional emissions
    v.e_globalco2emissions[t]=sum(v.e_regionalco2emissions[t,:])
end
