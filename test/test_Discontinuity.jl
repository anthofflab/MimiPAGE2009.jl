using Mimi

include("../src/Discontinuity.jl")

m = Model()
setindex(m, :time, [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200])
setindex(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])

addcomponent(m, Discontinuity)

setparameter(m, :Discontinuity, :rt_g_globaltemperature, ones(10))
setparameter(m, :Discontinuity, :y_year, [2009,2010,2020,2030,2040,2050,2075,2100,2150,2200]) 
setparameter(m, :Discontinuity, :y_year_0, 2008)

##running Model
run(m)
