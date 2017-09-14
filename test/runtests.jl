using Base.Test

tests = [
    "climatemodel",
    "AbatementCosts",
    "AdaptationCosts",
    "CH4cycle",
    "CH4emissions",
    "CH4forcing",
    "ClimateTemperature",
    "co2cycle",
    "CO2emissions",
    "CO2forcing",
    "Discontinuity",
    "EquityWeighting",
    "GDP",
    "LGcycle",
    "LGemissions",
    "LGforcing",
    "loadparameters",
    "mainmodel",
    "MarketDamages",
    "N2Ocycle",
    "N2Oemissions",
    "N2Oforcing",
    "NonMarketDamages",
    "Population",
    "radforcing",
    "SeaLevelRise",
    "SLRDamages",
    "SulphateForcing",
    "TotalAbatementCosts",
    "TotalAdaptationCosts",
    "TotalForcing"
]

for t in tests
    fp = joinpath("test_$t.jl")
    println("$fp ...")
    include(fp)
end
