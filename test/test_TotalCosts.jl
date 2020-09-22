using MimiPAGE2009 
using Test

m = MimiPAGE2009.get_model()
run(m)

# Test the values from this new components compared to the total cost calculation originally suggested by Fran

atol = 1e-8

@test all(isapprox.(m[:TotalCosts, :total_costs_percap_peryear],
    m[:EquityWeighting, :cons_percap_aftercosts] - m[:EquityWeighting, :rcons_percap_dis] + m[:EquityWeighting, :act_percap_adaptationcosts] + m[:EquityWeighting, :tct_percap_totalcosts_total],
    atol = atol))

@test all(isapprox.(m[:TotalCosts, :total_damages_percap_peryear],
    m[:EquityWeighting, :cons_percap_aftercosts] - m[:EquityWeighting, :rcons_percap_dis] + m[:EquityWeighting, :act_percap_adaptationcosts], # without abatement costs, just damages
    atol = atol))