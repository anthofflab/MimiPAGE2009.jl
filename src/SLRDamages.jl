using Mimi
include("load_parameters.jl")

@defcomp SLRDamages begin
    region = Index()

    y_year = Parameter(index=[time], unit="year")
    y_year_0 = Parameter(unit="year")

    #incoming parameters from SeaLevelRise
    s_sealevel = Parameter(index=[time], unit="m")
    #incoming parameters to calculate consumption per capita after Costs
    cons_percap_consumption = Parameter(index=[time, region], unit="\$/person")
    tct_per_cap_totalcostspercap = Parameter(index=[time,region], unit= "\$/person")
    act_percap_adaptationcosts = Parameter(index=[time, region], unit="\$/person")

    #component parameters
    impmax_maxSLRforadaptpolicySLR = Parameter(index=[region], unit= "m")

    SAVE_savingsrate = Parameter(unit= "%")
    WINCF_weightsfactor =Parameter(index=[region], unit="")
    W_SatCalibrationSLR =Parameter()
    ipow_SLRIncomeFxnExponent =Parameter()
    pow_SLRImpactFxnExponent=Parameter()
    iben_SLRInitialBenefit=Parameter()
    scal_calibrationSLR = Parameter()
    GDP_per_cap_focus_0_FocusRegionEU = Parameter()
    isat_0_InitialImpactFxnSaturation= Parameter()

    #component variables
    cons_percap_aftercosts = Variable(index=[time, region], unit = "\$/person")
    gdp_percap_aftercosts = Variable(index=[time, region], unit = "\$/person")

    atl_adjustedtolerablelevelofsealevelrise = Parameter(index=[time,region], unit="m") # meter
    imp_actualreductionSLR = Parameter(index=[time, region], unit="%")
    i_regionalimpactSLR = Variable(index=[time, region], unit="m")

    iref_ImpactatReferenceGDPperCapSLR = Variable(index=[time, region]) #variable or parameter?
    igdp_ImpactatActualGDPperCapSLR=Variable(index=[time, region])

    isat_ImpactinclSaturationandAdaptationSLR= Variable(index=[time,region])
    isatg_impactfxnsaturation = Variable()
    isat_per_cap_SLRImpactperCapinclSaturationandAdaptation = Variable(index=[time, region], unit="\$/person")

    rcons_per_cap_SLRRemainConsumption = Variable(index=[time, region], unit = "\$/person") #include?
    rgdp_per_cap_SLRRemainGDP = Variable(index=[time, region], unit = "\$/person") #include?
end

function init(s::SLRDamages)
    v = s.Variables
    p = s.Parameters
    d = s.Dimensions

    v.isatg_impactfxnsaturation= p.isat_0_InitialImpactFxnSaturation * (1 - p.SAVE_savingsrate/100)
end

function run_timestep(s::SLRDamages, t::Int64)
    v = s.Variables
    p = s.Parameters
    d = s.Dimensions

    for r in d.region
        v.cons_percap_aftercosts[t, r] = p.cons_percap_consumption[t, r] - p.tct_per_cap_totalcostspercap[t, r] - p.act_percap_adaptationcosts[t, r] # Check with Chris Hope: add or subtract adaptationcosts?
        v.gdp_percap_aftercosts[t,r]=v.cons_percap_aftercosts[t, r]/(1 - p.SAVE_savingsrate/100)

        if (p.s_sealevel[t]-p.atl_adjustedtolerablelevelofsealevelrise[t,r]) < 0
            v.i_regionalimpactSLR[t,r] = 0
        else
            v.i_regionalimpactSLR[t,r] = p.s_sealevel[t]-p.atl_adjustedtolerablelevelofsealevelrise[t,r]
        end

        v.iref_ImpactatReferenceGDPperCapSLR[t,r]= p.WINCF_weightsfactor[r]*((p.W_SatCalibrationSLR + p.iben_SLRInitialBenefit * p.scal_calibrationSLR)*
            (v.i_regionalimpactSLR[t,r]/p.scal_calibrationSLR)^p.pow_SLRImpactFxnExponent - v.i_regionalimpactSLR[t,r] * p.iben_SLRInitialBenefit)

        v.igdp_ImpactatActualGDPperCapSLR[t,r]= v.iref_ImpactatReferenceGDPperCapSLR[t,r]*
                (v.gdp_percap_aftercosts[t,r]/p.GDP_per_cap_focus_0_FocusRegionEU)^p.ipow_SLRIncomeFxnExponent

        if v.igdp_ImpactatActualGDPperCapSLR[t,r] < v.isatg_impactfxnsaturation
            v.isat_ImpactinclSaturationandAdaptationSLR[t,r] = v.igdp_ImpactatActualGDPperCapSLR[t,r]
        elseif v.i_regionalimpactSLR[t,r] < p.impmax_maxSLRforadaptpolicySLR[r]
            v.isat_ImpactinclSaturationandAdaptationSLR[t,r] = v.isatg_impactfxnsaturation+
                ((100-p.SAVE_savingsrate)-v.isatg_impactfxnsaturation)*
                ((v.igdp_ImpactatActualGDPperCapSLR[t,r]-v.isatg_impactfxnsaturation)/
                (((100-p.SAVE_savingsrate)-v.isatg_impactfxnsaturation)+
                (v.igdp_ImpactatActualGDPperCapSLR[t,r]- v.isatg_impactfxnsaturation)))*
                (1-p.imp_actualreductionSLR[t,r]/100)

        else
            v.isat_ImpactinclSaturationandAdaptationSLR[t,r] = v.isatg_impactfxnsaturation+
                ((100-p.SAVE_savingsrate)-v.isatg_impactfxnsaturation) *
                ((v.igdp_ImpactatActualGDPperCapSLR[t,r]-v.isatg_impactfxnsaturation)/
                (((100-p.SAVE_savingsrate)-v.isatg_impactfxnsaturation)+
                (v.igdp_ImpactatActualGDPperCapSLR[t,r] * v.isatg_impactfxnsaturation))) *
                (1-(p.imp_actualreductionSLR[t,r]/100)* p.impmax_maxSLRforadaptpolicySLR[r] /
                v.i_regionalimpactSLR[t,r])
        end

              v.isat_per_cap_SLRImpactperCapinclSaturationandAdaptation[t,r] = (v.isat_ImpactinclSaturationandAdaptationSLR[t,r]/100)*v.gdp_percap_aftercosts[t,r]
              v.rcons_per_cap_SLRRemainConsumption[t,r] = v.cons_percap_aftercosts[t,r] - v.isat_per_cap_SLRImpactperCapinclSaturationandAdaptation[t,r]
              v.rgdp_per_cap_SLRRemainGDP[t,r] = v.rcons_per_cap_SLRRemainConsumption[t,r]/(1-p.SAVE_savingsrate/100)

    end

end

function addslrdamages(model::Model)
    SLRDamagescomp = addcomponent(model, SLRDamages)

    SLRDamagescomp[:impmax_maxSLRforadaptpolicySLR] = readpagedata(model, "../data/sealevelmaxrise.csv")
    SLRDamagescomp[:WINCF_weightsfactor] = readpagedata(model, "../data/wincf_weightsfactor.csv")
    SLRDamagescomp[:pow_SLRImpactFxnExponent] = 0.73
    SLRDamagescomp[:ipow_SLRIncomeFxnExponent] = -0.30
    SLRDamagescomp[:iben_SLRInitialBenefit] = 0.00
    SLRDamagescomp[:scal_calibrationSLR] = 0.5

    return SLRDamagescomp
end
