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

    # Calculation of weighted costs
    emuc_utilityconvexity = Parameter(unit="none")
    cons_per_cap_0 = Parameter(unit="none") # Called "CONS_PER_CAP_FOCUS_0"
    cons_per_cap = Parameter(unit="none") # Called "CONS_PER_CAP"
    tct_per_cap_totalcosts = Parameter(unit="none")

    wtct_per_cap_weightedcosts = Variable(index=[time, region], unit="\$")

    # Amount of equity weighting variable (0, (0, 1), or 1)
    equity_proportion = Parameter(unit="fraction")

    pct_percap_partiallyweighted = Variable(index=[time, region], unit="\$/person")
    pct_partiallyweighted = Variable(index=[time, region], unit="\$million")
    pct_g_partiallyweighted_global = Variable(index=[time], unit="\$million")

    # Discount rates
    ptp_??? = Parameter(unit="???")
    grw_??? = Parameter(index=[time, region], unit="???")
    pop_grw_??? = Parameter(index=[time, region], unit="???")

    dr_discountrate = Variable(index=[time, region], unit="%/year")
    dfc_consumptiondiscountrate = Variable(index=[time, region], unit="1/year")

    df_utilitydiscountrate = Parameter(index=[time], unit="fraction")

    # Discounted costs
    pcdt_partiallyweighted_discounted = Variable(index=[time, region], unit="\$million")
    pcdt_g_partiallyweighted_discountedglobal = Variable(index=[time], unit="\$million")

    pcdat_partiallyweighted_discountedaggregated = Variable(index=[time, region], unit="\$million")
    tpc_totalaggregatedcosts = Variable(unit="\$million")

    # TODO: EQUATIONS ON END OF PAGE 28
    wit_equityweightedimpact = Variable(index=[time, region], unit="???")

    # TODO: CHECK IF THESE FROM PAGE 9 STILL RELEVANT
    gdp_focus_baseline = Parameter(unit="\$M")
    gdp = Parameter(index=[time, region], unit="\$M")

    e_equityweight = Variable(index=[time, region], unit="none")
end

function run_timestep(s::EquityWeighting, tt::Int64)
    v = s.Variables
    p = s.Parameters
    d = s.Dimensions

    if tt == 1
        v.tpc_totalaggregatedcosts = 0
    end

    for rr in d.region
        # Sum over all gases (Page 23 of Hope 2009)
        v.tct_totalcosts_total[tt, rr] = p.tc_totalcosts_co2[tt, rr] + p.tc_totalcosts_co2[tt, rr] + p.tc_totalcosts_ch4[tt, rr] + p.tc_totalcosts_n2o[tt, rr] + p.tc_totalcosts_linear[tt, rr]
        v.tct_percap_totalcosts_total[tt, rr] = v.tct_totalcosts_total[tt, rr] / p.pop_ulation[tt, rr]

        # Weighted costs (Page 23 of Hope 2009)
        v.wtct_per_cap_weightedcosts[tt, rr] = ((p.cons_per_cap_0^p.emuc_utilityconvexity) / (1 - p.emuc_utilityconvexity)) * (p.cons_per_cap^(1 - p.emuc_utilityconvexity) - (p.cons_per_cap - tct_per_cap_totalcosts)^(1 - p.emuc_utilityconvexity))

        # Do partial weighting
        if p.equity_proportion == 0
            v.pct_percap_partiallyweighted[tt, rr] = v.tct_percap_totalcosts_total[tt, rr]
        else
            v.pct_percap_partiallyweighted[tt, rr] = (1 - p.equity_proportion) * v.tct_percap_totalcosts_total[tt, rr] + p.equity_proportion * v.wtct_per_cap_weightedcosts[tt, rr]
        end

        v.pct_partiallyweighted[tt, rr] = v.pct_percap_partiallyweighted[tt, rr] * p.pop_ulation[tt, rr]

        # Discount rate calculations
        v.dr_discountrate[tt, rr] = p.ptp + (p.emuc_utilityconvexity * grw_???[tt, rr] - pop_grw_???[tt, rr])
        if tt == 1
            v.dfc_consumptiondiscountrate[1, rr] = (1 + v.dr_discountrate[1, rr] / 100)^(-(p.y_year[1] - p.y0_year0))
        else
            v.dfc_consumptiondiscountrate[tt, rr] = v.dfc_consumptiondiscountrate[tt - 1, rr] * (1 + v.dr_discountrate[tt, rr] / 100)^(p.yp_???[tt])
        end

        # Discounted costs
        if p.equity_proportion == 0
            v.pcdt_partiallyweighted_discounted[tt, rr] = v.pct_partiallyweighted[tt, rr] * v.dfc_consumptiondiscountrate[tt, rr]
        else
            v.pcdt_partiallyweighted_discounted[tt, rr] = v.pct_partiallyweighted[tt, rr] * p.df_utilitydiscountrate[tt]
        end

        v.pcdt_g_partiallyweighted_discountedglobal[tt] = sum(v.pcdt_partiallyweighted_discounted[tt, :])

        v.pcdt_partiallyweighted_discountedaggregated[tt, rr] = pcdt_partiallyweighted_discounted[tt, rr] * p.yagg_???[rr]

        # Page 12 of Hope 2009
        v.e_equityweight[tt, rr] = (p.gdp_focus_baseline / p.gdp[rr, tt])^p.emuc_utilityconvexity
    end

    v.pct_g_partiallyweighted_global = sum(v.pct_partiallyweighted[tt, :])
    v.tpc_totalaggregatedcosts = v.tpc_totalaggregatedcosts + sum(v.pcdt_partiallyweighted_discountedaggregated[tt, :])
end

function addadaptationcosts(model::Model)
    equityweighting = addcomponent(model, EquityWeighting)

    return equityweighting
end
