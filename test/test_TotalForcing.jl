using Base.Test
using Mimi

m = m = page_model()
include("../src/components/TotalForcing.jl")

totalforcing = add_comp!(m, TotalForcing)

totalforcing[:f_CO2forcing] = readpagedata(m,"test/validationdata/f_co2forcing.csv")
totalforcing[:f_CH4forcing] = readpagedata(m,"test/validationdata/f_ch4forcing.csv")
totalforcing[:f_N2Oforcing] = readpagedata(m,"test/validationdata/f_n2oforcing.csv")
totalforcing[:f_lineargasforcing] = readpagedata(m,"test/validationdata/f_LGforcing.csv")
totalforcing[:exf_excessforcing] = readpagedata(m,"data/exf_excessforcing.csv")

run(m)

forcing=m[:TotalForcing, :ft_totalforcing]
forcing_compare=readpagedata(m,"test/validationdata/ft_totalforcing.csv")

@test forcing ≈ forcing_compare rtol=1e-3
