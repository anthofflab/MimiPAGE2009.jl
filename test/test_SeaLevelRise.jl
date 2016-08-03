using Mimi

include("../src/SeaLevelRise.jl")

m = Model()
setindex(m, :time, 10)

addcomponent(m, SeaLevelRise)

setparameter(m, :SeaLevelRise, :rt_g_globaltemperature, ones(10))
setparameter(m, :SeaLevelRise, :sltemp_SLtemprise, 1.73) #real value
setparameter(m, :SeaLevelRise, :sla_SLbaselinerise, 0.15) #real value
setparameter(m, :SeaLevelRise, :sltau_SLresponsetime, 1000.) #real value
setparameter(m, :SeaLevelRise, :s0_initialSL, 3000.)
setparameter(m, :SeaLevelRise, :y_year, [2001.,2002.,2010.,2020.,2040.,2060.,2080.,2100.,2150.,2200.]) #real value
setparameter(m, :SeaLevelRise, :y_year_0, 2000.) #real value

##running Model
run(m)
