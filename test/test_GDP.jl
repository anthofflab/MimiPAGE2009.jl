using Mimi

include("../src/GDP.jl")

m = Model()

setindex(m, :time, 10)
setindex(m, :region, ["Region 1", "Region 2", "Region 3"])

addcomponent(m, GDP)

setparameter(m, :GDP, :y_year_0, 2000.)
setparameter(m, :GDP, :y_year, [2001.,2002.,2010.,2020.,2040.,2060.,2080.,2100.,2150.,2200.])
setparameter(m, :GDP, :grw_gdpgrowthrate, reshape(randn(30),10,3))
setparameter(m, :GDP, :gdp_0, [300.,20.,800.])

# run model
run(m)
