using Mimi
using DataFrames
using Base.Test

include("../src/utils/load_parameters.jl")
include("../src/components/MarketDamages.jl")

m = Model()
add_dimension(m, :time, [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200])
add_dimension(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])

marketdamages = addmarketdamages(m)

set_parameter!(m, :MarketDamages, :rtl_realizedtemperature, readpagedata(m, "test/validationdata/rtl_realizedtemperature.csv"))
set_parameter!(m, :MarketDamages, :rcons_per_cap_SLRRemainConsumption, readpagedata(m,"test/validationdata/rcons_per_cap_SLRRemainConsumption.csv"))
set_parameter!(m, :MarketDamages, :rgdp_per_cap_SLRRemainGDP, readpagedata(m,"test/validationdata/rgdp_per_cap_SLRRemainGDP.csv"))
set_parameter!(m, :MarketDamages, :atl_adjustedtolerableleveloftemprise, readpagedata(m,"test/validationdata/atl_adjustedtolerableleveloftemprise_market.csv"))
set_parameter!(m, :MarketDamages, :imp_actualreduction, readpagedata(m,"test/validationdata/imp_actualreduction_market.csv"))
set_parameter!(m, :MarketDamages, :isatg_impactfxnsaturation, 28.333333333333336)

p = load_parameters(m)
p["y_year_0"] = 2008.
p["y_year"] = Mimi.dim_keys(m.md, :time)
set_leftover_params!(m, p)

run(m)

rcons_per_cap = m[:MarketDamages, :rcons_per_cap_MarketRemainConsumption]
rcons_per_cap_compare = readpagedata(m, "test/validationdata/rcons_per_cap_MarketRemainConsumption.csv")
@test rcons_per_cap ≈ rcons_per_cap_compare rtol=1e-1

rgdp_per_cap = m[:MarketDamages, :rgdp_per_cap_MarketRemainGDP]
rgdp_per_cap_compare = readpagedata(m, "test/validationdata/rgdp_per_cap_MarketRemainGDP.csv")
@test rgdp_per_cap ≈ rgdp_per_cap_compare rtol=1e-2
