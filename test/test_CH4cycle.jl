using Mimi

include("../src/CH4cycle.jl")

m = Model()
setindex(m, :time, 10)

addcomponent(m, ch4cycle)

setparameter(m, :ch4cycle, :e_globalCH4emissions, ones(10))
setparameter(m, :ch4cycle, :pic_preindustconcCH4, 700.)
setparameter(m, :ch4cycle, :c0_CH4concbaseyr, 1760.)
setparameter(m, :ch4cycle, :air_CH4fractioninatm, 100.)
setparameter(m, :ch4cycle, :y_year, [2001.,2002.,2010.,2020.,2040.,2060.,2080.,2100.,2150.,2200.])
setparameter(m, :ch4cycle, :y_year_0, 2000.)
setparameter(m, :ch4cycle, :res_CH4atmlifetime, 10.5)
setparameter(m, :ch4cycle, :den_CH4density, 2.78)
setparameter(m, :ch4cycle, :stim_emissionfeedback, 0.)
setparameter(m, :ch4cycle, :rtl_g_0_realizedtemp, 0.5)
setparameter(m, :ch4cycle, :rtl_g_landtemperature, ones(10))

##running Model
run(m)
