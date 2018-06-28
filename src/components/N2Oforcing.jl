using Mimi

@defcomp n2oforcing begin
    c_N2Oconcentration=Parameter(index=[time],unit="ppbv")
    c_CH4concentration=Parameter(index=[time],unit="ppbv")
    f0_N2Obaseforcing=Parameter(unit="W/m2", default=0.180)
    fslope_N2Oforcingslope=Parameter(unit="W/m2", default=0.12)
    c0_baseN2Oconc=Parameter(unit="ppbv", default=322.)
    c0_baseCH4conc=Parameter(unit="ppbv", default=1860.)
    f_N2Oforcing=Variable(index=[time],unit="W/m2")
    over_baseoverlap=Variable(unit="W/m2")
    
    function run_timestep(p, v, d, t)

        #from p.16 in Hope 2009
        if t==1
            #calculate baseline forcing overlap in first time period
            v.over_baseoverlap=-0.47*log(1+2.0e-5*(p.c0_baseN2Oconc*p.c0_baseCH4conc)^0.75+5.3e-15*p.c0_baseCH4conc*(p.c0_baseCH4conc*p.c0_baseN2Oconc)^1.52)
        end

        over=-0.47*log(1+2.0e-5*(p.c0_baseCH4conc*p.c_N2Oconcentration[t])^0.75+5.3e-15*p.c0_baseCH4conc*(p.c0_baseCH4conc*p.c_N2Oconcentration[t])^1.52)
        v.f_N2Oforcing[t]=p.f0_N2Obaseforcing+p.fslope_N2Oforcingslope*(sqrt(p.c_N2Oconcentration[t])-sqrt(p.c0_baseN2Oconc))+over-v.over_baseoverlap
    end
end
