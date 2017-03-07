using Mimi
using Base.Test

include("../src/load_parameters.jl")
include("../src/CH4cycle.jl")

m = Model()
setindex(m, :time, [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200])
setindex(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])

addCH4cycle(m)

setparameter(m, :ch4cycle, :e_globalCH4emissions, readpagedata(m, joinpath(dirname(@__FILE__), "validationdata","e_globalCH4emissions.csv")))
setparameter(m, :ch4cycle, :y_year, [2009.,2010.,2020.,2040.,2060.,2080.,2100.,2150.,2200.]) #real value
setparameter(m, :ch4cycle, :y_year_0, 2008.) #real value
setparameter(m, :ch4cycle, :rtl_g0_baselandtemp, [0.93])
setparameter(m, :ch4cycle, :rtl_g_landtemperature, readpagedata(m, joinpath(dirname(@__FILE__), "validationdata","rtl_g_landtemperature.csv"))

##running Model
run(m)

<<<<<<< HEAD
#@test !isna(m[:ch4cycle, :c_CH4concentration][10])
m[:ch4cycle,  :c_CH4concentration]
=======
@test !isnan(m[:ch4cycle, :c_CH4concentration][10])
>>>>>>> d2699b2b0f70aacf724333646128ebf2530ad2f2
