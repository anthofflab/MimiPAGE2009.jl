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

@defcomp PAGE_marginal_emissions begin 
    er_CO2emissionsgrowth = Variable(index=[time,region], unit = "%")
    marginal_emissions_growth = Parameter(index=[time,region], unit = "%", default = zeros(10,8))
    function run_timestep(p, v, d, t)
        if is_first(t)
            v.er_CO2emissionsgrowth[:, :] = p.marginal_emissions_growth[:, :]
        end
    end
end

"""
compute_scc(m::Model = get_model(); year::Union{Int, Nothing} = nothing, eta::Union{Float64, Nothing} = nothing, prtp::Union{Float64, Nothing} = nothing)

Computes the social cost of CO2 for an emissions pulse in `year` for the provided MimiPAGE2009 model. 
If no model is provided, the default model from MimiPAGE2009.get_model() is used.
Discounting scheme can be specified by the `eta` and `prtp` parameters, which will update the values of emuc_utilitiyconvexity and ptp_timepreference in the model. 
If no values are provided, the discount factors will be computed using the default PAGE values of emuc_utilitiyconvexity=1.1666666667 and ptp_timepreference=1.0333333333.
"""
function compute_scc(
        m::Model = get_model();
        year::Union{Int, Nothing} = nothing,
        eta::Union{Float64, Nothing} = nothing,
        prtp::Union{Float64, Nothing} = nothing,
        pulse_size = 100000.,
        n::Union{Int,Nothing}=nothing,
        seed::Union{Int, Nothing} = nothing
        )

    year === nothing ? error("Must specify an emission year. Try `compute_scc(m, year=2020)`.") : nothing
    !(year in page_years) ? error("Cannot compute the scc for year $year, year must be within the model's time index $page_years.") : nothing 

    eta == nothing ? nothing : update_param!(m, :emuc_utilityconvexity, eta)
    prtp == nothing ? nothing : update_param!(m, :ptp_timepreference, prtp * 100.)

    mm = get_marginal_model(m, year=year, pulse_size=pulse_size)   # Returns a marginal model that has already been run

    if n===nothing
        # Run the "best guess" social cost calculation
        run(mm)
        scc = mm[:EquityWeighting, :td_totaldiscountedimpacts]
    elseif n<1
        error("Invalid `n` value, only values >=1 allowed.")
    else
        # Run a Monte Carlo simulation
        simdef = getsim()
        seed !== nothing ? Random.seed!(seed) : nothing
        si = run(simdef, mm, n)
        scc = si[:EquityWeighting, :td_totaldiscountedimpacts].td_totaldiscountedimpacts
    end

    return scc
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

    eta == nothing ? nothing : update_param!(m, :emuc_utilityconvexity, eta)
    prtp == nothing ? nothing : update_param!(m, :ptp_timepreference, prtp * 100.)

    mm = get_marginal_model(m, year=year, pulse_size=pulse_size)   # Returns a marginal model that has already been run
    scc = mm[:EquityWeighting, :td_totaldiscountedimpacts]

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

    add_comp!(mm.marginal, PAGE_marginal_emissions, :marginal_emissions; before = :co2emissions)
    connect_param!(mm.marginal, :co2emissions=>:er_CO2emissionsgrowth, :marginal_emissions=>:er_CO2emissionsgrowth)
    connect_param!(mm.marginal, :AbatementCostsCO2=>:er_emissionsgrowth, :marginal_emissions=>:er_CO2emissionsgrowth)

    i = getpageindexfromyear(year) 

    # Base model
    run(mm.base)
    base_glob0_emissions = mm.base[:co2cycle, :e0_globalCO2emissions]
    er_co2_a = mm.base[:co2emissions, :er_CO2emissionsgrowth][i, :]
    e_co2_g = mm.base[:co2emissions, :e_globalCO2emissions]  

    # Calculate pulse 
    ER_SCC = 100 * -1 * pulse_size / (base_glob0_emissions * getperiodlength(year))
    pulse = er_co2_a - ER_SCC * (er_co2_a/100) * (base_glob0_emissions / e_co2_g[i])
    marginal_emissions_growth = copy(mm.base[:co2emissions, :er_CO2emissionsgrowth])
    marginal_emissions_growth[i, :] = pulse

    # Marginal emissions model
    update_param!(mm.marginal, :marginal_emissions_growth, marginal_emissions_growth)
    run(mm.marginal)

    return mm
end