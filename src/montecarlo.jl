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
    randomizesulphatecomp(m)
    randomizeclimatetemperature(m)
    randomizeSLR(m)
    randomizegdp(m)
    randomizemarketdamages(m)
    randomizenonmarketdamages(m)
    randomizeslrdamages(m)
    randomizediscontinuity(m)
    randomizeequityweighting(m)
    randomizeabatementcosts(m)
    randomizeadaptationcosts(m)

    run(m)

    td[i]=m[:EquityWeighting,:td_totaldiscountedimpacts]
    tpc[i]=m[:EquityWeighting,:tpc_totalaggregatedcosts]
    tac[i]=m[:EquityWeighting,:tac_totaladaptationcosts]
    te[i]=m[:EquityWeighting,:te_totaleffect]

    print(i)
end
