using Mimi

include("..\src\LGforcing.jl")

m = Model()

setindex(m, :time, 10)

addcomponent(m, LGforcing)

setparameter(m, :LGforcing, :c_LGconcentration, ones(10)*0.2)
setparameter(m, :LGforcing, :c0_LGconcbaseyr, 0.11) # real value
setparameter(m, :LGforcing, :f0_LGforcingbase, 0.022) # real value
setparameter(m, :LGforcing, :fslope_LGforcingslope, 0.2) # real value

# run Model
run(m)
