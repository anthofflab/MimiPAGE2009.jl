using Mimi
using Base.Test

include("../src/CH4emissions.jl")

m = Model()
setindex(m, :time, 10)
setindex(m, :region, ["Region 1", "Region 2", "Region 3"])

addcomponent(m, ch4emissions)

setparameter(m, :ch4emissions, :e0_baselineCH4emissions, [25.,63.,43.])
setparameter(m, :ch4emissions, :er_CH4emissionsgrowth, reshape(randn(30),10,3))

##running Model
run(m)

@test !isnan(m[:ch4emissions, :e_globalCH4emissions][10])
