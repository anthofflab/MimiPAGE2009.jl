using Mimi
using Base.Test

include("../src/utils/load_parameters.jl")
include("../src/components/CO2emissions.jl")

m = Model()
set_dimension!(m, :time, [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200])
set_dimension!(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])

addcomponent(m, co2emissions)

set_parameter!(m, :co2emissions, :e0_baselineCO2emissions, readpagedata(m,"data/e0_baselineCO2emissions.csv"))
set_parameter!(m, :co2emissions, :er_CO2emissionsgrowth, readpagedata(m, "data/er_CO2emissionsgrowth.csv"))

##running Model
run(m)

emissions= m[:co2emissions,  :e_regionalCO2emissions]

# Recorded data
emissions_compare=readpagedata(m, "test/validationdata/e_regionalCO2emissions.csv")

@test emissions ≈ emissions_compare rtol=1e-3
