using Mimi
using Base.Test

include("../src/components/LGforcing.jl")

m = Model()
set_dimension!(m, :time, [2009.,2010.,2020.,2030.,2040., 2050., 2075., 2100., 2150., 2200.])
set_dimension!(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])

addcomponent(m, LGforcing)

set_parameter!(m, :LGforcing, :c_LGconcentration, readpagedata(m,"test/validationdata/c_LGconcentration.csv"))

# run Model
run(m)

forcing=m[:LGforcing,:f_LGforcing]
forcing_compare=readpagedata(m,"test/validationdata/f_LGforcing.csv")

@test forcing ≈ forcing_compare rtol=1e-3
