using Distributions
using DataFrames
using RCall

include("getpagefunction.jl")
m = getpage()
run(m)

nit=100000
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
end

df=DataFrame(td=td,tpc=tpc,tac=tac,te=te)
writetable("../test/validationdata/mimipagemontecarlooutput.csv",df)
#make plots of output Distributions
R"x11()"
R"par(mfrow=c(2,2))"
for i in 1:4
    R"hist($df[,$i]/1e9,main=c('Total Damages','Total Abatement Costs','Total Adaptation Costs','Total Effect')[$i],xlab='Billions of Dollars',col=c('darkslategray1','navyblue','deepskyblue3','dodgerblue4')[$i])"
    R"abline(v=quantile($df[,$i]/1e9,probs=c(0.05,0.95)),lty=2)"
end
