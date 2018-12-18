include("../utils/mctools.jl")

@defcomp AbatementCostParameters begin

    region = Index()
    y_year = Parameter(index=[time], unit="year")
    y_year_0 = Parameter(unit="year", default = 2008.)

    #gas inputs
    emit_UncertaintyinBAUEmissFactorinFocusRegioninFinalYear = Parameter(unit="%")
    q0propinit_CutbacksinNegativeCostinFocusRegioninBaseYear = Parameter(unit="% of BAU emissions")
    c0init_MostNegativeCostCutbackinBaseYear = Parameter(unit="\$/ton")
    qmaxminusq0propinit_MaxCutbackCostatPositiveCostinBaseYear = Parameter(unit="% of BAU emissions")
    cmaxinit_MaximumCutbackCostinFocusRegioninBaseYear = Parameter(unit="\$/ton")
    ies_InitialExperienceStockofCutbacks = Parameter(unit= "Million ton")
    e0_baselineemissions = Parameter(index=[region], unit= "Mtonne/year")

    #regional inputs
    emitf_uncertaintyinBAUemissfactor = Parameter(index=[region], unit= "none")
    q0f_negativecostpercentagefactor = Parameter(index=[region], unit="none")
    cmaxf_maxcostfactor = Parameter(index=[region], unit="none")

    bau_businessasusualemissions = Parameter(index=[time, region], unit = "%")
    yagg = Parameter(index=[time], unit="year") # from equity weighting

    #inputs with single, uncertain values
    q0propmult_cutbacksatnegativecostinfinalyear = Parameter(unit="none", default=.733333333333333334)
    qmax_minus_q0propmult_maxcutbacksatpositivecostinfinalyear = Parameter(unit="none", default=1.2666666666666666)
    c0mult_mostnegativecostinfinalyear = Parameter(unit="none", default=.8333333333333334)
    curve_below_curvatureofMACcurvebelowzerocost = Parameter(unit="none", default=.5)
    curve_above_curvatureofMACcurveabovezerocost = Parameter(unit="none", default=.4)
    cross_experiencecrossoverratio = Parameter(unit="none", default=.2)
    learn_learningrate = Parameter(unit="none", default=.2)
    automult_autonomoustechchange = Parameter(unit="none", default=.65)
    equity_prop_equityweightsproportion = Parameter(unit="none", default=1.)

    # Inputs from other components
    cbe_absoluteemissionreductions = Parameter(index=[time, region], unit="Mtonne") #TODO: default here?
    
    #Variables
    emit_UncertaintyinBAUEmissFactor = Variable(index=[region], unit = "%")
    q0propinit_CutbacksinNegativeCostinBaseYear = Variable(index=[region], unit= "% of BAU emissions")
    cmaxinit_MaxCutbackCostinBaseYear = Variable(index=[region], unit = "\$/ton")
    zc_zerocostemissions = Variable(index=[time, region], unit= "%")
    cumcbe_cumulativereductionssincebaseyear = Variable(index=[time, region], unit="Mtonne")
    cumcbe_g_totalreductions = Variable(index=[time], unit="Mtonne")
    learnfac_learning= Variable(index=[time, region], unit= "none")
    auto = Variable(unit="% per year")
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

    function run_timestep(p, v, d, t)

        for r in d.region
            v.emit_UncertaintyinBAUEmissFactor[r] = p.emit_UncertaintyinBAUEmissFactorinFocusRegioninFinalYear *
                p.emitf_uncertaintyinBAUemissfactor[r]
            v.q0propinit_CutbacksinNegativeCostinBaseYear[r] = p.q0propinit_CutbacksinNegativeCostinFocusRegioninBaseYear *
                p.q0f_negativecostpercentagefactor[r]
            v.cmaxinit_MaxCutbackCostinBaseYear[r] = p.cmaxinit_MaximumCutbackCostinFocusRegioninBaseYear *
                p.cmaxf_maxcostfactor[r]

            v.zc_zerocostemissions[t,r] = (1+v.emit_UncertaintyinBAUEmissFactor[r]/100 * (p.y_year[t]-p.y_year_0)/(p.y_year[end]-p.y_year_0)) * p.bau_businessasusualemissions[t,r]

            if is_first(t)
                v.cumcbe_cumulativereductionssincebaseyear[t,r] = 0.
            else
                v.cumcbe_cumulativereductionssincebaseyear[t,r] = v.cumcbe_cumulativereductionssincebaseyear[t-1, r] + p.cbe_absoluteemissionreductions[t-1, r] * p.yagg[t-1]
            end
        end
        
        v.cumcbe_g_totalreductions[t] = sum(v.cumcbe_cumulativereductionssincebaseyear[t,:])

        v.auto = (1-p.automult_autonomoustechchange^(1/(p.y_year[end]-p.y_year_0)))*100
        v.autofac[t] = (1-v.auto/100)^(p.y_year[t] - p.y_year_0)

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
        end
    end
end

function addabatementcostparameters(model::Model, class::Symbol, policy::String="policy-a")
    componentname = Symbol("AbatementCostParameters$class")
    abatementcostscomp = add_comp!(model, AbatementCostParameters, componentname)

    abatementcostscomp[:q0propmult_cutbacksatnegativecostinfinalyear] = .733333333333333334
    abatementcostscomp[:qmax_minus_q0propmult_maxcutbacksatpositivecostinfinalyear] = 1.2666666666666666
    abatementcostscomp[:c0mult_mostnegativecostinfinalyear] = .8333333333333334
    abatementcostscomp[:curve_below_curvatureofMACcurvebelowzerocost] = .5
    abatementcostscomp[:curve_above_curvatureofMACcurveabovezerocost] = .4
    abatementcostscomp[:cross_experiencecrossoverratio] = .2
    abatementcostscomp[:learn_learningrate] = .2
    abatementcostscomp[:automult_autonomoustechchange] = .65
    abatementcostscomp[:equity_prop_equityweightsproportion] = 1.
    abatementcostscomp[:y_year_0] = 2008.

    if class == :CO2
        setdistinctparameter(model, componentname, :emit_UncertaintyinBAUEmissFactorinFocusRegioninFinalYear, 8.333333333333334)
        setdistinctparameter(model, componentname, :q0propinit_CutbacksinNegativeCostinFocusRegioninBaseYear, 20.)
        setdistinctparameter(model, componentname, :c0init_MostNegativeCostCutbackinBaseYear, -233.333333333333)
        setdistinctparameter(model, componentname, :qmaxminusq0propinit_MaxCutbackCostatPositiveCostinBaseYear, 70.)
        setdistinctparameter(model, componentname, :cmaxinit_MaximumCutbackCostinFocusRegioninBaseYear, 400.)
        setdistinctparameter(model, componentname, :ies_InitialExperienceStockofCutbacks, 150000.)
        setdistinctparameter(model, componentname, :e0_baselineemissions, readpagedata(model, "data/e0_baselineCO2emissions.csv"))
        setdistinctparameter(model, componentname, :bau_businessasusualemissions, readpagedata(model, "data/bau_co2emissions.csv"))
    elseif class == :CH4
        setdistinctparameter(model, componentname, :emit_UncertaintyinBAUEmissFactorinFocusRegioninFinalYear, 25.)
        setdistinctparameter(model, componentname, :q0propinit_CutbacksinNegativeCostinFocusRegioninBaseYear, 10.)
        setdistinctparameter(model, componentname, :c0init_MostNegativeCostCutbackinBaseYear, -4333.3333333333333)
        setdistinctparameter(model, componentname, :qmaxminusq0propinit_MaxCutbackCostatPositiveCostinBaseYear, 51.66666666666666664)
        setdistinctparameter(model, componentname, :cmaxinit_MaximumCutbackCostinFocusRegioninBaseYear, 6333.33333333333)
        setdistinctparameter(model, componentname, :ies_InitialExperienceStockofCutbacks, 2000.)
        setdistinctparameter(model, componentname, :e0_baselineemissions, readpagedata(model, "data/e0_baselineCH4emissions.csv"))
        setdistinctparameter(model, componentname, :bau_businessasusualemissions, readpagedata(model, "data/bau_ch4emissions.csv"))
    elseif class == :N2O
        setdistinctparameter(model, componentname, :emit_UncertaintyinBAUEmissFactorinFocusRegioninFinalYear, 0.)
        setdistinctparameter(model, componentname, :q0propinit_CutbacksinNegativeCostinFocusRegioninBaseYear, 10.)
        setdistinctparameter(model, componentname, :c0init_MostNegativeCostCutbackinBaseYear, -7333.333333333333)
        setdistinctparameter(model, componentname, :qmaxminusq0propinit_MaxCutbackCostatPositiveCostinBaseYear, 51.66666666666666664)
        setdistinctparameter(model, componentname, :cmaxinit_MaximumCutbackCostinFocusRegioninBaseYear, 27333.3333333333)
        setdistinctparameter(model, componentname, :ies_InitialExperienceStockofCutbacks, 53.3333333333333)
        setdistinctparameter(model, componentname, :e0_baselineemissions, readpagedata(model, "data/e0_baselineN2Oemissions.csv"))
        setdistinctparameter(model, componentname, :bau_businessasusualemissions, readpagedata(model, "data/bau_n2oemissions.csv"))
    elseif class == :Lin
        setdistinctparameter(model, componentname, :emit_UncertaintyinBAUEmissFactorinFocusRegioninFinalYear, 0.)
        setdistinctparameter(model, componentname, :q0propinit_CutbacksinNegativeCostinFocusRegioninBaseYear, 10.)
        setdistinctparameter(model, componentname, :c0init_MostNegativeCostCutbackinBaseYear, -233.333333333333)
        setdistinctparameter(model, componentname, :qmaxminusq0propinit_MaxCutbackCostatPositiveCostinBaseYear, 70.)
        setdistinctparameter(model, componentname, :cmaxinit_MaximumCutbackCostinFocusRegioninBaseYear, 333.333333333333)
        setdistinctparameter(model, componentname, :ies_InitialExperienceStockofCutbacks, 2000.)
        setdistinctparameter(model, componentname, :e0_baselineemissions, readpagedata(model,"data/e0_baselineLGemissions.csv"))
        setdistinctparameter(model, componentname, :bau_businessasusualemissions, readpagedata(model,"data/bau_linemissions.csv"))
    else
        error("Unknown class of abatement costs.")
    end

    return abatementcostscomp
end
