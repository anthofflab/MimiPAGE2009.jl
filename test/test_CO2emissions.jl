using Mimi
using Base.Test

include("../src/load_parameters.jl")
include("../src/CO2emissions.jl")

m = Model()
setindex(m, :time, [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200])
setindex(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])

addcomponent(m, co2emissions)

setparameter(m, :co2emissions, :e0_baselineCO2emissions, [4400.,6183.,2438., 3216., 5040., 8286., 4656., 3971.])
setparameter(m, :co2emissions, :er_CO2emissionsgrowth, readpagedata(m, joinpath(dirname(@__FILE__), "..","data","er_CO2emissionsgrowth.csv")))
#setparameter(m, :ch4emissions, :er_CH4emissionsgrowth, readpagedata(m, joinpath(dirname(@__FILE__), "..","data","er_CO2emissionsgrowth.csv")))

##running Model
run(m)

#@test !isna(m[:co2emissions, :e_globalCO2emissions][10])
m[:co2emissions,  :e_globalCO2emissions]
