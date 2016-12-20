using Mimi
include("load_parameters.jl")

@defcomp SLRDamages begin
    region = Index()

    y_year = Parameter(index=[time], unit="year")
    y_year_0 = Parameter(unit="year")

    #incoming parameters from SeaLevelRise
    s_sealevel = Parameter(index=[time], unit="m")

    #component parameters
    plateau_increaseintolerableplateaufromadaptationSLR = Parameter(index=[region], unit="m")
    pstart_startdateofadaptpolicySLR = Parameter(index=[region], unit="year")
    pyears_yearstilfulleffectSLR = Parameter(index=[region], unit="year")
    impred_eventualpercentreductionSLR = Parameter(index=[region], unit= "%")
    impmax_maxSLRforadaptpolicySLR = Parameter(index=[region], unit= "m")
    istart_startdateSLR = Parameter(index=[region], unit = "year")
    iyears_yearstilfulleffectSLR = Parameter(index=[region], unit= "year")

    cons_per_cap_AfterCosts = Parameter(index=[time, region], unit = "\$")
    gdp_per_cap_after_costs = Parameter(index=[time, region], unit = "\$")
    SAVE_savingsrate = Parameter(unit= "%")
    WINCF_weightsfactor =Parameter(index=[region], unit="")
    W_SatCalibrationSLR =Parameter()
    ipow_SLRImpactFxnExponent =Parameter()
    pow_SLRImpactFxnExponent=Parameter()
    iben_SLRInitialBenefit=Parameter()
    scal_calibrationSLR = Parameter()
    GDP_per_cap_focus_0_FocusRegionEU = Parameter()
    isat_0_InitialImpactFxnSaturation= Parameter()

    #component variables
    atl_adjustedtolerablelevelofsealevelrise = Variable(index=[time,region], unit="m")
    imp_actualreductionSLR = Variable(index=[time, region], unit="%")
    i_regionalimpactSLR = Variable(index=[time, region], unit="m")

    iref_ImpactatReferenceGDPperCapSLR = Variable(index=[time, region]) #variable or parameter?
    igdp_ImpactatActualGDPperCapSLR=Variable(index=[time, region])

    isat_ImpactinclSaturationandAdaptationSLR= Variable(index=[time,region])
    isatg_impactfxnsaturation = Variable()
    isat_per_cap_SLRImpactperCapinclSaturationandAdaptation = Variable(index=[time, region], unit="\$")

    rcons_per_cap_SLRRemainConsumption = Variable(index=[time, region], unit = "\$") #include?
    rgdp_per_cap_SLRRemainGDP = Variable(index=[time, region], unit = "\$") #include?
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
        if (p.y_year[t] - p.pstart_startdateofadaptpolicySLR[r]) < 0
            v.atl_adjustedtolerablelevelofsealevelrise[t,r]= 0
        elseif ((p.y_year[t]-p.pstart_startdateofadaptpolicySLR[r])/p.pyears_yearstilfulleffectSLR[r])<1.
            v.atl_adjustedtolerablelevelofsealevelrise[t,r]=
                ((p.y_year[t]-p.pstart_startdateofadaptpolicySLR[r])/p.pyears_yearstilfulleffectSLR[r]) * p.plateau_increaseintolerableplateaufromadaptationSLR[r]
        else
            v.atl_adjustedtolerablelevelofsealevelrise[t,r]=p.plateau_increaseintolerableplateaufromadaptationSLR[r]
        end

        if (p.y_year[t]- p.istart_startdateSLR[r]) < 0
            v.imp_actualreductionSLR[t,r] = 0.
        elseif ((p.y_year[t]-p.istart_startdateSLR[r])/p.iyears_yearstilfulleffectSLR[r]) < 1 #changed istart_a to istart_startdateSLR
            v.imp_actualreductionSLR[t,r] =
                (p.y_year[t]-p.istart_startdateSLR[r])/p.iyears_yearstilfulleffectSLR[r]*p.impred_eventualpercentreductionSLR[r]
        else
            v.imp_actualreductionSLR[t,r] = p.impred_eventualpercentreductionSLR[r]
        end

        if (p.s_sealevel[t]-v.atl_adjustedtolerablelevelofsealevelrise[t,r]) < 0
            v.i_regionalimpactSLR[t,r] = 0
        else
            v.i_regionalimpactSLR[t,r] = p.s_sealevel[t]-v.atl_adjustedtolerablelevelofsealevelrise[t,r]
        end

        v.iref_ImpactatReferenceGDPperCapSLR[t,r]= p.WINCF_weightsfactor[r]*((p.W_SatCalibrationSLR + p.iben_SLRInitialBenefit * p.scal_calibrationSLR)*
            (v.i_regionalimpactSLR[t,r]/p.scal_calibrationSLR)^p.pow_SLRImpactFxnExponent - v.i_regionalimpactSLR[t,r] * p.iben_SLRInitialBenefit)

        v.igdp_ImpactatActualGDPperCapSLR[t,r]= v.iref_ImpactatReferenceGDPperCapSLR[t,r]*
                (p.gdp_per_cap_after_costs[t,r]/p.GDP_per_cap_focus_0_FocusRegionEU)^p.ipow_SLRImpactFxnExponent

        if v.igdp_ImpactatActualGDPperCapSLR[t,r] < v.isatg_impactfxnsaturation
            v.isat_ImpactinclSaturationandAdaptationSLR[t,r] = v.igdp_ImpactatActualGDPperCapSLR[t,r]
        elseif v.i_regionalimpactSLR[t,r] < p.impmax_maxSLRforadaptpolicySLR[r]
            v.isat_ImpactinclSaturationandAdaptationSLR[t,r] = v.isatg_impactfxnsaturation+
                ((100-p.SAVE_savingsrate)-v.isatg_impactfxnsaturation)*
                ((v.igdp_ImpactatActualGDPperCapSLR[t,r]-v.isatg_impactfxnsaturation)/
                (((100-p.SAVE_savingsrate)-v.isatg_impactfxnsaturation)+
                (v.igdp_ImpactatActualGDPperCapSLR[t,r]- v.isatg_impactfxnsaturation)))*
                (1-v.imp_actualreductionSLR[t,r]/100)

        else
            v.isat_ImpactinclSaturationandAdaptationSLR[t,r] = v.isatg_impactfxnsaturation+
                ((100-p.SAVE_savingsrate)-v.isatg_impactfxnsaturation) *
                ((v.igdp_ImpactatActualGDPperCapSLR[t,r]-v.isatg_impactfxnsaturation)/
                (((100-p.SAVE_savingsrate)-v.isatg_impactfxnsaturation)+
                (v.igdp_ImpactatActualGDPperCapSLR[t,r] * v.isatg_impactfxnsaturation))) *
                (1-(v.imp_actualreductionSLR[t,r]/100)* p.impmax_maxSLRforadaptpolicySLR[r] /
                v.i_regionalimpactSLR[t,r])
        end

              v.isat_per_cap_SLRImpactperCapinclSaturationandAdaptation[t,r] = (v.isat_ImpactinclSaturationandAdaptationSLR[t,r]/100)*p.gdp_per_cap_after_costs[t,r]
              v.rcons_per_cap_SLRRemainConsumption[t,r] = p.cons_per_cap_AfterCosts[t,r] - v.isat_per_cap_SLRImpactperCapinclSaturationandAdaptation[t,r]
              v.rgdp_per_cap_SLRRemainGDP[t,r] = v.rcons_per_cap_SLRRemainConsumption[t,r]/(1-p.SAVE_savingsrate/100)

    end

end

function addslrdamages(model::Model)
    SLRDamagescomp = addcomponent(model, SLRDamages)

    SLRDamagescomp[:plateau_increaseintolerableplateaufromadaptationSLR] = readpagedata(model, "../data/sealevel_plateau.csv")
    SLRDamagescomp[:pstart_startdateofadaptpolicySLR] = readpagedata(model, "../data/sealeveladaptstart.csv")
    SLRDamagescomp[:pyears_yearstilfulleffectSLR] = readpagedata(model, "../data/sealeveladapttimetoeffect.csv")
    SLRDamagescomp[:impred_eventualpercentreductionSLR] = readpagedata(model, "../data/sealevelimpactreduction.csv")
    SLRDamagescomp[:impmax_maxSLRforadaptpolicySLR] = readpagedata(model, "../data/sealevelmaxrise.csv")
    SLRDamagescomp[:istart_startdateSLR] = readpagedata(model, "../data/sealeveladaptstart.csv")
    SLRDamagescomp[:iyears_yearstilfulleffectSLR] = readpagedata(model, "../data/sealevelimpactyearstoeffect.csv")
    SLRDamagescomp[:pow_SLRImpactFxnExponent] = 0.73
    SLRDamagescomp[:ipow_SLRImpactFxnExponent] = -0.30
    SLRDamagescomp[:iben_SLRInitialBenefit] = 0.00
    SLRDamagescomp[:scal_calibrationSLR] = 0.5


    return SLRDamagescomp
end
