using Mimi

include("..\src\LGcycle.jl")

m = Model()

setindex(m, :time, 10)

addcomponent(m, LGcycle)

setparameter(m, :LGcycle, :e_globalLGemissions, ones(10))
setparameter(m, :LGcycle, :pic_preindustconcLG, 0) # real value
setparameter(m, :LGcycle, :c0_LGconcbaseyr, 1950) #http://cdiac.ornl.gov/oceans/new_atmCFC.html
setparameter(m, :LGcycle, :air_LGfractioninatm, 0.04)
setparameter(m, :LGcycle, :y_year, [2001.,2002.,2010.,2020.,2040.,2060.,2080.,2100.,2150.,2200.])
setparameter(m, :LGcycle, :y_year_0, 2000.)
setparameter(m, :LGcycle, :den_LGdensity, 100000.) # real value
setparameter(m, :LGcycle, :stim_emissionfeedback, 0) # real value
setparameter(m, :LGcycle, :rtl_g_0_realizedtemp, 0.5)
setparameter(m, :LGcycle, :rtl_g_landtemperature, ones(10))

# run Model
run(m)
