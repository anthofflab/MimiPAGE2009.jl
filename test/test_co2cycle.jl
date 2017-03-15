using Mimi
using Base.Test

include("../src/load_parameters.jl")
include("../src/CO2cycle.jl")

m = Model()

setindex(m, :time, [2009.,2010.,2020.,2030.,2040.,2050.,2075.,2100.,2150.,2200.])
setindex(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])

addCO2cycle(m)

globalemissionsarray=readpagedata(m, joinpath(dirname(@__FILE__), "validationdata","e_globalCO2emissions.csv"))
globalemissions=vec(sum(globalemissionsarray,2))
setparameter(m, :co2cycle, :e_globalCO2emissions, globalemissions)
setparameter(m, :co2cycle, :y_year,[2009.,2010.,2020.,2030.,2040.,2050.,2075.,2100.,2150.,2200.])#real values
setparameter(m, :co2cycle, :y_year_0,2008.)#real value
setparameter(m, :co2cycle, :rt_g0_baseglobaltemp,[0.93]) #value was 0.74
temp2=readpagedata(m, joinpath(dirname(@__FILE__), "validationdata","rtl_g_landtemperature.csv")) #average of regional land temperatures
globallandtemp=vec(sum(temp2,2)/8)
setparameter(m, :co2cycle, :rt_g_globaltemperature, globallandtemp)
p=load_parameters(m)
setleftoverparameters(m,p) #important for setting left over component values
##running Model
run(m)

m[:co2cycle,  :c_CO2concentration]
