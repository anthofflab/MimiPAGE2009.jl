using Mimi

include("../src/N2Ocycle.jl")

m = Model()
setindex(m, :time, 10)

addcomponent(m, n2ocycle)

setparameter(m, :n2ocycle, :e_globalN2Oemissions, ones(10))
setparameter(m, :n2ocycle, :pic_preindustconcN2O, 270.)
setparameter(m, :n2ocycle, :c0_N2Oconcbaseyr, 322.)
setparameter(m, :n2ocycle, :air_N2Ofractioninatm, 100.)
setparameter(m, :n2ocycle, :y_year, [2001.,2002.,2010.,2020.,2040.,2060.,2080.,2100.,2150.,2200.])
setparameter(m, :n2ocycle, :y_year_0, 2000.)
setparameter(m, :n2ocycle, :res_N2Oatmlifetime, 114.)
setparameter(m, :n2ocycle, :den_N2Odensity, 7.8)
setparameter(m, :n2ocycle, :stim_emissionfeedback, 0.)
setparameter(m, :n2ocycle, :rtl_g_0_realizedtemp, 0.5)
setparameter(m, :n2ocycle, :rtl_g_landtemperature, ones(10))

##running Model
run(m)
