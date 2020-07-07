
using Test

m = page_model()
include("../src/components/EquityWeighting.jl")

equityweighting = add_comp!(m, EquityWeighting)

equityweighting[:tct_percap_totalcosts_total] = readpagedata(m, "test/validationdata/tct_per_cap_totalcostspercap.csv")
equityweighting[:act_adaptationcosts_total] = readpagedata(m, "test/validationdata/act_adaptationcosts_tot.csv")
equityweighting[:act_percap_adaptationcosts] = readpagedata(m, "test/validationdata/act_percap_adaptationcosts.csv")
equityweighting[:cons_percap_aftercosts] = readpagedata(m, "test/validationdata/cons_percap_aftercosts.csv")
equityweighting[:cons_percap_consumption] = readpagedata(m, "test/validationdata/cons_percap_consumption.csv")
equityweighting[:cons_percap_consumption_0] = readpagedata(m, "test/validationdata/cons_percap_consumption_0.csv")
equityweighting[:rcons_percap_dis] = readpagedata(m, "test/validationdata/rcons_per_cap_DiscRemainConsumption.csv")
equityweighting[:yagg_periodspan] = readpagedata(m, "test/validationdata/yagg_periodspan.csv")
equityweighting[:pop_population] = readpagedata(m, "test/validationdata/pop_population.csv")
equityweighting[:y_year_0] = 2008.
equityweighting[:y_year] = Mimi.dim_keys(m.md, :time)

p = load_parameters(m)
set_leftover_params!(m, p)

run(m)

# Generated data
df = m[:EquityWeighting, :df_utilitydiscountfactor]
wtct_percap = m[:EquityWeighting, :wtct_percap_weightedcosts]
pct_percap = m[:EquityWeighting, :pct_percap_partiallyweighted]
dr = m[:EquityWeighting, :dr_discountrate]
dfc = m[:EquityWeighting, :dfc_consumptiondiscountrate]
pct = m[:EquityWeighting, :pct_partiallyweighted]
pcdt = m[:EquityWeighting, :pcdt_partiallyweighted_discounted]
wacdt = m[:EquityWeighting, :wacdt_partiallyweighted_discounted]
aact = m[:EquityWeighting, :aact_equityweightedadaptation_discountedaggregated]

wit = m[:EquityWeighting, :wit_equityweightedimpact]
addt = m[:EquityWeighting, :addt_equityweightedimpact_discountedaggregated]
addt_gt = m[:EquityWeighting, :addt_gt_equityweightedimpact_discountedglobal]
te = m[:EquityWeighting, :te_totaleffect]

# Recorded data
df_compare = readpagedata(m, "test/validationdata/df_utilitydiscountfactor.csv")
wtct_percap_compare = readpagedata(m, "test/validationdata/wtct_percap_weightedcosts.csv")
pct_percap_compare = readpagedata(m, "test/validationdata/pct_percap_partiallyweighted.csv")
dr_compare = readpagedata(m, "test/validationdata/dr_discountrate.csv")
dfc_compare = readpagedata(m, "test/validationdata/dfc_consumptiondiscountrate.csv")
pct_compare = readpagedata(m, "test/validationdata/pct_partiallyweighted.csv")
pcdt_compare = readpagedata(m, "test/validationdata/pcdt_partiallyweighted_discounted.csv")
wacdt_compare = readpagedata(m, "test/validationdata/wacdt_partiallyweighted_discounted.csv")
aact_compare = readpagedata(m, "test/validationdata/aact_equityweightedadaptation_discountedaggregated.csv")

wit_compare = readpagedata(m, "test/validationdata/wit_equityweightedimpact.csv")
addt_compare = readpagedata(m, "test/validationdata/addt_equityweightedimpact_discountedaggregated.csv")
addt_gt_compare = 204132238.85242900
te_compare = 213208136.69903600

@test df ≈ df_compare rtol=1e-8
@test wtct_percap ≈ wtct_percap_compare rtol=1e-7
@test pct_percap ≈ pct_percap_compare rtol=1e-7
@test dr ≈ dr_compare rtol=1e-5
@test dfc ≈ dfc_compare rtol=1e-7
@test pct ≈ pct_compare rtol=1e-3
@test pcdt ≈ pcdt_compare rtol=1e-3
@test wacdt ≈ wacdt_compare rtol=1e-4

@test aact ≈ aact_compare rtol=1e-3

@test wit ≈ wit_compare rtol=1e-3
@test addt ≈ addt_compare rtol=1e-2
@test addt_gt ≈ addt_gt_compare rtol=1e-2

@test te ≈ te_compare rtol=1e-2

