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

p = load_parameters(m)
p["y_year_0"] = 2008.
p["y_year"] = m.indices_values[:time]
setleftoverparameters(m, p)

run(m)

# Generated data
te = m[:EquityWeighting, :te_totaleffect]

# Recorded data
te_compare = 224812034.

@test_approx_eq_eps te te_compare 1.
