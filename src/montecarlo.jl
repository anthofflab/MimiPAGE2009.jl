using Distributions

include("getpagefunction.jl")
m = getpage()
run(m)
temp=[m[:ClimateTemperature,:rt_g_globaltemperature][10]]

nit=50
@time for i in 1:nit
    # Randomize all components with random parameters
    randomizeCO2cycle(m)
    randomizesulphatecomp(m)
    randomizeclimatetemperature(m)
    randomizeSLR(m)
    randomizegdp(m)
    randomizemarketdamages(m)
    randomizenonmarketdamages(m)
    randomizeslrdamages(m)
    randomizediscontinuity(m)
    randomizeequityweighting(m)

    run(m)
    push!(temp, m[:ClimateTemperature,:rt_g_globaltemperature][10])
end
