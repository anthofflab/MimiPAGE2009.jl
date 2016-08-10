using Mimi

include("../src/CO2cycle.jl")

m = Model()

setindex(m, :time, 10)

addcomponent(m, co2cycle)

setparameter(m, :co2cycle, :e_globalCO2emissions,collect(8.:17.))
setparameter(m, :co2cycle, :pic_preindustconcCO2,278000.)#real value
setparameter(m, :co2cycle, :c0_CO2concbaseyr,395000.)#real value
setparameter(m, :co2cycle, :air_CO2fractioninatm,100.)#documentation on this number is missing. Check with Chris Hope
setparameter(m, :co2cycle, :stay_fractionCO2emissionsinatm,0.3)#Check with Chris Hope - in input values this number is given as %, but in description this is described as a fraction
setparameter(m, :co2cycle, :ccf_CO2feedback,9.67)#real value
setparameter(m, :co2cycle, :ccfmax_maxCO2feedback,53.33)#real value
setparameter(m, :co2cycle, :ce_0_basecumCO2emissions,2050000.)#real value
setparameter(m, :co2cycle, :y_year,[2009.,2010.,2020.,2030.,2040.,2050,2075,2100,2150,2200])#real values
setparameter(m, :co2cycle, :y_year_0,2008.)#real value
setparameter(m, :co2cycle, :res_CO2atmlifetime,73.33)#real value
setparameter(m, :co2cycle, :den_CO2density,7.8)#real value
setparameter(m, :co2cycle, :rt_g0_baseglobaltemp,[0.8])
setparameter(m, :co2cycle, :rt_g_globaltemperature,collect(0.9:0.2:2.7))

##running Model
run(m)
