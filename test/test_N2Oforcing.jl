using Mimi
using Base.Test

m = page_model()
include("../src/components/N2Oforcing.jl")

add_comp!(m, n2oforcing)

set_param!(m, :n2oforcing, :c_N2Oconcentration, readpagedata(m,"test/validationdata/c_n2oconcentration.csv"))
set_param!(m, :n2oforcing, :c_CH4concentration, readpagedata(m,"test/validationdata/c_ch4concentration.csv"))

##running Model
run(m)

forcing=m[:n2oforcing,:f_N2Oforcing]
forcing_compare=readpagedata(m,"test/validationdata/f_n2oforcing.csv")

@test forcing ≈ forcing_compare rtol=1e-3
