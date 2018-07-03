using Mimi
using Distributions

include("getpagefunction.jl")
m = getpage() 
run(m)

mcs = @defmcs begin
    
    #Define random variables (RVs)
    include("mcs_RVs.jl")

    # indicate which parameters to save for each model run
    # TODO:  are data slices supported yet?  If not we can do the data slicing
    # afterwards
    save(EquityWeighting.td_totaldiscountedimpacts,
        EquityWeighting.tpc_totalaggregatedcosts, 
        EquityWeighting.tac_totaladaptationcosts,
        EquityWeighting.te_totaleffect,
        co2cycle.c_CO2concentration[10], 
        TotalForcing.ft_totalforcing[10],
        ClimateTemperature.rt_g_globaltemperature[10],
        SeaLevelRise.s_sealevel[10],
        SLRDamages.rgdp_per_cap_SLRRemainGDP[10,8],
        MarketDamages.rgdp_per_cap_MarketRemainGDP[10,8],
        NonMarketDamages.rgdp_per_cap_NonMarketRemainGDP[10,8],
        Discontinuity.rgdp_per_cap_NonMarketRemainGDP[10,8])

end 

# Generate trial data for all RVs and save to a file
# TODO:  see montecarlo.jl for how outputs were formatted, including a dataframe
# and renaming the parameters ... do we want to do that here?  If so, look at best
# way to do so
function do_montecarlo_runs(samplesize::Int)
    generate_trials!(mcs, samplesize, joinpath(@__DIR__, "../output/mimipagemontecarlooutput.csv"))
end
