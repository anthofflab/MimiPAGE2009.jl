using Mimi
using Base.Test

include("../src/load_parameters.jl")
include("../src/CH4cycle.jl")

m = Model()
setindex(m, :time, [2009.,2010.,2020.,2030.,2040., 2050., 2075.,2100.,2150.,2200.])
setindex(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])

addCH4cycle(m)

temp=readpagedata(m, joinpath(dirname(@__FILE__), "validationdata","e_globalCH4emissions.csv")) #horizontal addition of regions to get globalemissions
globalemissions=vec(sum(temp,2))
setparameter(m, :ch4cycle, :e_globalCH4emissions, globalemissions)
setparameter(m, :ch4cycle, :y_year, [2009.,2010.,2020.,2030.,2040., 2050., 2075.,2100.,2150.,2200.]) #real value
setparameter(m, :ch4cycle, :y_year_0, 2008.) #real value
setparameter(m, :ch4cycle, :rtl_g0_baselandtemp, [0.93])

temp2=readpagedata(m, joinpath(dirname(@__FILE__), "validationdata","rtl_g_landtemperature.csv")) #average of regional land temperatures to get global *DOUBLE CHECK*
globallandtemp=vec(sum(temp2,2)/8)
setparameter(m, :ch4cycle, :rtl_g_landtemperature, globallandtemp)

##running Model
run(m)

m[:ch4cycle,  :c_CH4concentration]
