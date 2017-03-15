using Mimi

include("../src/load_parameters.jl")
include("../src/LGcycle.jl")

m = Model()

setindex(m, :time, [2009.,2010.,2020.,2030.,2040.,2050.,2075.,2100.,2150.,2200.])
setindex(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])

addLGcycle(m)

globalemissionsarray=readpagedata(m, joinpath(dirname(@__FILE__), "validationdata","e_globalLGemissions.csv"))
globalemissions=vec(sum(globalemissionsarray,2))
setparameter(m, :LGcycle, :e_globalLGemissions, globalemissions)

#setparameter(m, :LGcycle, :e_globalLGemissions, ones(10))
setparameter(m, :LGcycle, :y_year, [2009.,2010.,2020.,2030.,2040.,2050.,2075.,2100.,2150.,2200.]) #real value
setparameter(m, :LGcycle, :y_year_0, 2008.) #real value
setparameter(m, :LGcycle, :rtl_g0_baselandtemp, [0.93]) #originally, was realizedlandtemp=.50

temp2=readpagedata(m, joinpath(dirname(@__FILE__), "validationdata","rtl_g_landtemperature.csv")) #average of regional land temperatures
globallandtemp=vec(sum(temp2,2)/8)
setparameter(m, :LGcycle, :rtl_g_landtemperature, globallandtemp)
#setparameter(m, :LGcycle, :rtl_g_landtemperature, readpagedata(m, joinpath(dirname(@__FILE__), "validationdata","rtl_g_landtemperature.csv"))

p=load_parameters(m)
setleftoverparameters(m,p) #important for setting left over component values

# run Model
run(m)

m[:LGcycle,  :c_LGconcentration]
