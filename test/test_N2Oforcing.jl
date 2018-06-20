using Mimi
using Base.Test

include("../src/components/N2Oforcing.jl")

m = Model()
set_dimension!(m, :time, [2009.,2010.,2020.,2030.,2040., 2050., 2075., 2100., 2150., 2200.])
set_dimension!(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])

addN2Oforcing(m)

set_parameter!(m, :n2oforcing, :c_N2Oconcentration, readpagedata(m,"test/validationdata/c_n2oconcentration.csv"))
set_parameter!(m, :n2oforcing, :c_CH4concentration, readpagedata(m,"test/validationdata/c_ch4concentration.csv"))

##running Model
run(m)

forcing=m[:n2oforcing,:f_N2Oforcing]
forcing_compare=readpagedata(m,"test/validationdata/f_n2oforcing.csv")

@test forcing ≈ forcing_compare rtol=1e-3
