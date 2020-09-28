page_years = [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200]
page_year_0 = 2008

function getpageindexfromyear(year)
    i = findfirst(isequal(year), page_years)
    if i == 0
        error("Invalid PAGE year: $year.")
    end 
    return i 
end

function getperiodlength(year)      # same calculations made for yagg_periodspan in the model
    i = getpageindexfromyear(year)

    if year==page_years[1]
        start_year = page_year_0
    else
        start_year = page_years[i - 1]
    end

    if year == page_years[end]
        last_year = page_years[end]
    else
        last_year = page_years[i + 1]
    end

    return (last_year - start_year) / 2
end

# This is different than the period span; this is just the difference between the current year and the previous year
function getindexlengthfromyear(year)
    if year == 2009
        return 1
    end 

    i = findfirst(isequal(year), page_years)
    if i == 0
        error("Invalid PAGE year: $year.")
    end 
    return page_years[i] - page_years[i-1]
end

"""
Applies undiscounting factor to get the SCC, discounted to the emissions year instead of the base year.
"""
function undiscount_scc(m::Model, year::Int)
    df = m[:EquityWeighting, :df_utilitydiscountfactor]
    consfocus0 = m[:GDP, :cons_percap_consumption_0][1]
    consfocus = m[:GDP, :cons_percap_consumption][:, 1]
    emuc = m[:EquityWeighting, :emuc_utilityconvexity]
    sccii = getpageindexfromyear(year)

    return df[sccii] * ((consfocus[sccii] / consfocus0)^-emuc)
end

@defcomp ExtraEmissions begin
    e_globalCO2emissions = Parameter(index=[time],unit="Mtonne/year")
    pulse_size = Parameter(unit="Mtonne CO2")
    pulse_year = Parameter()
    e_globalCO2emissions_adjusted = Variable(index=[time],unit="Mtonne/year")

    function run_timestep(p, v, d, t)
        if gettime(t) == p.pulse_year
            v.e_globalCO2emissions_adjusted[t] = p.e_globalCO2emissions[t] + p.pulse_size / getperiodlength(p.pulse_year)
        else
            v.e_globalCO2emissions_adjusted[t] = p.e_globalCO2emissions[t]
        end
    end
end

"""
    compute_scc(m::Model = get_model(); 
        year::Union{Int, Nothing} = nothing, 
        eta::Union{Float64, Nothing} = nothing, 
        prtp::Union{Float64, Nothing} = nothing,
        pulse_size = 100000.,
        n::Union{Int,Nothing}=nothing,
        trials_output_filename::Union{String, Nothing} = nothing,
        seed::Union{Int, Nothing} = nothing)

Computes the social cost of CO2 for an emissions pulse in `year` for the provided MimiPAGE2009 model `m`. 
If no model is provided, the default model from MimiPAGE2009.get_model() is used.
Units of the returned value are \$ per metric tonne of CO2.

The discounting scheme can be specified by the `eta` and `prtp` parameters, which will update the values of emuc_utilitiyconvexity
and ptp_timepreference in the model. If no values are provided, the discount factors will be computed using the default 
PAGE values of emuc_utilitiyconvexity=1.1666666667 and ptp_timepreference=1.0333333333.

The size of the marginal emission pulse can be modified with the `pulse_size` keyword argument, in metric 
tonnes of CO2 (this does not change the units of the returned value, which is always normalized by the `pulse_size` used).

By default, `n = nothing`, and a single value for the "best guess" social cost of CO2 is returned. If a positive 
value for keyword `n` is specified, then a Monte Carlo simulation with sample size `n` will run, sampling from 
all of PAGE's random variables, and a vector of `n` social cost values will be returned.
Optionally providing a CSV file path to `trials_output_filename` will save all of the sampled trial data as a CSV file.
Optionally providing a `seed` value will set the random seed before running the simulation, allowing the 
results to be replicated.
"""
function compute_scc(
        m::Model = get_model();
        year::Union{Int, Nothing} = nothing,
        eta::Union{Float64, Nothing} = nothing,
        prtp::Union{Float64, Nothing} = nothing,
        equity_weighting::Bool = true,
        pulse_size = 100_000.,
        n::Union{Int,Nothing}=nothing,
        trials_output_filename::Union{String, Nothing} = nothing,
        seed::Union{Int, Nothing} = nothing
        )

    year === nothing ? error("Must specify an emission year. Try `compute_scc(m, year=2020)`.") : nothing
    !(year in page_years) ? error("Cannot compute the scc for year $year, year must be within the model's time index $page_years.") : nothing 

    if eta !== nothing
        try
            set_param!(m, :emuc_utilityconvexity, eta)      # since eta is a default parameter in PAGE, we need to use `set_param!` if it hasn't been set yet
        catch e
            update_param!(m, :emuc_utilityconvexity, eta)   # or update_param! if it has been set
        end
    end

    if prtp !== nothing
        try
            set_param!(m, :ptp_timepreference, prtp * 100)      # since prtp is a default parameter in PAGE, we need to use `set_param!` if it hasn't been set yet
        catch e
            update_param!(m, :ptp_timepreference, prtp * 100)   # or update_param! if it has been set
        end
    end
    
    mm = get_marginal_model(m, year=year, pulse_size=pulse_size)   # Returns a marginal model that has already been run

   
    if n===nothing
        # Run the "best guess" social cost calculation (deterministic)
        scc = _compute_scc_from_mm(mm, year=year, prtp=prtp, eta=eta, equity_weighting=equity_weighting)
    elseif n<1
        error("Invalid `n` value, must be >=1.") 
    else
        # Run a Monte Carlo simulation of size `n`
        simdef = getsim()
        seed !== nothing ? Random.seed!(seed) : nothing
        payload = (Vector{Float64}(undef, n), year, prtp, eta, equity_weighting)    # pass the specs and a vector for storing SCC values to the `run` function
        Mimi.set_payload!(simdef, payload)
        si = run(simdef, mm, n, trials_output_filename = trials_output_filename, post_trial_func = _scc_post_trial_func)
        scc = Mimi.payload(si)[1]   # collect the values computed during the post-trial function
    end

    return scc
end

# Helper function-- computes the SCC from an already run marginal model
function _compute_scc_from_mm(mm::MarginalModel;
    year::Union{Int, Nothing} = nothing,
    eta::Union{Float64, Nothing} = nothing,
    prtp::Union{Float64, Nothing} = nothing,
    equity_weighting::Bool = true)

    if !equity_weighting && eta != 0
        # This is the case for using Ramsey discounting without regional equity weighting
        global_md = sum(mm[:TotalCosts, :total_damages_aggregated], dims=2) # get global marginal damages, already aggregated over the period length
        global_cpc = sum(mm.base[:GDP, :cons_consumption], dims=2) ./ sum(mm.base[:Population, :pop_population], dims=2) # get global consumption per capita

        p_idx = getpageindexfromyear(year) # index of the pulse year

        # calculate instantaneous cpc growth rates in each period
        g1 = NaN 
        idx_lengths = [getindexlengthfromyear(y) for y in page_years]
        g = [g1, [(global_cpc[i]/global_cpc[i-1]) ^ (1/idx_lengths[i]) - 1 for i in 2:length(page_years)]...] 

        # calculate the discount factor for each period
        r = prtp .+ eta .* g
        df = zeros(length(page_years))
        df[p_idx] = 1
        df[p_idx+1:end] = [prod([(1 + r[i])^(-1 * idx_lengths[i]) for i in p_idx+1:t]) for t in p_idx+1:length(page_years)] 

        # discount and sum to the SCC
        scc = sum(global_md .* df) 
    else
        # This case works for both constant discounting w/o equity weighting (i.e. eta==0), or for Ramsey discounting w/ equity weighting
        scc = mm[:EquityWeighting, :td_totaldiscountedimpacts] / undiscount_scc(mm.base, year)
    end
    return scc
end

# Post trial function for calculating the scc in Monte Carlo mode
function _scc_post_trial_func(si::SimulationInstance, trial::Int, ntimesteps::Int, tup::Nothing)
    (scc_array, year, prtp, eta, equity_weighting) = Mimi.payload(si)
    mm = si.models[1]
    scc_array[trial] = _compute_scc_from_mm(mm, year=year, prtp=prtp, eta=eta, equity_weighting=equity_weighting)
end

"""
compute_scc_mm(m::Model = get_model(); year::Union{Int, Nothing} = nothing, eta::Union{Float64, Nothing} = nothing, prtp::Union{Float64, Nothing} = nothing)

Returns a NamedTuple (scc=scc, mm=mm) of the social cost of carbon and the MarginalModel used to compute it.
Computes the social cost of CO2 for an emissions pulse in `year` for the provided MimiPAGE2009 model. 
If no model is provided, the default model from MimiPAGE2009.get_model() is used.
Discounting scheme can be specified by the `eta` and `prtp` parameters, which will update the values of emuc_utilitiyconvexity and ptp_timepreference in the model. 
If no values are provided, the discount factors will be computed using the default PAGE values of emuc_utilitiyconvexity=1.1666666667 and ptp_timepreference=1.0333333333.    
"""
function compute_scc_mm(m::Model = get_model(); year::Union{Int, Nothing} = nothing, eta::Union{Float64, Nothing} = nothing, prtp::Union{Float64, Nothing} = nothing, pulse_size = 100000.)
    year === nothing ? error("Must specify an emission year. Try `compute_scc(m, year=2020)`.") : nothing
    !(year in page_years) ? error("Cannot compute the scc for year $year, year must be within the model's time index $page_years.") : nothing 

    if eta != nothing
        try
            set_param!(m, :emuc_utilityconvexity, eta)      # since eta is a default parameter in PAGE, we need to use `set_param!` if it hasn't been set yet
        catch e
            update_param!(m, :emuc_utilityconvexity, eta)   # or update_param! if it has been set
        end
    end

    if prtp != nothing
        try
            set_param!(m, :ptp_timepreference, prtp * 100)      # since prtp is a default parameter in PAGE, we need to use `set_param!` if it hasn't been set yet
        catch e
            update_param!(m, :ptp_timepreference, prtp * 100)   # or update_param! if it has been set
        end
    end

    mm = get_marginal_model(m, year=year, pulse_size=pulse_size)   # Returns a marginal model that has already been run
    scc = mm[:EquityWeighting, :td_totaldiscountedimpacts] / undiscount_scc(mm.base, year)

    return (scc = scc, mm = mm)
end

"""
    get_marginal_model(m::Model = get_model(); year::Union{Int, Nothing} = nothing)

Returns a Mimi MarginalModel where the provided m is the base model, and the marginal model has additional emissions of CO2 in year `year`.
If no Model m is provided, the default model from MimiPAGE2009.get_model() is used as the base model.
Note that the returned MarginalModel has already been run.
"""
function get_marginal_model(m::Model = get_model(); year::Union{Int, Nothing} = nothing, pulse_size = 100000.)
    year === nothing ? error("Must specify an emission year. Try `get_marginal_model(m, year=2020)`.") : nothing
    !(year in page_years) ? error("Cannot add marginal emissions in $year, year must be within the model's time index $page_years.") : nothing
    
    mm = create_marginal_model(m, pulse_size)

    add_comp!(mm.modified, ExtraEmissions, :extra_emissions; after=:co2emissions)
    connect_param!(mm.modified, :extra_emissions => :e_globalCO2emissions, :co2emissions => :e_globalCO2emissions)
    set_param!(mm.modified, :extra_emissions, :pulse_size, pulse_size)
    set_param!(mm.modified, :extra_emissions, :pulse_year, year)

    connect_param!(mm.modified, :co2cycle => :e_globalCO2emissions, :extra_emissions => :e_globalCO2emissions_adjusted)
    run(mm)

    return mm
end
