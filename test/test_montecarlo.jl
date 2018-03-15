using Base.Test

include("../src/montecarlo.jl")

regenerate = false
samplesize = 1000

if regenerate
    do_monte_carlo_runs()
else
    do_monte_carlo_runs(samplesize)
end

df = readtable("../output/mimipagemontecarlooutput.csv")

if regenerate
    for name in names(df)
        mu = mean(df[name])
        sigma = std(df[name])
        mustderr = sigma / sqrt(samplesize)
        sigmastderr = sigma / sqrt(samplesize - 2)
        println("@test mean(df[:$name]) ≈ $mu rtol=$(ceil(2.576 * mustderr, -trunc(Int, log10(mustderr))))")
        println("@test std(df[:$name]) ≈ $sigma rtol=$(ceil(2.576 * mustderr, -trunc(Int, log10(sigmastderr))))")
    end
end

@test mean(df[:td]) ≈ 4.0045620307350564e8 rtol=5.0e7
@test std(df[:td]) ≈ 5.3118074357074183e8 rtol=5.0e7
@test mean(df[:tpc]) ≈ -2.6595182663207453e7 rtol=1.8999999999999998e6
@test std(df[:tpc]) ≈ 2.2695053054283816e7 rtol=1.8999999999999998e6
@test mean(df[:tac]) ≈ 3.663364738169777e7 rtol=1.2e6
@test std(df[:tac]) ≈ 1.3981586450397965e7 rtol=1.2e6
@test mean(df[:te]) ≈ 4.1049466779199594e8 rtol=5.0e7
@test std(df[:te]) ≈ 5.383906204839039e8 rtol=5.0e7
@test mean(df[:c_co2concentration]) ≈ 913185.0480391708 rtol=6000.0
@test std(df[:c_co2concentration]) ≈ 71599.16655409422 rtol=6000.0
@test mean(df[:ft]) ≈ 8.638614796688842 rtol=0.1
@test std(df[:ft]) ≈ 0.43102824184480093 rtol=0.1
@test mean(df[:rt_g]) ≈ 5.892286659666864 rtol=0.2
@test std(df[:rt_g]) ≈ 1.7716819863661326 rtol=0.2
@test mean(df[:sealevel]) ≈ 1.6077643074430088 rtol=0.1
@test std(df[:sealevel]) ≈ 0.6153532289526266 rtol=0.1
@test mean(df[:rgdppercap_slr]) ≈ 1.3467160532051844e6 rtol=240.0
@test std(df[:rgdppercap_slr]) ≈ 2850.3305973503266 rtol=240.0
@test mean(df[:rgdppercap_market]) ≈ 1.3202623978236795e6 rtol=3000.0
@test std(df[:rgdppercap_market]) ≈ 34132.24535263953 rtol=3000.0
@test mean(df[:rgdppercap_nonmarket]) ≈ 1.265622393634412e6 rtol=7000.0
@test std(df[:rgdppercap_nonmarket]) ≈ 84472.52874991852 rtol=7000.0
@test mean(df[:rgdppercap_di]) ≈ 1.265622393634412e6 rtol=7000.0
@test std(df[:rgdppercap_di]) ≈ 84472.52874991852 rtol=7000.0

