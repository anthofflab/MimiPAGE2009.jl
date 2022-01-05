

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

    # Mostly for debugging
    autofac_autonomouschangefraction = Variable(index=[time], unit="none")
    acp_adaptivecostplateau = Variable(index=[time, region], unit="\$million")
    aci_adaptivecostimpact = Variable(index=[time, region], unit="\$million")

    ac_adaptivecosts = Variable(index=[time, region], unit="\$million")

    function run_timestep(p, v, d, tt)

        # Hope (2009), p. 21, equation -5
        auto_autonomouschangepercent = (1 - p.automult_autonomouschange^(1/(p.y_year[end] - p.y_year_0)))*100 # % per year
        v.autofac_autonomouschangefraction[tt] = (1 - auto_autonomouschangepercent/100)^(p.y_year[tt] - p.y_year_0) # Varies by year

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
            v.acp_adaptivecostplateau[tt, rr] = v.atl_adjustedtolerablelevel[tt, rr] * cp_costplateau_regional * p.gdp[tt, rr] * v.autofac_autonomouschangefraction[tt] / 100
            v.aci_adaptivecostimpact[tt, rr] = v.imp_adaptedimpacts[tt, rr] * ci_costimpact_regional * p.gdp[tt, rr] * p.impmax_maximumadaptivecapacity[rr] * v.autofac_autonomouschangefraction[tt] / 100

            # Hope (2009), p. 25, equation 5
            v.ac_adaptivecosts[tt, rr] = v.acp_adaptivecostplateau[tt, rr] + v.aci_adaptivecostimpact[tt, rr]
        end
    end
end

function update_params_adaptationcosts_sealevel!(model::Model)

    # Sea Level-specific parameters
    update_param!(model, :AdaptiveCostsSeaLevel, :plateau_increaseintolerableplateaufromadaptation, readpagedata(model, "data/other_adaptation_parameters/sealevel_plateau.csv"))
    update_param!(model, :AdaptiveCostsSeaLevel, :pstart_startdateofadaptpolicy, readpagedata(model, "data/other_adaptation_parameters/sealeveladaptstart.csv"))
    update_param!(model, :AdaptiveCostsSeaLevel, :pyears_yearstilfulleffect, readpagedata(model, "data/other_adaptation_parameters/sealeveladapttimetoeffect.csv"))
    update_param!(model, :AdaptiveCostsSeaLevel, :impred_eventualpercentreduction, readpagedata(model, "data/other_adaptation_parameters/sealevelimpactreduction.csv"))
    update_param!(model, :AdaptiveCostsSeaLevel, :istart_startdate, readpagedata(model, "data/other_adaptation_parameters/sealevelimpactstart.csv"))
    update_param!(model, :AdaptiveCostsSeaLevel, :iyears_yearstilfulleffect, readpagedata(model, "data/other_adaptation_parameters/sealevelimpactyearstoeffect.csv"))
    update_param!(model, :AdaptiveCostsSeaLevel, :cp_costplateau_eu, 0.0233333333333333)
    update_param!(model, :AdaptiveCostsSeaLevel, :ci_costimpact_eu, 0.00116666666666667)

end

function update_params_adaptationcosts_economic!(model::Model)

    # Economic-specific parameters
    update_param!(model, :AdaptiveCostsEconomic, :plateau_increaseintolerableplateaufromadaptation, readpagedata(model, "data/other_adaptation_parameters/plateau_increaseintolerableplateaufromadaptationM.csv"))
    update_param!(model, :AdaptiveCostsEconomic, :pstart_startdateofadaptpolicy, readpagedata(model, "data/other_adaptation_parameters/pstart_startdateofadaptpolicyM.csv"))
    update_param!(model, :AdaptiveCostsEconomic, :pyears_yearstilfulleffect, readpagedata(model, "data/other_adaptation_parameters/pyears_yearstilfulleffectM.csv"))
    update_param!(model, :AdaptiveCostsEconomic, :impred_eventualpercentreduction, readpagedata(model, "data/other_adaptation_parameters/impred_eventualpercentreductionM.csv"))
    update_param!(model, :AdaptiveCostsEconomic, :istart_startdate, readpagedata(model, "data/other_adaptation_parameters/istart_startdateM.csv"))
    update_param!(model, :AdaptiveCostsEconomic, :iyears_yearstilfulleffect, readpagedata(model, "data/other_adaptation_parameters/iyears_yearstilfulleffectM.csv"))
    update_param!(model, :AdaptiveCostsEconomic, :cp_costplateau_eu, 0.0116666666666667)
    update_param!(model, :AdaptiveCostsEconomic, :ci_costimpact_eu, 0.0040000000)

end

function update_params_adaptationcosts_noneconomic!(model::Model)

    # Non-economic-specific parameters
    update_param!(model, :AdaptiveCostsNonEconomic, :plateau_increaseintolerableplateaufromadaptation, readpagedata(model, "data/other_adaptation_parameters/plateau_increaseintolerableplateaufromadaptationNM.csv"))
    update_param!(model, :AdaptiveCostsNonEconomic, :pstart_startdateofadaptpolicy, readpagedata(model, "data/other_adaptation_parameters/pstart_startdateofadaptpolicyNM.csv"))
    update_param!(model, :AdaptiveCostsNonEconomic, :pyears_yearstilfulleffect, readpagedata(model, "data/other_adaptation_parameters/pyears_yearstilfulleffectNM.csv"))
    update_param!(model, :AdaptiveCostsNonEconomic, :impred_eventualpercentreduction, readpagedata(model, "data/other_adaptation_parameters/impred_eventualpercentreductionNM.csv"))
    update_param!(model, :AdaptiveCostsNonEconomic, :istart_startdate, readpagedata(model, "data/other_adaptation_parameters/istart_startdateNM.csv"))
    update_param!(model, :AdaptiveCostsNonEconomic, :iyears_yearstilfulleffect, readpagedata(model, "data/other_adaptation_parameters/iyears_yearstilfulleffectNM.csv"))
    update_param!(model, :AdaptiveCostsNonEconomic, :cp_costplateau_eu, 0.0233333333333333)
    update_param!(model, :AdaptiveCostsNonEconomic, :ci_costimpact_eu, 0.00566666666666667)

end
