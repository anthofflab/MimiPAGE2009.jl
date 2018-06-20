using Mimi
using Base.Test

include("../src/utils/load_parameters.jl")
include("../src/components/N2Ocycle.jl")

m = Model()
add_dimension(m, :time, [2009.,2010.,2020.,2030.,2040.,2050.,2075.,2100.,2150.,2200.])
add_dimension(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])

addN2Ocycle(m)

set_parameter!(m, :n2ocycle, :e_globalN2Oemissions, readpagedata(m,"test/validationdata/e_globalN2Oemissions.csv"))
set_parameter!(m, :n2ocycle, :y_year, [2009.,2010.,2020.,2030.,2040.,2050.,2075.,2100.,2150.,2200.]) #real value
set_parameter!(m, :n2ocycle, :y_year_0, 2008.) #real value
set_parameter!(m, :n2ocycle, :rtl_g_landtemperature, readpagedata(m,"test/validationdata/rtl_g_landtemperature.csv"))

##running Model
run(m)

conc=m[:n2ocycle,  :c_N2Oconcentration]
conc_compare=readpagedata(m,"test/validationdata/c_n2oconcentration.csv")

@test conc ≈ conc_compare rtol=1e-4
