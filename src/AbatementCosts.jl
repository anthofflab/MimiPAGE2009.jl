
@defcomp AbatementCosts begin
    region = Index(region)
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
    automult_autonomoustechchange = Parameter(unit="none")
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
        #check with Chris Hope about missing parentheses

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

function addabatementcosts(model::Model, class::Symbol)
    abatementcostscomp = addcomponent(model, AbatementCosts, symbol("AbatementCosts$class"))

    abatementcostscomp[:q0propmult_cutbacksatnegativecostinfinalyear] = .73
    abatementcostscomp[:qmax_minus_q0propmult_maxcutbacksatpositivecostinfinalyear] = 1.27
    abatementcostscomp[:c0mult_mostnegativecostinfinalyear] = .83
    abatementcostscomp[:curve_below_curvatureofMACcurvebelowzerocost] = .5
    abatementcostscomp[:curve_above_curvatureofMACcurveabovezerocost] = .4
    abatementcostscomp[:cross_experiencecrossoverratio] = .2
    abatementcostscomp[:learn_learningrate] = .2
    abatementcostscomp[:automult_autonomoustechchange] = .65
    abatementcostscomp[:equity_prop_equityweightsproportion] = 1.
    abatementcostscomp[:y_year_0] = 2008.

    if class == :CO2
        abatementcostscomp[:emit_UncertaintyinBAUEmissFactorinFocusRegioninFinalYear] = 8.33
        abatementcostscomp[:q0propinit_CutbacksinNegativeCostinFocusRegioninBaseYear] = 20.
        abatementcostscomp[:c0init_MostNegativeCostCutbackinBaseYear] = -233.333333333333
        abatementcostscomp[:qmaxminusq0propinit_MaxCutbackCostatPositiveCostinBaseYear] = 70.
        abatementcostscomp[:cmaxinit_MaximumCutbackCostinFocusRegioninBaseYear] = 400.
        abatementcostscomp[:ies_InitialExperienceStockofCutbacks] = 150000.
        abatementcostscomp[:er_emissionsgrowth]= readpagedata(model, joinpath(dirname(@__FILE__), "..","data","er_CO2emissionsgrowth.csv"))
        abatementcostscomp[:e0_baselineemissions]= readpagedata(model, joinpath(dirname(@__FILE__),"..", "data","e0_baselineCO2emissions.csv"))
        abatementcostscomp[:bau_businessasusualemissions] = readpagedata(model, joinpath(dirname(@__FILE__),"..","data","bau_co2emissions.csv"))
    elseif class == :CH4
        abatementcostscomp[:emit_UncertaintyinBAUEmissFactorinFocusRegioninFinalYear] = 25.
        abatementcostscomp[:q0propinit_CutbacksinNegativeCostinFocusRegioninBaseYear] = 10.
        abatementcostscomp[:c0init_MostNegativeCostCutbackinBaseYear] = -4333.3333333333333
        abatementcostscomp[:qmaxminusq0propinit_MaxCutbackCostatPositiveCostinBaseYear] = 51.67
        abatementcostscomp[:cmaxinit_MaximumCutbackCostinFocusRegioninBaseYear] = 6333.33
        abatementcostscomp[:ies_InitialExperienceStockofCutbacks] = 2000.
        abatementcostscomp[:er_emissionsgrowth]= readpagedata(model, joinpath(dirname(@__FILE__), "..","data","er_CH4emissionsgrowth.csv"))
        abatementcostscomp[:e0_baselineemissions]= readpagedata(model, joinpath(dirname(@__FILE__), "..","data","e0_baselineCH4emissions.csv"))
        abatementcostscomp[:bau_businessasusualemissions] = readpagedata(model, joinpath(dirname(@__FILE__), "..","data","bau_ch4emissions.csv"))
    elseif class == :N2O
        abatementcostscomp[:emit_UncertaintyinBAUEmissFactorinFocusRegioninFinalYear] = 0.
        abatementcostscomp[:q0propinit_CutbacksinNegativeCostinFocusRegioninBaseYear] = 10.
        abatementcostscomp[:c0init_MostNegativeCostCutbackinBaseYear] = -7333.333333333333
        abatementcostscomp[:qmaxminusq0propinit_MaxCutbackCostatPositiveCostinBaseYear] = 51.67
        abatementcostscomp[:cmaxinit_MaximumCutbackCostinFocusRegioninBaseYear] = 27333.33
        abatementcostscomp[:ies_InitialExperienceStockofCutbacks] = 53.33
        abatementcostscomp[:er_emissionsgrowth]= readpagedata(model, joinpath(dirname(@__FILE__), "..","data","er_N2Oemissionsgrowth.csv"))
        abatementcostscomp[:e0_baselineemissions]= readpagedata(model, joinpath(dirname(@__FILE__), "..","data","e0_baselineN2Oemissions.csv"))
        abatementcostscomp[:bau_businessasusualemissions] = readpagedata(model, joinpath(dirname(@__FILE__), "..","data","bau_n2oemissions.csv"))
    elseif class == :Lin
        abatementcostscomp[:emit_UncertaintyinBAUEmissFactorinFocusRegioninFinalYear] = 0.
        abatementcostscomp[:q0propinit_CutbacksinNegativeCostinFocusRegioninBaseYear] = 10.
        abatementcostscomp[:c0init_MostNegativeCostCutbackinBaseYear] = -233.333333333333
        abatementcostscomp[:qmaxminusq0propinit_MaxCutbackCostatPositiveCostinBaseYear] = 70.
        abatementcostscomp[:cmaxinit_MaximumCutbackCostinFocusRegioninBaseYear] = 333.33
        abatementcostscomp[:ies_InitialExperienceStockofCutbacks] = 2000.
        abatementcostscomp[:er_emissionsgrowth]= readpagedata(model,joinpath(dirname(@__FILE__), "..","data","er_LGemissionsgrowth.csv"))
        abatementcostscomp[:e0_baselineemissions]= readpagedata(model,joinpath(dirname(@__FILE__), "..","data","e0_baselineLGemissions.csv"))
        abatementcostscomp[:bau_businessasusualemissions] = readpagedata(model,joinpath(dirname(@__FILE__), "..","data","bau_linemissions.csv"))
    else
        error("Unknown class of abatement costs.")
    end

    return abatementcostscomp
end
