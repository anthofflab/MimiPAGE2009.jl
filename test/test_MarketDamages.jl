
using DataFrames
using Test

m = test_page_model()
include("../src/components/MarketDamages.jl")

marketdamages = add_comp!(m, MarketDamages)

update_param!(m, :MarketDamages, :rtl_realizedtemperature, readpagedata(m, "test/validationdata/rtl_realizedtemperature.csv"))
update_param!(m, :MarketDamages, :rcons_per_cap_SLRRemainConsumption, readpagedata(m,"test/validationdata/rcons_per_cap_SLRRemainConsumption.csv"))
update_param!(m, :MarketDamages, :rgdp_per_cap_SLRRemainGDP, readpagedata(m,"test/validationdata/rgdp_per_cap_SLRRemainGDP.csv"))
update_param!(m, :MarketDamages, :atl_adjustedtolerableleveloftemprise, readpagedata(m,"test/validationdata/atl_adjustedtolerableleveloftemprise_market.csv"))
update_param!(m, :MarketDamages, :imp_actualreduction, readpagedata(m,"test/validationdata/imp_actualreduction_market.csv"))
update_param!(m, :MarketDamages, :isatg_impactfxnsaturation, 28.333333333333336)

update_param!(m, :MarketDamages, :y_year, Mimi.dim_keys(m, :time))

p = load_parameters(m, policy=policy)
update_param!(m, :MarketDamages, :wincf_weightsfactor, p[:shared][:wincf_weightsfactor])
update_param!(m, :MarketDamages, :impmax_maxtempriseforadaptpolicyM, p[:shared][:impmax_economic])

run(m)

rcons_per_cap = m[:MarketDamages, :rcons_per_cap_MarketRemainConsumption]
rcons_per_cap_compare = readpagedata(m, "test/validationdata/rcons_per_cap_MarketRemainConsumption.csv")
@test rcons_per_cap ≈ rcons_per_cap_compare rtol=1e-1

rgdp_per_cap = m[:MarketDamages, :rgdp_per_cap_MarketRemainGDP]
rgdp_per_cap_compare = readpagedata(m, "test/validationdata/rgdp_per_cap_MarketRemainGDP.csv")
@test rgdp_per_cap ≈ rgdp_per_cap_compare rtol=1e-2
