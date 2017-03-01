using Mimi

include("../src/LGemissions.jl")
include("../src/load_parameters.jl")

m = Model()

setindex(m, :time, [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200])
setindex(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])

addcomponent(m, LGemissions)

setparameter(m, :LGemissions, :e0_baselineLGemissions, [73.62, 191.64, 69.02])
setparameter(m, :LGemissions, :er_LGemissionsgrowth, fill(10.,(10,3)))

# run Model
run(m)
