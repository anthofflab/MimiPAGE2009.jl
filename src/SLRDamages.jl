using Mimi
include("load_parameters.jl")

@defcomp SLRDamages begin
    region = Index()

    y_year = Parameter(index=[time], unit="year")
    y_year_0 = Parameter(unit="year")

    #incoming parameters from SeaLevelRise
    s_sealevel = Parameter(index=[time, region], unit="m")

    #component parameters
    plateau_increaseintolerableplateaufromadaptationSLR = Parameter(index=[region], unit="m")
    pstart_startdateofadaptpolicySLR = Parameter(index=[region], unit="year")
    pyears_yearstilfulleffectSLR = Parameter(index=[region], unit="year")
    impred_eventualpercentreductionSLR = Parameter(index=[region], unit= "%")
    impmax_maxsealevelriseforadaptpolicySLR = Parameter(index=[region], unit= "m")
    impmax_maxtempriseforadaptpolicySLR = Parameter(index=[region], unit= "degreeC")
    istart_startdateSLR = Parameter(index=[region], unit = "year")
    iyears_yearstilfulleffectSLR = Parameter(index=[region], unit= "year")

    #pulled from non-SLR damages

    rcons_per_cap_AfterCosts = Parameter(index=[time, region], unit = "\$^m") #have this
    rgdp_per_cap_SLRRemainGDP = Parameter(index=[time, region], unit = "\$^m") #have this
    SAVE_savingsrate = Parameter(unit= "%") #have this
    WINCF_weightsfactor =Parameter(index=[region], unit="")
    W_NonImpactsatCalibrationTemp =Parameter()
    W_NonImpactsatCalibrationDISQ = Parameter()
    ipow_SLRImpactFxnExponent =Parameter()
    pow_SLRImpactFxnExponent=Parameter()
    iben_SLRInitialBenefit=Parameter()
    tcal_CalibrationTemp = Parameter()
    GDP_per_cap_focus_0_FocusRegionEU = Parameter()
    isat_0_InitialImpactFxnSaturation= Parameter()

    #component variables
    atl_adjustedtolerablelevelofsealevelrise = Variable(index=[time,region], unit="m")
    imp_actualreduction = Variable(index=[time, region], unit="%")
    i_regionalimpactSLR = Variable(index=[time, region], unit="m")

    iref_ImpactatReferenceGDPperCap = Variable(index=[time, region]) #variable or parameter?
    igdp_ImpactatActualGDPperCap=Variable(index=[time, region])

    isat_ImpactinclSaturationandAdaptation= Variable(index=[time,region])
    isatg_impactfxnsaturation = Variable()
    isat_per_cap_SLRImpactperCapinclSaturationandAdaptation = Variable(index=[time, region], unit="\$^m")

    rcons_per_cap_SLRRemainConsumption = Variable(index=[time, region], unit = "\$^m")
    rgdp_per_cap_SLRRemainGDP = Variable(index=[time, region], unit = "\$^m")
end

function run_timestep(s::SLRDamages, t::Int64)
    v = s.Variables
    p = s.Parameters
    d = s.Dimensions

    println("Timestep ")
    for r in d.region
        if (p.y_year[t] - p.pstart_startdateofadaptpolicySLR[r]) < 0
            v.atl_adjustedtolerablelevelofsealevelrise[t,r]= 0
        elseif ((p.y_year[t]-p.pstart_startdateofadaptpolicySLR[r])/p.pyears_yearstilfulleffectSLR[r])<1.
            v.atl_adjustedtolerablelevelofsealevelrise[t,r]=
                ((p.y_year[t]-p.pstart_startdateofadaptpolicySLR[r])/p.pyears_yearstilfulleffectSLR[r]) * p.plateau_increaseintolerableplateaufromadaptationSLR[r]
        else
            p.plateau_increaseintolerableplateaufromadaptationSLR[r] #not quite sure what this is doing
        end

        if (p.y_year[t]- p.istart_startdateSLR[r]) < 0
            v.imp_actualreduction[t,r] = 0.
        elseif ((p.y_year[t]-p.istart_startdateSLR[r])/p.iyears_yearstilfulleffectSLR[r]) < 1 #changed istart_a to istart_startdateSLR
            v.imp_actualreduction[t,r] =
                (p.y_year[t]-p.istart_startdateSLR[r])/p.iyears_yearstilfulleffectSLR[r]*p.impred_eventualpercentreductionSLR[r]
                println("I tripped the first else if")
                println(v.imp_actualreduction[t,r])
        else
            v.imp_actualreduction[t,r] = p.impred_eventualpercentreductionSLR[r]
            println("I tripped the second else if")
            println(v.imp_actualreduction[t,r])
        end

        #println("Hello world")
        if (p.s_sealevel[t,r]-v.atl_adjustedtolerablelevelofsealevelrise[t,r]) < 0
            v.i_regionalimpactSLR[t,r] = 0
        else
            v.i_regionalimpactSLR[t,r] = p.s_sealevel[t,r]-v.atl_adjustedtolerablelevelofsealevelrise[t,r]
        end

        v.iref_ImpactatReferenceGDPperCap[t,r]= p.WINCF_weightsfactor[r]*((p.W_NonImpactsatCalibrationTemp + p.iben_SLRInitialBenefit * p.tcal_CalibrationTemp)*
            (v.i_regionalimpactSLR[t,r]/p.tcal_CalibrationTemp)^p.pow_SLRImpactFxnExponent - v.i_regionalimpactSLR[t,r] * p.iben_SLRInitialBenefit)

        v.igdp_ImpactatActualGDPperCap[t,r]= v.iref_ImpactatReferenceGDPperCap[t,r]*
                (p.rgdp_per_cap_SLRRemainGDP[t,r]/p.GDP_per_cap_focus_0_FocusRegionEU)^p.ipow_SLRImpactFxnExponent

        v.isatg_impactfxnsaturation= p.isat_0_InitialImpactFxnSaturation * (1 - p.SAVE_savingsrate/100)
                println(v.imp_actualreduction[t,r])
                if v.igdp_ImpactatActualGDPperCap[t,r] < v.isatg_impactfxnsaturation
                    v.isat_ImpactinclSaturationandAdaptation[t,r] = v.igdp_ImpactatActualGDPperCap[t,r]
                elseif v.i_regionalimpactSLR[t,r] < p.impmax_maxtempriseforadaptpolicySLR[r]
                    v.isat_ImpactinclSaturationandAdaptation[t,r] = v.isatg_impactfxnsaturation+
                        ((100-p.SAVE_savingsrate)-v.isatg_impactfxnsaturation)*
                        ((v.igdp_ImpactatActualGDPperCap[t,r]-v.isatg_impactfxnsaturation)/
                        (((100-p.SAVE_savingsrate)-v.isatg_impactfxnsaturation)+
                        (v.igdp_ImpactatActualGDPperCap[t,r]*
                        v.isatg_impactfxnsaturation)))*
                        (1-v.imp_actualreduction[t,r]/100)

                else
                    v.isat_ImpactinclSaturationandAdaptation[t,r] = v.isatg_impactfxnsaturation+
                        ((100-p.SAVE_savingsrate)-v.isatg_impactfxnsaturation) *
                        ((v.igdp_ImpactatActualGDPperCap[t,r]-v.isatg_impactfxnsaturation)/
                        (((100-p.SAVE_savingsrate)-v.isatg_impactfxnsaturation)+
                        (v.igdp_ImpactatActualGDPperCap[t,r] * v.isatg_impactfxnsaturation))) *
                        (1-(v.imp_actualreduction[t,r]/100)* p.impmax_maxsealevelriseforadaptpolicySLR[r] /
                        v.i_regionalimpactSLR[t,r])
                end

              v.isat_per_cap_SLRImpactperCapinclSaturationandAdaptation[t,r] = (v.isat_ImpactinclSaturationandAdaptation[t,r]/100)*p.rgdp_per_cap_SLRRemainGDP[t,r]
              v.rcons_per_cap_SLRRemainConsumption[t,r] = p.rcons_per_cap_AfterCosts[t,r] - v.isat_per_cap_SLRImpactperCapinclSaturationandAdaptation[t,r]
              v.rgdp_per_cap_SLRRemainGDP[t,r] = v.rcons_per_cap_SLRRemainConsumption[t,r]/(1-p.SAVE_savingsrate/100)

    end

end

function addslrdamages(model::Model)
    SLRDamagescomp = addcomponent(model, SLRDamages)

    SLRDamagescomp[:plateau_increaseintolerableplateaufromadaptationSLR] = readpagedata(model, "../data/sealevel_plateau.csv")
    SLRDamagescomp[:pstart_startdateofadaptpolicySLR] = readpagedata(model, "../data/sealeveladaptstart.csv")
    SLRDamagescomp[:pyears_yearstilfulleffectSLR] = readpagedata(model, "../data/sealeveladapttimetoeffect.csv")
    SLRDamagescomp[:impred_eventualpercentreductionSLR] = readpagedata(model, "../data/sealevelimpactreduction.csv")
    SLRDamagescomp[:impmax_maxsealevelriseforadaptpolicySLR] = readpagedata(model, "../data/sealevelmaxrise.csv")
    SLRDamagescomp[:istart_startdateSLR] = readpagedata(model, "../data/sealeveladaptstart.csv")
    SLRDamagescomp[:iyears_yearstilfulleffectSLR] = readpagedata(model, "../data/sealevelimpactyearstoeffect.csv")
    SLRDamagescomp[:pow_SLRImpactFxnExponent] = 0.73
    SLRDamagescomp[:ipow_SLRImpactFxnExponent] = -0.30
    SLRDamagescomp[:iben_SLRInitialBenefit] = 0.00


    return SLRDamagescomp
end
