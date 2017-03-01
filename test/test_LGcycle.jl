using Mimi

include("../src/LGcycle.jl")

m = Model()

setindex(m, :time, 10)

addcomponent(m, LGcycle)

setparameter(m, :LGcycle, :e_globalLGemissions, ones(10))
setparameter(m, :LGcycle, :y_year, [2001.,2002.,2010.,2020.,2040.,2060.,2080.,2100.,2150.,2200.])
setparameter(m, :LGcycle, :y_year_0, 2000.)
setparameter(m, :LGcycle, :rtl_g_0_realizedtemp, [0.93])
setparameter(m, :LGcycle, :rtl_g_landtemperature, ones(10))

# run Model
run(m)
