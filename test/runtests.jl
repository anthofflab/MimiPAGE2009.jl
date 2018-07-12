using Base.Test
using Mimi

function page_model()
    include("../src/utils/load_parameters.jl")
    m = Model()
    set_dimension!(m, :time, [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200])
    set_dimension!(m, :region, ["EU", "USA", "OECD", "USSR", "China", "SEAsia", "Africa", "LatAmerica"])
    return m
 end

@testset "mimi-page.jl" begin

include("test_climatemodel.jl")
include("test_AbatementCosts.jl")
include("test_AdaptationCosts.jl")
include("test_CH4cycle.jl")
include("test_CH4emissions.jl")
include("test_CH4forcing.jl")
include("test_ClimateTemperature.jl")
include("test_CO2cycle.jl")
include("test_CO2emissions.jl")
include("test_CO2forcing.jl")
include("test_Discontinuity.jl")
include("test_EquityWeighting.jl")
include("test_GDP.jl")
include("test_LGcycle.jl")
include("test_LGemissions.jl")
include("test_LGforcing.jl")
include("test_loadparameters.jl")
include("test_mainmodel.jl")
include("test_mainmodel_policyb.jl")
include("test_MarketDamages.jl")
include("test_N2Ocycle.jl")
include("test_N2Oemissions.jl")
include("test_N2Oforcing.jl")
include("test_NonMarketDamages.jl")
include("test_Population.jl")
include("test_SeaLevelRise.jl")
include("test_SLRDamages.jl")
include("test_SulphateForcing.jl") 
include("test_TotalAbatementCosts.jl")
include("test_TotalAdaptationCosts.jl")
include("test_TotalForcing.jl")
#include("test_mcs.jl") #new mcs framework, not finished yet

end
