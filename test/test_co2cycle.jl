using Mimi
using Base.Test

include("../src/load_parameters.jl")
include("../src/CO2cycle.jl")

m = Model()

setindex(m, :time, [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200])

addcomponent(m, co2cycle)

setparameter(m, :co2cycle, :e_globalCO2emissions,collect(8.:17.)) #collect syntax?
setparameter(m, :co2cycle, :y_year,[2009.,2010.,2020.,2030.,2040.,2050.,2075.,2100.,2150.,2200.])#real values
setparameter(m, :co2cycle, :y_year_0,2008.)#real value
setparameter(m, :co2cycle, :rt_g0_baseglobaltemp,[0.8]) #why are these variable names different than in the other cycles?
setparameter(m, :co2cycle, :rt_g_globaltemperature,collect(0.9:0.2:2.7)) #

##running Model
run(m)

@test !isna(m[:co2cycle, :c_co2concentration][10])
