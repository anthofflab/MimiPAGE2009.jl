using Mimi
using Test

m = page_model()
include("../src/components/CH4forcing.jl")

add_comp!(m, ch4forcing, :ch4forcing)

set_param!(m, :ch4forcing, :c_N2Oconcentration, readpagedata(m,"test/validationdata/c_n2oconcentration.csv"))
set_param!(m, :ch4forcing, :c_CH4concentration, readpagedata(m,"test/validationdata/c_ch4concentration.csv"))

##running Model
run(m)

@test !isnan(m[:ch4forcing, :f_CH4forcing][10])

forcing=m[:ch4forcing,:f_CH4forcing]
forcing_compare=readpagedata(m,"test/validationdata/f_ch4forcing.csv")

@test forcing ≈ forcing_compare rtol=1e-3
