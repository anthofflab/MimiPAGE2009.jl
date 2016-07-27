using Mimi

include("../src/N2Oforcing.jl")

m = Model()
setindex(m, :time, 10)

addcomponent(m, n2oforcing)

setparameter(m, :n2oforcing, :c_N2Oconcentration, ones(10).*300)
setparameter(m, :n2oforcing, :c_CH4concentration, ones(10).*300)
setparameter(m, :n2oforcing, :f0_N2Obaseforcing, 0.18) #real value
setparameter(m, :n2oforcing, :fslope_N2Oforcingslope, 0.12) #real value
setparameter(m, :n2oforcing, :c0_baseN2Oconc, 332.) #real value
setparameter(m, :n2oforcing, :c0_baseCH4conc, 1860.) #real value

##running Model
run(m)
