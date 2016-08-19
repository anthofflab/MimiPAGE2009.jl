using Mimi

@defcomp LGforcing begin

    c_LGconcentration=Parameter(index=[time],unit="ppbv")
    c0_LGconcbaseyr=Parameter(unit="ppbv")
    f_LGforcing=Variable(index=[time],unit="W/m2")
    f0_LGforcingbase=Parameter(unit="W/m2")
    fslope_LGforcingslope=Parameter(unit="W/m2")

end

function run_timestep(s::LGforcing, t::Int64)
    v = s.Variables
    p = s.Parameters

    #eq.13 in Hope 2006
    v.f_LGforcing[t]=p.f0_LGforcingbase+p.fslope_LGforcingslope*(p.c_LGconcentration[t]-p.c0_LGconcbaseyr)

end

function addLGforcing(model::Model)
    lgforcingcomp = addcomponent(model, ch4forcing)

    lgforcingcomp[:f0_LGforcingbase] = 0.022
    lgforcingcomp[:fslope_LGforcingslope] = 0.2
    lgforcingcomp[:c0_LGconcbaseyr] = 0.11

    ch4forcingcomp
end
