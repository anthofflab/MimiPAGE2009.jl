using Mimi

include("utils/load_parameters.jl")
include("utils/mctools.jl")

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
add_comp!(m,co2emissions)
add_comp!(m, co2cycle)
add_comp!(m, co2forcing)
add_comp!(m, ch4emissions)
add_comp!(m, ch4cycle)
add_comp!(m, ch4forcing)
add_comp!(m, n2oemissions)
add_comp!(m, n2ocycle)
add_comp!(m, n2oforcing)
add_comp!(m, LGemissions)
add_comp!(m, LGcycle)
add_comp!(m, LGforcing)
add_comp!(m, SulphateForcing)
add_comp!(m, TotalForcing)
add_comp!(m, ClimateTemperature)

#connect parameters together

set_param!(m, :co2cycle, :y_year, [2009.,2010.,2020.,2030.,2040.,2050.,2075.,2100.,2150.,2200.])
set_param!(m, :co2cycle, :y_year_0, 2008.)
connect_param!(m, :co2cycle => :e_globalCO2emissions, :co2emissions => :e_globalCO2emissions)
connect_param!(m, :co2cycle => :rt_g0_baseglobaltemp, :ClimateTemperature => :rt_g0_baseglobaltemp, offset = 1)
connect_param!(m, :co2cycle => :rt_g_globaltemperature, :ClimateTemperature => :rt_g_globaltemperature, offset = 1)

connect_param!(m, :co2forcing => :c_CO2concentration, :co2cycle => :c_CO2concentration)

set_param!(m, :ch4cycle, :y_year, [2009.,2010.,2020.,2030.,2040.,2050.,2075.,2100.,2150.,2200.])
set_param!(m, :ch4cycle, :y_year_0, 2008.)
connect_param!(m, :ch4cycle => :e_globalCH4emissions, :ch4emissions => :e_globalCH4emissions)
connect_param!(m, :ch4cycle => :rtl_g0_baselandtemp, :ClimateTemperature => :rtl_g0_baselandtemp, offset = 1)
connect_param!(m, :ch4cycle => :rtl_g_landtemperature, :ClimateTemperature => :rtl_g_landtemperature, offset = 1)

connect_param!(m, :ch4forcing => :c_CH4concentration, :ch4cycle => :c_CH4concentration)
connect_param!(m, :ch4forcing => :c_N2Oconcentration, :n2ocycle => :c_N2Oconcentration, offset = 1)

set_param!(m, :n2ocycle, :y_year, [2009.,2010.,2020.,2030.,2040.,2050.,2075.,2100.,2150.,2200.])
set_param!(m, :n2ocycle, :y_year_0, 2008.)
connect_param!(m, :n2ocycle => :e_globalN2Oemissions, :n2oemissions => :e_globalN2Oemissions)
connect_param!(m, :n2ocycle => :rtl_g0_baselandtemp, :ClimateTemperature => :rtl_g0_baselandtemp, offset = 1)
connect_param!(m, :n2ocycle => :rtl_g_landtemperature, :ClimateTemperature => :rtl_g_landtemperature, offset = 1)

connect_param!(m, :n2oforcing => :c_CH4concentration, :ch4cycle => :c_CH4concentration)
connect_param!(m, :n2oforcing => :c_N2Oconcentration, :n2ocycle => :c_N2Oconcentration)

set_param!(m, :LGcycle, :y_year, [2009.,2010.,2020.,2030.,2040.,2050.,2075.,2100.,2150.,2200.])
set_param!(m, :LGcycle, :y_year_0, 2008.)
connect_param!(m, :LGcycle => :e_globalLGemissions, :LGemissions => :e_globalLGemissions)
connect_param!(m, :LGcycle => :rtl_g0_baselandtemp, :ClimateTemperature => :rtl_g0_baselandtemp, offset = 1)
connect_param!(m, :LGcycle => :rtl_g_landtemperature, :ClimateTemperature => :rtl_g_landtemperature, offset = 1)

connect_param!(m, :LGforcing => :c_LGconcentration, :LGcycle => :c_LGconcentration)

connect_param!(m, :TotalForcing => :f_CO2forcing, :co2forcing => :f_CO2forcing)
connect_param!(m, :TotalForcing => :f_CH4forcing, :ch4forcing => :f_CH4forcing)
connect_param!(m, :TotalForcing => :f_N2Oforcing, :n2oforcing => :f_N2Oforcing)
connect_param!(m, :TotalForcing => :f_lineargasforcing, :LGforcing => :f_LGforcing)

set_param!(m, :ClimateTemperature, :y_year, [2009.,2010.,2020.,2030.,2040.,2050.,2075.,2100.,2150.,2200.])
set_param!(m, :ClimateTemperature, :y_year_0, 2008.)
connect_param!(m, :ClimateTemperature => :ft_totalforcing, :TotalForcing => :ft_totalforcing)
connect_param!(m, :ClimateTemperature => :fs_sulfateforcing, :SulphateForcing => :fs_sulphateforcing)

# next: add vector and panel example
p = load_parameters(m)
p["y_year_0"] = 2008.
p["y_year"] = Mimi.dim_keys(m.md, :time)
set_leftover_params!(m, p)

run(m)
