
using Test

m = test_page_model()
include("../src/components/Population.jl")

add_comp!(m, Population)
population[:y_year_0] = 2008.
population[:y_year] = Mimi.dim_keys(m.md, :time)

p = load_parameters(m)

set_leftover_params!(m, p)

run(m)

# Generated data
pop = m[:Population, :pop_population]

# Recorded data
pop_compare = readpagedata(m, "test/validationdata/pop_population.csv")

@test pop ≈ pop_compare rtol=1e-3
