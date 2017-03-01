using Mimi

include("../src/load_parameters.jl")
include("../src/LGcycle.jl")

m = Model()

setindex(m, :time, [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200])

addcomponent(m, LGcycle)

setparameter(m, :LGcycle, :e_globalLGemissions, ones(10))
setparameter(m, :LGcycle, :y_year, [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200])
setparameter(m, :LGcycle, :y_year_0, 2009.)
setparameter(m, :LGcycle, :rtl_g_0_realizedtemp, [0.5]) #why is this a different variable than in the other cycles?
setparameter(m, :LGcycle, :rtl_g_landtemperature, readpagedata(m, joinpath(dirname(@__FILE__), "validationdata","rtl_g_landtemperature.csv"))

# run Model
run(m)
