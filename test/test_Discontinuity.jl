using Mimi
using Base.Test

include("../src/Discontinuity.jl")

m = Model()
setindex(m, :time, 10)
setindex(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])

adddiscontinuity(m)

setparameter(m, :Discontinuity, :rt_g_globaltemperature, [0.75,0.75,1.0,1.1,1.3,1.5,2.0,2.6,3.0,4.5])
setparameter(m, :Discontinuity, :y_year_0, 2008.)
setparameter(m, :Discontinuity, :y_year, [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200])
setparameter(m, :Discontinuity, :rgdp_per_cap_NonMarketRemainGDP, transpose(repmat(readpagedata(m, "../data/gdp_0.csv"), 1, 10))/transpose(repmat(readpagedata(m, "../data/pop0_initpopulation.csv"), 1, 10)))
setparameter(m, :Discontinuity, :rcons_per_cap_NonMarketRemainConsumption, ones(10,8))

##running Model
run(m)

@test !isna(m[:Discontinuity, :irefeqdis_eqdiscimpact][8])
@test !isna(m[:Discontinuity, :igdpeqdis_eqdiscimpact][10,8])
@test !isna(m[:Discontinuity, :igdp_realizeddiscimpact][10,8])
@test !isna(m[:Discontinuity, :occurdis_occurrencedummy][10])
@test !isna(m[:Discontinuity, :expfdis_discdecay][10])
@test !isna(m[:Discontinuity, :idis_lossfromdisc][10])
@test !isna(m[:Discontinuity, :isat_satdiscimpact][10,8])
@test !isna(m[:Discontinuity, :isat_per_cap_DiscImpactperCapinclSaturation][10,8])
@test !isna(m[:Discontinuity, :rcons_per_cap_DiscRemainConsumption][10])
