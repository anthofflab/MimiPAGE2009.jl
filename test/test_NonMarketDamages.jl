
using DataFrames
using Test

m = test_page_model()
include("../src/components/NonMarketDamages.jl")

nonmarketdamages = add_comp!(m, NonMarketDamages)

update_param!(m, :NonMarketDamages, :rtl_realizedtemperature, readpagedata(m, "test/validationdata/rtl_realizedtemperature.csv"))
update_param!(m, :NonMarketDamages, :rcons_per_cap_MarketRemainConsumption, readpagedata(m,"test/validationdata/rcons_per_cap_MarketRemainConsumption.csv"))
update_param!(m, :NonMarketDamages, :rgdp_per_cap_MarketRemainGDP, readpagedata(m,"test/validationdata/rgdp_per_cap_MarketRemainGDP.csv"))
update_param!(m, :NonMarketDamages, :atl_adjustedtolerableleveloftemprise, readpagedata(m,"test/validationdata/atl_adjustedtolerableleveloftemprise_nonmarket.csv"))
update_param!(m, :NonMarketDamages, :imp_actualreduction, readpagedata(m,"test/validationdata/imp_actualreduction_nonmarket.csv"))
update_param!(m, :NonMarketDamages, :isatg_impactfxnsaturation, 28.333333333333336)

update_param!(m, :NonMarketDamages, :y_year, Mimi.dim_keys(m, :time))

p = load_parameters(m,)
update_param!(m, :NonMarketDamages, :wincf_weightsfactor, p[:shared][:wincf_weightsfactor])
update_param!(m, :NonMarketDamages, :impmax_maxtempriseforadaptpolicyNM, p[:shared][:impmax_noneconomic])

run(m)

rcons_per_cap = m[:NonMarketDamages, :rcons_per_cap_NonMarketRemainConsumption]
rcons_per_cap_compare = readpagedata(m, "test/validationdata/rcons_per_cap_NonMarketRemainConsumption.csv")
@test rcons_per_cap ≈ rcons_per_cap_compare rtol=1e-2

rgdp_per_cap = m[:NonMarketDamages, :rgdp_per_cap_NonMarketRemainGDP]
rgdp_per_cap_compare = readpagedata(m, "test/validationdata/rgdp_per_cap_NonMarketRemainGDP.csv")
@test rgdp_per_cap ≈ rgdp_per_cap_compare rtol=1e-2
