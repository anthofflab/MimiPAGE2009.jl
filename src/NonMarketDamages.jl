using DataFrames
using Distributions
include("mctools.jl")

@defcomp NonMarketDamages begin
    region = Index()

    y_year = Parameter(index=[time], unit="year")

    #incoming parameters from Climate
    rtl_realizedtemperature = Parameter(index=[time, region], unit="degreeC")

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
    WINCF_weightsfactor =Parameter(index=[region], unit="unitless")
    w_NonImpactsatCalibrationTemp =Parameter(unit="%GDP")
    ipow_NonMarketIncomeFxnExponent =Parameter(unit="unitless")
    iben_NonMarketInitialBenefit=Parameter(unit="%GDP/degreeC")
    tcal_CalibrationTemp = Parameter(unit="degreeC")
    GDP_per_cap_focus_0_FocusRegionEU = Parameter(unit="\$/person")
    pow_NonMarketExponent = Parameter(unit="")

    #impact variables
    isatg_impactfxnsaturation = Parameter(unit="unitless")
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

        if p.rtl_realizedtemperature[t,r]-p.atl_adjustedtolerableleveloftemprise[t,r] < 0
            v.i_regionalimpact[t,r] = 0
        else
            v.i_regionalimpact[t,r] = p.rtl_realizedtemperature[t,r]-p.atl_adjustedtolerableleveloftemprise[t,r]
        end

        v.iref_ImpactatReferenceGDPperCap[t,r]= p.WINCF_weightsfactor[r]*
            ((p.w_NonImpactsatCalibrationTemp + p.iben_NonMarketInitialBenefit *p.tcal_CalibrationTemp)*
                (v.i_regionalimpact[t,r]/p.tcal_CalibrationTemp)^p.pow_NonMarketExponent - v.i_regionalimpact[t,r] * p.iben_NonMarketInitialBenefit)

        v.igdp_ImpactatActualGDPperCap[t,r]= v.iref_ImpactatReferenceGDPperCap[t,r]*
            (p.rgdp_per_cap_MarketRemainGDP[t,r]/p.GDP_per_cap_focus_0_FocusRegionEU)^p.ipow_NonMarketIncomeFxnExponent

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

            if v.i_regionalimpact[t,r] < p.impmax_maxtempriseforadaptpolicyNM[r]
                v.isat_ImpactinclSaturationandAdaptation[t,r]=v.isat_ImpactinclSaturationandAdaptation[t,r]*(1-p.imp_actualreduction[t,r]/100)
            else
                v.isat_ImpactinclSaturationandAdaptation[t,r] = v.isat_ImpactinclSaturationandAdaptation[t,r] *
                    (1-(p.imp_actualreduction[t,r]/100)* p.impmax_maxtempriseforadaptpolicyNM[r] /
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
    nonmarketdamagescomp[:w_NonImpactsatCalibrationTemp] = 0.5333333333333333
    nonmarketdamagescomp[:iben_NonMarketInitialBenefit] = 0.08333333333333333
    nonmarketdamagescomp[:ipow_NonMarketIncomeFxnExponent] = 0.
    nonmarketdamagescomp[:save_savingsrate]= 15.
    nonmarketdamagescomp[:GDP_per_cap_focus_0_FocusRegionEU]= 27934.244777382406
    nonmarketdamagescomp[:pow_NonMarketExponent] = 2.1666666666666665
    nonmarketdamagescomp[:impmax_maxtempriseforadaptpolicyNM] = readpagedata(model, "data/impmax_noneconomic.csv")

    return nonmarketdamagescomp
end

function randomizenonmarketdamages(model::Model)
    update_external_parameter(model, :tcal_CalibrationTemp, rand(TriangularDist(2.5, 3.5, 3.)))
    update_external_parameter(model, :iben_NonMarketInitialBenefit, rand(TriangularDist(0, .2, .05)))
    update_external_parameter(model, :w_NonImpactsatCalibrationTemp, rand(TriangularDist(.1, 1, .5)))
    update_external_parameter(model, :pow_NonMarketExponent, rand(TriangularDist(1.5, 3, 2)))
    update_external_parameter(model, :ipow_NonMarketIncomeFxnExponent, rand(TriangularDist(-.2, .2, 0)))
    # Also randomized in GDP and SLRDamages and Market Damages
    update_external_parameter(model, :save_savingsrate, rand(TriangularDist(10, 20, 15)))
    wincf = [1.0,
             rand(TriangularDist(.6, 1, .8)),
             rand(TriangularDist(.4, 1.2, .8)),
             rand(TriangularDist(.2, .6, .4)),
             rand(TriangularDist(.4, 1.2, .8)),
             rand(TriangularDist(.4, 1.2, .8)),
             rand(TriangularDist(.4, .8, .6)),
             rand(TriangularDist(.4, .8, .6))]
    update_external_parameter(model, :WINCF_weightsfactor, wincf)
end
