using Base.Test

# Include the model, in all its completeness
include("../src/main_model.jl")

te = m[:EquityWeighting, :te_totaleffect]
te_compare = 213208136.69903600

@test_approx_eq_eps te te_compare 1e-2
