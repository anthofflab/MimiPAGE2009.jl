using Distributions

include("getpagefunction.jl")
m = getpage()
run(m)

nit=50
td=zeros(nit)
tpc=zeros(nit)
tac=zeros(nit)
te=zeros(nit)
@time for i in 1:nit
    # Randomize all components with random parameters
    randomizeCO2cycle(m)
    randomizeclimatetemperature(m)
    randomizediscontinuity(m)
    randomizegdp(m)
    randomizeslrdamages(m)
    randomizesulphatecomp(m)
    randomizeabatementcosts(m)

    run(m)

    td[i]=m[:EquityWeighting,:td_totaldiscountedimpacts]
    tpc[i]=m[:EquityWeighting,:tpc_totalaggregatedcosts]
    tac[i]=m[:EquityWeighting,:tac_totaladaptationcosts]
    te[i]=m[:EquityWeighting,:te_totaleffect]

    print(i)
end
