using Mimi

@defcomp ch4forcing begin
    c_N2Oconcentration=Parameter(index=[time],unit="ppbv")
    c_CH4concentration=Parameter(index=[time],unit="ppbv")
    f0_CH4baseforcing=Parameter(unit="W/m2")
    fslope_CH4forcingslope=Parameter(unit="W/m2")
    c0_baseN2Oconc=Parameter(unit="ppbv")
    c0_baseCH4conc=Parameter(unit="ppbv")
    f_CH4forcing=Variable(index=[time],unit="W/m2")
    over_baseoverlap=Variable(unit="W/m2")
    over=Variable(index=[time],unit="W/m2")

    function run_timestep(p, v, d, t)

        #from p.16 in Hope 2009
        if t==1
            #calculate baseline forcing overlap in first time period
            v.over_baseoverlap=-0.47*log(1+2.0e-5*(p.c0_baseN2Oconc*p.c0_baseCH4conc)^0.75+5.3e-15*p.c0_baseCH4conc*(p.c0_baseCH4conc*p.c0_baseN2Oconc)^1.52)
        end

        v.over[t]=-0.47*log(1+2.0e-5*(p.c_CH4concentration[t]*p.c0_baseN2Oconc)^0.75+5.3e-15*p.c_CH4concentration[t]*(p.c0_baseN2Oconc*p.c_CH4concentration[t])^1.52)
        v.f_CH4forcing[t]=p.f0_CH4baseforcing+p.fslope_CH4forcingslope*(sqrt(p.c_CH4concentration[t])-sqrt(p.c0_baseCH4conc))+v.over[t]-v.over_baseoverlap
    end
end

function addCH4forcing(model::Model)
    ch4forcingcomp = addcomponent(model, ch4forcing)

    ch4forcingcomp[:fslope_CH4forcingslope] = 0.036
    ch4forcingcomp[:f0_CH4baseforcing] = 0.550
    ch4forcingcomp[:c0_baseN2Oconc] = 322.
    ch4forcingcomp[:c0_baseCH4conc] = 1860.

    return ch4forcingcomp
end
