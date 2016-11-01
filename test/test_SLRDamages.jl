using Mimi

include("../src/SLRDamages.jl")

m = Model()
setindex(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])
setindex(m, :time, 10)

slrdamages = addslrdamages(m)

slrdamages[:rt_g_globaltemperature] = ones(10)
slrdamages[:y_year] = [2001.,2002.,2010.,2020.,2040.,2060.,2080.,2100.,2150.,2200.] #real value
slrdamages[:y_year_0] = 2000.

##running Model
run(m)
