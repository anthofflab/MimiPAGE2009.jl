using Mimi

include("../src/CO2forcing.jl")

m = Model()
setindex(m, :time, 10)

addCO2forcing(m)

setparameter(m, :co2forcing, :c_CO2concentration, ones(10).*300)

##running Model
run(m)
