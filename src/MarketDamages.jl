
@defcomp MarketDamages begin
    region = Index(region)
    y_year = Parameter(index=[time], unit="year")

    #incoming parameters from Climate
    rt_realizedtemperature = Parameter(index=[time, region], unit="degreeC")

    #tolerability variables
    atl_adjustedtolerableleveloftemprise = Parameter(index=[time,region], unit="degreeC")
    imp_actualreduction = Parameter(index=[time, region], unit= "%")
    i_regionalimpact = Variable(index=[time, region], unit="degreeC")

    #impact Parameters
    rcons_per_cap_SLRRemainConsumption = Parameter(index=[time, region], unit = "\$/person")
    rgdp_per_cap_SLRRemainGDP = Parameter(index=[time, region], unit = "\$/person")

    SAVE_savingsrate = Parameter(unit= "%")
    WINCF_weightsfactor =Parameter(index=[region], unit="")
    W_MarketImpactsatCalibrationTemp =Parameter()
    ipow_MarketIncomeFxnExponent =Parameter()
    iben_MarketInitialBenefit=Parameter()
    tcal_CalibrationTemp = Parameter()
    GDP_per_cap_focus_0_FocusRegionEU = Parameter()
    isat_0_InitialImpactFxnSaturation= Parameter()

    #impact variables
    isatg_impactfxnsaturation = Variable()
    rcons_per_cap_MarketRemainConsumption = Variable(index=[time, region], unit = "\$/person")
    rgdp_per_cap_MarketRemainGDP = Variable(index=[time, region], unit = "\$/person")
    iref_ImpactatReferenceGDPperCap=Variable(index=[time, region])
    igdp_ImpactatActualGDPperCap=Variable(index=[time, region])
    isat_ImpactinclSaturationandAdaptation= Variable(index=[time,region])
    isat_per_cap_ImpactperCapinclSaturationandAdaptation = Variable(index=[time,region])
    pow_MarketImpactExponent=Parameter(unit="")

end

function run_timestep(s::MarketDamages, t::Int64)
    v = s.Variables
    p = s.Parameters
    d = s.Dimensions

    for r in d.region
        #calculate tolerability
        if (p.rt_realizedtemperature[t,r]-p.atl_adjustedtolerableleveloftemprise[t,r]) < 0
            v.i_regionalimpact[t,r] = 0
        else
            v.i_regionalimpact[t,r] = p.rt_realizedtemperature[t,r]-p.atl_adjustedtolerableleveloftemprise[t,r]
        end

        v.iref_ImpactatReferenceGDPperCap[t,r]= p.WINCF_weightsfactor[r]*((p.W_MarketImpactsatCalibrationTemp + p.iben_MarketInitialBenefit * p.tcal_CalibrationTemp)*
            (v.i_regionalimpact[t,r]/p.tcal_CalibrationTemp)^p.pow_MarketImpactExponent - v.i_regionalimpact[t,r] * p.iben_MarketInitialBenefit)

        v.igdp_ImpactatActualGDPperCap[t,r]= v.iref_ImpactatReferenceGDPperCap[t,r]*
            (p.rgdp_per_cap_SLRRemainGDP[t,r]/p.GDP_per_cap_focus_0_FocusRegionEU)^p.ipow_MarketIncomeFxnExponent

        v.isatg_impactfxnsaturation= p.isat_0_InitialImpactFxnSaturation * (1 - p.SAVE_savingsrate/100)

        if v.igdp_ImpactatActualGDPperCap[t,r] < v.isatg_impactfxnsaturation
            v.isat_ImpactinclSaturationandAdaptation[t,r] = v.igdp_ImpactatActualGDPperCap[t,r]
        elseif v.i_regionalimpact[t,r] < p.impmax_maxtempriseforadaptpolicyM[r]
            v.isat_ImpactinclSaturationandAdaptation[t,r] = v.isatg_impactfxnsaturation+
                ((100-p.SAVE_savingsrate)-v.isatg_impactfxnsaturation)*
                ((v.igdp_ImpactatActualGDPperCap[t,r]-v.isatg_impactfxnsaturation)/
                (((100-p.SAVE_savingsrate)-v.isatg_impactfxnsaturation)+
                (v.igdp_ImpactatActualGDPperCap[t,r]-
                v.isatg_impactfxnsaturation)))*(1-p.imp_actualreduction[t,r]/100)
        else
            v.isat_ImpactinclSaturationandAdaptation[t,r] = v.isatg_impactfxnsaturation+
                ((100-p.SAVE_savingsrate)-v.isatg_impactfxnsaturation) *
                ((v.igdp_ImpactatActualGDPperCap[t,r]-v.isatg_impactfxnsaturation)/
                (((100-p.SAVE_savingsrate)-v.isatg_impactfxnsaturation)+
                (v.igdp_ImpactatActualGDPperCap[t,r] * v.isatg_impactfxnsaturation))) *
                (1-(p.imp_actualreduction[t,r]/100)* p.impmax_maxtempriseforadaptpolicyM[r] /
                v.i_regionalimpact[t,r])
        end

        v.isat_per_cap_ImpactperCapinclSaturationandAdaptation[t,r] = (v.isat_ImpactinclSaturationandAdaptation[t,r]/100)*p.rgdp_per_cap_SLRRemainGDP[t,r]
        v.rcons_per_cap_MarketRemainConsumption[t,r] = p.rcons_per_cap_SLRRemainConsumption[t,r] - v.isat_per_cap_ImpactperCapinclSaturationandAdaptation[t,r]
        v.rgdp_per_cap_MarketRemainGDP[t,r] = v.rcons_per_cap_MarketRemainConsumption[t,r]/(1-p.SAVE_savingsrate/100)
    end

end

function addmarketdamages(model::Model)
    marketdamagescomp = addcomponent(model, MarketDamages)

    marketdamagescomp[:tcal_CalibrationTemp]= 3.
    marketdamagescomp[:isat_0_InitialImpactFxnSaturation]= .5 #can't find this parameter in the documentation. Check with Chris Hope.
    marketdamagescomp[:W_MarketImpactsatCalibrationTemp] = .5
    marketdamagescomp[:iben_MarketInitialBenefit] = .13
    marketdamagescomp[:ipow_MarketIncomeFxnExponent] = -.13
    marketdamagescomp[:SAVE_savingsrate]= 15.
    marketdamagescomp[:GDP_per_cap_focus_0_FocusRegionEU]= (1.39*10^7)/496
    marketdamagescomp[:pow_MarketImpactExponent]=2.17

    return marketdamagescomp
end
