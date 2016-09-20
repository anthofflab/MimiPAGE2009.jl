using Mimi

@defcomp AdaptationCosts begin
    region = Index()

    ylo = Parameter(index=[time], unit="year")
    yhi = Parameter(index=[time], unit="year")
    y_year = Parameter(index=[time], unit="year")
    dr_discountrate = Paramter(index=[time, region], unit="%")

    cs_costslope0 = Parameter(unit="$M/degree C/decade")
    cp_costplateau0 = Parameter(unit="$M/degree C")
    ci_costimpact0 = Parameter(unit="$M/%")
    cf_costregional = Parameter(index=[region], unit="none") # first value should be 1.

    slope_adaptedslope = Parameter(index=[time, region], unit="degree C/year")
    plat_adaptedplateau = Parameter(index=[time, region], unit="degree C")
    imp_adaptedimpacts = Parameter(index=[time, region], unit="%")

    ac_adaptivecosts = Variable(index=[time, region], unit="$M")
    aac_aggadaptativecosts = Variable(index=[time, region], unit="$M")

    dac_discountedadaptivecosts = Variable(unit="$M")
end

function run_timestep(s::AdaptationCosts, tt::Int64)
    v = s.Variables
    p = s.Parameters
    d = s.Dimensions

    v.dac_discountedadaptivecosts = 0
    for rr in d.region
        ## XXX: cs_costslope0 is /decade, but slope_adaptedslope is /year!  Scale it?
        cs_costslope_regional = p.cs_costslope0 * p.cf_costregional[rr]
        cs_costplateau_regional = p.cs_costplateau0 * p.cf_costregional[rr]
        cs_costimpact_regional = p.cs_costimpact0 * p.cf_costregional[rr]

        v.ac_adaptivecosts[tt, rr] = cs_costslope_regional * p.slope_adaptedslope[tt, rr] + cp_costplateau_regional * p.plat_adaptedplateau[tt, rr] + ci_costimpact_regional * p.imp_adaptedimpacts[tt, rr]

        v.aac_aggadaptativecosts[tt, rr] = v.ac_adaptivecosts[tt, rr] * (p.yhi[tt] - p.ylo[tt])

        v.dac_discountedadaptivecosts += v.aac_aggadaptativecosts[tt, rr] * (1 + p.dr_discountrate[tt, rr] / 100)^(-(p.y_year[tt] - p.y_year[tt-1]))
    end
end

