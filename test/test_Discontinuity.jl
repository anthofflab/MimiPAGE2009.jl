using Mimi

include("../src/Discontinuity.jl")

m = Model()
setindex(m, :time, 10)
setindex(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])

addcomponent(m, Discontinuity)

setparameter(m, :Discontinuity, :rt_g_globaltemperature, ones(10))
setparameter(m, :Discontinuity, :y_year_0, 2008.)
setparameter(m, :Discontinuity, :y_year, [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200])
setparameter(m, :Discontinuity, :wincf_weightsfactor, [1, 0.8, 0.8, 0.4, 0.8, 0.8, 0.6, 0.6])
setparameter(m, :Discontinuity, :wdis_gdplostdisc, 0.15)
setparameter(m, :Discontinuity, :rgdp_per_cap_NonMarketRemainGDP, ones(10,8))
setparameter(m, :Discontinuity, :rcons_per_cap_NonMarketRemainConsumption, ones(10,8))

##running Model
run(m)
