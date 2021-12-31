
using Test

m = test_page_model()
include("../src/components/GDP.jl")

gdp = add_comp!(m, GDP)

gdp[:pop0_initpopulation] = readpagedata(m, "data/shared_parameters/pop0_initpopulation.csv")
gdp[:pop_population] = readpagedata(m, "test/validationdata/pop_population.csv")
gdp[:y_year] = Mimi.dim_keys(m.md, :time)
gdp[:y_year_0] = 2008.

p=load_parameters(m)

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
