using Mimi

include("../src/CO2emissions.jl")

m = Model()
setindex(m, :time, 10)
setindex(m, :region, ["Region 1", "Region 2", "Region 3"])

addcomponent(m, co2emissions)

setparameter(m, :co2emissions, :e0_baselineCO2emissions, [3032.,5606.,2292.])
setparameter(m, :co2emissions, :er_CO2emissionsgrowth, reshape(randn(30),10,3))

##running Model
run(m)
