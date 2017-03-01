using Mimi
using Base.Test

include("../src/CH4cycle.jl")

m = Model()
setindex(m, :time, 10)
setindex(m, :region, ["Region 1", "Region 2", "Region 3"])

addCH4cycle(m)

setparameter(m, :ch4cycle, :e_globalCH4emissions, ones(10))
setparameter(m, :ch4cycle, :y_year, [2001.,2002.,2010.,2020.,2040.,2060.,2080.,2100.,2150.,2200.]) #real value
setparameter(m, :ch4cycle, :y_year_0, 2000.) #real value
setparameter(m, :ch4cycle, :rtl_g0_baselandtemp, [0.93])
setparameter(m, :ch4cycle, :rtl_g_landtemperature, ones(10))

##running Model
run(m)

@test !isnan(m[:ch4cycle, :c_CH4concentration][10])
