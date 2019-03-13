@defcomp ch4emissions begin
    region=Index()

    e_globalCH4emissions=Variable(index=[time],unit="Mtonne/year")
    e0_baselineCH4emissions=Parameter(index=[region],unit="Mtonne/year")
    e_regionalCH4emissions=Variable(index=[time,region],unit="Mtonne/year")
    er_CH4emissionsgrowth=Parameter(index=[time,region],unit="%")

    function run_timestep(p, v, d, t)

        #eq.4 in Hope (2006) - regional CH4 emissions as % change from baseline
        for r in d.region
            v.e_regionalCH4emissions[t,r]=p.er_CH4emissionsgrowth[t,r]*p.e0_baselineCH4emissions[r]/100
        end

        #eq. 5 in Hope (2006) - global CH4 emissions are sum of regional emissions
        v.e_globalCH4emissions[t]=sum(v.e_regionalCH4emissions[t,:])
    end
end
