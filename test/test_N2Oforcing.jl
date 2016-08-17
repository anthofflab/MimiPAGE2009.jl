using Mimi

include("../src/N2Oforcing.jl")

m = Model()
setindex(m, :time, 10)

addN2Oforcing(m)

setparameter(m, :n2oforcing, :c_N2Oconcentration, ones(10).*300)
setparameter(m, :n2oforcing, :c_CH4concentration, ones(10).*300)

##running Model
run(m)
