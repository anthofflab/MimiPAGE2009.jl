
using Test

m = test_page_model()
include("../src/components/ClimateTemperature.jl")

add_comp!(m, ClimateTemperature)

update_param!(m, :ClimateTemperature, :y_year_0, 2008.)
update_param!(m, :ClimateTemperature, :y_year, Mimi.dim_keys(m.md, :time))
update_param!(m, :ClimateTemperature, :ft_totalforcing, readpagedata(m, "test/validationdata/ft_totalforcing.csv"))
update_param!(m, :ClimateTemperature, :fs_sulfateforcing, readpagedata(m, "test/validationdata/fs_sulfateforcing.csv"))

p = load_parameters(m)
update_param!(m, :ClimateTemperature, :area, p[:shared][:area])
update_leftover_params!(m, p[:unshared])

##running Model
run(m)

rt_g = m[:ClimateTemperature, :rt_g_globaltemperature]
rt_g_compare = readpagedata(m, "test/validationdata/rt_g_globaltemperature.csv")

@test rt_g ≈ rt_g_compare rtol = 1e-5
