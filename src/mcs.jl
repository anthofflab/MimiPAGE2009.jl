using Distributions
using CSVFiles
using DataFrames

function getsim()
        mcs = @defsim begin
                
                ############################################################################
                # Define random variables (RVs) - for UNSHARED parameters
                ############################################################################

                # each component should have the same value for its save_savingsrate,
                # so we use an RV here because in the model this is not an explicitly
                # shared parameter, then assign to components
                rv(RV_save_savingsrate) = TriangularDist(10, 20, 15)
                GDP.save_savingsrate = RV_save_savingsrate
                MarketDamages.save_savingsrate = RV_save_savingsrate
                NonMarketDamages.save_savingsrate = RV_save_savingsrate
                SLRDamages.save_savingsrate = RV_save_savingsrate

                # each component should have the same value for its tcal_CalibrationTemp
                # so we use an RV here because in the model this is not an explicitly
                # shared parameter, then assign to components
                rv(RV_tcal_CalibrationTemp) = TriangularDist(2.5, 3.5, 3.)
                MarketDamages.tcal_CalibrationTemp = RV_tcal_CalibrationTemp
                NonMarketDamages.tcal_CalibrationTemp = RV_tcal_CalibrationTemp

                # CO2cycle
                co2cycle.air_CO2fractioninatm = TriangularDist(57, 67, 62)
                co2cycle.res_CO2atmlifetime = TriangularDist(50, 100, 70)
                co2cycle.ccf_CO2feedback = TriangularDist(4, 15, 10)
                co2cycle.ccfmax_maxCO2feedback = TriangularDist(30, 80, 50)
                co2cycle.stay_fractionCO2emissionsinatm = TriangularDist(0.25,0.35,0.3)
                
                # SulphateForcing
                SulphateForcing.d_sulphateforcingbase = TriangularDist(-0.8, -0.2, -0.4)
                SulphateForcing.ind_slopeSEforcing_indirect = TriangularDist(-0.8, 0, -0.4)
                
                # ClimateTemperature
                ClimateTemperature.rlo_ratiolandocean = TriangularDist(1.2, 1.6, 1.4)
                ClimateTemperature.pole_polardifference = TriangularDist(1, 2, 1.5)
                ClimateTemperature.frt_warminghalflife = TriangularDist(10, 65, 30)
                ClimateTemperature.tcr_transientresponse = TriangularDist(1, 2.8, 1.3)
                
                # SeaLevelRise
                SeaLevelRise.s0_initialSL = TriangularDist(0.1, 0.2, 0.15)
                SeaLevelRise.sltemp_SLtemprise = TriangularDist(0.7, 3., 1.5)
                SeaLevelRise.sla_SLbaselinerise = TriangularDist(0.5, 1.5, 1.)
                SeaLevelRise.sltau_SLresponsetime = TriangularDist(500, 1500, 1000)
                
                # GDP
                GDP.isat0_initialimpactfxnsaturation = TriangularDist(20, 50, 30) 
                
                # MarketDamages
                MarketDamages.iben_MarketInitialBenefit = TriangularDist(0, .3, .1)
                MarketDamages.W_MarketImpactsatCalibrationTemp = TriangularDist(.2, .8, .5)
                MarketDamages.pow_MarketImpactExponent = TriangularDist(1.5, 3, 2)
                MarketDamages.ipow_MarketIncomeFxnExponent = TriangularDist(-.3, 0, -.1)

                # NonMarketDamages
                NonMarketDamages.iben_NonMarketInitialBenefit = TriangularDist(0, .2, .05)
                NonMarketDamages.w_NonImpactsatCalibrationTemp = TriangularDist(.1, 1, .5)
                NonMarketDamages.pow_NonMarketExponent = TriangularDist(1.5, 3, 2)
                NonMarketDamages.ipow_NonMarketIncomeFxnExponent = TriangularDist(-.2, .2, 0)
                
                # SLRDamages
                SLRDamages.scal_calibrationSLR = TriangularDist(0.45, 0.55, .5)
                #SLRDamages.iben_SLRInitialBenefit = TriangularDist(0, 0, 0) # only usable if lb <> ub
                SLRDamages.W_SatCalibrationSLR = TriangularDist(.5, 1.5, 1)
                SLRDamages.pow_SLRImpactFxnExponent = TriangularDist(.5, 1, .7)
                SLRDamages.ipow_SLRIncomeFxnExponent = TriangularDist(-.4, -.2, -.3)
                
                # Discontinuity
                Discontinuity.rand_discontinuity = Uniform(0, 1)
                Discontinuity.tdis_tolerabilitydisc = TriangularDist(2, 4, 3)
                Discontinuity.pdis_probability = TriangularDist(10, 30, 20)
                Discontinuity.wdis_gdplostdisc = TriangularDist(5, 25, 15)
                Discontinuity.ipow_incomeexponent = TriangularDist(-.3, 0, -.1)
                Discontinuity.distau_discontinuityexponent = TriangularDist(20, 200, 50)
                
                # EquityWeighting
                EquityWeighting.civvalue_civilizationvalue = TriangularDist(1e10, 1e11, 5e10)
                EquityWeighting.ptp_timepreference = TriangularDist(0.1,2,1)
                EquityWeighting.emuc_utilityconvexity = TriangularDist(0.5,2,1)
                
                ############################################################################
                # Define random variables (RVs) - for SHARED parameters
                ############################################################################

                # shared parameter linked to components: MarketDamages, NonMarketDamages, 
                # SLRDamages, Discountinuity
                wincf_weightsfactor["USA"] = TriangularDist(.6, 1, .8) 
                wincf_weightsfactor["OECD"] = TriangularDist(.4, 1.2, .8)
                wincf_weightsfactor["USSR"] = TriangularDist(.2, .6, .4)
                wincf_weightsfactor["China"] = TriangularDist(.4, 1.2, .8)
                wincf_weightsfactor["SEAsia"] = TriangularDist(.4, 1.2, .8)
                wincf_weightsfactor["Africa"] = TriangularDist(.4, .8, .6)
                wincf_weightsfactor["LatAmerica"] = TriangularDist(.4, .8, .6)

                # shared parameter linked to components: AdaptationCosts, AbatementCosts
                automult_autonomouschange = TriangularDist(0.5, 0.8, 0.65)  

                #the following variables need to be set, but set the same in all 4 abatement cost components
                #note that for these regional variables, the first region is the focus region (EU), which is set in the preceding code, and so is always one for these variables
                
                emitf_uncertaintyinBAUemissfactor["USA"] = TriangularDist(0.8,1.2,1.0)
                emitf_uncertaintyinBAUemissfactor["OECD"] = TriangularDist(0.8,1.2,1.0)
                emitf_uncertaintyinBAUemissfactor["USSR"] = TriangularDist(0.65,1.35,1.0)
                emitf_uncertaintyinBAUemissfactor["China"] = TriangularDist(0.5,1.5,1.0)
                emitf_uncertaintyinBAUemissfactor["SEAsia"] = TriangularDist(0.5,1.5,1.0)
                emitf_uncertaintyinBAUemissfactor["Africa"] = TriangularDist(0.5,1.5,1.0)
                emitf_uncertaintyinBAUemissfactor["LatAmerica"] = TriangularDist(0.5,1.5,1.0)
                
                q0f_negativecostpercentagefactor["USA"] = TriangularDist(0.75,1.5,1.0)
                q0f_negativecostpercentagefactor["OECD"] = TriangularDist(0.75,1.25,1.0)
                q0f_negativecostpercentagefactor["USSR"] = TriangularDist(0.4,1.0,0.7)      
                q0f_negativecostpercentagefactor["China"] = TriangularDist(0.4,1.0,0.7)
                q0f_negativecostpercentagefactor["SEAsia"] = TriangularDist(0.4,1.0,0.7)
                q0f_negativecostpercentagefactor["Africa"] = TriangularDist(0.4,1.0,0.7)
                q0f_negativecostpercentagefactor["LatAmerica"] = TriangularDist(0.4,1.0,0.7)
                
                cmaxf_maxcostfactor["USA"] = TriangularDist(0.8,1.2,1.0)
                cmaxf_maxcostfactor["OECD"] = TriangularDist(1.0,1.5,1.2)
                cmaxf_maxcostfactor["USSR"] = TriangularDist(0.4,1.0,0.7)
                cmaxf_maxcostfactor["China"] = TriangularDist(0.8,1.2,1.0)
                cmaxf_maxcostfactor["SEAsia"] = TriangularDist(1,1.5,1.2)
                cmaxf_maxcostfactor["Africa"] = TriangularDist(1,1.5,1.2)
                cmaxf_maxcostfactor["LatAmerica"] = TriangularDist(0.4,1.0,0.7)
                
                cf_costregional["USA"] = TriangularDist(0.6, 1, 0.8)
                cf_costregional["OECD"] = TriangularDist(0.4, 1.2, 0.8)
                cf_costregional["USSR"] = TriangularDist(0.2, 0.6, 0.4)
                cf_costregional["China"] = TriangularDist(0.4, 1.2, 0.8)
                cf_costregional["SEAsia"] = TriangularDist(0.4, 1.2, 0.8)
                cf_costregional["Africa"] = TriangularDist(0.4, 0.8, 0.6)
                cf_costregional["LatAmerica"] = TriangularDist(0.4, 0.8, 0.6)

                # Other
                q0propmult_cutbacksatnegativecostinfinalyear = TriangularDist(0.3,1.2,0.7)
                qmax_minus_q0propmult_maxcutbacksatpositivecostinfinalyear = TriangularDist(1,1.5,1.3)
                c0mult_mostnegativecostinfinalyear = TriangularDist(0.5,1.2,0.8)
                curve_below_curvatureofMACcurvebelowzerocost = TriangularDist(0.25,0.8,0.45)
                curve_above_curvatureofMACcurveabovezerocost = TriangularDist(0.1,0.7,0.4)
                cross_experiencecrossoverratio = TriangularDist(0.1,0.3,0.2)
                learn_learningrate = TriangularDist(0.05,0.35,0.2)

                # NOTE: the below can probably be resolved into unique, unshared parameters with the same name
                # in the new Mimi paradigm of shared and unshared parameters, but for now this will 
                # continue to work!

                # AbatementCosts
                AbatementCostParametersCO2_emit_UncertaintyinBAUEmissFactorinFocusRegioninFinalYear = TriangularDist(-50,75,0)
                AbatementCostParametersCH4_emit_UncertaintyinBAUEmissFactorinFocusRegioninFinalYear = TriangularDist(-25,100,0)
                AbatementCostParametersN2O_emit_UncertaintyinBAUEmissFactorinFocusRegioninFinalYear = TriangularDist(-50,50,0)
                AbatementCostParametersLin_emit_UncertaintyinBAUEmissFactorinFocusRegioninFinalYear = TriangularDist(-50,50,0)
                
                AbatementCostParametersCO2_q0propinit_CutbacksinNegativeCostinFocusRegioninBaseYear = TriangularDist(0,40,20)
                AbatementCostParametersCH4_q0propinit_CutbacksinNegativeCostinFocusRegioninBaseYear = TriangularDist(0,20,10)
                AbatementCostParametersN2O_q0propinit_CutbacksinNegativeCostinFocusRegioninBaseYear = TriangularDist(0,20,10)
                AbatementCostParametersLin_q0propinit_CutbacksinNegativeCostinFocusRegioninBaseYear = TriangularDist(0,20,10)
                
                AbatementCostParametersCO2_c0init_MostNegativeCostCutbackinBaseYear = TriangularDist(-400,-100,-200)
                AbatementCostParametersCH4_c0init_MostNegativeCostCutbackinBaseYear = TriangularDist(-8000,-1000,-4000)
                AbatementCostParametersN2O_c0init_MostNegativeCostCutbackinBaseYear = TriangularDist(-15000,0,-7000)
                AbatementCostParametersLin_c0init_MostNegativeCostCutbackinBaseYear = TriangularDist(-400,-100,-200)
                
                AbatementCostParametersCO2_qmaxminusq0propinit_MaxCutbackCostatPositiveCostinBaseYear = TriangularDist(60,80,70)
                AbatementCostParametersCH4_qmaxminusq0propinit_MaxCutbackCostatPositiveCostinBaseYear = TriangularDist(35,70,50)
                AbatementCostParametersN2O_qmaxminusq0propinit_MaxCutbackCostatPositiveCostinBaseYear = TriangularDist(35,70,50)
                AbatementCostParametersLin_qmaxminusq0propinit_MaxCutbackCostatPositiveCostinBaseYear = TriangularDist(60,80,70)
                
                AbatementCostParametersCO2_cmaxinit_MaximumCutbackCostinFocusRegioninBaseYear = TriangularDist(100,700,400)
                AbatementCostParametersCH4_cmaxinit_MaximumCutbackCostinFocusRegioninBaseYear = TriangularDist(3000,10000,6000)
                AbatementCostParametersN2O_cmaxinit_MaximumCutbackCostinFocusRegioninBaseYear = TriangularDist(2000,60000,20000)
                AbatementCostParametersLin_cmaxinit_MaximumCutbackCostinFocusRegioninBaseYear = TriangularDist(100,600,300)
                
                AbatementCostParametersCO2_ies_InitialExperienceStockofCutbacks = TriangularDist(100000,200000,150000)
                AbatementCostParametersCH4_ies_InitialExperienceStockofCutbacks = TriangularDist(1500,2500,2000)
                AbatementCostParametersN2O_ies_InitialExperienceStockofCutbacks = TriangularDist(30,80,50)
                AbatementCostParametersLin_ies_InitialExperienceStockofCutbacks = TriangularDist(1500,2500,2000)

                # AdaptationCosts
                AdaptiveCostsSeaLevel_cp_costplateau_eu = TriangularDist(0.01, 0.04, 0.02)
                AdaptiveCostsSeaLevel_ci_costimpact_eu = TriangularDist(0.0005, 0.002, 0.001)
                AdaptiveCostsEconomic_cp_costplateau_eu = TriangularDist(0.005, 0.02, 0.01)
                AdaptiveCostsEconomic_ci_costimpact_eu = TriangularDist(0.001, 0.008, 0.003)
                AdaptiveCostsNonEconomic_cp_costplateau_eu = TriangularDist(0.01, 0.04, 0.02)
                AdaptiveCostsNonEconomic_ci_costimpact_eu = TriangularDist(0.002, 0.01, 0.005)

                ############################################################################
                # Indicate which parameters to save for each model run
                ############################################################################
                
                save(EquityWeighting.td_totaldiscountedimpacts,
                        EquityWeighting.tpc_totalaggregatedcosts, 
                        EquityWeighting.tac_totaladaptationcosts,
                        EquityWeighting.te_totaleffect,
                        co2cycle.c_CO2concentration, 
                        TotalForcing.ft_totalforcing,
                        ClimateTemperature.rt_g_globaltemperature,
                        SeaLevelRise.s_sealevel,
                        SLRDamages.rgdp_per_cap_SLRRemainGDP,
                        MarketDamages.rgdp_per_cap_MarketRemainGDP,
                        NonMarketDamages.rgdp_per_cap_NonMarketRemainGDP,
                        Discontinuity.rgdp_per_cap_NonMarketRemainGDP)

                end #def
        return mcs 
end

#Reformat the RV results into the format used for testing
function reformat_RV_outputs(samplesize::Int; output_path::String = joinpath(@__DIR__, "../output"))         

    #create vectors to hold results of Monte Carlo runs
    td=zeros(samplesize);
    tpc=zeros(samplesize);
    tac=zeros(samplesize);
    te=zeros(samplesize);
    ft=zeros(samplesize);
    rt_g=zeros(samplesize);
    s=zeros(samplesize);
    c_co2concentration=zeros(samplesize);
    rgdppercap_slr=zeros(samplesize);
    rgdppercap_market=zeros(samplesize);
    rgdppercap_nonmarket=zeros(samplesize);
    rgdppercap_disc=zeros(samplesize);

    #load raw data
    #no filter
    td      = load_RV("EquityWeighting_td_totaldiscountedimpacts", "td_totaldiscountedimpacts"; output_path = output_path)
    tpc     = load_RV("EquityWeighting_tpc_totalaggregatedcosts", "tpc_totalaggregatedcosts"; output_path = output_path)
    tac     = load_RV("EquityWeighting_tac_totaladaptationcosts", "tac_totaladaptationcosts"; output_path = output_path)
    te      = load_RV("EquityWeighting_te_totaleffect", "te_totaleffect"; output_path = output_path)

    #time index
    c_co2concentration = load_RV("co2cycle_c_CO2concentration", "c_CO2concentration"; output_path = output_path)
    ft      = load_RV("TotalForcing_ft_totalforcing", "ft_totalforcing"; output_path = output_path)
    rt_g    = load_RV("ClimateTemperature_rt_g_globaltemperature", "rt_g_globaltemperature"; output_path = output_path)
    s       = load_RV("SeaLevelRise_s_sealevel", "s_sealevel"; output_path = output_path)

    #region index
    rgdppercap_slr          = load_RV("SLRDamages_rgdp_per_cap_SLRRemainGDP", "rgdp_per_cap_SLRRemainGDP"; output_path = output_path)
    rgdppercap_market       = load_RV("MarketDamages_rgdp_per_cap_MarketRemainGDP", "rgdp_per_cap_MarketRemainGDP"; output_path = output_path)
    rgdppercap_nonmarket    =load_RV("NonMarketDamages_rgdp_per_cap_NonMarketRemainGDP", "rgdp_per_cap_NonMarketRemainGDP"; output_path = output_path)
    rgdppercap_disc         = load_RV("NonMarketDamages_rgdp_per_cap_NonMarketRemainGDP", "rgdp_per_cap_NonMarketRemainGDP"; output_path = output_path)

    #resave data
    df=DataFrame(td=td,tpc=tpc,tac=tac,te=te,c_co2concentration=c_co2concentration,ft=ft,rt_g=rt_g,sealevel=s,rgdppercap_slr=rgdppercap_slr,rgdppercap_market=rgdppercap_market,rgdppercap_nonmarket=rgdppercap_nonmarket,rgdppercap_di=rgdppercap_disc)
    save(joinpath(output_path, "mimipagemontecarlooutput.csv"),df)
end

function do_monte_carlo_runs(samplesize::Int; output_dir::String = joinpath(@__DIR__, "../output"))

        # get simulation
        mcs = getsim()
        
        # get a model
        m = get_model()
        run(m)

        # Run
        res = run(mcs, m, samplesize; trials_output_filename = joinpath(output_dir, "trialdata.csv"), results_output_dir = output_dir)

        # reformat outputs for testing and analysis
        MimiPAGE2009.reformat_RV_outputs(samplesize, output_path = output_dir)
end
