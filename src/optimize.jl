using Mimi
using OptiMimi

include("getpagefunction.jl")
m = buildpage()

@defcomp AbatementScale begin
    q0propinit = Parameter(unit="% of BAU emissions")

    co2_q0propinit = Variable(unit="% of BAU emissions")
    ch4_q0propinit = Variable(unit="% of BAU emissions")
    n2o_q0propinit = Variable(unit="% of BAU emissions")
    lin_q0propinit = Variable(unit="% of BAU emissions")
end

function init(s::AbatementScale)
    v = s.Variables
    p = s.Parameters
    d = s.Dimensions

    v.co2_q0propinit = v.ch4_q0propinit = v.n2o_q0propinit = v.lin_q0propinit = p.q0propinit
end

function run_timestep(s::AbatementScale, t::Int64)
    v = s.Variables
    p = s.Parameters
    d = s.Dimensions

    v.co2_q0propinit = v.ch4_q0propinit = v.n2o_q0propinit = v.lin_q0propinit = p.q0propinit
end

abatementscale = addcomponent(m, AbatementScale)
connectparameter(m, :AbatementCostsCO2, :q0propinit_CutbacksinNegativeCostinFocusRegioninBaseYear, :AbatementScale, :co2_q0propinit)
connectparameter(m, :AbatementCostsCH4, :q0propinit_CutbacksinNegativeCostinFocusRegioninBaseYear, :AbatementScale, :ch4_q0propinit)
connectparameter(m, :AbatementCostsN2O, :q0propinit_CutbacksinNegativeCostinFocusRegioninBaseYear, :AbatementScale, :n2o_q0propinit)
connectparameter(m, :AbatementCostsLin, :q0propinit_CutbacksinNegativeCostinFocusRegioninBaseYear, :AbatementScale, :lin_q0propinit)

# Initial value of q0propinit
setparameter(m, :AbatementScale, :q0propinit, 10.)

initpage(m)
run(m)

#objective(model::Model) = -model[:EquityWeighting, :te_totaleffect]

function bestpolicy(model::Model)
    -model[:EquityWeighting, :te_totaleffect]
end

optprob = problem(m, [:AbatementScale], [:q0propinit], [0.], [100.0], bestpolicy)
(maxf, maxx) = solution(optprob, () -> [10.])

# (-2.04735392060811e8,[100.0])

function worstpolicy(model::Model)
    model[:EquityWeighting, :te_totaleffect]
end

optprob = problem(m, [:AbatementScale], [:q0propinit], [0.], [100.0], worstpolicy)
(maxf, maxx) = solution(optprob, () -> [10.])

# (2.373957504679534e8,[0.0])
