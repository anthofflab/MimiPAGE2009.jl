using Mimi
include("load_parameters.jl")
include("CO2forcing.jl")
include("ClimateTemperature.jl")

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
co2cycle[:rt_g_globaltemperature] = climatetemperature[:rt_g_globaltemperature]
co2forcing[:c_CO2concentration] = co2emissions[:c_CO2concentration]
ch4cycle[:e_globalCH4emissions] = ch4emissions[:e_globalCH4emissions]
ch4cycle[:rtl_g0_baselandtemp] = climatetemperature[:rtl_g0_baselandtemp]
ch4cycle[:rtl_g_landtemperature] = climatetemperature[:rtl_g_landtemperature]
ch4forcing[:c_CH4concentration] = ch4cycle[:c_CH4concentration]
ch4forcing[:c_N2Oconcentration] = n2ocycle[:c_N2Oconcentration]
n2ocycle[:e_globalN2Oemissions] = n2oemissions[:e_globalN2Oemissions]
n2ocycle[:rtl_g0_baselandtemp] = climatetemperature[:rtl_g0_baselandtemp]
n2ocycle[:rtl_g_landtemperature] = climatetemperature[:rtl_g_landtemperature]
n2oforcing[:c_CH4concentration] = ch4cycle[:c_CH4concentration]




climatetemperature[:ft_totalforcing] = co2forcingref[:f_CO2forcing]

#climatetemperature[:y_year_0] = 2008.
climatetemperature[:fslope_CO2forcingslope] = 5.5

# next: add vector and panel example
p = load_parameters()
p["y_year_0"] = 2008.
setleftoverparameters(m, p)

run(m)
