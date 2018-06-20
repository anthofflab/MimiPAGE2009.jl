using Mimi
using Base.Test

include("../src/utils/load_parameters.jl")
include("../src/components/CO2cycle.jl")

m = Model()

add_dimension(m, :time, [2009.,2010.,2020.,2030.,2040.,2050.,2075.,2100.,2150.,2200.])
add_dimension(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])

addCO2cycle(m)

set_parameter!(m, :co2cycle, :e_globalCO2emissions, readpagedata(m, "test/validationdata/e_globalCO2emissions.csv"))
set_parameter!(m, :co2cycle, :y_year,[2009.,2010.,2020.,2030.,2040.,2050.,2075.,2100.,2150.,2200.])#real values
set_parameter!(m, :co2cycle, :y_year_0,2008.)#real value
set_parameter!(m, :co2cycle, :rt_g_globaltemperature, readpagedata(m, "test/validationdata/rt_g_globaltemperature.csv"))
p=load_parameters(m)
set_leftover_params!(m,p) #important for setting left over component values
##running Model
run(m)

pop=m[:co2cycle,  :c_CO2concentration]

pop_compare=readpagedata(m, "test/validationdata/c_co2concentration.csv")

@test pop ≈ pop_compare rtol=1e-4
