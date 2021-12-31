
using Test

m = test_page_model()
include("../src/components/CO2emissions.jl")

add_comp!(m, co2emissions)

update_param!(m, :co2emissions, :e0_baselineCO2emissions, readpagedata(m,"data/shared_parameters/e0_baselineCO2emissions.csv"))
update_param!(m, :co2emissions, :er_CO2emissionsgrowth, readpagedata(m, "data/shared_parameters/er_CO2emissionsgrowth.csv"))

##running Model
run(m)

emissions= m[:co2emissions,  :e_regionalCO2emissions]

# Recorded data
emissions_compare=readpagedata(m, "test/validationdata/e_regionalCO2emissions.csv")

@test emissions ≈ emissions_compare rtol=1e-3
