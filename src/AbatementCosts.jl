
@defcomp AbatementCosts begin
    region = Index(region)
    y_year = Parameter(index=[time], unit="year")

    #gas inputs
    emit_UncertaintyinBAUEmissFactorinFocusRegioninFinalYear = Parameter(unit="%")
    q0propinit_CutbacksinNegativeCostinFocusRegioninBaseYear = Parameter(unit="% of BAU emissions")
    c0init_MostNegativeCostCutbackinBaseYear = Parameter(unit="\$/ton")
    qmaxminusq0propinit_MaxCutbackCostatPositiveCostinBaseYear = Parameter(unit="% of BAU emissions")
    cmaxinit_MaximumCutbackCostinFocusRegioninBaseYear = Parameter(unit="\$/ton")
    ies_InitialExperienceStockofCutbacks = Parameter(unit= "Million ton")

    #regional inputs
    emitf_uncertaintyinBAUemissfactor = Parameter(index=[region])
    q0f_negativecostpercentagefactor = Parameter(index=[region])
    cmaxf_maxcostfactor = Parameter(index=[region])

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

    #Variables
    emit_UncertaintyinBAUEmissFactor = Variable(index=[region], unit = "%")
    q0propinit_CutbacksinNegativeCostinBaseYear = Variable(index=[region], unit= "% of BAU emissions")
    cmaxinit_MaxCutbackCostinBaseYear = Variable(index=[region], unit = "\$/ton")


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

        #need to calculate zero-cost emissions like in PAGE02


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

    if class == :CO2
        abatementcostscomp[:emit_UncertaintyinBAUEmissFactorinFocusRegioninFinalYear] = 8.33
        abatementcostscomp[:q0propinit_CutbacksinNegativeCostinFocusRegioninBaseYear] = 20.
        abatementcostscomp[:c0init_MostNegativeCostCutbackinBaseYear] = -233.33
        abatementcostscomp[:qmaxminusq0propinit_MaxCutbackCostatPositiveCostinBaseYear] = 70.
        abatementcostscomp[:cmaxinit_MaximumCutbackCostinFocusRegioninBaseYear] = 400.
        abatementcostscomp[:ies_InitialExperienceStockofCutbacks] = 150000.
    elseif class == :CH4
        abatementcostscomp[:emit_UncertaintyinBAUEmissFactorinFocusRegioninFinalYear] = 25.
        abatementcostscomp[:q0propinit_CutbacksinNegativeCostinFocusRegioninBaseYear] = 10.
        abatementcostscomp[:c0init_MostNegativeCostCutbackinBaseYear] = -4333.33
        abatementcostscomp[:qmaxminusq0propinit_MaxCutbackCostatPositiveCostinBaseYear] = 51.67
        abatementcostscomp[:cmaxinit_MaximumCutbackCostinFocusRegioninBaseYear] = 6333.33
        abatementcostscomp[:ies_InitialExperienceStockofCutbacks] = 2000.
    elseif class == :N20
        abatementcostscomp[:emit_UncertaintyinBAUEmissFactorinFocusRegioninFinalYear] = 0.
        abatementcostscomp[:q0propinit_CutbacksinNegativeCostinFocusRegioninBaseYear] = 10.
        abatementcostscomp[:c0init_MostNegativeCostCutbackinBaseYear] = -7333.33
        abatementcostscomp[:qmaxminusq0propinit_MaxCutbackCostatPositiveCostinBaseYear] = 51.67
        abatementcostscomp[:cmaxinit_MaximumCutbackCostinFocusRegioninBaseYear] = 27333.33
        abatementcostscomp[:ies_InitialExperienceStockofCutbacks] = 53.33
    elseif class == :Lin
        abatementcostscomp[:emit_UncertaintyinBAUEmissFactorinFocusRegioninFinalYear] = 0.
        abatementcostscomp[:q0propinit_CutbacksinNegativeCostinFocusRegioninBaseYear] = 10.
        abatementcostscomp[:c0init_MostNegativeCostCutbackinBaseYear] = -233.33
        abatementcostscomp[:qmaxminusq0propinit_MaxCutbackCostatPositiveCostinBaseYear] = 70.
        abatementcostscomp[:cmaxinit_MaximumCutbackCostinFocusRegioninBaseYear] = 333.33
        abatementcostscomp[:ies_InitialExperienceStockofCutbacks] = 2000.
    else
        error("Unknown class of abatement costs.")
    end

    return abatementcostscomp
end
