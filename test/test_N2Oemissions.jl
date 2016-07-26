using Mimi

include("../src/N2Oemissions.jl")

m = Model()
setindex(m, :time, 10)
setindex(m, :region, ["Region 1", "Region 2", "Region 3"])

addcomponent(m, n2oemissions)

setparameter(m, :n2oemissions, :e0_baselineN2Oemissions, [1.40,1.23,0.66])
setparameter(m, :n2oemissions, :er_N2Oemissionsgrowth, reshape(randn(30),10,3))

##running Model
run(m)
