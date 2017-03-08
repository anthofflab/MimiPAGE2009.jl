using Mimi
using Base.Test

include("../src/load_parameters.jl")
include("../src/EquityWeighting.jl")

m = Model()
setindex(m, :time, [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200])
setindex(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])

equityweighting = addequityweighting(m)

equityweighting[:tct_percap_totalcosts_total] = readpagedata(m, "test/validationdata/tct_per_cap_totalcostspercap.csv")
equityweighting[:act_adaptationcosts_total] = readpagedata(m, "test/validationdata/act_adaptationcosts_tot.csv")
equityweighting[:act_percap_adaptationcosts] = readpagedata(m, "test/validationdata/act_percap_adaptationcosts.csv")
equityweighting[:isat_percap_dis] = readpagedata(m, "test/validationdata/isat_percap_dis.csv")
equityweighting[:cons_percap_aftercosts] = readpagedata(m, "test/validationdata/cons_percap_aftercosts.csv")
equityweighting[:cons_percap_consumption] = readpagedata(m, "test/validationdata/cons_percap_consumption.csv")
equityweighting[:yagg_periodspan] = readpagedata(m, "test/validationdata/yagg_periodspan.csv")
equityweighting[:pop_population] = readpagedata(m, "test/validationdata/pop_population.csv")
equityweighting[:y_year_0] = 2008.
equityweighting[:y_year] = m.indices_values[:time]

p = load_parameters(m)
setleftoverparameters(m, p)

run(m)

# Generated data
df = m[:EquityWeighting, :df_utilitydiscountrate]
wtct_percap = m[:EquityWeighting, :wtct_percap_weightedcosts]
pct_percap = m[:EquityWeighting, :pct_percap_partiallyweighted]
wacdt = m[:EquityWeighting, :wacdt_partiallyweighted_discounted]
te = m[:EquityWeighting, :te_totaleffect]

# Recorded data
df_compare = readpagedata(m, "test/validationdata/df_utilitydiscountrate.csv")
wtct_percap_compare = readpagedata(m, "test/validationdata/wtct_percap_weightedcosts.csv")
pct_percap_compare = readpagedata(m, "test/validationdata/pct_percap_partiallyweighted.csv")
wacdt_compare = readpagedata(m, "test/validationdata/wacdt_partiallyweighted_discounted.csv")
te_compare = 224812034.

@test_approx_eq_eps df df_compare 1e-6 # Checks out

@test_approx_eq_eps wtct_percap wtct_percap_compare 1.

@test_approx_eq_eps pct_percap pct_percap_compare 1.

@test_approx_eq_eps wacdt wacdt_compare 1.

@test_approx_eq_eps te te_compare 1.
