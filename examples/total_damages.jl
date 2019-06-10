using MimiPAGE2009 

m = MimiPAGE2009.get_model()
run(m)

# Look at the values from this new components
m[:TotalDamages, :total_damages_percap]

# They are equal to this calculation that Fran originally suggested, if you add in the last term for abatement which is currently included in TotalDamages
m[:EquityWeighting, :cons_percap_aftercosts] - m[:EquityWeighting, :rcons_percap_dis] + m[:EquityWeighting, :act_percap_adaptationcosts] + m[:EquityWeighting, :tct_percap_totalcosts_total]