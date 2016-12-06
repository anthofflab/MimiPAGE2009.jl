using Mimi
include("load_parameters.jl")

@defcomp EquityWeighting begin
    region = Index()

    # Impacts across all gases
    tc_totalcosts_co2 = Parameter(index=[time, region], unit="\$million")
    tc_totalcosts_ch4 = Parameter(index=[time, region], unit="\$million")
    tc_totalcosts_n2o = Parameter(index=[time, region], unit="\$million")
    tc_totalcosts_linear = Parameter(index=[time, region], unit="\$million")
    pop_ulation = Parameter(index=[time, region], unit="million person")

    tct_totalcosts_total = Variable(index=[time, region], unit="\$million")
    tct_percap_totalcosts_total = Variable(index=[time, region], unit="\$/person")

    # Consumption calculations
    gdp = Parameter(index=[time, region], unit="\$million")
    save_savingsrate = Parmater(unit="%")
    cons_consumption = Variable(index=[time, region], unit="\$million")

    cons_per_cap_consumption_0 = Parameter(unit="\$") # Called "CONS_PER_CAP_FOCUS_0"
    cons_per_cap_consumption = Parameter(unit="\$") # Called "CONS_PER_CAP"

    cons_per_cap_aftercosts = Parameter(index=[time, region], unit="none")

    # Calculation of weighted costs
    emuc_utilityconvexity = Parameter(unit="none")

    wtct_per_cap_weightedcosts = Variable(index=[time, region], unit="\$")

    # Calculation of adaptation costs
    ac_adaptationcosts_economic = Parameter(index=[time, region], unit="\$million")
    ac_adaptationcosts_noneconomic = Parameter(index=[time, region], unit="\$million")
    ac_adaptationcosts_sealevelrise = Parameter(index=[time, region], unit="\$million")

    act_adaptationcosts_total = Variable(index=[time, region], unit="\$million")
    act_per_cap_adaptationcosts = Variable(index=[time, region], unit="\$")

    eact_per_cap_weightedadaptationcosts = Variable(index=[time, region], unit="\$")
    wact_per_cap_partiallyweighted = Variable(index=[time, region], unit="\$")
    wact_partiallyweighted = Variable(index=[time, region], unit="\$million")

    # Amount of equity weighting variable (0, (0, 1), or 1)
    equity_proportion = Parameter(unit="fraction")

    pct_percap_partiallyweighted = Variable(index=[time, region], unit="\$/person")
    pct_partiallyweighted = Variable(index=[time, region], unit="\$million")
    pct_g_partiallyweighted_global = Variable(index=[time], unit="\$million")

    # Discount rates
    ptp_timepreference = Parameter(unit="%/year")
    grw_gdpgrowth = Parameter(index=[time, region], unit="%/year")
    pop_grw_populationgrowth = Parameter(index=[time, region], unit="%/year")

    dr_discountrate = Variable(index=[time, region], unit="%/year")
    yp_yearsperiod = Variable(index=[time], unit="year") # defined differently from yagg
    dfc_consumptiondiscountrate = Variable(index=[time, region], unit="1/year")

    df_utilitydiscountrate = Variable(index=[time], unit="fraction")

    # Discounted costs
    pcdt_partiallyweighted_discounted = Variable(index=[time, region], unit="\$million")
    pcdt_g_partiallyweighted_discountedglobal = Variable(index=[time], unit="\$million")

    pcdat_partiallyweighted_discountedaggregated = Variable(index=[time, region], unit="\$million")
    tpc_totalaggregatedcosts = Variable(unit="\$million")

    wacdt_partiallyweighted_discounted = Variable(index=[time, region], unit="\$million")

    # Equity weighted impact totals
    rcons_per_cap_dis = Variable(index=[time, region], unit="\$")

    wit_equityweightedimpact = Variable(index=[time, region], unit="\$")
    widt_equityweightedimpact_discounted = Variable(index=[time, region], unit="\$million")

    ylo_periodstart = Variable(index=[time], unit="year")
    yhi_periodend = Variable(index=[time], unit="year")
    yagg_periodspan = Variable(index=[time], unit="year")

    addt_equityweightedimpact_discountedaggregated = Variable(index=[time, region], unit="\$million")
    addt_gt_equityweightedimpact_discountedglobal = Variable(unit="\$million")

    td_totaldiscountedimpacts = Variable(unit="\$million") # Called "CIV_VALUE"

    aact_equityweightedadaptation_discountedaggregated = Variable(unit="\$million")
    tac_totaladaptationcosts = Variable(unit="\$million")

    # Final result: total effect of climate change
    te_totaleffect = Variable(unit="\$million")
end

function run_timestep(s::EquityWeighting, tt::Int64)
    v = s.Variables
    p = s.Parameters
    d = s.Dimensions

    if tt == 1
        v.tpc_totalaggregatedcosts = 0
        v.addt_gt_equityweightedimpact_discountedglobal = 0
        v.tac_totaladaptationcosts = 0
        v.te_totaleffect = 0
    end

    v.df_utilitydiscountrate[tt] = (1 + p.ptp_timepreference / 100)^(-(y_year[tt] - y_year_0))

    for rr in d.region
        ## Consumption calculations
        v.cons_consumption[tt, rr] = p.gdp[tt, rr] * (1 - p.save_savingsrate / 100)
        v.cons_per_cap_consumption[tt, rr] = v.cons_consumption[tt, rr] / p.pop_ulation[tt, rr]

        ## Gas Costs Accounting

        # Sum over all gases (Page 23 of Hope 2009)
        v.tct_totalcosts_total[tt, rr] = p.tc_totalcosts_co2[tt, rr] + p.tc_totalcosts_co2[tt, rr] + p.tc_totalcosts_ch4[tt, rr] + p.tc_totalcosts_n2o[tt, rr] + p.tc_totalcosts_linear[tt, rr]
        v.tct_percap_totalcosts_total[tt, rr] = v.tct_totalcosts_total[tt, rr] / p.pop_ulation[tt, rr]

        # Weighted costs (Page 23 of Hope 2009)
        v.wtct_per_cap_weightedcosts[tt, rr] = ((p.cons_per_cap_0^p.emuc_utilityconvexity) / (1 - p.emuc_utilityconvexity)) * (p.cons_per_cap^(1 - p.emuc_utilityconvexity) - (p.cons_per_cap - tct_per_cap_totalcosts)^(1 - p.emuc_utilityconvexity))

        ## Adaptation Costs Accounting
        v.act_adaptationcosts_total[tt, rr] = p.ac_adaptationcosts_economic[tt, rr] + p.ac_adaptationcosts_noneconomic[tt, rr] + p.ac_adaptationcosts_sealevelrise[tt, rr]
        v.act_per_cap_adaptationcosts[tt, rr] = v.act_adaptationcosts_total[tt, rr] / p.pop_ulation[tt, rr]

        v.eact_per_cap_weightedadaptationcosts[tt, rr] = ((p.cons_per_cap_0^p.emuc_utilityconvexity) / (1 - p.emuc_utilityconvexity)) * (p.cons_per_cap^(1 - p.emuc_utilityconvexity) - (p.cons_per_cap - v.act_per_cap_adaptationcosts[tt, rr])^(1 - p.emuc_utilityconvexity))

        # Do partial weighting
        if p.equity_proportion == 0
            v.pct_percap_partiallyweighted[tt, rr] = v.tct_percap_totalcosts_total[tt, rr]
            v.wact_per_cap_partiallyweighted[tt, rr] = v.act_per_cap_adaptationcosts[tt, rr]
        else
            v.pct_percap_partiallyweighted[tt, rr] = (1 - p.equity_proportion) * v.tct_percap_totalcosts_total[tt, rr] + p.equity_proportion * v.wtct_per_cap_weightedcosts[tt, rr]
             v.wact_per_cap_partiallyweighted[tt, rr] = (1 - p.equity_proportion) * v.act_per_cap_adaptationcosts[tt, rr] + p.equity_proportion * v.eact_per_cap_weightedadaptationcosts[tt, rr]
        end

        v.pct_partiallyweighted[tt, rr] = v.pct_percap_partiallyweighted[tt, rr] * p.pop_ulation[tt, rr]
        v.wact_partiallyweighted[tt, rr] = v.v.wact_per_cap_partiallyweighted[tt, rr] * p.pop_ulation[tt, rr]

        # Discount rate calculations
        v.dr_discountrate[tt, rr] = p.ptp + (p.emuc_utilityconvexity * grw_gdpgrowth[tt, rr] - pop_grw_populationgrowth[tt, rr])
        if tt == 1
            v.yp_yearsperiod[1] = p.y_year[1] - p.y_year_0
        else
            v.yp_yearsperiod[tt] = p.y_year[tt] - p.y_year[tt-1]
        end

        if tt == 1
            v.dfc_consumptiondiscountrate[1, rr] = (1 + v.dr_discountrate[1, rr] / 100)^(-(p.y_year[1] - p.y0_year0))
        else
            v.dfc_consumptiondiscountrate[tt, rr] = v.dfc_consumptiondiscountrate[tt - 1, rr] * (1 + v.dr_discountrate[tt, rr] / 100)^(v.yp_yearsperiod[tt])
        end

        # Discounted costs
        if p.equity_proportion == 0
            v.pcdt_partiallyweighted_discounted[tt, rr] = v.pct_partiallyweighted[tt, rr] * v.dfc_consumptiondiscountrate[tt, rr]
            v.wacdt_partiallyweighted_discounted[tt, rr] = v.act_adaptationcosts_total[tt, rr] * v.dfc_consumptiondiscountrate[tt, rr]
        else
            v.pcdt_partiallyweighted_discounted[tt, rr] = v.pct_partiallyweighted[tt, rr] * p.df_utilitydiscountrate[tt]
            v.wacdt_partiallyweighted_discounted[tt, rr] = v.wact_partiallyweighted[tt, rr] * p.df_utilitydiscountrate[tt]
        end

        v.pcdt_g_partiallyweighted_discountedglobal[tt] = sum(v.pcdt_partiallyweighted_discounted[tt, :])

        # Analysis period ranges, from Hope (2006)
        if tt == 1
            v.ylo_periodstart[tt] = p.y_year_0
        else
            v.ylo_periodstart[tt] = (p.y_year[tt] + p.y_year[tt-1]) / 2
        end

        if tt == length(d.time)
            v.yhi_periodend[tt] = p.y_year[tt]
        else
            v.yhi_periodend[tt] = (p.y_year[tt] + p.y_year[tt+1]) / 2
        end

        v.yagg_periodspan[tt] = yhi_periodend[tt] - ylo_periodstart[tt]

        v.pcdt_partiallyweighted_discountedaggregated[tt, rr] = pcdt_partiallyweighted_discounted[tt, rr] * p.yagg_periodspan[rr]

        ## Equity weighted impacts (end of page 28, Hope 2009)
        v.wit_equityweightedimpact[tt, rr] = ((p.cons_per_cap_0^p.emuc_utilityconvexity) / (1 - p.emuc_utilityconvexity)) * ((p.cons_per_cap_aftercosts[tt, rr]^(1 - p.emuc_utilityconvexity) - p.rcons_per_cap_dis[tt, rr])^(1 - p.emuc_utilityconvexity)) * p.pop_ulation[tt, rr]

        v.widt_equityweightedimpact_discounted[tt, rr] = v.wit_equityweightedimpact[tt, rr] * v.df[tt]

        v.addt_equityweightedimpact_discountedaggregated[tt, rr] = v.widt_equityweightedimpact_discounted[tt, rr] * v.yagg_periodspan[tt]
        v.aact_equityweightedadaptation_discountedaggregated[tt, rr] = v.wacdt_partiallyweighted_discounted[tt, rr] * v.yagg_periodspan[tt]
    end

    v.pct_g_partiallyweighted_global = sum(v.pct_partiallyweighted[tt, :])
    v.tpc_totalaggregatedcosts = v.tpc_totalaggregatedcosts + sum(v.pcdt_partiallyweighted_discountedaggregated[tt, :])

    v.addt_gt_equityweightedimpact_discountedglobal = v.addt_gt_equityweightedimpact_discountedglobal + sum(v.addt_equityweightedimpact_discountedaggregated[tt, :])

    v.tac_totaladaptationcosts = v.tac_totaladaptationcosts + sum(aact_equityweightedadaptation_discountedaggregated[tt, :])

    v.td_totaldiscountedimpacts_capped = min(v.addt_gt_equityweightedimpact_discountedglobal, civvalue_impactcap)

    # Total effect of climate change
    v.te_totaleffect = min(v.td_totaldiscountedimpacts + v.tpc_totalaggregatedcosts + v.tac_totaladaptationcosts, civvalue_impactcap)
end

function addequityweighting(model::Model)
    equityweighting = addcomponent(model, EquityWeighting)

    equityweighting[:ptp_timepreference] = 1.033333 # <0.1,1, 2>

    return equityweighting
end
