using Mimi
using DataFrames
using Base.Test

m = page_model()
include("../src/components/AdaptationCosts.jl")

adaptationcosts_noneconomic = addadaptationcosts_noneconomic(m)
adaptationcosts_noneconomic[:y_year_0] = 2008.
adaptationcosts_noneconomic[:y_year] = Mimi.dim_keys(m.md, :time)
adaptationcosts_noneconomic[:gdp] = readpagedata(m, "test/validationdata/gdp.csv")

adaptationcosts_economic = addadaptationcosts_economic(m)
adaptationcosts_economic[:y_year_0] = 2008.
adaptationcosts_economic[:y_year] = Mimi.dim_keys(m.md, :time)
adaptationcosts_economic[:gdp] = readpagedata(m, "test/validationdata/gdp.csv")

adaptationcosts_sealevel = addadaptationcosts_sealevel(m)
adaptationcosts_sealevel[:y_year_0] = 2008.
adaptationcosts_sealevel[:y_year] = Mimi.dim_keys(m.md, :time)
adaptationcosts_sealevel[:gdp] = readpagedata(m, "test/validationdata/gdp.csv")

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
