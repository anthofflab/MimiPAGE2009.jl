
using Test

m = test_page_model()
include("../src/components/Population.jl")

add_comp!(m, Population)

update_param!(m, :Population, :y_year_0, 2008.)
update_param!(m, :Population, :y_year,  Mimi.dim_keys(m.md, :time))

p = load_parameters(m)

update_param!(m, :Population, :popgrw_populationgrowth, p[:shared][:popgrw_populationgrowth])
update_param!(m, :Population, :pop0_initpopulation, p[:shared][:pop0_initpopulation])

run(m)

# Generated data
pop = m[:Population, :pop_population]

# Recorded data
pop_compare = readpagedata(m, "test/validationdata/pop_population.csv")

@test pop ≈ pop_compare rtol=1e-3
