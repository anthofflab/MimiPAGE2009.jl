using Mimi

@defcomp co2forcing begin
    c_CO2concentration=Parameter(index=[time],unit="ppbv")
    f0_CO2baseforcing=Parameter(unit="W/m2")
    fslope_CO2forcingslope=Parameter(unit="W/m2")
    c0_baseCO2conc=Parameter(unit="ppbv")
    f_CO2forcing=Variable(index=[time],unit="W/m2")
end

function run_timestep(s::co2forcing, t::Int64)
    v = s.Variables
    p = s.Parameters

    #eq.13 in Hope 2006
    v.f_CO2forcing[t]=p.f0_CO2baseforcing+p.fslope_CO2forcingslope*log(p.c_CO2concentration[t]/p.c0_baseCO2conc)
end

function addCO2forcing(model::Model)
    co2forcingcomp = addcomponent(model, co2forcing)

    co2forcingcomp[:fslope_CO2forcingslope] = 5.5
    co2forcingcomp[:f0_CO2baseforcing] = 1.735
    co2forcingcomp[:c0_baseCO2conc] = 395000.

    co2forcingcomp
end
