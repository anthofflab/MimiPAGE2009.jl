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
co2emissions = addcomponent(m,CO2emissions)
co2cycle = addcomponent(m,CO2cycle)
co2forcing = addcomponent(m, CO2forcing)
ch4emissions = addcomponent(m, CH4emissions)
ch4cycle = addcomponent(m, CH4cycle)
ch4forcing = addcomponent(m, CH4forcing)
n2oemissions = addcomponent(m, N2Ocycle)
n2ocycle = addcomponent(m, N2Ocycle)
n2oforcing = addcomponent(m, N2Oforcing)
lgemissions = addcomponent(m, LGemissions)
lgcycle = addcomponent(m, LGcycle)
lgforcing = addcomponent(m, LGforcing)
sulphateforcing = addcomponent(m, SulphateForcing)
totalforcing = addcomponent(m, TotalForcing)
climatetemperature = addcomponent(m, ClimateTemperature)
sealevelrise = addcomponent(m, SeaLevelRise)

#connect parameters together

co2cycle[:e_globalCO2emissions] = co2emissions[:e_globalCO2emissions]
co2cycle[:rt_g0_baseglobaltemp] = climatetemperature[:rt_g0_baseglobaltemp]
co2cycle[:rt_g_globaltemperature] = climatetemperature[:rt_g_globaltemperature

co2forcing[:c_CO2concentration] = co2cycle[:c_CO2concentration]

ch4cycle[:e_globalCH4emissions] = ch4emissions[:e_globalCH4emissions]
ch4cycle[:rtl_g0_baselandtemp] = climatetemperature[:rtl_g0_baselandtemp]
ch4cycle[:rtl_g_landtemperature] = climatetemperature[:rtl_g_landtemperature]

ch4forcing[:c_CH4concentration] = ch4cycle[:c_CH4concentration]
ch4forcing[:c_N2Oconcentration] = n2ocycle[:c_N2Oconcentration]

n2ocycle[:e_globalN2Oemissions] = n2oemissions[:e_globalN2Oemissions]
n2ocycle[:rtl_g0_baselandtemp] = climatetemperature[:rtl_g0_baselandtemp]
n2ocycle[:rtl_g_landtemperature] = climatetemperature[:rtl_g_landtemperature]

n2oforcing[:c_CH4concentration] = ch4cycle[:c_CH4concentration]
n2oforcing[:c_N2Oconcentration] = n2ocycle[:c_N2Oconcentration]

lgcycle[:e_globalLGemissions] = lgemissions[:e_globalLGemissions]
lgcycle[:rtl_g_0_realizedtemp] = climatetemperature[:rtl_g_0_realizedtemp]
lgcycle[:rtl_g_landtemperature] = climatetemperature[:rtl_g_landtemperature]

lgforcing[:c_LGconcentration] = lgcycle[:c_LGconcentration]

totalforcing[:f_CO2forcing] = co2forcing[:f_CO2forcing]
totalforcing[:f_CH4forcing] = ch4forcing[:f_CH4forcing]
totalforcing[:f_N2Oforcing] = n2oforcing[:f_N2Oforcing]
totalforcing[:f_lineargasforcing] = lgforcing[:f_LGforcing]

climatetemperature[:ft_totalforcing] = totalforcing[:ft_totalforcing]
climatetemperature[:fs_sulfateforcing] = sulphateforcing[:fs_sulphateforcing]

sealevelrise[:rt_g_globaltemperature] = climatetemperature[:rt_g_globaltemperature]

# next: add vector and panel example
p = load_parameters()
p["y_year_0"] = 2008.
setleftoverparameters(m, p)

run(m)
