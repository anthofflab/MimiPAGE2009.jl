using Test

m = test_page_model()
include("../src/climate_model.jl")

rt_g = m[:ClimateTemperature, :rt_g_globaltemperature]
rt_g_compare = readpagedata(m, "test/validationdata/rt_g_globaltemperature.csv")

@test rt_g ≈ rt_g_compare rtol = 1e-4
