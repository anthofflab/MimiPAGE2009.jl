using Base.Test

include("../src/climate_model.jl")

rt_g = m[:ClimateTemperature, :rt_g_globaltemperature]
rt_g_compare = readpagedata(m, "test/validationdata/rt_g_globaltemperature.csv")

@test_approx_eq_eps rt_g rt_g_compare 1e-4
