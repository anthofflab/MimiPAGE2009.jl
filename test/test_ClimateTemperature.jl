using Mimi
using Base.Test

include("../src/load_parameters.jl")
include("../src/ClimateTemperature.jl")

m = Model()
setindex(m, :time, [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200])
setindex(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])

climatetemperature = addclimatetemperature(m)

climatetemperature[:y_year_0] = 2008.
climatetemperature[:y_year] = m.indices_values[:time]

climatetemperature[:ft_totalforcing] = readpagedata(m, "test/validationdata/ft_totalforcing.csv")
climatetemperature[:fs_sulfateforcing] = readpagedata(m, "test/validationdata/fs_sulfateforcing.csv")

p = load_parameters(m)
setleftoverparameters(m, p)

##running Model
run(m)

rt_g = m[:ClimateTemperature, :rt_g_globaltemperature]
rt_g_compare = readpagedata(m, "test/validationdata/rt_g_globaltemperature.csv")

@test rt_g ≈ rt_g_compare atol=1e-5
