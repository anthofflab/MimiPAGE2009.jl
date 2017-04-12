using Mimi
using Base.Test

include("../src/load_parameters.jl")
include("../src/CH4cycle.jl")

m = Model()
setindex(m, :time, [2009.,2010.,2020.,2030.,2040., 2050., 2075.,2100.,2150.,2200.])
setindex(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])

addCH4cycle(m)

setparameter(m, :ch4cycle, :e_globalCH4emissions, readpagedata(m,"test/validationdata/e_globalCH4emissions.csv"))
setparameter(m, :ch4cycle, :rtl_g_landtemperature, readpagedata(m,"test/validationdata/rtl_g_landtemperature.csv"))
setparameter(m,:ch4cycle,:y_year_0,2008.)

p = load_parameters(m)
#p["y_year_0"] = 2008.
p["y_year"] = m.indices_values[:time]
setleftoverparameters(m, p)

#running Model
run(m)

conc=m[:ch4cycle,  :c_CH4concentration]
conc_compare=readpagedata(m,"test/validationdata/c_ch4concentration.csv")

@test_approx_eq_eps conc conc_compare 1e-4
