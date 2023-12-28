
using Test

m = test_page_model()
include("../src/components/CO2emissions.jl")

add_comp!(m, co2emissions)

p = load_parameters(m)
update_param!(m, :co2emissions, :e0_baselineCO2emissions, p[:shared][:e0_baselineCO2emissions])
update_param!(m, :co2emissions, :er_CO2emissionsgrowth, p[:shared][:er_CO2emissionsgrowth])

##running Model
run(m)

emissions = m[:co2emissions, :e_regionalCO2emissions]

# Recorded data
emissions_compare = readpagedata(m, "test/validationdata/e_regionalCO2emissions.csv")

@test emissions ≈ emissions_compare rtol = 1e-3
