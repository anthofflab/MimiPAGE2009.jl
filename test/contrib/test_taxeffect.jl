using Test
include("../../src/contrib/taxeffect.jl")

taxes = rand(10) * 100

m = getuniformtaxmodel()
set_param!(m, :UniformTaxDrivenGrowth, :uniformtax, taxes)
run(m)

for ii in 1:10
    @test all(m[:AbatementCostsCO2, :mc_marginalcost][ii, :] .≈ taxes[ii])
    @test all(m[:AbatementCostsCH4, :mc_marginalcost][ii, :] .≈ taxes[ii])
    @test all(m[:AbatementCostsN2O, :mc_marginalcost][ii, :] .≈ taxes[ii])
    @test all(m[:AbatementCostsLin, :mc_marginalcost][ii, :] .≈ taxes[ii])
end
