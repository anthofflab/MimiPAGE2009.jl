using Test


m = test_page_model()
include("../src/components/SulphateForcing.jl")

add_comp!(m, SulphateForcing)

p = load_parameters(m)

update_param!(m, :SulphateForcing, :area, p[:shared][:area])
update_leftover_params!(m, p[:unshared])

run(m)

forcing=m[:SulphateForcing,:fs_sulphateforcing]
forcing_compare=readpagedata(m,"test/validationdata/fs_sulphateforcing.csv")

@test forcing ≈ forcing_compare rtol=1e-3
