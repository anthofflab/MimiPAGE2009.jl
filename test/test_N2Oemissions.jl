using Mimi
using Base.Test

include("../src/load_parameters.jl")
include("../src/N2Oemissions.jl")

m = Model()
setindex(m, :time, [2009.,2010.,2020.,2030.,2040.,2050.,2075.,2100.,2150.,2200.])
setindex(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])

addcomponent(m, n2oemissions)


setparameter(m, :n2oemissions, :e0_baselineN2Oemissions, [1.400109,1.234923,0.66379, 0.448255, 2.436778, 1.02158, 1.951801, 1.889284])
setparameter(m, :n2oemissions, :er_N2Oemissionsgrowth, readpagedata(m, joinpath(dirname(@__FILE__), "..","data","er_N2Oemissionsgrowth.csv")))

##running Model
run(m)
#@test !isna(m[:N2Oemissions, :e_globalN2Oemissions][10])

# Generated data
pop= m[:n2oemissions,  :e_globalN2Oemissions]

# Recorded data
temp=readpagedata(m, joinpath(dirname(@__FILE__), "validationdata","e_globaln2oemissions.csv"))
pop_compare=vec(sum(temp,2))

@test_approx_eq_eps pop pop_compare 1e-1
