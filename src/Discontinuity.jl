
using Mimi

@defcomp Discontinuity begin
  irefeqdis_eqdiscimpact=Variable(index=[region], unit="%")
  wincf_weightsfactor=Parameter(index=[region], unit="unitless")
  wdis_gdplostdisc=Parameter(unit="%")

  igdpeqdis_eqdiscimpact=Variable(index=[time,region], unit="%")
  rgdp_per_cap_DiscRemainGDP=Parameter(index=[time,region], unit="unitless")
  ipow_incomeexponent=Parameter(unit="unitless")

  igdp_realizeddiscimpact=Variable(index=[time,region], unit="%")
  occurdis_occurrencedummy=Variable(index=[time], unit="unitless")
  expfdis_discdecay=Variable(index=[time], unit="unitless")

  y_year=Parameter(index=[time], unit="year")
  distau_discontinuityexponent=Parameter(unit="unitless")

  idis_lossfromdisc=Parameter(index=[time], unit="degreeC") # could just be temperature rise - asking Chris Hope
  pdis_probability=Parameter(unit="%/degreeC")

  isat_satdiscimpact=Variable(index=[time,region], unit="%")
  isatg_saturationmodification=Variable(unit="unitless")

  isat_per_cap_DiscImpactperCapinclSaturation=Variable(index=[time,region], unit="%/person")
  rcons_per_cap_DiscRemainConsumption=Variable(index=[time, region], unit = "\$/person")    # check units - per person?
  rcons_per_cap_NonMarketRemainConsumption = Parameter(index=[time, region], unit = "\$/person")   # check units - per person?

end

run_timestep(s::Discontinuity, tt::Int64)
  v = s.Variables
  p = s.Parameters
  d = s.Dimensions

  for rr in d.region

  v.expfdis_discdecay[t]=exp(‐(p.y_year[t] – p.y_year[t-1])/p.distau_discontinuityexponent) # may have problem with negative exponent

  if t == 1

  v.igdp_realizeddiscimpact[t,r]=v.occurdis_occurrencedummy[t]*(1-v.expfdis_discdecay[t])*v.igdpeqdis_eqdiscimpact[t,r]

  else

  v.igdp_realizeddiscimpact[t,r]=v.igdp_realizeddiscimpact[t-1,r]+v.occurdis_occurrencedummy[t]*(1-v.expfdis_discdecay[t])*(v.igdpeqdis_eqdiscimpact[t,r]-v.igdp_realizeddiscimpact[t-1,r])

  v.irefeqdis_discimpact[r] = p.wincf_weightsfactor[r]*p.wdis_gdplostdisc

  v.igdpeqdis_eqdiscimpact[t,r] = v.irefeqdis_discimpact[r] * (p.rgdp_per_cap_DiscRemainGDP[t,r]/p.rgdp_per_cap_DiscMarketRemainGDP[t,1])^p.ipow_incomeexponent

  v.isat_per_cap_DiscImpactperCapinclSaturation[t,r] = v.isat_satdiscimpact[t,r]*p.rgdp_per_cap_DiscRemainGDP[t,r]
  v.rcons_per_cap_DiscRemainConsumption[t,r] = p.rcons_per_cap_NonMarketRemainConsumption - v.isat_per_cap_DiscImpactperCapinclSaturation[t,r]

    if v.igdp_realizeddiscimpact[t,r] < v.isatg_saturationmodification
      v.isat_satdiscimpact[t,r] = v.igdp_realizeddiscimpact[t,r]

    else v.isat_satdiscimpact[t,r] = v.isatg_saturationmodification + (100-v.isatg_saturationmodification)*((v.igdp_realizeddiscimpact[t,r]-v.isatg_saturationmodification)/((100-v.isatg_saturationmodification)+(v.igdp_realizeddiscimpact[t,r] - v.isatg_saturationmodification))

    end

    if   p.idis_lossfromdisc[t]*(p.pdis_probability/100) > rand(0:1)
      v.occurdis_occurrencedummy[t] = 1

    elseif v.occurdis_occurrencedummy[t-1] = 1
      v.occurdis_occurrencedummy[t] = 1

    else  v.occurdis_occurrencedummy[t] = 0

    end

  end

end

# next: add parameter data, debug

  # for weights data, if using the provided distributions:
  # using Distributions
  # x = TriangularDist(min, max, mode)    put in actual data
  # mean(x)
  # construct a vector of triangular distributions
  # data = [TriangularDist(46, 74, 60), Normal(4.,3.)]
  # mean.(data)

function addDiscontinuity(model::Model)

    discontinuitycomp = addcomponent(model, Discontinuity)

    discontinuitycomp[:wincf_weightsfactor]=[0.8, 0.8, 0.4, 0.8, 0.8, 0.6, 0.6]
    discontinuitycomp[:wdis_gdplostdisc]=0.15
    discontinuitycomp[:ipow_incomeexponent]=-0.5

    discontinuitycomp[:distau_discontinuityexponent]=-0.13    # unclear if this is right - PAGE 2009, pg. 24 "discontinuity exponent with income"

    discontinuitycomp[:pdis_probability]=20
  # disccomp[:idis_lossfromdisc] = ?        still don't know what this is
