using Mimi
using DataFrames
using Base.Test

include("../src/utils/load_parameters.jl")
include("../src/components/NonMarketDamages.jl")

m = Model()
add_dimension(m, :time, [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200])
add_dimension(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])

nonmarketdamages = addnonmarketdamages(m)

set_parameter!(m, :NonMarketDamages, :rtl_realizedtemperature, readpagedata(m, "test/validationdata/rtl_realizedtemperature.csv"))
set_parameter!(m, :NonMarketDamages, :rcons_per_cap_MarketRemainConsumption, readpagedata(m,
"test/validationdata/rcons_per_cap_MarketRemainConsumption.csv"))
set_parameter!(m, :NonMarketDamages, :rgdp_per_cap_MarketRemainGDP, readpagedata(m,
"test/validationdata/rgdp_per_cap_MarketRemainGDP.csv"))
set_parameter!(m, :NonMarketDamages, :atl_adjustedtolerableleveloftemprise, readpagedata(m,
"test/validationdata/atl_adjustedtolerableleveloftemprise_nonmarket.csv"))
set_parameter!(m, :NonMarketDamages, :imp_actualreduction, readpagedata(m,
"test/validationdata/imp_actualreduction_nonmarket.csv"))
set_parameter!(m, :NonMarketDamages, :isatg_impactfxnsaturation, 28.333333333333336)

p = load_parameters(m)
p["y_year_0"] = 2008.
p["y_year"] = Mimi.dim_keys(m.md, :time)
set_leftover_params!(m, p)

run(m)

rcons_per_cap = m[:NonMarketDamages, :rcons_per_cap_NonMarketRemainConsumption]
rcons_per_cap_compare = readpagedata(m, "test/validationdata/rcons_per_cap_NonMarketRemainConsumption.csv")
@test rcons_per_cap ≈ rcons_per_cap_compare rtol=1e-2

rgdp_per_cap = m[:NonMarketDamages, :rgdp_per_cap_NonMarketRemainGDP]
rgdp_per_cap_compare = readpagedata(m, "test/validationdata/rgdp_per_cap_NonMarketRemainGDP.csv")
@test rgdp_per_cap ≈ rgdp_per_cap_compare rtol=1e-2
