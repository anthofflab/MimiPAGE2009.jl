using Mimi
using DataFrames
using Base.Test

include("../src/SeaLevelRise.jl")

m = Model()
setindex(m, :time, [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200])

SLR = addSLR(m)

setparameter(m, :SeaLevelRise, :rt_g_globaltemperature, readpagedata(m, "../test/validationdata/rt_g_globaltemperature.csv"))
setparameter(m, :SeaLevelRise, :y_year_0, 2008.)
setparameter(m, :SeaLevelRise, :y_year, [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200])

run(m)


es_equilibriumSL = m[:SeaLevelRise, :es_equilibriumSL] # currently throwing NaNs
es_equilibriumSL_compare = readpagedata(m, "../test/validationdata/es_equilibriumSL.csv")
@test_approx_eq_eps ones(10) es_equilibriumSL ./ es_equilibriumSL .01

s_sealevel = m[:SeaLevelRise, :s_sealevel]
s_sealevel_compare = readpagedata(m, "../test/validationdata/s_sealevel.csv")
@test_approx_eq_eps ones(10) s_sealevel ./ s_sealevel_compare .01

expfs_exponential = m[:SeaLevelRise, :expfs_exponential]
expfs_exponential_compare = readpagedata(m, "../test/validationdata/expfs_exponential.csv")
@test_approx_eq_eps ones(10) expfs_exponential ./ expfs_exponential_compare .01
