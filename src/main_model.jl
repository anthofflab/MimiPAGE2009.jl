using Mimi
include("load_parameters.jl")
include("CO2forcing.jl")
include("ClimateTemperature.jl")

m = Model()
setindex(m, :time, [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200])
setindex(m, :region, ["EU", "USA", "OECD", "Africa", "China", "SAsia", "LAmerica", "USSR"])
co2forcingref = addcomponent(m, co2forcing)
climatetemperature = addcomponent(m, ClimateTemperature)
# connectparameter(m, :ClimateTemperature, :ft_totalforcing, :co2forcing, :f_CO2forcing)
# alternative method
climatetemperature[:ft_totalforcing] = co2forcingref[:f_CO2forcing]

#climatetemperature[:y_year_0] = 2008.
climatetemperature[:fslope_CO2forcingslope] = 5.5

# next: add vector and panel example
p = load_parameters()
p["y_year_0"] = 2008.
setleftoverparameters(m, p)

run(m)
