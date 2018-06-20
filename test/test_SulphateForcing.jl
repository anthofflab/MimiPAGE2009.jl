using Base.Test
using Mimi

include("../src/components/SulphateForcing.jl")

m = Model()
set_dimension!(m, :time, [2009.,2010.,2020.,2030.,2040., 2050., 2075., 2100., 2150., 2200.])
set_dimension!(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])

addsulphatecomp(m)

p = load_parameters(m)
p["y_year_0"] = 2008.
p["y_year"] = Mimi.dim_keys(m.md, :time)
set_leftover_params!(m, p)

run(m)

forcing=m[:SulphateForcing,:fs_sulphateforcing]
forcing_compare=readpagedata(m,"test/validationdata/fs_sulphateforcing.csv")

@test forcing ≈ forcing_compare rtol=1e-3
