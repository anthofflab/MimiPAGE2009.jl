using Mimi
using Base.Test

include("../src/load_parameters.jl")
include("../src/N2Oemissions.jl")

m = Model()
setindex(m, :time, [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200])
setindex(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])

addcomponent(m, n2oemissions)

setparameter(m, :n2oemissions, :e0_baselineN2Oemissions, [1.40,1.23,0.66])
setparameter(m, :n2oemissions, :er_N2Oemissionsgrowth, reshape(randn(30),10,3))

##running Model
run(m)

@test !isna(m[:N2Oemissions, :e_globalN2Oemissions][10])
