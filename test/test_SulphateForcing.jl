using Base.Test
using Mimi

m = page_model()
include("../src/components/SulphateForcing.jl")

addcomponent(m, SulphateForcing)

p = load_parameters(m)
p["y_year_0"] = 2008.
p["y_year"] = Mimi.dim_keys(m.md, :time)
set_leftover_params!(m, p)

run(m)

forcing=m[:SulphateForcing,:fs_sulphateforcing]
forcing_compare=readpagedata(m,"test/validationdata/fs_sulphateforcing.csv")

@test forcing ≈ forcing_compare rtol=1e-3
