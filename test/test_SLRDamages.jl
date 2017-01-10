using Mimi

include("../src/SLRDamages.jl")

m = Model()
setindex(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])
setindex(m, :time, 10)

slrdamages = addslrdamages(m)

#slrdamages[:rt_g_globaltemperature] = ones(10)
slrdamages[:y_year] = [2001.,2002.,2010.,2020.,2040.,2060.,2080.,2100.,2150.,2200.]
slrdamages[:atl_adjustedtolerablelevelofsealevelrise] = ones(10,8)
slrdamages[:imp_actualreductionSLR] = ones(10,8) *0.5
setparameter(m, :SLRDamages, :y_year_0, 2000.) #real value
# TODO Replace with real numbers
setparameter(m, :SLRDamages, :s_sealevel, zeros(10))
setparameter(m, :SLRDamages, :GDP_per_cap_focus_0_FocusRegionEU, float(30000))
slrdamages[:cons_percap_consumption]= fill(20000,10,8)
slrdamages[:tct_per_cap_totalcostspercap]= fill(5000,10,8)
slrdamages[:act_percap_adaptationcosts]= fill(2000,10,8)

##running Model
run(m)
