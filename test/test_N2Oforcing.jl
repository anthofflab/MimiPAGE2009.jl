using Mimi

include("../src/N2Oforcing.jl")

m = Model()
setindex(m, :time, 10)

addcomponent(m, n2oforcing)

setparameter(m, :n2oforcing, :c_N2Oconcentration, ones(10).*300)
setparameter(m, :n2oforcing, :c_CH4concentration, ones(10).*300)
setparameter(m, :n2oforcing, :f0_N2Obaseforcing, 1.5)
setparameter(m, :n2oforcing, :fslope_N2Oforcingslope, 5.35)
setparameter(m, :n2oforcing, :c0_baseN2Oconc, 367000.)
setparameter(m, :n2oforcing, :c0_baseCH4conc, 367000.)

##running Model
run(m)
