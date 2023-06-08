using DataFrames
using CSVFiles
using Test
using Dates

atol = 1e-9 # TODO what is a reasonable tolerance given we test on a few different machines etc.

# the validation file we will use to compare against
validation_results_path = joinpath(@__DIR__, "validationdata", "scc", "deterministic_scc_values_v4_0_2.csv")

# will compute scc for all permutations of following spec options
specs = Dict([
    :year => [2020, 2030, 2040],
    :eta => [0., 1.5],
    :prtp => [0.015, 0.03],
    :equity_weighting => [true, false],
    :pulse_size => [1e5, 1e7, 1e10]
])

# option to create a new validation file to be the baseline for future comparisons
create_validation_file = false

if create_validation_file

    validation_results = DataFrame(year=[], eta=[], prtp=[], equity_weighting=[], pulse_size=[], SCC=[])

    for yr in specs[:year]
        for eta in specs[:eta]
            for prtp in specs[:prtp]
                for equity_weighting in Bool.(specs[:equity_weighting])
                    for pulse_size in specs[:pulse_size]
                        scc = MimiPAGE2009.compute_scc(year=Int(yr), eta=eta, prtp=prtp, equity_weighting=equity_weighting, pulse_size=pulse_size)
                        push!(validation_results, (yr, eta, prtp, string(equity_weighting), pulse_size, scc))
                    end
                end
            end
        end
    end

    d = Dates.now()
    path = joinpath(@__DIR__, "validationdata", "scc", "deterministic_scc_values_$(month(d))_$(day(d))_$(year(d)).csv")
    save(path, validation_results)
end

curr_results = DataFrame(year=[], eta=[], prtp=[], equity_weighting=[], pulse_size=[], SCC=[])

for yr in specs[:year]
    for eta in specs[:eta]
        for prtp in specs[:prtp]
            for equity_weighting in Bool.(specs[:equity_weighting])
                for pulse_size in specs[:pulse_size]
                    scc = MimiPAGE2009.compute_scc(year=Int(yr), eta=eta, prtp=prtp, equity_weighting=equity_weighting, pulse_size=pulse_size)
                    push!(curr_results, (yr, eta, prtp, string(equity_weighting), pulse_size, scc))
                end
            end
        end
    end
end

# Test several validation configurations against the pre-saved values
validation_results = load(validation_results_path) |> DataFrame
@test all(isapprox.(curr_results[!, :SCC], validation_results[!, :SCC], atol=atol))
