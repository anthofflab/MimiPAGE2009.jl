using Mimi
include("load_parameters.jl")
include("CO2emissions.jl")
include("CO2cycle.jl")
include("CO2forcing.jl")
include("CH4emissions.jl")
include("CH4cycle.jl")
include("CH4forcing.jl")
include("N2Oemissions.jl")
include("N2Ocycle.jl")
include("N2Oforcing.jl")
include("LGemissions.jl")
include("LGcycle.jl")
include("LGforcing.jl")
include("SulphateForcing.jl")
include("TotalForcing.jl")
include("ClimateTemperature.jl")
include("SeaLevelRise.jl")


m = Model()
setindex(m, :time, [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200])
setindex(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])

#add all the components
CO2emissions = addcomponent(m,co2emissions)
CO2cycle = addCO2cycle(m)
CO2forcing = addCO2forcing(m, co2forcing)
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
sealevelrise = addSLR(m)

#connect parameters together

CO2cycle[:e_globalCO2emissions] = CO2emissions[:e_globalCO2emissions]
CO2cycle[:rt_g0_baseglobaltemp] = climatetemperature[:rt_g0_baseglobaltemp]
CO2cycle[:rt_g_globaltemperature] = climatetemperature[:rt_g_globaltemperature

CO2forcing[:c_CO2concentration] = CO2cycle[:c_CO2concentration]

CH4cycle[:e_globalCH4emissions] = CH4emissions[:e_globalCH4emissions]
CH4cycle[:rtl_g0_baselandtemp] = climatetemperature[:rtl_g0_baselandtemp]
CH4cycle[:rtl_g_landtemperature] = climatetemperature[:rtl_g_landtemperature]

CH4forcing[:c_CH4concentration] = CH4cycle[:c_CH4concentration]
CH4forcing[:c_N2Oconcentration] = N2Ocycle[:c_N2Oconcentration]

N2Ocycle[:e_globalN2Oemissions] = N2Oemissions[:e_globalN2Oemissions]
N2Ocycle[:rtl_g0_baselandtemp] = climatetemperature[:rtl_g0_baselandtemp]
N2Ocycle[:rtl_g_landtemperature] = climatetemperature[:rtl_g_landtemperature]

N2Oforcing[:c_CH4concentration] = CH4cycle[:c_CH4concentration]
N2Oforcing[:c_N2Oconcentration] = N2Ocycle[:c_N2Oconcentration]

lgcycle[:e_globalLGemissions] = lgemissions[:e_globalLGemissions]
lgcycle[:rtl_g_0_realizedtemp] = climatetemperature[:rtl_g_0_realizedtemp]
lgcycle[:rtl_g_landtemperature] = climatetemperature[:rtl_g_landtemperature]

lgforcing[:c_LGconcentration] = lgcycle[:c_LGconcentration]

totalforcing[:f_CO2forcing] = CO2forcing[:f_CO2forcing]
totalforcing[:f_CH4forcing] = CH4forcing[:f_CH4forcing]
totalforcing[:f_N2Oforcing] = N2Oforcing[:f_N2Oforcing]
totalforcing[:f_lineargasforcing] = lgforcing[:f_LGforcing]

climatetemperature[:ft_totalforcing] = totalforcing[:ft_totalforcing]
climatetemperature[:fs_sulfateforcing] = sulphateforcing[:fs_sulphateforcing]

sealevelrise[:rt_g_globaltemperature] = climatetemperature[:rt_g_globaltemperature]

# next: add vector and panel example
p = load_parameters()
p["y_year_0"] = 2008.
setleftoverparameters(m, p)

run(m)