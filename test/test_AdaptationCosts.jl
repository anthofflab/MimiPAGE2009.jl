
using DataFrames
using Test

m = test_page_model()
include("../src/components/AdaptationCosts.jl")

adaptationcosts_noneconomic = MimiPAGE2009.addadaptationcosts_noneconomic(m)
adaptationcosts_economic = MimiPAGE2009.addadaptationcosts_economic(m)
adaptationcosts_sealevel = MimiPAGE2009.addadaptationcosts_sealevel(m)

update_param!(m, :y_year_0, 2008)
update_param!(m, :y_year, Mimi.dim_keys(m.md, :time))
update_param!(m, :gdp, readpagedata(m, "test/validationdata/gdp.csv"))
update_param!(m, :automult_autonomouschange, 0.65)

p = load_parameters(m)
set_leftover_params!(m, p)

run(m)

autofac = m[:AdaptiveCostsEconomic, :autofac_autonomouschangefraction]
atl_economic = m[:AdaptiveCostsEconomic, :atl_adjustedtolerablelevel]
imp_economic = m[:AdaptiveCostsEconomic, :imp_adaptedimpacts]
acp_economic = m[:AdaptiveCostsEconomic, :acp_adaptivecostplateau]
aci_economic = m[:AdaptiveCostsEconomic, :aci_adaptivecostimpact]

autofac_compare = readpagedata(m, "test/validationdata/autofac_autonomouschangefraction.csv")
atl_economic_compare = readpagedata(m, "test/validationdata/atl_1.csv")
imp_economic_compare = readpagedata(m, "test/validationdata/imp_1.csv")
acp_economic_compare = readpagedata(m, "test/validationdata/acp_adaptivecostplateau_economic.csv")
aci_economic_compare = readpagedata(m, "test/validationdata/aci_adaptivecostimpact_economic.csv")

@test autofac ≈ autofac_compare rtol=1e-8
@test atl_economic ≈ atl_economic_compare rtol=1e-8
@test imp_economic ≈ imp_economic_compare rtol=1e-8
@test acp_economic ≈ acp_economic_compare rtol=1e-3
@test aci_economic ≈ aci_economic_compare rtol=1e-3

ac_noneconomic = m[:AdaptiveCostsNonEconomic, :ac_adaptivecosts]
ac_economic = m[:AdaptiveCostsEconomic, :ac_adaptivecosts]
ac_sealevel = m[:AdaptiveCostsSeaLevel, :ac_adaptivecosts]

ac_noneconomic_compare = readpagedata(m, "test/validationdata/ac_adaptationcosts_noneconomic.csv")
ac_economic_compare = readpagedata(m, "test/validationdata/ac_adaptationcosts_economic.csv")
ac_sealevel_compare = readpagedata(m, "test/validationdata/ac_adaptationcosts_sealevelrise.csv")

@test ac_noneconomic ≈ ac_noneconomic_compare rtol=1e-2
@test ac_economic ≈ ac_economic_compare rtol=1e-3
@test ac_sealevel ≈ ac_sealevel_compare rtol=1e-2
