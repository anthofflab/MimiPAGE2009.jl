
using Test

m = test_page_model()
include("../src/components/GDP.jl")

add_comp!(m, GDP)

update_param!(m, :GDP, :y_year, Mimi.dim_keys(m.md, :time))
update_param!(m, :GDP, :y_year_0, 2008.)
update_param!(m, :GDP, :pop_population, readpagedata(m, "test/validationdata/pop_population.csv"))

p = load_parameters(m)

update_param!(m, :GDP, :pop0_initpopulation, p[:shared][:pop0_initpopulation])
update_param!(m, :GDP, :grw_gdpgrowthrate, p[:shared][:grw_gdpgrowthrate])
update_param!(m, :GDP, :gdp_0, p[:unshared][(:GDP, :gdp_0)])

# run model
run(m)

# Generated data
gdp = m[:GDP, :gdp]

# Recorded data
gdp_compare = readpagedata(m, "test/validationdata/gdp.csv")

@test gdp ≈ gdp_compare rtol=100

cons_percap_consumption_0_compare = readpagedata(m, "test/validationdata/cons_percap_consumption_0.csv")
@test m[:GDP, :cons_percap_consumption_0] ≈ cons_percap_consumption_0_compare rtol=1e-2
