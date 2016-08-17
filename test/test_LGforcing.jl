using Mimi

include("../src/LGforcing.jl")

m = Model()

setindex(m, :time, 10)

addcomponent(m, LGforcing)

setparameter(m, :LGforcing, :c_LGconcentration, ones(10)*0.2)

# run Model
run(m)
