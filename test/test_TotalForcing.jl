using Base.Test
using Mimi

include("../src/TotalForcing.jl")

m = Model()
setindex(m, :time, [2009.,2010.,2020.,2030.,2040., 2050., 2075., 2100., 2150., 2200.])
setindex(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])

totalforcing = addcomponent(m, TotalForcing)

totalforcing[:f_CO2forcing] = readpagedata(m,"test/validationdata/f_co2forcing.csv")
totalforcing[:f_CH4forcing] = readpagedata(m,"test/validationdata/f_ch4forcing.csv")
totalforcing[:f_N2Oforcing] = readpagedata(m,"test/validationdata/f_n2oforcing.csv")
totalforcing[:f_lineargasforcing] = readpagedata(m,"test/validationdata/f_LGforcing.csv")
totalforcing[:exf_excessforcing] = readpagedata(m,"data/exf_excessforcing.csv")

run(m)

forcing=m[:TotalForcing, :ft_totalforcing]
forcing_compare=readpagedata(m,"test/validationdata/ft_totalforcing.csv")

@test_approx_eq_eps forcing forcing_compare 1e-3
