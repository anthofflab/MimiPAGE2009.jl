using Base.Test
using CSVFiles
using Missings

Mimi.reset_compdefs()

include("../src/mcs.jl")

regenerate = false # do a large MC run, to regenerate information needed for std. errors
samplesize = 1000 # normal MC sample size (takes ~5 seconds)
confidence = 2.576 # 99% CI by default; use 1.96 to apply a 95% CI, but expect more spurious errors

# Monte Carlo distribution information
# Filled in from a run with regenerate = true
information = Dict(
    :td => Dict(:transform => x -> log(x), :mu => 19.268649852193303, :sigma => 1.0189429437682878),
    :tpc => Dict(:transform => x -> log(-x), :mu => 16.723536381185546, :sigma => 0.9100375935397476),
    :tac => Dict(:transform => x -> log(x), :mu => 17.35110886191308, :sigma => 0.3586397403122257),
    :te => Dict(:transform => x -> log(x), :mu => 19.30193679432187, :sigma => 1.048364875171592),
    :c_co2concentration => Dict(:transform => x -> x, :mu => 913073.0003103315, :sigma => 71674.18878428967),
    :ft => Dict(:transform => x -> x, :mu => 8.637901336461365, :sigma => 0.4315112767385383),
    :rt_g => Dict(:transform => x -> x, :mu => 5.888175260413073, :sigma => 1.7673873280904946),
    :sealevel => Dict(:transform => x -> x, :mu => 1.6056649448621665, :sigma => 0.6124270241884567)
)

compare = DataFrame(load(joinpath(@__DIR__, "validationdata/PAGE09montecarloquantiles.csv")))

if regenerate
    println("Regenerating MC distribution information")

    # Perform a large MC run and extract statistics
    do_monte_carlo_runs(100_000)
    df = DataFrame(load(joinpath(@__DIR__, "../output/mimipagemontecarlooutput.csv")))

     for ii in 1:nrow(compare)
        name = Symbol(compare[ii, :Variable_Name])
        if kurtosis(df[name]) > 2.9 # exponential distribution
            if name == :tpc # negative across all quantiles
                print("    :$name => Dict(:transform => x -> log(-x), :mu => $(mean(log(-df[df[name] .< 0, name]))), :sigma => $(std(log(-df[df[name] .< 0, name]))))")
            else
                print("    :$name => Dict(:transform => x -> log(x), :mu => $(mean(log(df[df[name] .> 0, name]))), :sigma => $(std(log(df[df[name] .> 0, name]))))")
            end
        else
            print("    :$name => Dict(:transform => x -> x, :mu => $(mean(df[name])), :sigma => $(std(df[name])))")
        end
        if ii != nrow(compare)
            println(",")
        end
    end 

else
    println("Performing MC sample")
    # Perform a small MC run
    do_monte_carlo_runs(samplesize)
    df = DataFrame(load(joinpath(@__DIR__, "../output/mimipagemontecarlooutput.csv")))
end

# Compare all known quantiles
for ii in 1:nrow(compare)
    name = Symbol(compare[ii, :Variable_Name])
    transform = information[name][:transform]
    distribution = Normal(information[name][:mu], information[name][:sigma])
    for qval in [.05, .10, .25, .50, .75, .90, .95]
        estimated = transform(quantile(collect(Missings.skipmissing(df[name])), qval)) # perform transform *after* quantile, so captures effect of all values
        stderr = sqrt(qval * (1 - qval) / (samplesize * pdf(distribution, estimated)^2))

        expected = transform(compare[ii, Symbol("perc_$(trunc(Int, qval * 100))")])

        #println("$name x $qval: $estimated ≈ $expected rtol=$(ceil(confidence * stderr, -trunc(Int, log10(stderr))))")
        @test estimated ≈ expected rtol=ceil(confidence * stderr, -trunc(Int, log10(stderr)))
    end
end
