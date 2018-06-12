include("mctools.jl")

@defcomp AbatementCosts begin
    region = Index()
    y_year = Parameter(index=[time], unit="year")
    y_year_0 = Parameter(unit="year")

    #gas inputs
    emit_UncertaintyinBAUEmissFactorinFocusRegioninFinalYear = Parameter(unit="%")
    q0propinit_CutbacksinNegativeCostinFocusRegioninBaseYear = Parameter(unit="% of BAU emissions")
    c0init_MostNegativeCostCutbackinBaseYear = Parameter(unit="\$/ton")
    qmaxminusq0propinit_MaxCutbackCostatPositiveCostinBaseYear = Parameter(unit="% of BAU emissions")
    cmaxinit_MaximumCutbackCostinFocusRegioninBaseYear = Parameter(unit="\$/ton")
    ies_InitialExperienceStockofCutbacks = Parameter(unit= "Million ton")
    er_emissionsgrowth = Parameter(index=[time, region], unit= "%")
    e0_baselineemissions = Parameter(index=[region], unit= "Mtonne/year")

    #regional inputs
    emitf_uncertaintyinBAUemissfactor = Parameter(index=[region], unit= "none")
    q0f_negativecostpercentagefactor = Parameter(index=[region], unit="none")
    cmaxf_maxcostfactor = Parameter(index=[region], unit="none")

    bau_businessasusualemissions = Parameter(index=[time, region], unit = "%")
    yagg = Parameter(index=[time], unit="year") # from equity weighting

    #inputs with single, uncertain values
    q0propmult_cutbacksatnegativecostinfinalyear = Parameter(unit="none")
    qmax_minus_q0propmult_maxcutbacksatpositivecostinfinalyear = Parameter(unit="none")
    c0mult_mostnegativecostinfinalyear = Parameter(unit="none")
    curve_below_curvatureofMACcurvebelowzerocost = Parameter(unit="none")
    curve_above_curvatureofMACcurveabovezerocost = Parameter(unit="none")
    cross_experiencecrossoverratio = Parameter(unit="none")
    learn_learningrate = Parameter(unit="none")
    # automult_autonomoustechchange = Parameter(unit="none")
    equity_prop_equityweightsproportion = Parameter(unit="none")

    #Variables
    emit_UncertaintyinBAUEmissFactor = Variable(index=[region], unit = "%")
    q0propinit_CutbacksinNegativeCostinBaseYear = Variable(index=[region], unit= "% of BAU emissions")
    cmaxinit_MaxCutbackCostinBaseYear = Variable(index=[region], unit = "\$/ton")
    zc_zerocostemissions = Variable(index=[time, region], unit= "%")
    cb_reductionsfromzerocostemissions = Variable(index=[time, region], unit= "%")
    cbe_absoluteemissionreductions = Variable(index=[time, region], unit="Mtonne")
    cumcbe_cumulativereductionssincebaseyear = Variable(index=[time, region], unit="Mtonne")
    cumcbe_g_totalreductions = Variable(index=[time], unit="Mtonne")
    learnfac_learning= Variable(index=[time, region], unit= "none")
    # auto = Variable(unit="% per year")
    auto = Parameter(unit="% per year")
    autofac = Variable(index=[time], unit= "% per year")
    c0g = Variable(unit= "% per year")
    c0 = Variable(index=[time], unit= "\$/ton")
    qmaxminusq0propg = Variable(unit= "% per year")
    qmaxminusq0prop = Variable(unit = "% of BAU emissions")
    q0propg = Variable(unit = "% per year")
    q0prop = Variable(index=[time, region], unit="% of BAU emissions")
    q0_absolutecutbacksatnegativecost = Variable(index=[time, region], unit= "Mtonne")
    qmax_maxreferencereductions = Variable(index=[time, region], unit="Mtonne")
    cmax = Variable(index=[time,region], unit = "\$/tonne")
    blo = Variable(index=[time, region], unit = "per Mtonne")
    alo = Variable(index=[time, region], unit = "\$/tonne")
    bhi = Variable(index=[time, region], unit = "per Mtonne")
    ahi = Variable(index=[time, region], unit = "\$/tonne")
    mc_marginalcost = Variable(index=[time, region], unit = "\$/tonne")
    tcq0 = Variable(index=[time, region], unit = "\$million")
    tc_totalcost = Variable(index=[time, region], unit= "\$million")

end

function run_timestep(s::AbatementCosts, t::Int64)
    v = s.Variables
    p = s.Parameters
    d = s.Dimensions

    for r in d.region
        v.emit_UncertaintyinBAUEmissFactor[r] = p.emit_UncertaintyinBAUEmissFactorinFocusRegioninFinalYear *
            p.emitf_uncertaintyinBAUemissfactor[r]
        v.q0propinit_CutbacksinNegativeCostinBaseYear[r] = p.q0propinit_CutbacksinNegativeCostinFocusRegioninBaseYear *
            p.q0f_negativecostpercentagefactor[r]
        v.cmaxinit_MaxCutbackCostinBaseYear[r] = p.cmaxinit_MaximumCutbackCostinFocusRegioninBaseYear *
            p.cmaxf_maxcostfactor[r]

        v.zc_zerocostemissions[t,r] = (1+v.emit_UncertaintyinBAUEmissFactor[r]/100 * (p.y_year[t]-p.y_year_0)/(p.y_year[end]-p.y_year_0)) * p.bau_businessasusualemissions[t,r]

        v.cb_reductionsfromzerocostemissions[t,r] = max(v.zc_zerocostemissions[t,r] - p.er_emissionsgrowth[t,r], 0)

        v.cbe_absoluteemissionreductions[t,r] = v.cb_reductionsfromzerocostemissions[t,r]* p.e0_baselineemissions[r]/100

        if t==1
            v.cumcbe_cumulativereductionssincebaseyear[t,r] = 0.
        else
            v.cumcbe_cumulativereductionssincebaseyear[t,r] = v.cumcbe_cumulativereductionssincebaseyear[t-1, r] + v.cbe_absoluteemissionreductions[t-1, r] * p.yagg[t-1]
        end
    end
        v.cumcbe_g_totalreductions[t] = sum(v.cumcbe_cumulativereductionssincebaseyear[t,:])

        # v.auto = (1-p.automult_autonomoustechchange^(1/(p.y_year[end]-p.y_year_0)))*100
        # v.autofac[t] = (1-v.auto/100)^(p.y_year[t] - p.y_year_0)
        v.autofac[t] = (1-p.auto/100)^(p.y_year[t] - p.y_year_0)

        v.c0g = (p.c0mult_mostnegativecostinfinalyear^(1/(p.y_year[end]-p.y_year_0))-1)*100
        v.c0[t] = p.c0init_MostNegativeCostCutbackinBaseYear* (1+v.c0g/100)^(p.y_year[t]-p.y_year_0)

        v.qmaxminusq0propg = (p.qmax_minus_q0propmult_maxcutbacksatpositivecostinfinalyear ^(1/(p.y_year[end]-p.y_year_0))- 1)* 100
        v.qmaxminusq0prop = p.qmaxminusq0propinit_MaxCutbackCostatPositiveCostinBaseYear * (1+ v.qmaxminusq0propg/100)^(p.y_year[t]-p.y_year_0)

        v.q0propg = (p.q0propmult_cutbacksatnegativecostinfinalyear^(1/(p.y_year[end]-p.y_year_0))-1)*100

    for r in d.region
        v.learnfac_learning[t,r] = ((p.cross_experiencecrossoverratio *v.cumcbe_g_totalreductions[t]+ (1-p.cross_experiencecrossoverratio)*v.cumcbe_cumulativereductionssincebaseyear[t,r] + p.ies_InitialExperienceStockofCutbacks)/ p.ies_InitialExperienceStockofCutbacks)^ -(log(1/(1-p.learn_learningrate))/log(2))

        v.q0prop[t,r] = v.q0propinit_CutbacksinNegativeCostinBaseYear[r]* (1+v.q0propg/100)^(p.y_year[t]-p.y_year_0)

        v.q0_absolutecutbacksatnegativecost[t,r]= (v.q0prop[t,r]/100)* (v.zc_zerocostemissions[t,r]/100) * p.e0_baselineemissions[r]

        v.qmax_maxreferencereductions[t,r] = (v.qmaxminusq0prop/100) * (v.zc_zerocostemissions[t,r]/100)* p.e0_baselineemissions[r] + v.q0_absolutecutbacksatnegativecost[t,r]

        v.cmax[t,r] = v.cmaxinit_MaxCutbackCostinBaseYear[r] * v.learnfac_learning[t,r]* v.autofac[t]

        v.blo[t,r] = -2*log((1+p.curve_below_curvatureofMACcurvebelowzerocost)/(1-p.curve_below_curvatureofMACcurvebelowzerocost))/ v.q0_absolutecutbacksatnegativecost[t,r]
        v.alo[t,r] = v.c0[t]/(exp(-v.blo[t,r]*v.q0_absolutecutbacksatnegativecost[t,r])-1)
        v.bhi[t,r] = 2*log((1+p.curve_above_curvatureofMACcurveabovezerocost)/(1-p.curve_above_curvatureofMACcurveabovezerocost))/ (v.qmax_maxreferencereductions[t,r] - v.q0_absolutecutbacksatnegativecost[t,r])
        v.ahi[t,r] = v.cmax[t,r]/ (exp(v.bhi[t,r]*(v.qmax_maxreferencereductions[t,r]-v.q0_absolutecutbacksatnegativecost[t,r]))-1)

        if v.cbe_absoluteemissionreductions[t,r]< v.q0_absolutecutbacksatnegativecost[t,r]
            v.mc_marginalcost[t,r] = v.alo[t,r]* (exp(v.blo[t,r]*(v.cbe_absoluteemissionreductions[t,r]- v.q0_absolutecutbacksatnegativecost[t,r]))-1)
        else
            v.mc_marginalcost[t,r] = v.ahi[t,r]*(exp(v.bhi[t,r]*(v.cbe_absoluteemissionreductions[t,r]- v.q0_absolutecutbacksatnegativecost[t,r]))-1)
        end

        if v.q0_absolutecutbacksatnegativecost[t,r] == 0.
            v.tcq0[t,r] = 0.
        else
            v.tcq0[t,r] = (v.alo[t,r]/v.blo[t,r])*(1-exp(-v.blo[t,r]* v.q0_absolutecutbacksatnegativecost[t,r]))- v.alo[t,r]*v.q0_absolutecutbacksatnegativecost[t,r]
        end

        if v.cbe_absoluteemissionreductions[t,r]<v.q0_absolutecutbacksatnegativecost[t,r]
            v.tc_totalcost[t,r] = (v.alo[t,r]/v.blo[t,r])*(exp(v.blo[t,r]*(v.cbe_absoluteemissionreductions[t,r]- v.q0_absolutecutbacksatnegativecost[t,r]))- exp(-v.blo[t,r]*v.q0_absolutecutbacksatnegativecost[t,r])) - v.alo[t,r]*v.cbe_absoluteemissionreductions[t,r]
        else
            v.tc_totalcost[t,r] = (v.ahi[t,r]/v.bhi[t,r])* (exp(v.bhi[t,r]*(v.cbe_absoluteemissionreductions[t,r]-v.q0_absolutecutbacksatnegativecost[t,r]))-1) - v.ahi[t,r]*(v.cbe_absoluteemissionreductions[t,r] - v.q0_absolutecutbacksatnegativecost[t,r]) + v.tcq0[t,r]
        end
    end
end

function addabatementcosts(model::Model, class::Symbol, policy::String="policy-a")
    componentname = Symbol("AbatementCosts$class")
    abatementcostscomp = addcomponent(model, AbatementCosts, componentname)

    abatementcostscomp[:q0propmult_cutbacksatnegativecostinfinalyear] = .733333333333333334
    abatementcostscomp[:qmax_minus_q0propmult_maxcutbacksatpositivecostinfinalyear] = 1.2666666666666666
    abatementcostscomp[:c0mult_mostnegativecostinfinalyear] = .8333333333333334
    abatementcostscomp[:curve_below_curvatureofMACcurvebelowzerocost] = .5
    abatementcostscomp[:curve_above_curvatureofMACcurveabovezerocost] = .4
    abatementcostscomp[:cross_experiencecrossoverratio] = .2
    abatementcostscomp[:learn_learningrate] = .2
    # abatementcostscomp[:automult_autonomoustechchange] = .65
    abatementcostscomp[:auto] = 0.22411458953073282
    abatementcostscomp[:equity_prop_equityweightsproportion] = 1.
    abatementcostscomp[:y_year_0] = 2008.

    if class == :CO2
        setdistinctparameter(model, componentname, :emit_UncertaintyinBAUEmissFactorinFocusRegioninFinalYear, 8.333333333333334)
        setdistinctparameter(model, componentname, :q0propinit_CutbacksinNegativeCostinFocusRegioninBaseYear, 20.)
        setdistinctparameter(model, componentname, :c0init_MostNegativeCostCutbackinBaseYear, -233.333333333333)
        setdistinctparameter(model, componentname, :qmaxminusq0propinit_MaxCutbackCostatPositiveCostinBaseYear, 70.)
        setdistinctparameter(model, componentname, :cmaxinit_MaximumCutbackCostinFocusRegioninBaseYear, 400.)
        setdistinctparameter(model, componentname, :ies_InitialExperienceStockofCutbacks, 150000.)
        if policy == "policy-a"
            setdistinctparameter(model, componentname, :er_emissionsgrowth, readpagedata(model, joinpath(dirname(@__FILE__), "..","data","er_CO2emissionsgrowth.csv")))
        else
            setdistinctparameter(model, componentname, :er_emissionsgrowth, readpagedata(model, joinpath(dirname(@__FILE__), "..", "data", policy, "er_CO2emissionsgrowth.csv")))
        end
        setdistinctparameter(model, componentname, :e0_baselineemissions, readpagedata(model, joinpath(dirname(@__FILE__),"..", "data","e0_baselineCO2emissions.csv")))
        setdistinctparameter(model, componentname, :bau_businessasusualemissions, readpagedata(model, joinpath(dirname(@__FILE__),"..","data","bau_co2emissions.csv")))
    elseif class == :CH4
        setdistinctparameter(model, componentname, :emit_UncertaintyinBAUEmissFactorinFocusRegioninFinalYear, 25.)
        setdistinctparameter(model, componentname, :q0propinit_CutbacksinNegativeCostinFocusRegioninBaseYear, 10.)
        setdistinctparameter(model, componentname, :c0init_MostNegativeCostCutbackinBaseYear, -4333.3333333333333)
        setdistinctparameter(model, componentname, :qmaxminusq0propinit_MaxCutbackCostatPositiveCostinBaseYear, 51.66666666666666664)
        # setdistinctparameter(model, componentname, :cmaxinit_MaximumCutbackCostinFocusRegioninBaseYear, 6333.33)
        setdistinctparameter(model, componentname, :cmaxinit_MaximumCutbackCostinFocusRegioninBaseYear, 6333.33333333333)
        setdistinctparameter(model, componentname, :ies_InitialExperienceStockofCutbacks, 2000.)
        if policy == "policy-a"
            setdistinctparameter(model, componentname, :er_emissionsgrowth, readpagedata(model, joinpath(dirname(@__FILE__), "..","data","er_CH4emissionsgrowth.csv")))
        else
            setdistinctparameter(model, componentname, :er_emissionsgrowth, readpagedata(model, joinpath(dirname(@__FILE__), "..", "data", policy, "er_CH4emissionsgrowth.csv")))
        end
        setdistinctparameter(model, componentname, :e0_baselineemissions, readpagedata(model, joinpath(dirname(@__FILE__), "..","data","e0_baselineCH4emissions.csv")))
        setdistinctparameter(model, componentname, :bau_businessasusualemissions, readpagedata(model, joinpath(dirname(@__FILE__), "..","data","bau_ch4emissions.csv")))
    elseif class == :N2O
        setdistinctparameter(model, componentname, :emit_UncertaintyinBAUEmissFactorinFocusRegioninFinalYear, 0.)
        setdistinctparameter(model, componentname, :q0propinit_CutbacksinNegativeCostinFocusRegioninBaseYear, 10.)
        setdistinctparameter(model, componentname, :c0init_MostNegativeCostCutbackinBaseYear, -7333.333333333333)
        setdistinctparameter(model, componentname, :qmaxminusq0propinit_MaxCutbackCostatPositiveCostinBaseYear, 51.66666666666666664)
        # setdistinctparameter(model, componentname, :cmaxinit_MaximumCutbackCostinFocusRegioninBaseYear, 27333.33)
        setdistinctparameter(model, componentname, :cmaxinit_MaximumCutbackCostinFocusRegioninBaseYear, 27333.3333333333)
        # setdistinctparameter(model, componentname, :ies_InitialExperienceStockofCutbacks, 53.33)
        setdistinctparameter(model, componentname, :ies_InitialExperienceStockofCutbacks, 53.3333333333333)
        if policy == "policy-a"
            setdistinctparameter(model, componentname, :er_emissionsgrowth, readpagedata(model, joinpath(dirname(@__FILE__), "..","data","er_N2Oemissionsgrowth.csv")))
        else
            setdistinctparameter(model, componentname, :er_emissionsgrowth, readpagedata(model, joinpath(dirname(@__FILE__), "..", "data", policy, "er_N2Oemissionsgrowth.csv")))
        end
        setdistinctparameter(model, componentname, :e0_baselineemissions, readpagedata(model, joinpath(dirname(@__FILE__), "..","data","e0_baselineN2Oemissions.csv")))
        setdistinctparameter(model, componentname, :bau_businessasusualemissions, readpagedata(model, joinpath(dirname(@__FILE__), "..","data","bau_n2oemissions.csv")))
    elseif class == :Lin
        setdistinctparameter(model, componentname, :emit_UncertaintyinBAUEmissFactorinFocusRegioninFinalYear, 0.)
        setdistinctparameter(model, componentname, :q0propinit_CutbacksinNegativeCostinFocusRegioninBaseYear, 10.)
        setdistinctparameter(model, componentname, :c0init_MostNegativeCostCutbackinBaseYear, -233.333333333333)
        setdistinctparameter(model, componentname, :qmaxminusq0propinit_MaxCutbackCostatPositiveCostinBaseYear, 70.)
        # setdistinctparameter(model, componentname, :cmaxinit_MaximumCutbackCostinFocusRegioninBaseYear, 333.33)
        setdistinctparameter(model, componentname, :cmaxinit_MaximumCutbackCostinFocusRegioninBaseYear, 333.333333333333)
        setdistinctparameter(model, componentname, :ies_InitialExperienceStockofCutbacks, 2000.)
        if policy == "policy-a"
            setdistinctparameter(model, componentname, :er_emissionsgrowth, readpagedata(model,joinpath(dirname(@__FILE__), "..","data","er_LGemissionsgrowth.csv")))
        else
            setdistinctparameter(model, componentname, :er_emissionsgrowth, readpagedata(model,joinpath(dirname(@__FILE__), "..", "data", policy, "er_LGemissionsgrowth.csv")))
        end
        setdistinctparameter(model, componentname, :e0_baselineemissions, readpagedata(model,joinpath(dirname(@__FILE__), "..","data","e0_baselineLGemissions.csv")))
        setdistinctparameter(model, componentname, :bau_businessasusualemissions, readpagedata(model,joinpath(dirname(@__FILE__), "..","data","bau_linemissions.csv")))
    else
        error("Unknown class of abatement costs.")
    end

    return abatementcostscomp
end

function randomizeabatementcosts(model::Model)
    update_external_parameter(model,:AbatementCostsCO2_emit_UncertaintyinBAUEmissFactorinFocusRegioninFinalYear,rand(TriangularDist(-50,75,0)))
    update_external_parameter(model,:AbatementCostsCH4_emit_UncertaintyinBAUEmissFactorinFocusRegioninFinalYear,rand(TriangularDist(-25,100,0)))
    update_external_parameter(model,:AbatementCostsN2O_emit_UncertaintyinBAUEmissFactorinFocusRegioninFinalYear,rand(TriangularDist(-50,50,0)))
    update_external_parameter(model,:AbatementCostsLin_emit_UncertaintyinBAUEmissFactorinFocusRegioninFinalYear,rand(TriangularDist(-50,50,0)))

    update_external_parameter(model,:AbatementCostsCO2_q0propinit_CutbacksinNegativeCostinFocusRegioninBaseYear,rand(TriangularDist(0,40,20)))
    update_external_parameter(model,:AbatementCostsCH4_q0propinit_CutbacksinNegativeCostinFocusRegioninBaseYear,rand(TriangularDist(0,20,10)))
    update_external_parameter(model,:AbatementCostsN2O_q0propinit_CutbacksinNegativeCostinFocusRegioninBaseYear,rand(TriangularDist(0,20,10)))
    update_external_parameter(model,:AbatementCostsLin_q0propinit_CutbacksinNegativeCostinFocusRegioninBaseYear,rand(TriangularDist(0,20,10)))

    update_external_parameter(model,:AbatementCostsCO2_c0init_MostNegativeCostCutbackinBaseYear,rand(TriangularDist(-400,-100,-200)))
    update_external_parameter(model,:AbatementCostsCH4_c0init_MostNegativeCostCutbackinBaseYear,rand(TriangularDist(-8000,-1000,-4000)))
    update_external_parameter(model,:AbatementCostsN2O_c0init_MostNegativeCostCutbackinBaseYear,rand(TriangularDist(-15000,0,-7000)))
    update_external_parameter(model,:AbatementCostsLin_c0init_MostNegativeCostCutbackinBaseYear,rand(TriangularDist(-400,-100,-200)))

    update_external_parameter(model,:AbatementCostsCO2_qmaxminusq0propinit_MaxCutbackCostatPositiveCostinBaseYear,rand(TriangularDist(60,80,70)))
    update_external_parameter(model,:AbatementCostsCH4_qmaxminusq0propinit_MaxCutbackCostatPositiveCostinBaseYear,rand(TriangularDist(35,70,50)))
    update_external_parameter(model,:AbatementCostsN2O_qmaxminusq0propinit_MaxCutbackCostatPositiveCostinBaseYear,rand(TriangularDist(35,70,50)))
    update_external_parameter(model,:AbatementCostsLin_qmaxminusq0propinit_MaxCutbackCostatPositiveCostinBaseYear,rand(TriangularDist(60,80,70)))

    update_external_parameter(model,:AbatementCostsCO2_cmaxinit_MaximumCutbackCostinFocusRegioninBaseYear,rand(TriangularDist(100,700,400)))
    update_external_parameter(model,:AbatementCostsCH4_cmaxinit_MaximumCutbackCostinFocusRegioninBaseYear,rand(TriangularDist(3000,10000,6000)))
    update_external_parameter(model,:AbatementCostsN2O_cmaxinit_MaximumCutbackCostinFocusRegioninBaseYear,rand(TriangularDist(2000,60000,20000)))
    update_external_parameter(model,:AbatementCostsLin_cmaxinit_MaximumCutbackCostinFocusRegioninBaseYear,rand(TriangularDist(100,600,300)))

    update_external_parameter(model,:AbatementCostsCO2_ies_InitialExperienceStockofCutbacks,rand(TriangularDist(100000,200000,150000)))
    update_external_parameter(model,:AbatementCostsCH4_ies_InitialExperienceStockofCutbacks,rand(TriangularDist(1500,2500,2000)))
    update_external_parameter(model,:AbatementCostsN2O_ies_InitialExperienceStockofCutbacks,rand(TriangularDist(30,80,50)))
    update_external_parameter(model,:AbatementCostsLin_ies_InitialExperienceStockofCutbacks,rand(TriangularDist(1500,2500,2000)))

    #the following variables need to be randomized, but set the same in all 4 abatement cost components
    #note that for these regional variables, the first region is the focus region (EU), which is randomized in the preceding code, and so is always one for these variables
    update_external_parameter(model,:emitf_uncertaintyinBAUemissfactor,[1,rand(TriangularDist(0.8,1.2,1.0)),rand(TriangularDist(0.8,1.2,1.0)),rand(TriangularDist(0.65,1.35,1.0)),rand(TriangularDist(0.5,1.5,1.0)),rand(TriangularDist(0.5,1.5,1.0)),rand(TriangularDist(0.5,1.5,1.0)),rand(TriangularDist(0.5,1.5,1.0))])
    update_external_parameter(model,:q0f_negativecostpercentagefactor,[1,rand(TriangularDist(0.75,1.5,1.0)),rand(TriangularDist(0.75,1.25,1.0)),rand(TriangularDist(0.4,1.0,0.7)),rand(TriangularDist(0.4,1.0,0.7)),rand(TriangularDist(0.4,1.0,0.7)),rand(TriangularDist(0.4,1.0,0.7)),rand(TriangularDist(0.4,1.0,0.7))])
    update_external_parameter(model,:cmaxf_maxcostfactor,[1,rand(TriangularDist(0.8,1.2,1.0)),rand(TriangularDist(1.0,1.5,1.2)),rand(TriangularDist(0.4,1.0,0.7)),rand(TriangularDist(0.8,1.2,1.0)),rand(TriangularDist(1,1.5,1.2)),rand(TriangularDist(1,1.5,1.2)),rand(TriangularDist(0.4,1.0,0.7))])
    update_external_parameter(model,:q0propmult_cutbacksatnegativecostinfinalyear,rand(TriangularDist(0.3,1.2,0.7)))
    update_external_parameter(model,:qmax_minus_q0propmult_maxcutbacksatpositivecostinfinalyear,rand(TriangularDist(1,1.5,1.3)))
    update_external_parameter(model,:c0mult_mostnegativecostinfinalyear,rand(TriangularDist(0.5,1.2,0.8)))
    update_external_parameter(model,:curve_below_curvatureofMACcurvebelowzerocost,rand(TriangularDist(0.25,0.8,0.45)))
    update_external_parameter(model,:curve_above_curvatureofMACcurveabovezerocost,rand(TriangularDist(0.1,0.7,0.4)))
    update_external_parameter(model,:cross_experiencecrossoverratio,rand(TriangularDist(0.1,0.3,0.2)))
    update_external_parameter(model,:learn_learningrate,rand(TriangularDist(0.05,0.35,0.2)))
    update_external_parameter(model,:automult_autonomoustechchange,rand(TriangularDist(0.5,0.8,0.65)))
end
