using Mimi

include("../src/load_parameters.jl")

m = Model()
setindex(m, :time, [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200])
setindex(m, :region, ["EU", "USA", "OECD", "Africa", "China", "SAsia", "LAmerica", "USSR"])

load_parameters(m)
