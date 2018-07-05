using Mimi

@defcomp co2forcing begin
    c_CO2concentration=Parameter(index=[time],unit="ppbv")
    f0_CO2baseforcing=Parameter(unit="W/m2", default=1.735)
    fslope_CO2forcingslope=Parameter(unit="W/m2", default=5.5)
    c0_baseCO2conc=Parameter(unit="ppbv", default=395000.)
    f_CO2forcing=Variable(index=[time],unit="W/m2")

    function run_timestep(p, v, d, t)

        #eq.13 in Hope 2006
        v.f_CO2forcing[t]=p.f0_CO2baseforcing+p.fslope_CO2forcingslope*log(p.c_CO2concentration[t]/p.c0_baseCO2conc)
    end
end
