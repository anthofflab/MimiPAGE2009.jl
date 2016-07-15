using Mimi

include("../src/CO2cycle.jl")
include("../src/ClimateTemperature.jl")


m = Model()

setindex(m, :time, 10)
setindex(m, :region, ["Region 1", "Region 2", "Region 3"])

addcomponent(m, CO2cycle)
addcomponent(m, ClimateTemperature)

setparameter(m, :CO2cycle, :area, ones(3))
setparameter(m, :CO2cycle, :y_year, collect(1.0:10.0))
setparameter(m, :CO2cycle, :c_CO2concentration, collect(2.0:11.0))
setparameter(m, :CO2cycle, :pic_preindustconcCO2, 20.0)
setparameter(m, :CO2cycle, :exc_excessconcCO2, ones(10).*3)
setparameter(m, :CO2cycle, :c0_CO2concbaseyr, 20.0)
setparameter(m, :CO2cycle, :renoccff_remainCO2wocarboncyclefeedback, ones(10, 3).*0.5)
setparameter(m, :CO2cycle, :den_densityofgas, 1.0)
setparameter(m, :CO2cycle, :cea_cumemissionsatm, [-20., 10., 40.])
setparameter(m, :CO2cycle, :ce_basecumemissions, 10.)
setparameter(m, :CO2cycle, :res_CO2atmlifetime, 10.)
setparameter(m, :CO2cycle, :stay_propemissstayatm, 10.)
setparameter(m, :CO2cycle, :gain_linearfeedbackofCO2, 10.)
setparameter(m, :CO2cycle, :re_remainCO2, 10.)
setparameter(m, :CO2cycle, :ccf_climatecarbonfeedbackfactor, 10.)
setparameter(m, :CO2cycle, :ccffmax_climatecarbonfeedbackmax, 10.)




setparameter(m, :CO2cycle, :rt_0_realizedtemperature, ones(3).*4)

#Connect components
connectparameter(m, :CO2cycle, :rt_realizedtemperature, :ClimateTemperature, :rt_realizedtemperature)
connectparameter(m, :CO2cycle, :rt_0_realizedtemperature, :ClimateTemperature, :rt_0_realizedtemperature)


##running Model
run(m)
