@defcomp n2oemissions begin
    region=Index()

    e_globalN2Oemissions=Variable(index=[time],unit="Mtonne/year")
    e0_baselineN2Oemissions=Parameter(index=[region],unit="Mtonne/year")
    e_regionalN2Oemissions=Variable(index=[time,region],unit="Mtonne/year")
    er_N2Oemissionsgrowth=Parameter(index=[time,region],unit="%")

    function run_timestep(p, v, d, t)
        #note that Hope (2009) states that Equations 1-12 for methane also apply to N2O

        #eq.4 in Hope (2006) - regional N2O emissions as % change from baseline
        for r in d.region
            v.e_regionalN2Oemissions[t,r]=p.er_N2Oemissionsgrowth[t,r]*p.e0_baselineN2Oemissions[r]/100
        end

        #eq. 5 in Hope (2006) - global N2O emissions are sum of regional emissions
        v.e_globalN2Oemissions[t]=sum(v.e_regionalN2Oemissions[t,:])
    end
end
