
using Test

m = test_page_model()
include("../src/components/N2Oemissions.jl")

add_comp!(m, n2oemissions)

p = load_parameters(m)

update_param!(m, :n2oemissions, :e0_baselineN2Oemissions, p[:shared][:e0_baselineN2Oemissions])
update_param!(m, :n2oemissions, :er_N2Oemissionsgrowth, p[:shared][:er_N2Oemissionsgrowth])

##running Model
run(m)

# Generated data
emissions = m[:n2oemissions, :e_regionalN2Oemissions]
# Recorded data
emissions_compare = readpagedata(m, "test/validationdata/e_regionalN2Oemissions.csv")

@test emissions ≈ emissions_compare rtol = 1e-3
