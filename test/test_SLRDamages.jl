using Mimi
using DataFrames
using Base.Test

include("../src/SLRDamages.jl")

m = Model()
setindex(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])
setindex(m, :time, [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200])

slrdamages = addslrdamages(m)

setparameter(m, :SLRDamages, :y_year, [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200])
setparameter(m, :SLRDamages, :atl_adjustedtolerablelevelofsealevelrise, readpagedata(m,
"../test/validationdata/atl_adjustedtolerablelevelofsealevelrise.csv"))
setparameter(m, :SLRDamages, :imp_actualreductionSLR, readpagedata(m,
"../test/validationdata/imp_actualreductionSLR.csv"))
setparameter(m, :SLRDamages, :y_year_0, 2008.)
setparameter(m, :SLRDamages, :s_sealevel, readpagedata(m, "../test/validationdata/s_sealevel.csv"))
setparameter(m, :SLRDamages, :GDP_per_cap_focus_0_FocusRegionEU, readpagedata(m, "../test/validationdata/gdp.csv"))
setparameter(m, :SLRDamages, :cons_percap_consumption, readpagedata(m, "../test/validationdata/cons_percap_consumption.csv"))
setparameter(m, :SLRDamages, :tct_per_cap_totalcostspercap, readpagedata(m, "../test/validationdata/tct_per_cap_totalcostspercap.csv"))
setparameter(m, :SLRDamages, :act_percap_adaptationcosts, readpagedata(m, "../test/validationdata/act_percap_adaptationcosts.csv"))

##running Model
run(m)
