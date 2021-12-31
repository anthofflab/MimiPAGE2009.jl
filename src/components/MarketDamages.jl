@defcomp MarketDamages begin
    region = Index()
    y_year = Parameter(index=[time], unit="year")

    #incoming parameters from Climate
    rtl_realizedtemperature = Parameter(index=[time, region], unit="degreeC")

    #tolerability variables
    atl_adjustedtolerableleveloftemprise = Parameter(index=[time,region], unit="degreeC")
    imp_actualreduction = Parameter(index=[time, region], unit= "%")
    i_regionalimpact = Variable(index=[time, region], unit="degreeC")

    #impact Parameters
    rcons_per_cap_SLRRemainConsumption = Parameter(index=[time, region], unit = "\$/person")
    rgdp_per_cap_SLRRemainGDP = Parameter(index=[time, region], unit = "\$/person")

    save_savingsrate = Parameter(unit= "%", default=15.)
    wincf_weightsfactor =Parameter(index=[region], unit="unitless")
    W_MarketImpactsatCalibrationTemp =Parameter(unit="%GDP", default=0.5)
    ipow_MarketIncomeFxnExponent =Parameter(default=-0.13333333333333333)
    iben_MarketInitialBenefit=Parameter(default=.1333333333333)
    tcal_CalibrationTemp = Parameter(unit="degreeC", default=3.)
    GDP_per_cap_focus_0_FocusRegionEU = Parameter(unit="\$/person", default=27934.244777382406)

    #impact variables
    isatg_impactfxnsaturation = Parameter(unit="unitless")
    rcons_per_cap_MarketRemainConsumption = Variable(index=[time, region], unit = "\$/person")
    rgdp_per_cap_MarketRemainGDP = Variable(index=[time, region], unit = "\$/person")
    iref_ImpactatReferenceGDPperCap=Variable(index=[time, region])
    igdp_ImpactatActualGDPperCap=Variable(index=[time, region])
    impmax_maxtempriseforadaptpolicyM = Parameter(index=[region], unit= "degreeC")

    isat_ImpactinclSaturationandAdaptation= Variable(index=[time,region])
    isat_per_cap_ImpactperCapinclSaturationandAdaptation = Variable(index=[time,region], unit="\$/person")
    pow_MarketImpactExponent=Parameter(unit="", default=2.16666666666665)

    function run_timestep(p, v, d, t)

        for r in d.region
            #calculate tolerability
            if (p.rtl_realizedtemperature[t,r]-p.atl_adjustedtolerableleveloftemprise[t,r]) < 0
                v.i_regionalimpact[t,r] = 0
            else
                v.i_regionalimpact[t,r] = p.rtl_realizedtemperature[t,r]-p.atl_adjustedtolerableleveloftemprise[t,r]
            end

            v.iref_ImpactatReferenceGDPperCap[t,r]= p.wincf_weightsfactor[r]*((p.W_MarketImpactsatCalibrationTemp + p.iben_MarketInitialBenefit * p.tcal_CalibrationTemp)*
                (v.i_regionalimpact[t,r]/p.tcal_CalibrationTemp)^p.pow_MarketImpactExponent - v.i_regionalimpact[t,r] * p.iben_MarketInitialBenefit)

            v.igdp_ImpactatActualGDPperCap[t,r]= v.iref_ImpactatReferenceGDPperCap[t,r]*
                (p.rgdp_per_cap_SLRRemainGDP[t,r]/p.GDP_per_cap_focus_0_FocusRegionEU)^p.ipow_MarketIncomeFxnExponent

            if v.igdp_ImpactatActualGDPperCap[t,r] < p.isatg_impactfxnsaturation
                v.isat_ImpactinclSaturationandAdaptation[t,r] = v.igdp_ImpactatActualGDPperCap[t,r]
            else
                v.isat_ImpactinclSaturationandAdaptation[t,r] = p.isatg_impactfxnsaturation+
                    ((100-p.save_savingsrate)-p.isatg_impactfxnsaturation)*
                    ((v.igdp_ImpactatActualGDPperCap[t,r]-p.isatg_impactfxnsaturation)/
                    (((100-p.save_savingsrate)-p.isatg_impactfxnsaturation)+
                    (v.igdp_ImpactatActualGDPperCap[t,r]-
                    p.isatg_impactfxnsaturation)))
                end

            if v.i_regionalimpact[t,r] < p.impmax_maxtempriseforadaptpolicyM[r]
                v.isat_ImpactinclSaturationandAdaptation[t,r]=v.isat_ImpactinclSaturationandAdaptation[t,r]*(1-p.imp_actualreduction[t,r]/100)
            else
                v.isat_ImpactinclSaturationandAdaptation[t,r] = v.isat_ImpactinclSaturationandAdaptation[t,r] *
                    (1-(p.imp_actualreduction[t,r]/100)* p.impmax_maxtempriseforadaptpolicyM[r] /
                    v.i_regionalimpact[t,r])
            end

            v.isat_per_cap_ImpactperCapinclSaturationandAdaptation[t,r] = (v.isat_ImpactinclSaturationandAdaptation[t,r]/100)*p.rgdp_per_cap_SLRRemainGDP[t,r]
            v.rcons_per_cap_MarketRemainConsumption[t,r] = p.rcons_per_cap_SLRRemainConsumption[t,r] - v.isat_per_cap_ImpactperCapinclSaturationandAdaptation[t,r]
            v.rgdp_per_cap_MarketRemainGDP[t,r] = v.rcons_per_cap_MarketRemainConsumption[t,r]/(1-p.save_savingsrate/100)
        end

    end
end
