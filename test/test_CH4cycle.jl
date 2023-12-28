
using Test

m = test_page_model()
include("../src/components/CH4cycle.jl")

add_comp!(m, ch4cycle, :ch4cycle)

update_param!(m, :ch4cycle, :e_globalCH4emissions, readpagedata(m, "test/validationdata/e_globalCH4emissions.csv"))
update_param!(m, :ch4cycle, :rtl_g_landtemperature, readpagedata(m, "test/validationdata/rtl_g_landtemperature.csv"))
update_param!(m, :ch4cycle, :y_year_0, 2008.)
update_param!(m, :ch4cycle, :y_year, Mimi.dim_keys(m.md, :time))

p = load_parameters(m)
update_leftover_params!(m, p[:unshared])

#running Model
run(m)

conc = m[:ch4cycle, :c_CH4concentration]
conc_compare = readpagedata(m, "test/validationdata/c_ch4concentration.csv")

@test conc ≈ conc_compare rtol = 1e-4
