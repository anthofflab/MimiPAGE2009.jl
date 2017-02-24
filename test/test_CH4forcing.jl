using Mimi

include("../src/CH4forcing.jl")

m = Model()
setindex(m, :time, 10)

addcomponent(m, ch4forcing)

setparameter(m, :ch4forcing, :c_N2Oconcentration, ones(10).*300)
setparameter(m, :ch4forcing, :c_CH4concentration, ones(10).*300)

##running Model
run(m)

@test !isnan(m[:ch4forcing, :f_CH4forcing][10])
