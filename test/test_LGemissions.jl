
using Test

m = test_page_model()
include("../src/components/LGemissions.jl")

add_comp!(m, LGemissions)

p = load_parameters(m)

update_param!(m, :LGemissions, :e0_baselineLGemissions, p[:shared][:e0_baselineLGemissions])
update_param!(m, :LGemissions, :er_LGemissionsgrowth, p[:shared][:er_LGemissionsgrowth])

# run Model
run(m)

emissions = m[:LGemissions, :e_regionalLGemissions]
emissions_compare = readpagedata(m, "test/validationdata/e_regionalLGemissions.csv")

@test emissions ≈ emissions_compare rtol = 1e-3
