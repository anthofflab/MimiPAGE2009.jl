using Mimi

include("../src/CH4forcing.jl")

m = Model()
setindex(m, :time, 10)

addcomponent(m, ch4forcing)

setparameter(m, :ch4forcing, :c_N2Oconcentration, ones(10).*300)
setparameter(m, :ch4forcing, :c_CH4concentration, ones(10).*300)
setparameter(m, :ch4forcing, :f0_CH4baseforcing, 0.550) #real value
setparameter(m, :ch4forcing, :fslope_CH4forcingslope, 0.036) #real value
setparameter(m, :ch4forcing, :c0_baseN2Oconc, 332.) #real value
setparameter(m, :ch4forcing, :c0_baseCH4conc, 1860.) #real value

##running Model
run(m)
