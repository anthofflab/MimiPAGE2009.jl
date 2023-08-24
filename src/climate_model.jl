using Mimi
using MimiPAGE2009

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
add_comp!(m, co2emissions)
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
connect_param!(m, :co2cycle => :e_globalCO2emissions, :co2emissions => :e_globalCO2emissions)
connect_param!(m, :co2cycle => :rt_g0_baseglobaltemp, :ClimateTemperature => :rt_g0_baseglobaltemp)
connect_param!(m, :co2cycle => :rt_g_globaltemperature, :ClimateTemperature => :rt_g_globaltemperature)

connect_param!(m, :co2forcing => :c_CO2concentration, :co2cycle => :c_CO2concentration)

connect_param!(m, :ch4cycle => :e_globalCH4emissions, :ch4emissions => :e_globalCH4emissions)
connect_param!(m, :ch4cycle => :rtl_g0_baselandtemp, :ClimateTemperature => :rtl_g0_baselandtemp)
connect_param!(m, :ch4cycle => :rtl_g_landtemperature, :ClimateTemperature => :rtl_g_landtemperature)

connect_param!(m, :ch4forcing => :c_CH4concentration, :ch4cycle => :c_CH4concentration)
connect_param!(m, :ch4forcing => :c_N2Oconcentration, :n2ocycle => :c_N2Oconcentration)

connect_param!(m, :n2ocycle => :e_globalN2Oemissions, :n2oemissions => :e_globalN2Oemissions)
connect_param!(m, :n2ocycle => :rtl_g0_baselandtemp, :ClimateTemperature => :rtl_g0_baselandtemp)
connect_param!(m, :n2ocycle => :rtl_g_landtemperature, :ClimateTemperature => :rtl_g_landtemperature)

connect_param!(m, :n2oforcing => :c_CH4concentration, :ch4cycle => :c_CH4concentration)
connect_param!(m, :n2oforcing => :c_N2Oconcentration, :n2ocycle => :c_N2Oconcentration)

connect_param!(m, :LGcycle => :e_globalLGemissions, :LGemissions => :e_globalLGemissions)
connect_param!(m, :LGcycle => :rtl_g0_baselandtemp, :ClimateTemperature => :rtl_g0_baselandtemp)
connect_param!(m, :LGcycle => :rtl_g_landtemperature, :ClimateTemperature => :rtl_g_landtemperature)

connect_param!(m, :LGforcing => :c_LGconcentration, :LGcycle => :c_LGconcentration)

connect_param!(m, :TotalForcing => :f_CO2forcing, :co2forcing => :f_CO2forcing)
connect_param!(m, :TotalForcing => :f_CH4forcing, :ch4forcing => :f_CH4forcing)
connect_param!(m, :TotalForcing => :f_N2Oforcing, :n2oforcing => :f_N2Oforcing)
connect_param!(m, :TotalForcing => :f_lineargasforcing, :LGforcing => :f_LGforcing)

connect_param!(m, :ClimateTemperature => :ft_totalforcing, :TotalForcing => :ft_totalforcing)
connect_param!(m, :ClimateTemperature => :fs_sulfateforcing, :SulphateForcing => :fs_sulphateforcing)

# Load parameter values 
p = load_parameters(m)

# Set shared parameters - name is a Symbol representing the param_name, here
# we will create a shared model parameter with the same name as the component
# parameter and then connect our component parameters to this shared model parameter

# * for convenience later, name model parameter same as the component parameters,
# but this is not required could give a unique name

add_shared_param!(m, :y_year, Mimi.dim_keys(m.md, :time), dims=[:time])
for compname in [:ch4cycle, :ClimateTemperature, :co2cycle, :n2ocycle, :LGcycle]
    connect_param!(m, compname, :y_year, :y_year)
end

add_shared_param!(m, :y_year_0, 2008.)
for compname in [:ch4cycle, :ClimateTemperature, :co2cycle, :n2ocycle, :LGcycle]
    connect_param!(m, compname, :y_year_0, :y_year_0)
end

add_shared_param!(m, :area, p[:shared][:area], dims=[:region])
connect_param!(m, :ClimateTemperature, :area, :area)
connect_param!(m, :SulphateForcing, :area, :area)

# Set unshared parameters - in p[:unshared] the name is a Tuple{Symbol, Symbol} 
# of (component_name, param_name)

# these are shared in the main model but can be unshared in our climate model since
# the other components that use them do not exist in this model
update_param!(m, :co2emissions, :er_CO2emissionsgrowth, p[:shared][:er_CO2emissionsgrowth])
update_param!(m, :n2oemissions, :er_N2Oemissionsgrowth, p[:shared][:er_N2Oemissionsgrowth])
update_param!(m, :ch4emissions, :er_CH4emissionsgrowth, p[:shared][:er_CH4emissionsgrowth])
update_param!(m, :LGemissions, :er_LGemissionsgrowth, p[:shared][:er_LGemissionsgrowth])

update_param!(m, :co2emissions, :e0_baselineCO2emissions, p[:shared][:e0_baselineCO2emissions])
update_param!(m, :n2oemissions, :e0_baselineN2Oemissions, p[:shared][:e0_baselineN2Oemissions])
update_param!(m, :ch4emissions, :e0_baselineCH4emissions, p[:shared][:e0_baselineCH4emissions])
update_param!(m, :LGemissions, :e0_baselineLGemissions, p[:shared][:e0_baselineLGemissions])

# this will set any parameters that are not set (1) explicitly or (2) by default
update_leftover_params!(m, p[:unshared])

run(m)
