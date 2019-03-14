
using Test

m = page_model()
include("../src/components/N2Oemissions.jl")

add_comp!(m, n2oemissions)

set_param!(m, :n2oemissions, :e0_baselineN2Oemissions, readpagedata(m,"data/e0_baselineN2Oemissions.csv"))
set_param!(m, :n2oemissions, :er_N2Oemissionsgrowth, readpagedata(m, "data/er_N2Oemissionsgrowth.csv"))

##running Model
run(m)

# Generated data
emissions= m[:n2oemissions,  :e_regionalN2Oemissions]
# Recorded data
emissions_compare=readpagedata(m, "test/validationdata/e_regionalN2Oemissions.csv")

@test emissions ≈ emissions_compare rtol=1e-3
