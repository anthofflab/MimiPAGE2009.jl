
using Test

m = test_page_model()
include("../src/components/Discontinuity.jl")

add_comp!(m, Discontinuity)

update_param!(m, :Discontinuity, :rt_g_globaltemperature, [0.75,0.77,0.99,1.27,1.62,1.99,3.07,3.90,5.10,6.03])
update_param!(m, :Discontinuity, :y_year_0, 2008.)
update_param!(m, :Discontinuity, :y_year, [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200])
update_param!(m, :Discontinuity, :rgdp_per_cap_NonMarketRemainGDP, readpagedata(m, "test/validationdata/rgdp_per_cap_NonMarketRemainGDP.csv"))
update_param!(m, :Discontinuity, :rcons_per_cap_NonMarketRemainConsumption, readpagedata(m, "test/validationdata/rcons_per_cap_NonMarketRemainConsumption.csv"))
update_param!(m, :Discontinuity, :isatg_saturationmodification, 28.333333333333336)

##running Model
run(m)

@test !isnan(m[:Discontinuity, :irefeqdis_eqdiscimpact][8])
@test !isnan(m[:Discontinuity, :igdpeqdis_eqdiscimpact][10,8])
@test !isnan(m[:Discontinuity, :igdp_realizeddiscimpact][10,8])
@test !isnan(m[:Discontinuity, :occurdis_occurrencedummy][10])
@test !isnan(m[:Discontinuity, :expfdis_discdecay][10])
@test !isnan(m[:Discontinuity, :idis_lossfromdisc][10])
@test !isnan(m[:Discontinuity, :isat_satdiscimpact][10,8])
@test !isnan(m[:Discontinuity, :isat_per_cap_DiscImpactperCapinclSaturation][10,8])
@test !isnan(m[:Discontinuity, :rcons_per_cap_DiscRemainConsumption][10])

#validating - comparison spreadsheet has discontinuity occuring in 2200
#keep running model until m[:Discontinuity,:occurdis_occurrencedummy] shows discontiuity occuring in 2200
output=m[:Discontinuity,:rcons_per_cap_DiscRemainConsumption]
validation=readpagedata(m,"test/validationdata/rcons_per_cap_DiscRemainConsumption.csv")

@test output ≈ validation rtol=1e-2
