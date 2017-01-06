
using Mimi

@defcomp Discontinuity begin

  region = Index(region)
  y_year=Parameter(index=[time], unit="year")
  y_year_0 = Parameter(unit="year")

  irefeqdis_eqdiscimpact=Variable(index=[region], unit="%")
  wincf_weightsfactor=Parameter(index=[region], unit="unitless")
  wdis_gdplostdisc=Parameter(unit="%")

  igdpeqdis_eqdiscimpact=Variable(index=[time,region], unit="%")
  rgdp_per_cap_DiscRemainGDP=Parameter(index=[time,region], unit="\$/person")
  GDP_per_cap_focus_0_FocusRegionEU = Parameter(unit="unitless")
  ipow_incomeexponent=Parameter(unit="unitless")

  igdp_realizeddiscimpact=Variable(index=[time,region], unit="%")
  occurdis_occurrencedummy=Variable(index=[time], unit="unitless")
  expfdis_discdecay=Variable(index=[time], unit="unitless")

  distau_discontinuityexponent=Parameter(unit="unitless")

  idis_lossfromdisc=Variable(index=[time], unit="degreeC")
  tdis_tolerabilitydisc=Parameter(unit="degreeC")
  rt_g_globaltemperature = Parameter(index=[time], unit="degreeC")
  pdis_probability=Parameter(unit="%/degreeC")

  isat_satdiscimpact=Variable(index=[time,region], unit="%")
  isatg_saturationmodification=Variable(unit="unitless")

  isat_per_cap_DiscImpactperCapinclSaturation=Variable(index=[time,region], unit="%/person")
  rcons_per_cap_DiscRemainConsumption=Variable(index=[time, region], unit = "\$/person")    # check units - per person?
  rcons_per_cap_NonMarketRemainConsumption = Parameter(index=[time, region], unit = "\$/person")   # check units - per person?

end

function run_timestep(s::Discontinuity, t::Int64)
  v = s.Variables
  p = s.Parameters
  d = s.Dimensions

  for r in d.region

    v.idis_lossfromdisc[t] = p.rt_g_globaltemperature[t] - p.tdis_tolerabilitydisc

    v.irefeqdis_eqdiscimpact[r] = p.wincf_weightsfactor[r]*p.wdis_gdplostdisc

    v.igdpeqdis_eqdiscimpact[t,r] = v.irefeqdis_eqdiscimpact[r] * (p.rgdp_per_cap_DiscRemainGDP[t,r]/p.GDP_per_cap_focus_0_FocusRegionEU)^p.ipow_incomeexponent

    if t == 1

      v.expfdis_discdecay[t]=exp(-(p.y_year[t] - p.y_year_0)/p.distau_discontinuityexponent) # may have problem with negative exponent

      v.igdp_realizeddiscimpact[t,r]=v.occurdis_occurrencedummy[t]*(1-v.expfdis_discdecay[t])*v.igdpeqdis_eqdiscimpact[t,r]

    else

      srand(1234) # set seed
      if v.idis_lossfromdisc[t]*(p.pdis_probability/100) > rand()
        v.occurdis_occurrencedummy[t] = 1

      elseif v.occurdis_occurrencedummy[t-1] == 1
        v.occurdis_occurrencedummy[t] = 1

      else
        v.occurdis_occurrencedummy[t] = 0

      end

      v.expfdis_discdecay[t]=exp(-(p.y_year[t] - p.y_year[t-1])/p.distau_discontinuityexponent) # may have problem with negative exponent

      v.igdp_realizeddiscimpact[t,r]=v.igdp_realizeddiscimpact[t-1,r]+v.occurdis_occurrencedummy[t]*(1-v.expfdis_discdecay[t])*(v.igdpeqdis_eqdiscimpact[t,r]-v.igdp_realizeddiscimpact[t-1,r])

        if v.igdp_realizeddiscimpact[t,r] < v.isatg_saturationmodification
          v.isat_satdiscimpact[t,r] = v.igdp_realizeddiscimpact[t,r]

        else
          v.isat_satdiscimpact[t,r] = v.isatg_saturationmodification + (100-v.isatg_saturationmodification)*((v.igdp_realizeddiscimpact[t,r]-v.isatg_saturationmodification)/((100-v.isatg_saturationmodification)+(v.igdp_realizeddiscimpact[t,r] - v.isatg_saturationmodification)))

        end

        v.isat_per_cap_DiscImpactperCapinclSaturation[t,r] = v.isat_satdiscimpact[t,r]*p.rgdp_per_cap_DiscRemainGDP[t,r]
        v.rcons_per_cap_DiscRemainConsumption[t,r] = p.rcons_per_cap_NonMarketRemainConsumption - v.isat_per_cap_DiscImpactperCapinclSaturation[t,r]

    end

  end

end


function adddiscontinuity(model::Model)

    discontinuitycomp = addcomponent(model, Discontinuity)

#    discontinuitycomp[:wincf_weightsfactor]=[1, 0.8, 0.8, 0.4, 0.8, 0.8, 0.6, 0.6]
#    discontinuitycomp[:wdis_gdplostdisc]=0.15
    discontinuitycomp[:ipow_incomeexponent]=-0.5

    discontinuitycomp[:distau_discontinuityexponent]=-0.13    # unclear if this is right - PAGE 2009, pg. 24 "discontinuity exponent with income"
    discontinuitycomp[:tdis_tolerabilitydisc]=3
    discontinuitycomp[:pdis_probability]=20

    discontinuitycomp[:GDP_per_cap_focus_0_FocusRegionEU]= (1.39*10^7)/496

    # disccomp[:idis_lossfromdisc] = ?        still don't know what this is

    return discontinuitycomp
end
