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

    cp_costplateau_eu = Parameter(unit="%GDP/driver")
    ci_costimpact_eu = Parameter(unit="%GDP/%driver")

    atl_adjustedtolerablelevel = Parameter(index=[time, region], unit="%")
    imp_adaptedimpacts = Parameter(index=[time, region], unit="%")

    ac_adaptivecosts = Variable(index=[time, region], unit="\$M")
end

function run_timestep(s::AdaptationCosts, tt::Int64)
    v = s.Variables
    p = s.Parameters
    d = s.Dimensions

    # Hope (2009), p. 21, equation -5
    auto_autonomouschangepercent = (1 - p.automult_autonomouschange^(1/(p.y_year[length(m.indices_values[:time])] - p.y_year_0)))*100 # % per year
    autofac_autonomouschangefraction = (1 - auto_autonomouschangepercent/100)^(p.y_year[tt] - p.y_year_0) # Varies by year

    for rr in d.region
        # Hope (2009), p. 25, equations 1-2
        cp_costplateau_regional = p.cp_costplateau_eu * p.cf_costregional[rr]
        ci_costimpact_regional = p.ci_costimpact_eu * p.cf_costregional[rr]

        # Hope (2009), p. 25, equations 3-4
        acp_adaptivecostplateau = p.atl_adjustedtolerablelevel[tt, rr] * cp_costplateau_regional * p.gdp[tt, rr] * autofac_autonomouschangefraction / 100
        aci_adaptivecostimpact = p.imp_adaptedimpacts[tt, rr] * ci_costimpact_regional * p.gdp[tt, rr] * p.impmax_maximumadaptivecapacity[rr] * autofac_autonomouschangefraction / 100

        # Hope (2009), p. 25, equation 5
        v.ac_adaptivecosts[tt, rr] = acp_adaptivecostplateau + aci_adaptivecostimpact
    end
end

function addadaptationcosts(model::Model, class::Symbol)
    adaptationcosts = addcomponent(model, AdaptationCosts, symbol("AdaptiveCosts$class"))
    adaptationcosts[:automult_autonomouschange] = 0.22

    if class == :SeaLevel
        adaptationcosts[:impmax_maximumadaptivecapacity] = readpagedata(model, "../data/impmax_sealevel.csv")
        adaptationcosts[:cp_costplateau_eu] = 0.0233
        adaptationcosts[:ci_costimpact_eu] = 0.0012
    elseif class == :Economic
        adaptationcosts[:impmax_maximumadaptivecapacity] = readpagedata(model, "../data/impmax_economic.csv")
        adaptationcosts[:cp_costplateau_eu] = 0.0117
        adaptationcosts[:ci_costimpact_eu] = 0.0040
    elseif class == :NonEconomic
        adaptationcosts[:impmax_maximumadaptivecapacity] = readpagedata(model, "../data/impmax_noneconomic.csv")
        adaptationcosts[:cp_costplateau_eu] = 0.0233
        adaptationcosts[:ci_costimpact_eu] = 0.0057
    else
        error("Unknown class of adaptation costs.")
    end

    return adaptationcosts
end
