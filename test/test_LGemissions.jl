using Mimi

include("../src/LGemissions.jl")

m = Model()

setindex(m, :time, 10)
setindex(m, :region, ["Region 1", "Region 2", "Region 3"])

addcomponent(m, LGemissions)

setparameter(m, :LGemissions, :e0_baselineLGemissions, [73.62, 191.64, 69.02])
setparameter(m, :LGemissions, :er_LGemissionsgrowth, fill(10.,(10,3)))

# run Model
run(m)
