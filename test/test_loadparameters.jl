using Mimi

include("../src/utils/load_parameters.jl")

m = Model()
add_dimension(m, :time, [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200])
add_dimension(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])

load_parameters(m)
