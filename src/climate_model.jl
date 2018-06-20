using Mimi

#TODO:  Should we add a module wrapper here, or leave it as is?
include("utils/load_parameters.jl")
include("components/CO2emissions.jl")
include("components/CO2cycle.jl")
include("components/CO2forcing.jl")
include("components/CH4emissions.jl")
include("components/CH4cycle.jl")
include("components/CH4forcing.jl")
include("components/N2Oemissions.jl")
include("components/N2Ocycle.jl")
include("components/N2Oforcing.jl")
include("components/LGemissions.jl")
include("components/LGcycle.jl")
include("components/LGforcing.jl")
include("components/SulphateForcing.jl")
include("components/TotalForcing.jl")
include("components/ClimateTemperature.jl")


m = Model()
set_dimension!(m, :time, [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200])
set_dimension!(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])

#add all the components
CO2emissions = addcomponent(m,co2emissions)
CO2cycle = addCO2cycle(m)
CO2forcing = addCO2forcing(m)
CH4emissions = addcomponent(m, ch4emissions)
CH4cycle = addCH4cycle(m)
CH4forcing = addCH4forcing(m)
N2Oemissions = addcomponent(m, n2oemissions)
N2Ocycle = addN2Ocycle(m)
N2Oforcing = addN2Oforcing(m)
lgemissions = addcomponent(m, LGemissions)
lgcycle = addLGcycle(m)
lgforcing = addLGforcing(m)
sulphateforcing = addsulphatecomp(m)
totalforcing = addcomponent(m, TotalForcing)
climatetemperature = addclimatetemperature(m)

#connect parameters together

CO2cycle[:y_year] = [2009.,2010.,2020.,2030.,2040.,2050.,2075.,2100.,2150.,2200.]
CO2cycle[:y_year_0] = 2008.
CO2cycle[:e_globalCO2emissions] = CO2emissions[:e_globalCO2emissions]
CO2cycle[:rt_g0_baseglobaltemp] = climatetemperature[:rt_g0_baseglobaltemp]
CO2cycle[:rt_g_globaltemperature] = climatetemperature[:rt_g_globaltemperature]

CO2forcing[:c_CO2concentration] = CO2cycle[:c_CO2concentration]

CH4cycle[:y_year] = [2009.,2010.,2020.,2030.,2040.,2050.,2075.,2100.,2150.,2200.]
CH4cycle[:y_year_0] = 2008.
CH4cycle[:e_globalCH4emissions] = CH4emissions[:e_globalCH4emissions]
CH4cycle[:rtl_g0_baselandtemp] = climatetemperature[:rtl_g0_baselandtemp]
CH4cycle[:rtl_g_landtemperature] = climatetemperature[:rtl_g_landtemperature]

CH4forcing[:c_CH4concentration] = CH4cycle[:c_CH4concentration]
CH4forcing[:c_N2Oconcentration] = N2Ocycle[:c_N2Oconcentration]

N2Ocycle[:y_year] = [2009.,2010.,2020.,2030.,2040.,2050.,2075.,2100.,2150.,2200.]
N2Ocycle[:y_year_0] = 2008.
N2Ocycle[:e_globalN2Oemissions] = N2Oemissions[:e_globalN2Oemissions]
N2Ocycle[:rtl_g0_baselandtemp] = climatetemperature[:rtl_g0_baselandtemp]
N2Ocycle[:rtl_g_landtemperature] = climatetemperature[:rtl_g_landtemperature]

N2Oforcing[:c_CH4concentration] = CH4cycle[:c_CH4concentration]
N2Oforcing[:c_N2Oconcentration] = N2Ocycle[:c_N2Oconcentration]

lgcycle[:y_year] = [2009.,2010.,2020.,2030.,2040.,2050.,2075.,2100.,2150.,2200.]
lgcycle[:y_year_0] = 2008.
lgcycle[:e_globalLGemissions] = lgemissions[:e_globalLGemissions]
lgcycle[:rtl_g0_baselandtemp] = climatetemperature[:rtl_g0_baselandtemp]
lgcycle[:rtl_g_landtemperature] = climatetemperature[:rtl_g_landtemperature]

lgforcing[:c_LGconcentration] = lgcycle[:c_LGconcentration]

totalforcing[:f_CO2forcing] = CO2forcing[:f_CO2forcing]
totalforcing[:f_CH4forcing] = CH4forcing[:f_CH4forcing]
totalforcing[:f_N2Oforcing] = N2Oforcing[:f_N2Oforcing]
totalforcing[:f_lineargasforcing] = lgforcing[:f_LGforcing]

climatetemperature[:y_year] = [2009.,2010.,2020.,2030.,2040.,2050.,2075.,2100.,2150.,2200.]
climatetemperature[:y_year_0] = 2008.
climatetemperature[:ft_totalforcing] = totalforcing[:ft_totalforcing]
climatetemperature[:fs_sulfateforcing] = sulphateforcing[:fs_sulphateforcing]

# next: add vector and panel example
p = load_parameters(m)
p["y_year_0"] = 2008.
p["y_year"] = Mimi.dim_keys(m.md, :time)
set_leftover_params!(m, p)

run(m)
