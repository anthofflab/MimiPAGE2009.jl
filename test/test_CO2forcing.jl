
using Test

m = page_model()
include("../src/components/CO2forcing.jl")

add_comp!(m, co2forcing)

set_param!(m, :co2forcing, :c_CO2concentration, readpagedata(m,"test/validationdata/c_co2concentration.csv"))

##running Model
run(m)

forcing=m[:co2forcing,:f_CO2forcing]
forcing_compare=readpagedata(m,"test/validationdata/f_co2forcing.csv")

@test forcing ≈ forcing_compare rtol=1e-3
