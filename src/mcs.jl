using Mimi
using Distributions

include("getpagefunction.jl")
m = getpage() 
run(m)

mcs = @defmcs begin
    
    #Define random variables (RVs)
    using Distributions
    
    #TODO:  is there a way to specificy parameters by component, or do we need all
    # component parameters to have distinct names (seems smart to enforce this
    # in general)
    
    # TODO:  In a few places, a parameter is randomized twice with the same values, 
    # once in each component.  Organization wise for PAGE, it may make sense to
    # keep them this way, however we should consider if this repetition is the right
    # approach within this MCS framework.  
    
    # CO2cycle
    air_CO2fractioninatm = TriangularDist(57, 67, 62)
    res_CO2atmlifetime = TriangularDist(50, 100, 70)
    ccf_CO2feedback = TriangularDist(4, 15, 10)
    ccfmax_maxCO2feedback = TriangularDist(30, 80, 50)
    stay_fractionCO2emissionsinatm = TriangularDist(0.25,0.35,0.3)
    
    
    # SulphateForcing
    d_sulphateforcingbase = TriangularDist(-0.8, -0.2, -0.4)
    ind_slopeSEforcing_indirect = TriangularDist(-0.8, 0, -0.4)
    
    
    # ClimateTemperature
    rlo_ratiolandocean = TriangularDist(1.2, 1.6, 1.4)
    pole_polardifference = TriangularDist(1, 2, 1.5)
    frt_warminghalflife = TriangularDist(10, 65, 30)
    tcr_transientresponse = TriangularDist(1, 2.8, 1.3)
    
    
    # SeaLevelRise
    s0_initialSL = TriangularDist(0.1, 0.2, 0.15)
    sltemp_SLtemprise = TriangularDist(0.7, 3., 1.5)
    sla_SLbaselinerise = TriangularDist(0.5, 1.5, 1.)
    sltau_SLresponsetime = TriangularDist(500, 1500, 1000)
    
    
    # GDP
    save_savingsrate = TriangularDist(10, 20, 15)
    isat0_initialimpactfxnsaturation = TriangularDist(20, 50, 30)
    
    
    # MarketDamages
    tcal_CalibrationTemp = TriangularDist(2.5, 3.5, 3.)
    iben_MarketInitialBenefit = TriangularDist(0, .3, .1)
    W_MarketImpactsatCalibrationTemp = TriangularDist(.2, .8, .5)
    pow_MarketImpactExponent = TriangularDist(1.5, 3, 2)
    ipow_MarketIncomeFxnExponent = TriangularDist(-.3, 0, -.1)
    save_savingsrate = TriangularDist(10, 20, 15)
    #TODO is this the right way to set the array?
    wincf_weightsfactor = [1.0,
             TriangularDist(.6, 1, .8),
             TriangularDist(.4, 1.2, .8),
             TriangularDist(.2, .6, .4),
             TriangularDist(.4, 1.2, .8),
             TriangularDist(.4, 1.2, .8),
             TriangularDist(.4, .8, .6),
             TriangularDist(.4, .8, .6)] 
    
    
    # NonMarketDamages
    tcal_CalibrationTemp = TriangularDist(2.5, 3.5, 3.)
    iben_NonMarketInitialBenefit = TriangularDist(0, .2, .05)
    w_NonImpactsatCalibrationTemp = TriangularDist(.1, 1, .5)
    pow_NonMarketExponent = TriangularDist(1.5, 3, 2)
    ipow_NonMarketIncomeFxnExponent = TriangularDist(-.2, .2, 0)
    
    #repeat randomization: Also randomized in GDP and SLRDamages and Market Damages
    save_savingsrate = TriangularDist(10, 20, 15)
    wincf_weightsfactor = [1.0,
            TriangularDist(.6, 1, .8),
            TriangularDist(.4, 1.2, .8),
            TriangularDist(.2, .6, .4),
            TriangularDist(.4, 1.2, .8),
            TriangularDist(.4, 1.2, .8),
            TriangularDist(.4, .8, .6),
            TriangularDist(.4, .8, .6)]
    
    
    # SLRDamages
    save_savingsrate = TriangularDist(10, 20, 15)
    scal_calibrationSLR = TriangularDist(0.45, 0.55, .5)
    #iben_SLRInitialBenefit = TriangularDist(0, 0, 0) # only usable if lb <> ub
    W_SatCalibrationSLR = TriangularDist(.5, 1.5, 1)
    pow_SLRImpactFxnExponent = TriangularDist(.5, 1, .7)
    ipow_SLRIncomeFxnExponent = TriangularDist(-.4, -.2, -.3)
    
    # repeat randomization
    wincf_weightsfactor = [1.0,
            TriangularDist(.6, 1, .8),
            TriangularDist(.4, 1.2, .8),
            TriangularDist(.2, .6, .4),
            TriangularDist(.4, 1.2, .8),
            TriangularDist(.4, 1.2, .8),
            TriangularDist(.4, .8, .6),
            TriangularDist(.4, .8, .6)]
    
    
    # Discountinuity
    rand_discontinuity = Uniform(0, 1)
    tdis_tolerabilitydisc = TriangularDist(2, 4, 3)
    pdis_probability = TriangularDist(10, 30, 20)
    wdis_gdplostdisc = TriangularDist(5, 25, 15)
    ipow_incomeexponent = TriangularDist(-.3, 0, -.1)
    distau_discontinuityexponent = TriangularDist(20, 200, 50)
    
    # repeat randomization
    wincf_weightsfactor = [1.0,
            TriangularDist(.6, 1, .8),
            TriangularDist(.4, 1.2, .8),
            TriangularDist(.2, .6, .4),
            TriangularDist(.4, 1.2, .8),
            TriangularDist(.4, 1.2, .8),
            TriangularDist(.4, .8, .6),
            TriangularDist(.4, .8, .6)]
    
    
    # EquityWeighting
    civvalue_civilizationvalue = TriangularDist(1e10, 1e11, 5e10)
    ptp_timepreference = TriangularDist(0.1,2,1)
    emuc_utilityconvexity = TriangularDist(0.5,2,1)
    
    
    # AbatementCosts
    AbatementCostsCO2_emit_UncertaintyinBAUEmissFactorinFocusRegioninFinalYear = TriangularDist(-50,75,0)
    AbatementCostsCH4_emit_UncertaintyinBAUEmissFactorinFocusRegioninFinalYear = TriangularDist(-25,100,0)
    AbatementCostsN2O_emit_UncertaintyinBAUEmissFactorinFocusRegioninFinalYear = TriangularDist(-50,50,0)
    AbatementCostsLin_emit_UncertaintyinBAUEmissFactorinFocusRegioninFinalYear = TriangularDist(-50,50,0)
    
    AbatementCostsCO2_q0propinit_CutbacksinNegativeCostinFocusRegioninBaseYear = TriangularDist(0,40,20)
    AbatementCostsCH4_q0propinit_CutbacksinNegativeCostinFocusRegioninBaseYear = TriangularDist(0,20,10)
    AbatementCostsN2O_q0propinit_CutbacksinNegativeCostinFocusRegioninBaseYear = TriangularDist(0,20,10)
    AbatementCostsLin_q0propinit_CutbacksinNegativeCostinFocusRegioninBaseYear = TriangularDist(0,20,10)
    
    AbatementCostsCO2_c0init_MostNegativeCostCutbackinBaseYear = TriangularDist(-400,-100,-200)
    AbatementCostsCH4_c0init_MostNegativeCostCutbackinBaseYear = TriangularDist(-8000,-1000,-4000)
    AbatementCostsN2O_c0init_MostNegativeCostCutbackinBaseYear = TriangularDist(-15000,0,-7000)
    AbatementCostsLin_c0init_MostNegativeCostCutbackinBaseYear = TriangularDist(-400,-100,-200)
    
    AbatementCostsCO2_qmaxminusq0propinit_MaxCutbackCostatPositiveCostinBaseYear = TriangularDist(60,80,70)
    AbatementCostsCH4_qmaxminusq0propinit_MaxCutbackCostatPositiveCostinBaseYear = TriangularDist(35,70,50)
    AbatementCostsN2O_qmaxminusq0propinit_MaxCutbackCostatPositiveCostinBaseYear = TriangularDist(35,70,50)
    AbatementCostsLin_qmaxminusq0propinit_MaxCutbackCostatPositiveCostinBaseYear = TriangularDist(60,80,70)
    
    AbatementCostsCO2_cmaxinit_MaximumCutbackCostinFocusRegioninBaseYear = TriangularDist(100,700,400)
    AbatementCostsCH4_cmaxinit_MaximumCutbackCostinFocusRegioninBaseYear = TriangularDist(3000,10000,6000)
    AbatementCostsN2O_cmaxinit_MaximumCutbackCostinFocusRegioninBaseYear = TriangularDist(2000,60000,20000)
    AbatementCostsLin_cmaxinit_MaximumCutbackCostinFocusRegioninBaseYear = TriangularDist(100,600,300)
    
    AbatementCostsCO2_ies_InitialExperienceStockofCutbacks = TriangularDist(100000,200000,150000)
    AbatementCostsCH4_ies_InitialExperienceStockofCutbacks = TriangularDist(1500,2500,2000)
    AbatementCostsN2O_ies_InitialExperienceStockofCutbacks = TriangularDist(30,80,50)
    AbatementCostsLin_ies_InitialExperienceStockofCutbacks = TriangularDist(1500,2500,2000)
    
    #the following variables need to be randomized, but set the same in all 4 abatement cost components
    #note that for these regional variables, the first region is the focus region (EU), which is randomized in the preceding code, and so is always one for these variables
    #TODO:  is this the right way to be creating arrays?
    emitf_uncertaintyinBAUemissfactor = 
            [1,
            TriangularDist(0.8,1.2,1.0),
            TriangularDist(0.8,1.2,1.0),
            TriangularDist(0.65,1.35,1.0),
            TriangularDist(0.5,1.5,1.0),
            TriangularDist(0.5,1.5,1.0),
            TriangularDist(0.5,1.5,1.0),
            TriangularDist(0.5,1.5,1.0)]
    
    q0f_negativecostpercentagefactor =
            [1,
            TriangularDist(0.75,1.5,1.0),
            TriangularDist(0.75,1.25,1.0),
            TriangularDist(0.4,1.0,0.7),       
            TriangularDist(0.4,1.0,0.7),
            TriangularDist(0.4,1.0,0.7),
            TriangularDist(0.4,1.0,0.7),
            TriangularDist(0.4,1.0,0.7)]
    
    cmaxf_maxcostfactor = 
            [1,
            TriangularDist(0.8,1.2,1.0),
            TriangularDist(1.0,1.5,1.2),
            TriangularDist(0.4,1.0,0.7),
            TriangularDist(0.8,1.2,1.0),
            TriangularDist(1,1.5,1.2),
            TriangularDist(1,1.5,1.2),
            TriangularDist(0.4,1.0,0.7)]
    
    q0propmult_cutbacksatnegativecostinfinalyear = TriangularDist(0.3,1.2,0.7)
    qmax_minus_q0propmult_maxcutbacksatpositivecostinfinalyear = TriangularDist(1,1.5,1.3)
    c0mult_mostnegativecostinfinalyear = TriangularDist(0.5,1.2,0.8)
    curve_below_curvatureofMACcurvebelowzerocost = TriangularDist(0.25,0.8,0.45)
    curve_above_curvatureofMACcurveabovezerocost = TriangularDist(0.1,0.7,0.4)
    cross_experiencecrossoverratio = TriangularDist(0.1,0.3,0.2)
    learn_learningrate = TriangularDist(0.05,0.35,0.2)
    automult_autonomoustechchange = TriangularDist(0.5,0.8,0.65)
    
    
    # AdaptationCosts
    AdaptiveCostsSeaLevel_cp_costplateau_eu = TriangularDist(0.01, 0.04, 0.02)
    AdaptiveCostsSeaLevel_ci_costimpact_eu = TriangularDist(0.0005, 0.002, 0.001)
    AdaptiveCostsEconomic_cp_costplateau_eu = TriangularDist(0.005, 0.02, 0.01)
    AdaptiveCostsEconomic_ci_costimpact_eu = TriangularDist(0.001, 0.008, 0.003)
    AdaptiveCostsNonEconomic_cp_costplateau_eu = TriangularDist(0.01, 0.04, 0.02)
    AdaptiveCostsNonEconomic_ci_costimpact_eu = TriangularDist(0.002, 0.01, 0.005)
    
    #TODO is this the right way to set the array?
    cf_costregional = 
        [1., 
        TriangularDist(0.6, 1, 0.8),
        TriangularDist(0.4, 1.2, 0.8),
        TriangularDist(0.2, 0.6, 0.4),
        TriangularDist(0.4, 1.2, 0.8),
        TriangularDist(0.4, 1.2, 0.8),
        TriangularDist(0.4, 0.8, 0.6),
        TriangularDist(0.4, 0.8, 0.6)]
    
    # repeat randomization: Note - this parameter also randomized in Abatement Costs
    automult_autonomouschange = TriangularDist(0.5, 0.8, 0.65)    

    # indicate which parameters to save for each model run
    # TODO:  are data slices supported yet?  If not we can do the data slicing
    # afterwards
    save(EquityWeighting.td_totaldiscountedimpacts,
        EquityWeighting.tpc_totalaggregatedcosts, 
        EquityWeighting.tac_totaladaptationcosts,
        EquityWeighting.te_totaleffect,
        co2cycle.c_CO2concentration[10], 
        TotalForcing.ft_totalforcing[10],
        ClimateTemperature.rt_g_globaltemperature[10],
        SeaLevelRise.s_sealevel[10],
        SLRDamages.rgdp_per_cap_SLRRemainGDP[10,8],
        MarketDamages.rgdp_per_cap_MarketRemainGDP[10,8],
        NonMarketDamages.rgdp_per_cap_NonMarketRemainGDP[10,8],
        Discontinuity.rgdp_per_cap_NonMarketRemainGDP[10,8])

end 

# Generate trial data for all RVs and save to a file
# TODO:  see montecarlo.jl for how outputs were formatted, including a dataframe
# and renaming the parameters ... do we want to do that here?  If so, look at best
# way to do so
function do_montecarlo_runs(samplesize::Int)
    generate_trials!(mcs, samplesize, joinpath(@__DIR__, "../output/mimipagemontecarlooutput.csv"))
end
