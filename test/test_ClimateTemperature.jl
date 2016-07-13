using Mimi

include("../src/ClimateTemperature.jl")

m = Model()
setindex(m, :time, 10)
setindex(m, :region, ["Region 1", "Region 2", "Region 3"])

addcomponent(m, ClimateTemperature)

setparameter(m, :ClimateTemperature, :area, ones(3))
setparameter(m, :ClimateTemperature, :y_year, collect(1.0:10.0))
setparameter(m, :ClimateTemperature, :sens_climatesensitivity, 3.0)
setparameter(m, :ClimateTemperature, :ocean_climatehalflife, 20.0)
setparameter(m, :ClimateTemperature, :fslope_forcingslope, 0.8)
setparameter(m, :ClimateTemperature, :ft_totalforcing, ones(10).*3)
setparameter(m, :ClimateTemperature, :fs_sulfateforcing, ones(10).*0.5)
setparameter(m, :ClimateTemperature, :rt_0_realizedtemperature, ones(3).*4)

##running Model
run(m)
