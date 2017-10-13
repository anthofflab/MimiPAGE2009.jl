using Mimi
using Base.Test

include("../src/load_parameters.jl")
include("../src/N2Ocycle.jl")

m = Model()
setindex(m, :time, [2009.,2010.,2020.,2030.,2040.,2050.,2075.,2100.,2150.,2200.])
setindex(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])

addN2Ocycle(m)

setparameter(m, :n2ocycle, :e_globalN2Oemissions, readpagedata(m,"test/validationdata/e_globalN2Oemissions.csv"))
setparameter(m, :n2ocycle, :y_year, [2009.,2010.,2020.,2030.,2040.,2050.,2075.,2100.,2150.,2200.]) #real value
setparameter(m, :n2ocycle, :y_year_0, 2008.) #real value
setparameter(m, :n2ocycle, :rtl_g_landtemperature, readpagedata(m,"test/validationdata/rtl_g_landtemperature.csv"))

##running Model
run(m)

conc=m[:n2ocycle,  :c_N2Oconcentration]
conc_compare=readpagedata(m,"test/validationdata/c_n2oconcentration.csv")

@test_approx_eq_eps conc conc_compare 1e-4
