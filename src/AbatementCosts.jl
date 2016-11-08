
@defcomp AbatementCosts begin
    region = Index(region)
    y_year = Parameter(index=[time], unit="year")
    y_year_0 = Parameter(unit="year")
    population = Parameter(index=)

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
    emitf_uncertaintyinBAUemissfactor = Parameter(index=[region])
    q0f_negativecostpercentagefactor = Parameter(index=[region])
    cmaxf_maxcostfactor = Parameter(index=[region])

    #input from other component
    bau_businessasusualemissions = Parameter(index=[time, region], unit = "%")
    yagg = Parameter(index=[time], unit="years") # from equity weighting

    #inputs with single, uncertain values
    q0propmult_cutbacksatnegativecostinfinalyear = Parameter()
    qmax_minus_q0propmult_maxcutbacksatpositivecostinfinalyear = Parameter()
    c0mult_mostnegativecostinfinalyear = Parameter()
    curve_below_curvatureofMACcurvebelowzerocost = Parameter()
    curve_above_curvatureofMACcurveabovezerocost = Parameter()
    cross_experiencecrossoverratio = Parameter()
    learn_learningrate = Parameter()
    automult_autonomoustechchange = Parameter()
    equity_prop_equityweightsproportion = Parameter()

    #other parameters

    #Variables
    emit_UncertaintyinBAUEmissFactor = Variable(index=[region], unit = "%")
    q0propinit_CutbacksinNegativeCostinBaseYear = Variable(index=[region], unit= "% of BAU emissions")
    cmaxinit_MaxCutbackCostinBaseYear = Variable(index=[region], unit = "\$/ton")
    zc_zerocostemissions = Variable(index=[time, region], unit= "%")
    cb_reductionsfromzerocostemissions = Variable(index=[time, region], unit= "%")
    cbe_absoluteemissionreductions = Variable(index=[time, region], unit="Mtonne")
    cumcbe_cumulativereductionssincebaseyear = Variable(index=[time, region], unit="Mtonne")
    cumcbe_g_totalreductions = Variable(index=[time], unit="Mtonne")
    learnfac_learning= Variable(index=[time, region], unit= "")
    auto = Variable(unit="% per year")
    c0g = Variable(unit= "% per year")
    c0 = Variable(index=[time], unit= "\$/ton")
    qmaxminusq0propg = Variable(unit= "% per year")
    qmaxminusq0prop = Variable(unit = "% of BAU emissions")
    q0propg = Variable(unit = "% per year")
    q0prop = Variable(index=[time, region], unit="% of BAU emissions")
    q0_absolutecutbacksatnegativecost = Variable(index=[time, region], unit= "Mtonne")
    qmax_maxreferencereductions = Variable(index=[time, region], unit="Mtonne")
    cmax_ = Variable(index=[time,region], unit = "\$/tonne")
    blo_ = Variable(index=[time, region], unit = "per Mtonne")
    alo_ = Variable(index=[time, region], unit = "\$/tonne")
    bhi_ = Variable(index=[time, region], unit = "per Mtonne")
    ahi_ = Variable(index=[time, region], unit = "\$/tonne")
    mc_ = Variable(index=[time, region], unit = "\$/tonne")
    tcq0_ = Variable(index=[time, region], unit = "\$million")

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
        v.cmaxinit[r] = p.cmaxinit_MaximumCutbackCostinFocusRegioninBaseYear *
            p.cmaxf_maxcostfactor[r]

        v.zc_zerocostemissions[t,r] = (1+v.emit_UncertaintyinBAUEmissFactor[r]/100 * (p.y_year[t]-p.y_year_0)/(p.y_year[end]-p.y_year_0)) * p.bau_businessasusualemissions[t,r]

        v.cb_reductionsfromzerocostemissions[t,r] = max(v.zc_zerocostemissions[t,r] - p.er_emissionsgrowth[t,r], 0)

        v.cbe_absoluteemissionreductions[t,r] = v.cb_reductionsfromzerocostemissions[t,r]* p.e0_baselineemissions[r]/100

        if t==1
            v.cumcbe_cumulativereductionssincebaseyear[t,r] = 0.
        else
            v.cumcbe_cumulativereductionssincebaseyear[t,r] = v.cumcbe_cumulativereductionssincebaseyear[t-1, r] + v.cbe_absoluteemissionreductions[t-1, r] * p.yagg[t-1]
        end

        v.cumcbe_g_totalreductions[t] = sum(v.cumcbe_cumulativereductionssincebaseyear[t,:])

        v.learnfac_learning[t,r] = ((p.cross_experiencecrossoverratio *cumcbe_g_totalreductions[t]+ (1-p.cross_experiencecrossoverratio)*cumcbe_cumulativereductionssincebaseyear[t,r] + p.ies_InitialExperienceStockofCutbacks)/ p.ies_InitialExperienceStockofCutbacks)^ -(ln(1/(1-p.learn_learningrate))/ln(2))

        v.auto = (1-p.automult_autonomoustechchange^(1/(p.y_year[10]-p.y_year_0)))*100
        v.autofac[t] = (1-v.auto/100)^(p.y_year[t] - p.y_year_0)

        v.c0g = (p.c0mult_mostnegativecostinfinalyear^(1/(p.y_year[10]-p.y_year_0))-1)*100
        v.c0[t] = p.c0init_MostNegativeCostCutbackinBaseYear* (1-v.c0g/100)^(p.y_year[t]-p.y_year_0)

        v.qmaxminusq0propg = (p.qmax_minus_q0propmult_maxcutbacksatpositivecostinfinalyear ^(1/(p.y_year[10]-p.y_year_0))- 1)* 100
        v.qmaxminusq0prop[t] = p.qmaxminusq0propinit_MaxCutbackCostatPositiveCostinBaseYear * (1+ v.qmaxminusq0propg/100)^(p.y_year[t]-p.y_year_0)

        v.q0propg = p.q0propmult_cutbacksatnegativecostinfinalyear^(1/(p.y_year[10]-p.y_year_0))-1)*100
        v.q0prop[t,r] = p.q0propinit_CutbacksinNegativeCostinBaseYear[r]* (1+v.q0propg/100)^(p.y_year[t]-p.y_year_0)

        v.q0_absolutecutbacksatnegativecost[t,r]= (v.q0prop[t,r]/100)* (v.zc_zerocostemissions[t,r]/100) * p.e0_baselineemissions[r]
        v.qmax_maxreferencereductions[t,r] = (v.qmaxminusq0prop[t]/100) * (v.zc_zerocostemissions[t,r]/100)* p.e0_baselineemissions[r] + v.q0_absolutecutbacksatnegativecost[t,r]

        v.cmax_[t,r] = p.cmaxinit_MaxCutbackCostinBaseYear[r] * v.learnfac_learning[t,r]* v.autofac[t]

        v.blo_[t,r] = -2*log((1+p.curve_below_curvatureofMACcurvebelowzerocost)/(1-p.curve_below_curvatureofMACcurvebelowzerocost))/ v.q0_absolutecutbacksatnegativecost[t,r]
        v.alo_[t,r] = v.c0[t]/(exp(-v.blo_[t,r]*v.q0_absolutecutbacksatnegativecost[t,r])-1)
        v.bhi_[t,r] = 2*log((1+p.curve_above_curvatureofMACcurveabovezerocost)/(1-p.curve_above_curvatureofMACcurveabovezerocost))/ (v.qmax_maxreferencereductions[t,r] - v.q0_absolutecutbacksatnegativecost[t,r])
        v.ahi_[t,r] = v.cmax_[t,r]/(exp(v.bhi_[t,r]*(v.qmax_maxreferencereductions[t,r]-v.q0_absolutecutbacksatnegativecost[t,r]))-1)

        if v.cbe_absoluteemissionreductions[t,r]< v.q0_absolutecutbacksatnegativecost[t,r]
            v.mc_[t,r] = v.alo_[t,r]* (exp(v.blo_[t,r]*(v.cbe_absoluteemissionreductions[t,r]- v.q0_absolutecutbacksatnegativecost[t,r]))-1)
        else
            v.mc_[t,r] = v.ahi_[t,r]*(exp(v.bhi_[t,r]*(v.cbe_absoluteemissionreductions[t,r]- v.q0_absolutecutbacksatnegativecost[t,r]))-1)
        end

        if v.q0_absolutecutbacksatnegativecost[t,r] == 0.
            v.tcq0_[t,r] = 0.
        else
            v.tcq0_[t,r] = (v.alo_[t,r]/v.blo_[t,r])*(1-exp(-v.blo_[t,r]* v.q0_absolutecutbacksatnegativecost[t,r]))- v.alo_[t,r]*v.q0_absolutecutbacksatnegativecost[t,r]
        end

        if v.cbe_absoluteemissionreductions[t,r]<v.q0_absolutecutbacksatnegativecost[t,r]
            v.tc_[t,r] = (v.alo_[t,r]/v.blo_[t,r])*(exp(v.blo_[t,r]*(v.cbe_absoluteemissionreductions[t,r]- v.q0_absolutecutbacksatnegativecost[t,r]))- exp(-v.blo_[t,r]*v.q0_absolutecutbacksatnegativecost[t,r])) - v.alo_[t,r]*v.cbe_absoluteemissionreductions[t,r]
        else
            v.tc_[t,r] = (v.ahi_[t,r]/v.bhi_[t,r])* (exp(v.bhi_[t,r]*(v.cbe_absoluteemissionreductions[t,r]-v.q0_absolutecutbacksatnegativecost[t,r]))-1) - v.ahi_[t,r]*(v.cbe_absoluteemissionreductions[t,r] - v.q0_absolutecutbacksatnegativecost[t,r]) + v.tcq0_[t,r]
        end

        #sum the gases in another component
        v.tct_[t,r] =
        v.tct_per_cap[t,r] = v.tct_[t,r]/


end

function addabatementcosts(model::Model, class::Symbol)
    abatementcostscomp = addcomponent(model, AbatementCosts, symbol("AbatementCosts$class"))

    abatementcostscomp[:q0propmult_cutbacksatnegativecostinfinalyear] = .73
    abatementcostscomp[:qmax_minus_q0propmult_maxcutbacksatpositivecostinfinalyear] = 1.27
    abatementcostscomp[:c0mult_mostnegativecostinfinalyear] = .83
    abatementcostscomp[:curve_below_curvatureofMACcurvebelowzerocost] = .5
    abatementcostscomp[:curve_above_curvatureofMACcurveabovezerocost] = .4
    abatementcostscomp[:cross_experiencecrossoverratio] = .2
    abatementcostscomp[:learn_learningrate] = .2
    abatementcostscomp[:automult_autonomoustechchange] = .22
    abatementcostscomp[:equity_prop_equityweightsproportion] = 1.
    abatementcostscomp[:y_year_0] = 2008.

    if class == :CO2
        abatementcostscomp[:emit_UncertaintyinBAUEmissFactorinFocusRegioninFinalYear] = 8.33
        abatementcostscomp[:q0propinit_CutbacksinNegativeCostinFocusRegioninBaseYear] = 20.
        abatementcostscomp[:c0init_MostNegativeCostCutbackinBaseYear] = -233.33
        abatementcostscomp[:qmaxminusq0propinit_MaxCutbackCostatPositiveCostinBaseYear] = 70.
        abatementcostscomp[:cmaxinit_MaximumCutbackCostinFocusRegioninBaseYear] = 400.
        abatementcostscomp[:ies_InitialExperienceStockofCutbacks] = 150000.
        abatementcostscomp[:er_emissionsgrowth]= readdata("../data/er_CO2emissionsgrowth.csv")
        abatementcostscomp[:e0_baselineemissions]= readdata("../data/e0_baselineC02emissions.csv")
        abatementcostscomp[:bau_businessasusualemissions] = readdata("../data/bau_co2emissions.csv")
    elseif class == :CH4
        abatementcostscomp[:emit_UncertaintyinBAUEmissFactorinFocusRegioninFinalYear] = 25.
        abatementcostscomp[:q0propinit_CutbacksinNegativeCostinFocusRegioninBaseYear] = 10.
        abatementcostscomp[:c0init_MostNegativeCostCutbackinBaseYear] = -4333.33
        abatementcostscomp[:qmaxminusq0propinit_MaxCutbackCostatPositiveCostinBaseYear] = 51.67
        abatementcostscomp[:cmaxinit_MaximumCutbackCostinFocusRegioninBaseYear] = 6333.33
        abatementcostscomp[:ies_InitialExperienceStockofCutbacks] = 2000.
        abatementcostscomp[:er_emissionsgrowth]= readdata("../data/er_CH4emissionsgrowth.csv")
        abatementcostscomp[:e0_baselineemissions]= readdata("../data/e0_baselineCH4emissions.csv")
        abatementcostscomp[:bau_businessasusualemissions] = readdata("../data/bau_ch4emissions.csv")
    elseif class == :N20
        abatementcostscomp[:emit_UncertaintyinBAUEmissFactorinFocusRegioninFinalYear] = 0.
        abatementcostscomp[:q0propinit_CutbacksinNegativeCostinFocusRegioninBaseYear] = 10.
        abatementcostscomp[:c0init_MostNegativeCostCutbackinBaseYear] = -7333.33
        abatementcostscomp[:qmaxminusq0propinit_MaxCutbackCostatPositiveCostinBaseYear] = 51.67
        abatementcostscomp[:cmaxinit_MaximumCutbackCostinFocusRegioninBaseYear] = 27333.33
        abatementcostscomp[:ies_InitialExperienceStockofCutbacks] = 53.33
        abatementcostscomp[:er_emissionsgrowth]= readdata("../data/er_N20emissionsgrowth.csv")
        abatementcostscomp[:e0_baselineemissions]= readdata("../data/e0_baselineN20emissions.csv")
        abatementcostscomp[:bau_businessasusualemissions] = readdata("../data/bau_n20emissions.csv")
    elseif class == :Lin
        abatementcostscomp[:emit_UncertaintyinBAUEmissFactorinFocusRegioninFinalYear] = 0.
        abatementcostscomp[:q0propinit_CutbacksinNegativeCostinFocusRegioninBaseYear] = 10.
        abatementcostscomp[:c0init_MostNegativeCostCutbackinBaseYear] = -233.33
        abatementcostscomp[:qmaxminusq0propinit_MaxCutbackCostatPositiveCostinBaseYear] = 70.
        abatementcostscomp[:cmaxinit_MaximumCutbackCostinFocusRegioninBaseYear] = 333.33
        abatementcostscomp[:ies_InitialExperienceStockofCutbacks] = 2000.
        abatementcostscomp[:er_emissionsgrowth]= readdata("../data/er_LGemissionsgrowth.csv")
        abatementcostscomp[:e0_baselineemissions]= readdata("../data/e0_baselineLGemissions.csv")
        abatementcostscomp[:bau_businessasusualemissions] = readdata("../data/bau_linemissions.csv")
    else
        error("Unknown class of abatement costs.")
    end

    return abatementcostscomp
end
