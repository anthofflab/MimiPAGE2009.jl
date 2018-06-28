using Mimi
using Base.Test

include("../src/utils/load_parameters.jl")
include("../src/components/ClimateTemperature.jl")

m = Model()
set_dimension!(m, :time, [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200])
set_dimension!(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])

climatetemperature = addcomponent(m, ClimateTemperature)

climatetemperature[:y_year_0] = 2008.
climatetemperature[:y_year] = Mimi.dim_keys(m.md, :time)

climatetemperature[:ft_totalforcing] = readpagedata(m, "test/validationdata/ft_totalforcing.csv")
climatetemperature[:fs_sulfateforcing] = readpagedata(m, "test/validationdata/fs_sulfateforcing.csv")

p = load_parameters(m)
set_leftover_params!(m, p)

##running Model
run(m)

rt_g = m[:ClimateTemperature, :rt_g_globaltemperature]
rt_g_compare = readpagedata(m, "test/validationdata/rt_g_globaltemperature.csv")

@test rt_g ≈ rt_g_compare rtol=1e-5
