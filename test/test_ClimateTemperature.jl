using Mimi

include("../src/ClimateTemperature.jl")
m = Model()
setindex(m, :time, 10)
setindex(m, :region, ["Region 1", "Region 2", "Region 3"])
#Order of addcomponent is important
addcomponent(m, ClimateTemperature)
area = Parameter(index=[region], unit="km2")
y_year = Parameter(index=[time], unit="year")

sens_climatesensitivity = Parameter(unit="degreeC")
ocean_climatehalflife = Parameter(unit="year")
fslope_forcingslope = Parameter(unit="W/m2")

ft_totalforcing = Parameter(index=[time], unit="W/m2")
fs_sulfateforcing = Parameter(index=[time], unit="W/m2")

rt_0_realizedtemperature = Parameter(index=[region], unit="degreeC")
#setparameter(m, :emissions, :gdp, ones(10))
setparameter(m, :emissions, :intensity0, 5.)
setparameter(m, :emissions, :g_intensity, -0.01)

#Connect components
#connectparameter(model, target component, target parameter, source component, source parameter)
connectparameter(m, :emissions, :gdp, :gdp, :gdp)
#names should be differentiated
#should create separate files. modularity.

##running Model
run(m)

#Access the variable outcomes
m[:emissions, :emissions]
