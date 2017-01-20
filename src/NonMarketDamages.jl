using DataFrames

@defcomp NonMarketDamages begin
    region = Index(region)

    y_year = Parameter(index=[time], unit="year")

    #incoming parameters from Climate
    rt_realizedtemperature = Parameter(index=[time, region], unit="degreeC")

    #tolerability parameters
    impmax_maxtempriseforadaptpolicyNM = Parameter(index=[region], unit= "degreeC")
    atl_adjustedtolerableleveloftemprise = Parameter(index=[time,region], unit="degreeC")
    imp_actualreduction = Parameter(index=[time, region], unit= "%")

    #tolerability variables
    i_regionalimpact = Variable(index=[time, region], unit="degreeC")

    #impact Parameters
    rcons_per_cap_MarketRemainConsumption = Parameter(index=[time, region], unit = "\$/person")
    rgdp_per_cap_MarketRemainGDP = Parameter(index=[time, region], unit = "\$/person")

    save_savingsrate = Parameter(unit= "%")
    wincf_weightsfactor =Parameter(index=[region], unit="unitless")
    w_NonImpactsatCalibrationTemp =Parameter(unit="%GDP")
    ipow_NonMarketIncomeFxnExponent =Parameter(unit="unitless")
    iben_NonMarketInitialBenefit=Parameter(unit="%GDP/degreeC")
    tcal_CalibrationTemp = Parameter(unit="degreeC")
    GDP_per_cap_focus_0_FocusRegionEU = Parameter(unit="\$/person")
    isat_0_InitialImpactFxnSaturation= Parameter(unit="unitless")
    pow_NonMarketExponent = Parameter(unit="")

    #impact variables
    isatg_impactfxnsaturation = Variable(unit="unitless")
    rcons_per_cap_NonMarketRemainConsumption = Variable(index=[time, region], unit = "\$/person")
    rgdp_per_cap_NonMarketRemainGDP = Variable(index=[time, region], unit = "\$/person")
    iref_ImpactatReferenceGDPperCap=Variable(index=[time, region], unit="%")
    igdp_ImpactatActualGDPperCap=Variable(index=[time, region], unit="%")
    isat_ImpactinclSaturationandAdaptation= Variable(index=[time,region], unit="\$")
    isat_per_cap_ImpactperCapinclSaturationandAdaptation = Variable(index=[time,region], unit="\$/person")

end

function run_timestep(s::NonMarketDamages, t::Int64)
    v = s.Variables
    p = s.Parameters
    d = s.Dimensions

    for r in d.region

        if p.rt_realizedtemperature[t,r]-p.atl_adjustedtolerableleveloftemprise[t,r] < 0
            v.i_regionalimpact[t,r] = 0
        else
            v.i_regionalimpact[t,r] = p.rt_realizedtemperature[t,r]-p.atl_adjustedtolerableleveloftemprise[t,r]
        end

        v.iref_ImpactatReferenceGDPperCap[t,r]= p.wincf_weightsfactor[r]*
            ((p.w_NonImpactsatCalibrationTemp + p.iben_NonMarketInitialBenefit *p.tcal_CalibrationTemp)*
                (v.i_regionalimpact[t,r]/p.tcal_CalibrationTemp)^p.pow_NonMarketExponent - v.i_regionalimpact[t,r] * p.iben_NonMarketInitialBenefit)

        v.igdp_ImpactatActualGDPperCap[t,r]= v.iref_ImpactatReferenceGDPperCap[t,r]*
            (p.rgdp_per_cap_MarketRemainGDP[t,r]/p.GDP_per_cap_focus_0_FocusRegionEU)^p.ipow_NonMarketIncomeFxnExponent

        v.isatg_impactfxnsaturation= p.isat_0_InitialImpactFxnSaturation * (1 - p.save_savingsrate/100)

        if v.igdp_ImpactatActualGDPperCap[t,r] < v.isatg_impactfxnsaturation
            v.isat_ImpactinclSaturationandAdaptation[t,r] = v.igdp_ImpactatActualGDPperCap[t,r]
        else

            v.isat_ImpactinclSaturationandAdaptation[t,r] = v.isatg_impactfxnsaturation+
                ((100-p.save_savingsrate)-v.isatg_impactfxnsaturation)*
                    ((v.igdp_ImpactatActualGDPperCap[t,r]-v.isatg_impactfxnsaturation)/
                    (((100-p.save_savingsrate)-v.isatg_impactfxnsaturation)+
                        (v.igdp_ImpactatActualGDPperCap[t,r]-v.isatg_impactfxnsaturation)))* (1-p.imp_actualreduction[t,r]/100) *
                            (v.i_regionalimpact[t,r] < p.impmax_maxtempriseforadaptpolicyNM[r] ? 1 :
                                    p.impmax_maxtempriseforadaptpolicyNM[r] /
                                        v.i_regionalimpact[t,r])
        end

        v.isat_per_cap_ImpactperCapinclSaturationandAdaptation[t,r] = (v.isat_ImpactinclSaturationandAdaptation[t,r]/100)*p.rgdp_per_cap_MarketRemainGDP[t,r]
        v.rcons_per_cap_NonMarketRemainConsumption[t,r] = p.rcons_per_cap_MarketRemainConsumption[t,r] - v.isat_per_cap_ImpactperCapinclSaturationandAdaptation[t,r]
        v.rgdp_per_cap_NonMarketRemainGDP[t,r] = v.rcons_per_cap_NonMarketRemainConsumption[t,r]/(1-p.save_savingsrate/100)
    end
end

function addnonmarketdamages(model::Model)
    nonmarketdamagescomp = addcomponent(model, NonMarketDamages)

    nonmarketdamagescomp[:tcal_CalibrationTemp]= 3.
    nonmarketdamagescomp[:isat_0_InitialImpactFxnSaturation]= .33 #check with Chris Hope -  number give in 33 and units are in percent, but ISAT is never divided by 100 in equations
    nonmarketdamagescomp[:w_NonImpactsatCalibrationTemp] = .53
    nonmarketdamagescomp[:iben_NonMarketInitialBenefit] = .08
    nonmarketdamagescomp[:ipow_NonMarketIncomeFxnExponent] = 0.
    nonmarketdamagescomp[:save_savingsrate]= 15.
    nonmarketdamagescomp[:GDP_per_cap_focus_0_FocusRegionEU]= (1.39*10^7)/496
    nonmarketdamagescomp[:pow_NonMarketExponent] = 2.17
    nonmarketdamagescomp[:impmax_maxtempriseforadaptpolicyNM] = readpagedata(model, "../data/impmax_noneconomic.csv")

    return nonmarketdamagescomp
end
