@defcomp EquityWeighting begin
    region = Index()

    # Basic information
    y_year = Parameter(index=[time], unit="year")
    y_year_0 = Parameter(unit="year")

    # Impacts across all gases
    pop_population = Parameter(index=[time, region], unit="million person")

    #Total and Per-Capita Abatement and Adaptation Costs
    tct_percap_totalcosts_total = Parameter(index=[time, region], unit="\$/person")
    act_adaptationcosts_total = Parameter(index=[time, region], unit="\$million")
    act_percap_adaptationcosts = Parameter(index=[time, region], unit="\$/person")

    # Consumption
    cons_percap_consumption = Parameter(index=[time, region], unit="\$/person") # Called "CONS_PER_CAP"
    cons_percap_consumption_0 = Parameter(index=[region], unit="\$/person")
    cons_percap_aftercosts = Parameter(index=[time, region], unit="\$/person")

    # Calculation of weighted costs
    emuc_utilityconvexity = Parameter(unit="none", default=1.1666666667)

    wtct_percap_weightedcosts = Variable(index=[time, region], unit="\$/person")
    eact_percap_weightedadaptationcosts = Variable(index=[time, region], unit="\$/person")
    wact_percap_partiallyweighted = Variable(index=[time, region], unit="\$/person")
    wact_partiallyweighted = Variable(index=[time, region], unit="\$million")

    # Amount of equity weighting variable (0, (0, 1), or 1)
    equity_proportion = Parameter(unit="fraction", default=1.0)

    pct_percap_partiallyweighted = Variable(index=[time, region], unit="\$/person")
    pct_partiallyweighted = Variable(index=[time, region], unit="\$million")
    pct_g_partiallyweighted_global = Variable(index=[time], unit="\$million")

    # Discount rates
    ptp_timepreference = Parameter(unit="%/year", default=1.0333333333) # <0.1,1, 2>
    grw_gdpgrowthrate = Parameter(index=[time, region], unit="%/year")
    popgrw_populationgrowth = Parameter(index=[time, region], unit="%/year")

    dr_discountrate = Variable(index=[time, region], unit="%/year")
    yp_yearsperiod = Variable(index=[time], unit="year") # defined differently from yagg
    dfc_consumptiondiscountrate = Variable(index=[time, region], unit="1/year")

    df_utilitydiscountfactor = Variable(index=[time], unit="fraction")

    # Discounted costs
    pcdt_partiallyweighted_discounted = Variable(index=[time, region], unit="\$million")
    pcdt_g_partiallyweighted_discountedglobal = Variable(index=[time], unit="\$million")

    pcdat_partiallyweighted_discountedaggregated = Variable(index=[time, region], unit="\$million")
    tpc_totalaggregatedcosts = Variable(unit="\$million")

    wacdt_partiallyweighted_discounted = Variable(index=[time, region], unit="\$million")

    # Equity weighted impact totals
    rcons_percap_dis = Parameter(index=[time, region], unit="\$/person")

    wit_partiallyweighted = Variable(index=[time, region], unit="\$million")
    widt_partiallyweighted_discounted = Variable(index=[time, region], unit="\$million")

    yagg_periodspan = Parameter(index=[time], unit="year")

    addt_equityweightedimpact_discountedaggregated = Variable(index=[time, region], unit="\$million")
    addt_gt_equityweightedimpact_discountedglobal = Variable(unit="\$million")

    civvalue_civilizationvalue = Parameter(unit="\$million", default=5.3e10) # Called "CIV_VALUE"
    td_totaldiscountedimpacts = Variable(unit="\$million")

    aact_equityweightedadaptation_discountedaggregated = Variable(index=[time, region], unit="\$million")
    tac_totaladaptationcosts = Variable(unit="\$million")

    # Final result: total effect of climate change
    te_totaleffect = Variable(unit="\$million")

    function run_timestep(p, v, d, tt)
        if is_first(tt)
            v.tpc_totalaggregatedcosts = 0
            v.addt_gt_equityweightedimpact_discountedglobal = 0
            v.tac_totaladaptationcosts = 0
            v.te_totaleffect = 0
        end

        v.df_utilitydiscountfactor[tt] = (1 + p.ptp_timepreference / 100)^(-(p.y_year[tt] - p.y_year_0))

        for rr in d.region

            ## Gas Costs Accounting
            # Weighted costs (Page 23 of Hope 2009)
            v.wtct_percap_weightedcosts[tt, rr] = ((p.cons_percap_consumption_0[1]^p.emuc_utilityconvexity) / (1 - p.emuc_utilityconvexity)) * (p.cons_percap_consumption[tt, rr]^(1 - p.emuc_utilityconvexity) - (p.cons_percap_consumption[tt, rr] - p.tct_percap_totalcosts_total[tt, rr])^(1 - p.emuc_utilityconvexity))

            # Add these into consumption
            v.eact_percap_weightedadaptationcosts[tt, rr] = ((p.cons_percap_consumption_0[1]^p.emuc_utilityconvexity) / (1 - p.emuc_utilityconvexity)) * (p.cons_percap_consumption[tt, rr]^(1 - p.emuc_utilityconvexity) - (p.cons_percap_consumption[tt, rr] - p.act_percap_adaptationcosts[tt, rr])^(1 - p.emuc_utilityconvexity))

            # Do partial weighting
            if p.equity_proportion == 0
                v.pct_percap_partiallyweighted[tt, rr] = p.tct_percap_totalcosts_total[tt, rr]
                v.wact_percap_partiallyweighted[tt, rr] = p.act_percap_adaptationcosts[tt, rr]
            else
                v.pct_percap_partiallyweighted[tt, rr] = (1 - p.equity_proportion) * p.tct_percap_totalcosts_total[tt, rr] + p.equity_proportion * v.wtct_percap_weightedcosts[tt, rr]
                v.wact_percap_partiallyweighted[tt, rr] = (1 - p.equity_proportion) * p.act_percap_adaptationcosts[tt, rr] + p.equity_proportion * v.eact_percap_weightedadaptationcosts[tt, rr]
            end

            v.pct_partiallyweighted[tt, rr] = v.pct_percap_partiallyweighted[tt, rr] * p.pop_population[tt, rr]
            v.wact_partiallyweighted[tt, rr] = v.wact_percap_partiallyweighted[tt, rr] * p.pop_population[tt, rr]

            # Discount rate calculations
            v.dr_discountrate[tt, rr] = p.ptp_timepreference + p.emuc_utilityconvexity * (p.grw_gdpgrowthrate[tt, rr] - p.popgrw_populationgrowth[tt, rr])
            if is_first(tt)
                v.yp_yearsperiod[TimestepIndex(1)] = p.y_year[TimestepIndex(1)] - p.y_year_0
            else
                v.yp_yearsperiod[tt] = p.y_year[tt] - p.y_year[tt-1]
            end

            if is_first(tt)
                v.dfc_consumptiondiscountrate[TimestepIndex(1), rr] = (1 + v.dr_discountrate[TimestepIndex(1), rr] / 100)^(-v.yp_yearsperiod[TimestepIndex(1)])
            else
                v.dfc_consumptiondiscountrate[tt, rr] = v.dfc_consumptiondiscountrate[tt-1, rr] * (1 + v.dr_discountrate[tt, rr] / 100)^(-v.yp_yearsperiod[tt])
            end

            # Discounted costs
            if p.equity_proportion == 0
                v.pcdt_partiallyweighted_discounted[tt, rr] = v.pct_partiallyweighted[tt, rr] * v.dfc_consumptiondiscountrate[tt, rr]
                v.wacdt_partiallyweighted_discounted[tt, rr] = p.act_adaptationcosts_total[tt, rr] * v.dfc_consumptiondiscountrate[tt, rr]

                v.wit_partiallyweighted[tt, rr] = (p.cons_percap_aftercosts[tt, rr] - p.rcons_percap_dis[tt, rr]) * p.pop_population[tt, rr] # equivalent to emuc = 0
                v.widt_partiallyweighted_discounted[tt, rr] = v.wit_partiallyweighted[tt, rr] * v.dfc_consumptiondiscountrate[tt] # apply Ramsey discounting
            else
                v.pcdt_partiallyweighted_discounted[tt, rr] = v.pct_partiallyweighted[tt, rr] * v.df_utilitydiscountfactor[tt]
                v.wacdt_partiallyweighted_discounted[tt, rr] = v.wact_partiallyweighted[tt, rr] * v.df_utilitydiscountfactor[tt]

                ## Equity weighted impacts (end of page 28, Hope 2009)
                v.wit_partiallyweighted[tt, rr] = ((p.cons_percap_consumption_0[1]^p.emuc_utilityconvexity) / (1 - p.emuc_utilityconvexity)) * (p.cons_percap_aftercosts[tt, rr]^(1 - p.emuc_utilityconvexity) - p.rcons_percap_dis[tt, rr]^(1 - p.emuc_utilityconvexity)) * p.pop_population[tt, rr]
                v.widt_partiallyweighted_discounted[tt, rr] = v.wit_partiallyweighted[tt, rr] * v.df_utilitydiscountfactor[tt]
            end

            v.pcdat_partiallyweighted_discountedaggregated[tt, rr] = v.pcdt_partiallyweighted_discounted[tt, rr] * p.yagg_periodspan[tt]
            v.addt_equityweightedimpact_discountedaggregated[tt, rr] = v.widt_partiallyweighted_discounted[tt, rr] * p.yagg_periodspan[tt]
            v.aact_equityweightedadaptation_discountedaggregated[tt, rr] = v.wacdt_partiallyweighted_discounted[tt, rr] * p.yagg_periodspan[tt]
        end

        v.pct_g_partiallyweighted_global[tt] = sum(v.pct_partiallyweighted[tt, :])
        v.pcdt_g_partiallyweighted_discountedglobal[tt] = sum(v.pcdt_partiallyweighted_discounted[tt, :])
        v.tpc_totalaggregatedcosts = v.tpc_totalaggregatedcosts + sum(v.pcdat_partiallyweighted_discountedaggregated[tt, :])

        v.addt_gt_equityweightedimpact_discountedglobal = v.addt_gt_equityweightedimpact_discountedglobal + sum(v.addt_equityweightedimpact_discountedaggregated[tt, :])

        v.tac_totaladaptationcosts = v.tac_totaladaptationcosts + sum(v.aact_equityweightedadaptation_discountedaggregated[tt, :])

        v.td_totaldiscountedimpacts = min(v.addt_gt_equityweightedimpact_discountedglobal, p.civvalue_civilizationvalue)

        # Total effect of climate change
        v.te_totaleffect = min(v.td_totaldiscountedimpacts + v.tpc_totalaggregatedcosts + v.tac_totaladaptationcosts, p.civvalue_civilizationvalue)
    end
end
