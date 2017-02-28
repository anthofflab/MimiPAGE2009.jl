using Mimi
include("load_parameters.jl")

@defcomp AdaptationCosts begin
    region = Index()

    y_year_0 = Parameter(unit="year")
    y_year = Parameter(index=[time], unit="year")
    gdp = Parameter(index=[time, region], unit="\$M")
    cf_costregional = Parameter(index=[region], unit="none") # first value should be 1.

    automult_autonomouschange = Parameter(unit="none")
    impmax_maximumadaptivecapacity = Parameter(index=[region], unit="driver")
    #tolerability parameters
    plateau_increaseintolerableplateaufromadaptation = Parameter(index=[region], unit="driver")
    pstart_startdateofadaptpolicy = Parameter(index=[region], unit="year")
    pyears_yearstilfulleffect = Parameter(index=[region], unit="year")
    impred_eventualpercentreduction = Parameter(index=[region], unit= "%")
    istart_startdate = Parameter(index=[region], unit = "year")
    iyears_yearstilfulleffect = Parameter(index=[region], unit= "year")

    cp_costplateau_eu = Parameter(unit="%GDP/driver")
    ci_costimpact_eu = Parameter(unit="%GDP/%driver")

    atl_adjustedtolerablelevel = Variable(index=[time, region]) # Unit depends on instance (degreeC or m)
    imp_adaptedimpacts = Variable(index=[time, region], unit="%")

    ac_adaptivecosts = Variable(index=[time, region], unit="\$million")
end

function run_timestep(s::AdaptationCosts, tt::Int64)
    v = s.Variables
    p = s.Parameters
    d = s.Dimensions

    # Hope (2009), p. 21, equation -5
    auto_autonomouschangepercent = (1 - p.automult_autonomouschange^(1/(p.y_year[end] - p.y_year_0)))*100 # % per year
    autofac_autonomouschangefraction = (1 - auto_autonomouschangepercent/100)^(p.y_year[tt] - p.y_year_0) # Varies by year

    for rr in d.region
        #calculate adjusted tolerable level and max impact based on adaptation policy
        if (p.y_year[tt] - p.pstart_startdateofadaptpolicy[rr]) < 0
            v.atl_adjustedtolerablelevel[tt,rr]= 0
        elseif ((p.y_year[tt]-p.pstart_startdateofadaptpolicy[rr])/p.pyears_yearstilfulleffect[rr])<1.
            v.atl_adjustedtolerablelevel[tt,rr]=
                ((p.y_year[tt]-p.pstart_startdateofadaptpolicy[rr])/p.pyears_yearstilfulleffect[rr]) *
                p.plateau_increaseintolerableplateaufromadaptation[rr]
        else
            v.atl_adjustedtolerablelevel[tt,rr] = p.plateau_increaseintolerableplateaufromadaptation[rr]
        end

        if (p.y_year[tt]- p.istart_startdate[rr]) < 0
            v.imp_adaptedimpacts[tt,rr] = 0
        elseif ((p.y_year[tt]-p.istart_startdate[rr])/p.iyears_yearstilfulleffect[rr]) < 1
            v.imp_adaptedimpacts[tt,rr] =
                (p.y_year[tt]-p.istart_startdate[rr])/p.iyears_yearstilfulleffect[rr]*
                p.impred_eventualpercentreduction[rr]
        else
            v.imp_adaptedimpacts[tt,rr] = p.impred_eventualpercentreduction[rr]
        end

        # Hope (2009), p. 25, equations 1-2
        cp_costplateau_regional = p.cp_costplateau_eu * p.cf_costregional[rr]
        ci_costimpact_regional = p.ci_costimpact_eu * p.cf_costregional[rr]

        # Hope (2009), p. 25, equations 3-4
        acp_adaptivecostplateau = v.atl_adjustedtolerablelevel[tt, rr] * cp_costplateau_regional * p.gdp[tt, rr] * autofac_autonomouschangefraction / 100
        aci_adaptivecostimpact = v.imp_adaptedimpacts[tt, rr] * ci_costimpact_regional * p.gdp[tt, rr] * p.impmax_maximumadaptivecapacity[rr] * autofac_autonomouschangefraction / 100

        # Hope (2009), p. 25, equation 5
        v.ac_adaptivecosts[tt, rr] = acp_adaptivecostplateau + aci_adaptivecostimpact
    end
end

function addadaptationcosts_sealevel(model::Model)
    adaptationcosts = addcomponent(model, AdaptationCosts, symbol("AdaptiveCostsSeaLevel"))
    adaptationcosts[:automult_autonomouschange] = 0.22

    # Sea Level-specific parameters
    adaptationcosts[:impmax_maximumadaptivecapacity] = readpagedata(model, joinpath(dirname(@__FILE__), "..", "data", "impmax_sealevel.csv"))
    adaptationcosts[:plateau_increaseintolerableplateaufromadaptation] = readpagedata(model, joinpath(dirname(@__FILE__), "..", "data", "sealevel_plateau.csv"))
    adaptationcosts[:pstart_startdateofadaptpolicy] =readpagedata(model, joinpath(dirname(@__FILE__), "..", "data", "sealeveladaptstart.csv"))
    adaptationcosts[:pyears_yearstilfulleffect] = readpagedata(model, joinpath(dirname(@__FILE__), "..", "data", "sealeveladapttimetoeffect.csv"))
    adaptationcosts[:impred_eventualpercentreduction] = readpagedata(model, joinpath(dirname(@__FILE__), "..", "data", "sealevelimpactreduction.csv"))
    adaptationcosts[:istart_startdate] = readpagedata(model, joinpath(dirname(@__FILE__), "..", "data", "sealevelimpactstart.csv"))
    adaptationcosts[:iyears_yearstilfulleffect] = readpagedata(model, joinpath(dirname(@__FILE__), "..", "data", "sealevelimpactyearstoeffect.csv"))
    adaptationcosts[:cp_costplateau_eu] = 0.0233
    adaptationcosts[:ci_costimpact_eu] = 0.0012


    return adaptationcosts
end

function addadaptationcosts_economic(model::Model)
    adaptationcosts = addcomponent(model, AdaptationCosts, symbol("AdaptiveCostsEconomic"))
    adaptationcosts[:automult_autonomouschange] = 0.22

    # Economic-specific parameters
    adaptationcosts[:impmax_maximumadaptivecapacity] = readpagedata(model, joinpath(dirname(@__FILE__), "..", "data", "impmax_economic.csv"))
    adaptationcosts[:plateau_increaseintolerableplateaufromadaptation] = readpagedata(model, joinpath(dirname(@__FILE__), "..", "data", "plateau_increaseintolerableplateaufromadaptationM.csv"))
    adaptationcosts[:pstart_startdateofadaptpolicy] =readpagedata(model, joinpath(dirname(@__FILE__), "..", "data", "pstart_startdateofadaptpolicyM.csv"))
    adaptationcosts[:pyears_yearstilfulleffect] = readpagedata(model, joinpath(dirname(@__FILE__), "..", "data", "pyears_yearstilfulleffectM.csv"))
    adaptationcosts[:impred_eventualpercentreduction] = readpagedata(model, joinpath(dirname(@__FILE__), "..", "data", "impred_eventualpercentreductionM.csv"))
    adaptationcosts[:istart_startdate] = readpagedata(model, joinpath(dirname(@__FILE__), "..", "data", "istart_startdateM.csv"))
    adaptationcosts[:iyears_yearstilfulleffect] = readpagedata(model, joinpath(dirname(@__FILE__), "..", "data", "iyears_yearstilfulleffectM.csv"))
    adaptationcosts[:cp_costplateau_eu] = 0.0117
    adaptationcosts[:ci_costimpact_eu] = 0.0040

    return adaptationcosts
end

function addadaptationcosts_noneconomic(model::Model)
    adaptationcosts = addcomponent(model, AdaptationCosts, symbol("AdaptiveCostsNonEconomic"))
    adaptationcosts[:automult_autonomouschange] = 0.22

    # Non-economic-specific parameters
    adaptationcosts[:impmax_maximumadaptivecapacity] = readpagedata(model, joinpath(dirname(@__FILE__), "..", "data", "impmax_noneconomic.csv"))
    adaptationcosts[:plateau_increaseintolerableplateaufromadaptation] = readpagedata(model, joinpath(dirname(@__FILE__), "..", "data", "plateau_increaseintolerableplateaufromadaptationNM.csv"))
    adaptationcosts[:pstart_startdateofadaptpolicy] =readpagedata(model, joinpath(dirname(@__FILE__), "..", "data", "pstart_startdateofadaptpolicyNM.csv"))
    adaptationcosts[:pyears_yearstilfulleffect] = readpagedata(model, joinpath(dirname(@__FILE__), "..", "data", "pyears_yearstilfulleffectNM.csv"))
    adaptationcosts[:impred_eventualpercentreduction] = readpagedata(model, joinpath(dirname(@__FILE__), "..", "data", "impred_eventualpercentreductionNM.csv"))
    adaptationcosts[:istart_startdate] = readpagedata(model, joinpath(dirname(@__FILE__), "..", "data", "istart_startdateNM.csv"))
    adaptationcosts[:iyears_yearstilfulleffect] = readpagedata(model, joinpath(dirname(@__FILE__), "..", "data", "iyears_yearstilfulleffectNM.csv"))
    adaptationcosts[:cp_costplateau_eu] = 0.0233
    adaptationcosts[:ci_costimpact_eu] = 0.0057

    return adaptationcosts
end
