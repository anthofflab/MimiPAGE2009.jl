
@defcomp Tolerability begin
    region = Index(region)

    y_year = Parameter(index=[time], unit="year")

    #incoming parameters from Climate
    rt_realizedtemperature = Parameter(index=[time, region], unit="degreeC")

    #component parameters
    #uncertain parameter (tolerable before discontinuity)
    tm_regionalmultiplier = Parameter()
    tr_0_tolerablerateofchange= Parameter()
    tp_0_tolerableplateau = Parameter()
    atl_0_adjustedtolerableplateau = Parameter(index=[region], unit="degreeC")
    plat_increaseintolerableplateaufromadaptation = Parameter(index=[time, region], unit="degreeC")
    slope_increaseintolerableratefromadaptation = Parameter(index=[time,region], unit="degreeC/year")

    #component variables
    tr_tolerablerateofchange = Variable(index=[region], unit="degreeC/year")
    atp_adjustedtolerableplateau = Variable(index=[time, region], unit="degreeC")
    tp_tolerableplateau = Variable(index=[time, region], unit="degreeC")
    atr_adjustedtolerablerate = Variable(index=[time, region], unit="degreeC/year")
    atl_adjustedtolerableleveloftemprise = Variable(index=[time,region], unit="degreeC")
    i_regionalimpact = Variable(index=[time, region], unit="degreeC")

end

function run_timestep(s::Tolerability, t::Int64)
    #calculate global baseline temperature from initial regional temperatures
    v = s.Variables
    p = s.Parameters
    d = s.Dimensions

    for r in d.region
        v.tr_tolerablerateofchange[r]= p.tr_0_tolerablerateofchange * p.tm_regionalmultiplier[r]
        v.tp_tolerableplateau[r] = p.tp_0_tolerableplateau * p.tm_regionalmultiplier[r]

        v.atp_adjustedtolerableplateau[t,r] = v.tp_tolerableplateau[r] + p.plat_increaseintolerableplateaufromadaptation[t,r]
        v.atr_adjustedtolerablerate[t,r] = v.tr_tolerablerateofchange[r] + p.slope_increaseintolerableratefromadaptation[t,r]

        v.atl_adjustedtolerableleveloftemprise[t,r] = min[v.atp_adjustedtolerableplateau[t,r], v.atl_adjustedtolerableleveloftemprise[t-1,r] +
            v.atr_adjustedtolerablerate[r]*(p.y_year[t]-p.y_year[t-1])]

        v.i_regionalimpact[t,r] = max[0, p.rt_g_globaltemperature[t,r]- v.atl_adjustedtolerableleveloftemprise[t,r]]
    end
end

function addtolerabilitymarket(model::Model)
    tolerabilitymarketcomp = addcomponent(model, Tolerability, :MarketTolerability)

    tolerabilitymarketcomp[:tm_regionalmultiplier] = 1.
    tolerabilitymarketcomp[:tr_0_tolerablerateofchange] = 0.
    tolerabilitymarketcomp[:tp_0_tolerableplateau] = 2.
    tolerabilitymarketcomp[:atl_0_adjustedtolerableplateau] = 0.
    tolerabilitymarketcomp[:slope_increaseintolerableratefromadaptation] = readfile("../data/market_slope.csv")
    tolerabilitymarketcomp[:plat_increaseintolerableplateaufromadaptation] = readfile("../data/market_plateau.csv")


    return tolerabilitymarketcomp
end

function addtolerabilitynonmarket(model::Model)
    tolerabilitynonmarketcomp = addcomponent(model, Tolerability, :NonMarketTolerability)

    tolerabilitynonmarketcomp[:tm_regionalmultiplier] = 1.
    tolerabilitynonmarketcomp[:tr_0_tolerablerateofchange] = 0.
    tolerabilitynonmarketcomp[:tp_0_tolerableplateau] = 2.
    tolerabilitynonmarketcomp[:atl_0_adjustedtolerableplateau] = 0.
    tolerabilitynonmarketcomp[:slope_increaseintolerableratefromadaptation] = readfile("../data/nonmarket_slope.csv")
    tolerabilitynonmarketcomp[:plat_increaseintolerableplateaufromadaptation] = readfile("../data/market_plateau.csv")


    return tolerabilitynonmarketcomp
end
