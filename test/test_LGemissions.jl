using Mimi
using Base.Test

include("../src/components/LGemissions.jl")
include("../src/utils/load_parameters.jl")

m = Model()

setindex(m, :time, [2009.,2010.,2020.,2030.,2040.,2050.,2075.,2100.,2150.,2200.])
setindex(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])


addcomponent(m, LGemissions)

setparameter(m, :LGemissions, :e0_baselineLGemissions, readpagedata(m,"data/e0_baselineLGemissions.csv"))
setparameter(m, :LGemissions, :er_LGemissionsgrowth, readpagedata(m, "data/er_LGemissionsgrowth.csv"))

# run Model
run(m)

emissions= m[:LGemissions,  :e_regionalLGemissions]
emissions_compare=readpagedata(m, "test/validationdata/e_regionalLGemissions.csv")

@test emissions ≈ emissions_compare rtol=1e-3
