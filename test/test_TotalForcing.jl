using Test


m = m = test_page_model()
include("../src/components/TotalForcing.jl")

totalforcing = add_comp!(m, TotalForcing)

update_param!(m, :TotalForcing, :f_CO2forcing, readpagedata(m,"test/validationdata/f_co2forcing.csv"))
update_param!(m, :TotalForcing, :f_CH4forcing, readpagedata(m,"test/validationdata/f_ch4forcing.csv"))
update_param!(m, :TotalForcing, :f_N2Oforcing, readpagedata(m,"test/validationdata/f_n2oforcing.csv"))
update_param!(m, :TotalForcing, :f_lineargasforcing, readpagedata(m,"test/validationdata/f_LGforcing.csv"))

p = load_parameters(m)

update_param!(m, :TotalForcing, :exf_excessforcing, p[:unshared][(:TotalForcing, :exf_excessforcing)])

run(m)

forcing=m[:TotalForcing, :ft_totalforcing]
forcing_compare=readpagedata(m,"test/validationdata/ft_totalforcing.csv")

@test forcing ≈ forcing_compare rtol=1e-3
