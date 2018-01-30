using Mimi
using Base.Test

include("../src/LGforcing.jl")

m = Model()
setindex(m, :time, [2009.,2010.,2020.,2030.,2040., 2050., 2075., 2100., 2150., 2200.])
setindex(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])

addLGforcing(m)

setparameter(m, :LGforcing, :c_LGconcentration, readpagedata(m,"test/validationdata/c_LGconcentration.csv"))

# run Model
run(m)

forcing=m[:LGforcing,:f_LGforcing]
forcing_compare=readpagedata(m,"test/validationdata/f_LGforcing.csv")

@test forcing ≈ forcing_compare rtol=1e-3
