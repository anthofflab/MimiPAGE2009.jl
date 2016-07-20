using Mimi
include("CO2forcing.jl")
include("ClimateTemperature.jl")

m = Model()
setindex(m, :time, [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200])
setindex(m, :region, ["EU", "USA", "OECD", "Africa", "China", "SAsia", "LAmerica", "USSR"])
co2forcingref = addcomponent(m, co2forcing)
climatetemperature = addcomponent(m, ClimateTemperature)
connectparameter(m, :ClimateTemperature, :ft_totalforcing, :co2forcing, :f_CO2forcing)
# alternative method
climatetemperature[:ft_totalforcing] = co2forcingref[:f_CO2forcing]
