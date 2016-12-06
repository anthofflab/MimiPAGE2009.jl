using Mimi

include("../src/Discontinuity.jl")

m = Model()
setindex(m, :time, 10)
setindex(m, :region, ["Region 1", "Region 2", "Region 3"])

addcomponent(m, Discontinuity)

setparameter(m, :Discontinuity, :rt_g_globaltemperature, ones(10))
setparameter(m, :Discontinuity, :y_year, [2001.,2002.,2010.,2020.,2040.,2060.,2080.,2100.,2150.,2200.]) #real value
setparameter(m, :Discontinuity, :y_year_0, 2000.) #real value

##running Model
run(m)

pwd()
