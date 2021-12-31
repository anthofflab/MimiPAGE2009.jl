
using Test

m = test_page_model()
include("../src/components/LGemissions.jl")

add_comp!(m, LGemissions)

update_param!(m, :LGemissions, :e0_baselineLGemissions, readpagedata(m,"data/e0_baselineLGemissions.csv"))
update_param!(m, :LGemissions, :er_LGemissionsgrowth, readpagedata(m, "data/er_LGemissionsgrowth.csv"))

# run Model
run(m)

emissions= m[:LGemissions,  :e_regionalLGemissions]
emissions_compare=readpagedata(m, "test/validationdata/e_regionalLGemissions.csv")

@test emissions ≈ emissions_compare rtol=1e-3
