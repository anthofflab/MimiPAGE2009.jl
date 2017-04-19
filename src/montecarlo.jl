using Distributions

include("getpagefunction.jl")
m = getpage()
run(m)
temp=[m[:ClimateTemperature,:rt_g_globaltemperature][10]]

nit=50
@time for i in 1:nit
    # Randomize all components with random parameters
    randomizeCO2cycle(m)
    randomizeclimatetemperature(m)
    randomizediscontinuity(m)
    randomizegdp(m)
    randomizeslrdamages(m)
    randomizesulphatecomp(m)

    run(m)
    push!(temp, m[:ClimateTemperature,:rt_g_globaltemperature][10])
end
