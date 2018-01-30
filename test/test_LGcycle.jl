using Mimi
using Base.Test

include("../src/load_parameters.jl")
include("../src/LGcycle.jl")

m = Model()

setindex(m, :time, [2009.,2010.,2020.,2030.,2040.,2050.,2075.,2100.,2150.,2200.])
setindex(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])

addLGcycle(m)

setparameter(m, :LGcycle, :e_globalLGemissions, readpagedata(m,"test/validationdata/e_globalLGemissions.csv"))
setparameter(m, :LGcycle, :y_year, [2009.,2010.,2020.,2030.,2040.,2050.,2075.,2100.,2150.,2200.]) #real value
setparameter(m, :LGcycle, :y_year_0, 2008.) #real value
setparameter(m, :LGcycle, :rtl_g_landtemperature, readpagedata(m,"test/validationdata/rtl_g_landtemperature.csv"))

p=load_parameters(m)
setleftoverparameters(m,p) #important for setting left over component values

# run Model
run(m)

conc=m[:LGcycle,  :c_LGconcentration]
conc_compare=readpagedata(m,"test/validationdata/c_LGconcentration.csv")

@test conc ≈ conc_compare atol=1e-4
