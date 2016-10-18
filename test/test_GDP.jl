using Mimi

include("../src/GDP.jl")

m = Model()
setindex(m, :time, 10)
setindex(m, :region, ["Region 1", "Region 2", "Region 3"])

addGDP(m)

setparameter(m, :GDP, :y0_baselineyear, 2000.)
setparameter(m, :GDP, :y_year, [2001.,2002.,2010.,2020.,2040.,2060.,2080.,2100.,2150.,2200.])

# run model
run(m)
