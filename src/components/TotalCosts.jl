@defcomp TotalCosts begin

    # Per capita costs to aggregate
    abatement_costs_percap_peryear = Parameter(index=[time, region], unit="\$/person") # Total abatement costs per capita per year
    adaptation_costs_percap_peryear = Parameter(index=[time, region], unit="\$/person") # Total adaptation costs per capita per year
    slr_damages_percap_peryear = Parameter(index=[time, region], unit="\$/person") # SLR damages per capita per year
    market_damages_percap_peryear = Parameter(index=[time, region], unit="\$/person") # Market damages per capita per year
    non_market_damages_percap_peryear = Parameter(index=[time, region], unit="\$/person") # Non market damages per capita per year
    discontinuity_damages_percap_peryear = Parameter(index=[time, region], unit="\$/person") # Discontinuity damages per capita per year

    # other parameters 
    population = Parameter(index=[time, region], unit="million person")
    period_length = Parameter(index=[time], unit="year")

    # Undiscounted costs to calculate

    total_damages_percap_peryear = Variable(index=[time, region], unit="\$/person")  # Undiscounted total damages per capita per year   
    total_damages_peryear = Variable(index=[time, region], unit="\$million")  # Undiscounted total damages per year 
    total_damages_aggregated = Variable(index=[time, region], unit="\$million")  # Undiscounted total damages per period

    total_abatement_percap_peryear = Variable(index=[time, region], unit="\$/person")  # Undiscounted total abatement per capita per year     
    total_abatement_peryear = Variable(index=[time, region], unit="\$million")  # Undiscounted total abatement per year 
    total_abatement_aggregated = Variable(index=[time, region], unit="\$million")  # Undiscounted total abatement per period 

    total_costs_percap_peryear = Variable(index=[time, region], unit="\$/person")  # Undiscounted total costs per capita per year (damages + abatement)
    total_costs_peryear = Variable(index=[time, region], unit="\$million")  # Undiscounted total costs per year                  
    total_costs_aggregated = Variable(index=[time, region], unit="\$million")  # Undiscounted total costs per period                  

    function run_timestep(p, v, d, t)

        # Damages
        v.total_damages_percap_peryear[t, :] =
            p.adaptation_costs_percap_peryear[t, :] +
            p.slr_damages_percap_peryear[t, :] +
            p.market_damages_percap_peryear[t, :] +
            p.non_market_damages_percap_peryear[t, :] +
            p.discontinuity_damages_percap_peryear[t, :]
        v.total_damages_peryear[t, :] = v.total_damages_percap_peryear[t, :] .* p.population[t, :]
        v.total_damages_aggregated[t, :] = v.total_damages_peryear[t, :] .* p.period_length[t]

        # Abatement
        v.total_abatement_percap_peryear[t, :] = p.abatement_costs_percap_peryear[t, :]
        v.total_abatement_peryear[t, :] = v.total_abatement_percap_peryear[t, :] .* p.population[t, :]
        v.total_abatement_aggregated[t, :] = v.total_abatement_peryear[t, :] .* p.period_length[t]

        # Total costs (damages + abatement)
        v.total_costs_percap_peryear[t, :] = v.total_damages_percap_peryear[t, :] + p.abatement_costs_percap_peryear[t, :]
        v.total_costs_peryear[t, :] = v.total_costs_percap_peryear[t, :] .* p.population[t, :]
        v.total_costs_aggregated[t, :] = v.total_costs_peryear[t, :] .* p.period_length[t]
    end
end
