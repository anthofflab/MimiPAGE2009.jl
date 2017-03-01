using Mimi
using Base.Test

include("../src/load_parameters.jl")
include("../src/N2Ocycle.jl")

m = Model()
setindex(m, :time, [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200])

addN2Ocycle(m)

setparameter(m, :n2ocycle, :e_globalN2Oemissions, ones(10))
setparameter(m, :n2ocycle, :y_year, [2009.,2010.,2020.,2030.,2040.,2050.,2075.,2100.,2150.,2200.]) #real value
setparameter(m, :n2ocycle, :y_year_0, 2008.) #real value
setparameter(m, :n2ocycle, :rtl_g0_baselandtemp, [0.93])
setparameter(m, :n2ocycle, :rtl_g_landtemperature, readpagedata(m, joinpath(dirname(@__FILE__), "validationdata","rtl_g_landtemperature.csv"))

##running Model
run(m)

@test !isna(m[:N2Ocycle, :c_N2Oconcentration][10])
