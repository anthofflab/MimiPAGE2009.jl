using Mimi
using Base.Test

include("../src/components/CO2forcing.jl")

m = Model()
setindex(m, :time, [2009.,2010.,2020.,2030.,2040., 2050., 2075., 2100., 2150., 2200.])
setindex(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])

addCO2forcing(m)

setparameter(m, :co2forcing, :c_CO2concentration, readpagedata(m,"test/validationdata/c_co2concentration.csv"))

##running Model
run(m)

forcing=m[:co2forcing,:f_CO2forcing]
forcing_compare=readpagedata(m,"test/validationdata/f_co2forcing.csv")

@test forcing ≈ forcing_compare rtol=1e-3
