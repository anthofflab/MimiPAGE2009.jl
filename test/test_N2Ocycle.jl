using Mimi
using Base.Test

include("../src/load_parameters.jl")
include("../src/N2Ocycle.jl")

m = Model()
setindex(m, :time, [2009.,2010.,2020.,2030.,2040.,2050.,2075.,2100.,2150.,2200.])
setindex(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])

addN2Ocycle(m)

globalemissionsarray=readpagedata(m, joinpath(dirname(@__FILE__), "validationdata","e_globalN2Oemissions.csv"))
globalemissions=vec(sum(globalemissionsarray,2))
setparameter(m, :n2ocycle, :e_globalN2Oemissions, globalemissions)
setparameter(m, :n2ocycle, :y_year, [2009.,2010.,2020.,2030.,2040.,2050.,2075.,2100.,2150.,2200.]) #real value
setparameter(m, :n2ocycle, :y_year_0, 2008.) #real value
setparameter(m, :n2ocycle, :rtl_g0_baselandtemp, [0.93])
temp2=readpagedata(m, joinpath(dirname(@__FILE__), "validationdata","rtl_g_landtemperature.csv")) #average of regional land temperatures
globallandtemp=vec(sum(temp2,2)/8)
setparameter(m, :n2ocycle, :rtl_g_landtemperature, globallandtemp)

##running Model
run(m)

m[:n2ocycle,  :c_N2Oconcentration]
#@test !isna(m[:N2Ocycle, :c_N2Oconcentration][10])
