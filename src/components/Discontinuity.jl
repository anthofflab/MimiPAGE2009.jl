using Mimi
using Distributions
include("../utils/mctools.jl")

@defcomp Discontinuity begin

  region = Index()
  y_year=Parameter(index=[time], unit="year")
  y_year_0 = Parameter(unit="year")

  rand_discontinuity = Parameter(unit="unitless", default=.5)

  irefeqdis_eqdiscimpact=Variable(index=[region], unit="%")
  wincf_weightsfactor=Parameter(index=[region], unit="unitless", default=[1, 0.8, 0.8, 0.4, 0.8, 0.8, 0.6, 0.6])
  wdis_gdplostdisc=Parameter(unit="%", default=15.)

  igdpeqdis_eqdiscimpact=Variable(index=[time,region], unit="%")
  rgdp_per_cap_NonMarketRemainGDP=Parameter(index=[time,region], unit="\$/person")
  GDP_per_cap_focus_0_FocusRegionEU = Parameter(unit="unitless", default=27934.244777382406)
  ipow_incomeexponent=Parameter(unit="unitless", default=-0.13333333333333333)

  igdp_realizeddiscimpact=Variable(index=[time,region], unit="%")
  occurdis_occurrencedummy=Variable(index=[time], unit="unitless")
  expfdis_discdecay=Variable(index=[time], unit="unitless")

  distau_discontinuityexponent=Parameter(unit="unitless", default=90.)

  idis_lossfromdisc=Variable(index=[time], unit="degreeC")
  tdis_tolerabilitydisc=Parameter(unit="degreeC", default=3.)
  rt_g_globaltemperature = Parameter(index=[time], unit="degreeC")
  pdis_probability=Parameter(unit="%/degreeC", default=20.)

  isatg_saturationmodification = Parameter(unit="unitless")
  isat_satdiscimpact=Variable(index=[time,region], unit="%")

  isat_per_cap_DiscImpactperCapinclSaturation=Variable(index=[time,region], unit="\$/person")
  rcons_per_cap_DiscRemainConsumption=Variable(index=[time, region], unit = "\$/person")
  rcons_per_cap_NonMarketRemainConsumption = Parameter(index=[time, region], unit = "\$/person")   

    function run_timestep(p, v, d, t)

        v.idis_lossfromdisc[t] = max(0, p.rt_g_globaltemperature[t] - p.tdis_tolerabilitydisc)

        if t == 1
            if v.idis_lossfromdisc[t]*(p.pdis_probability/100) > p.rand_discontinuity
                v.occurdis_occurrencedummy[t] = 1
            else
                v.occurdis_occurrencedummy[t] = 0
            end
            v.expfdis_discdecay[t]=exp(-(p.y_year[t] - p.y_year_0)/p.distau_discontinuityexponent)
        else
            if v.idis_lossfromdisc[t]*(p.pdis_probability/100) > p.rand_discontinuity
                v.occurdis_occurrencedummy[t] = 1
            elseif v.occurdis_occurrencedummy[t-1] == 1
                v.occurdis_occurrencedummy[t] = 1
            else
                v.occurdis_occurrencedummy[t] = 0
            end
            v.expfdis_discdecay[t]=exp(-(p.y_year[t] - p.y_year[t-1])/p.distau_discontinuityexponent)
        end

        for r in d.region
            v.irefeqdis_eqdiscimpact[r] = p.wincf_weightsfactor[r]*p.wdis_gdplostdisc

            v.igdpeqdis_eqdiscimpact[t,r] = v.irefeqdis_eqdiscimpact[r] * (p.rgdp_per_cap_NonMarketRemainGDP[t,r]/p.GDP_per_cap_focus_0_FocusRegionEU)^p.ipow_incomeexponent

            if t==1
                v.igdp_realizeddiscimpact[t,r]=v.occurdis_occurrencedummy[t]*(1-v.expfdis_discdecay[t])*v.igdpeqdis_eqdiscimpact[t,r]
            else
                v.igdp_realizeddiscimpact[t,r]=v.igdp_realizeddiscimpact[t-1,r]+v.occurdis_occurrencedummy[t]*(1-v.expfdis_discdecay[t])*(v.igdpeqdis_eqdiscimpact[t,r]-v.igdp_realizeddiscimpact[t-1,r])
            end

            if v.igdp_realizeddiscimpact[t,r] < p.isatg_saturationmodification
                v.isat_satdiscimpact[t,r] = v.igdp_realizeddiscimpact[t,r]
            else
                v.isat_satdiscimpact[t,r] = p.isatg_saturationmodification + (100-p.isatg_saturationmodification)*((v.igdp_realizeddiscimpact[t,r]-p.isatg_saturationmodification)/((100-p.isatg_saturationmodification)+(v.igdp_realizeddiscimpact[t,r] - p.isatg_saturationmodification)))
            end
            v.isat_per_cap_DiscImpactperCapinclSaturation[t,r] = (v.isat_satdiscimpact[t,r]/100)*p.rgdp_per_cap_NonMarketRemainGDP[t,r]
            v.rcons_per_cap_DiscRemainConsumption[t,r] = p.rcons_per_cap_NonMarketRemainConsumption[t,r] - v.isat_per_cap_DiscImpactperCapinclSaturation[t,r]
        end
    end
end
