using Mimi
using DataFrames
using Base.Test

include("../src/load_parameters.jl")
include("../src/SeaLevelRise.jl")

m = Model()
setindex(m, :time, [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200])

SLR = addSLR(m)
#addcomponent(m, SeaLevelRise)

setparameter(m, :SeaLevelRise, :rt_g_globaltemperature, readpagedata(m, "../test/validationdata/rt_g_globaltemperature.csv"))


p = load_parameters(m)
p["y_year_0"] = 2008.
p["y_year"] = m.indices_values[:time]
setleftoverparameters(m, p)

##running Model
run(m)
