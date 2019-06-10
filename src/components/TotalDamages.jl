@defcomp TotalDamages begin

    # Per capita damages to aggregate   TODO: should this include abatement or not?
    abatement_costs_percap          = Parameter(index = [time, region], unit = "\$/person") # Total abatement costs per capita
    adaptation_costs_percap         = Parameter(index = [time, region], unit = "\$/person") # Total adaptation costs per capita
    slr_damages_percap              = Parameter(index = [time, region], unit = "\$/person") # SLR damages per capita 
    market_damages_percap           = Parameter(index = [time, region], unit = "\$/person") # Market damages per capita
    non_market_damages_percap       = Parameter(index = [time, region], unit = "\$/person") # Non market damages per capita 
    discontinuity_damages_percap    = Parameter(index = [time, region], unit = "\$/person") # Discontinuity damages per capita 

    # other parameters 
    population = Parameter(index = [time, region], unit = "million person")

    # Undiscounted damages to calculate
    total_damages_percap    = Variable(index = [time, region], unit = "\$/person")  # Undiscounted total damages per capita     TODO: are these the units we want?
    total_damages           = Variable(index = [time, region], unit = "\$million")  # Undiscounted total damages                TODO: are these the units we want? and should we multiply by period length, or leave this as the value in one year?

    function run_timestep(p, v, d, t)
        v.total_damages_percap[t, :] =
            p.abatement_costs_percap[t, :] +
            p.adaptation_costs_percap[t, :] +
            p.slr_damages_percap[t, :] +
            p.market_damages_percap[t, :] +
            p.non_market_damages_percap[t, :] +
            p.discontinuity_damages_percap[t, :]
        
        v.total_damages[t, :] = v.total_damages_percap[t, :] .* p.population[t, :]
    end
end



# OLD code from trying to calculate undiscounted damages within the EquityWeighting component:

# Calculate undiscounted damages (impact + adaptation, but without abatement)
# v.undiscounted_damages_percap[tt, rr] = p.cons_percap_aftercosts[tt, rr] - p.rcons_percap_dis[tt, rr] + p.act_percap_adaptationcosts[tt, rr]
# v.undiscounted_damages_tot[tt, rr] = v.undiscounted_damages_percap[tt, rr] * p.pop_population[tt, rr]