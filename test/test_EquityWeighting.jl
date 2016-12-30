using Mimi

include("../src/EquityWeighting.jl")

m = Model()
setindex(m, :time, [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200])
setindex(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])

equityweighting = addequityweighting(m)

equityweighting[:tct_percap_totalcosts_total] = zeros(10, 8)
equityweighting[:act_adaptationcosts_total] = zeros(10, 8)
equityweighting[:act_percap_adaptationcosts]=zeros(10,8)
equityweighting[:isat_percap_dis] = zeros(10, 8)
equityweighting[:cons_percap_aftercosts] = zeros(10, 8)
equityweighting[:cons_percap_consumption] = zeros(10, 8)
equityweighting[:yagg_periodspan]=[1.5,5.50,10.,10.,10.,17.5,25.,37.5,50.,25.]

p = load_parameters(m)
p["y_year_0"] = 2008.
p["y_year"] = m.indices_values[:time]

equityweighting[:pop_population] = repeat(p["pop0_initpopulation"]', outer=[10, 1])

setleftoverparameters(m, p)

run(m)
