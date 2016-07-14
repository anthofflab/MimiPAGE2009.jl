using Mimi

include("../src/CO2forcing.jl")

m = Model()
setindex(m, :time, 10)

addcomponent(m, co2forcing)

setparameter(m, :co2forcing, :c_CO2concentration, ones(10).*300)
setparameter(m, :co2forcing, :f0_CO2baseforcing, 1.5)
setparameter(m, :co2forcing, :fslope_CO2forcingslope, 5.35)
setparameter(m, :co2forcing, :c0_baseCO2conc, 367000.)

##running Model
run(m)
