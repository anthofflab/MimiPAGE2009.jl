include("load_parameters.jl")

@defcomp SLRDamages begin
    region = Index(region)

    y_year = Parameter(index=[time], unit="year")

    #incoming parameters from SeaLevelRise
    s_sealevel = Parameter(index=[time, region], unit="m")

    #component parameters
    plateau_increaseintolerableplateaufromadaptation = Parameter(index=[region], unit="m")
    pstart_startdateofadaptpolicy = Parameter(index=[region], unit="year")
    pyears_yearstilfulleffect = Parameter(index=[region], unit="year")
    impred_eventualpercentreduction = Parameter(index=[region], unit= "%")
    impmax_maxsealevelriseforadaptpolicy = Parameter(index=[region], unit= "m")
    istart_startdate = Parameter(index=[region], unit = "year")
    iyears_yearstilfulleffect = Parameter(index=[region], unit= "year")

    #component variables
    atl_adjustedtolerablelevelofsealevelrise = Variable(index=[time,region], unit="m")
    imp_actualreduction = Variable(index=[time, region], unit= "%")
    i_regionalimpact = Variable(index=[time, region], unit="m")

end

function run_timestep(s::SLRDamages, t::Int64)
    v = s.Variables
    p = s.Parameters
    d = s.Dimensions

    for r in d.region
        if (Y[t] - p.pstart_startdateofadaptpolicy[r]) < 0
            v.atl_adjustedtolerablelevelofsealevelrise[t,r]= 0
        elseif ((Y[t]-p.pstart_startdateofadaptpolicy[r])/p.pyears_yearstilfulleffect[r])<1.
            v.atl_adjustedtolerablelevelofsealevelrise[t,r]=
                ((Y[t]-p.pstart_startdateofadaptpolicy[r])/p.pyears_yearstilfulleffect[r]) * p.plateau_increaseintolerableplateaufromadaptation[r]
        else
            p.plateau_increaseintolerableplateaufromadaptation[r]
        end

        if (Y[t]- p.istart_startdate[r]) < 0
            v.imp_actualreduction[t,r] = 0
        elseif ((Y[t]-istart_a[r])/iyears_a[r]) < 1
            v.imp_actualreduction[t,r] =
                (Y[t]-p.istart_startdate[r])/p.iyears_yearstilfulleffect[r]*p.impred_eventualpercentreduction[r]
        else
            v.imp_actualreduction[t,r] = p.impred_eventualpercentreduction[r]
        end

        if (p.s_sealevel[t,r]-v.atl_adjustedtolerablelevelofsealevelrise[t,r]) < 0
            v.i_regionalimpact[t,r] = 0
        else
            v.i_regionalimpact[t,r] = p.s_sealevel[t,r]-v.atl_adjustedtolerablelevelofsealevelrise[t,r]
        end
    end

end

function addslrdamages(model::Model)
    SLRDamagescomp = addcomponent(model, SLRDamages, :SLRDamages)

    SLRDamagescomp[:plateau_increaseintolerableplateaufromadaptation] = readpagedata(model, "../data/sealevel_plateau.csv")
    SLRDamagescomp[:pstart_startdateofadaptpolicy] = readpagedata(model, "../data/sealeveladaptstart.csv")
    SLRDamagescomp[:pyears_yearstilfulleffect] = readpagedata(model, "../data/sealeveladapttimetoeffect.csv")
    SLRDamagescomp[:impred_eventualpercentreduction] = readpagedata(model, "../data/sealevelimpactreduction.csv")
    SLRDamagescomp[:impmax_maxsealevelriseforadaptpolicy] = readpagedata(model, "../data/sealevelmaxrise.csv")
    SLRDamagescomp[:istart_startdate] = readpagedata(model, "../data/sealeveladaptstart.csv")
    SLRDamagescomp[:iyears_yearstilfulleffect] = readpagedata(model, "../data/sealevelimpactyearstoeffect.csv")

    return SLRDamagescomp
end
