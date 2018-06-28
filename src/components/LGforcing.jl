using Mimi

@defcomp LGforcing begin

    c_LGconcentration=Parameter(index=[time],unit="ppbv")
    c0_LGconcbaseyr=Parameter(unit="ppbv", default=0.11)
    f_LGforcing=Variable(index=[time],unit="W/m2")
    f0_LGforcingbase=Parameter(unit="W/m2", default=0.022)
    fslope_LGforcingslope=Parameter(unit="W/m2", default=0.2)

    function run_timestep(p, v, d, t)

        #eq.13 in Hope 2006
        v.f_LGforcing[t]=p.f0_LGforcingbase+p.fslope_LGforcingslope*(p.c_LGconcentration[t]-p.c0_LGconcbaseyr)

    end
end
