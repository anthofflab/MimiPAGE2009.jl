using Mimi

include("../src/LGemissions.jl")
include("../src/load_parameters.jl")

m = Model()

setindex(m, :time, [2009.,2010.,2020.,2030.,2040.,2050.,2075.,2100.,2150.,2200.])
setindex(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])


addcomponent(m, LGemissions)

setparameter(m, :LGemissions, :e0_baselineLGemissions, [73.61871, 191.6451, 69.02367, 24.67513, 79.08005, 55.24011, 33.74054, 30.18799])
setparameter(m, :LGemissions, :er_LGemissionsgrowth, readpagedata(m, joinpath(dirname(@__FILE__), "..","data","er_LGemissionsgrowth.csv")))

# run Model
run(m)

pop= m[:LGemissions,  :e_globalLGemissions]

# Recorded data
temp=readpagedata(m, joinpath(dirname(@__FILE__), "validationdata","e_globalLGemissions.csv"))
pop_compare=vec(sum(temp,2))

@test_approx_eq_eps pop pop_compare 1e1
