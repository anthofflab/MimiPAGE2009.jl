
using Mimi

@defcomp Discontinuity begin
  irefeqdis_eqdiscimpact=Variable(index=[region], unit="%")
  wincf_weightsfactor=Parameter(index=[region], unit="unitless")
  wdis_gdplostdisc=Parameter(unit="%")

  igdpeqdis_eqdiscimpact=Variable(index=[time,region], unit="%")
  rgdp_per_cap_NonMarketRemainGDP=Parameter(index=[time,region], unit="unitless")
  ipow_incomeexponent=Parameter(unit="unitless")

  igdp_realizeddiscimpact=Variable(index=[time,region], unit="%")
  occurdis_occurrencedummy=Variable(index=[time], unit="unitless")
  expfdis_discdecay=Variable(index=[time], unit="unitless")

  y_year=Parameter(index=[time], unit="year")
  distau_discontinuityexponent=Parameter(unit="unitless")

  idis_lossfromdisc=Parameter(index=[time], unit="%") # could be wrong
  pdis_probability=Parameter(unit="%/degreeC")

  isat_satdiscimpact=Variable(index=[time,region], unit="%")
  isatg_saturationmodification=Variable(unit="unitless")

  # documentation includes per capita saturation impacts, but we did not include it here

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

  v.igdpeqdis_eqdiscimpact[t,r] = v.irefeqdis_discimpact[r] * (p.rgdp_per_cap_NonMarketRemainGDP[t,r]/p.rgdp_per_cap_NonMarketRemainGDP[t,1])^p.ipow_incomeexponent

## ending here 11/14 - figure out if else thingy

  if   p.idis_lossfromdisc[i]*(p.pdis_probability/100) > rand(0:1)

  elseif

  else

  end




end


  # for weights data, if using the provided distributions:
  # using Distributions
  # x = TriangularDist(min, max, mode)    put in actual data
  # mean(x)
  # construct a vector of triangular distributions
  # data = [TriangularDist(46, 74, 60), Normal(4.,3.)]
  # mean.(data)

function addDiscontinuity(model::Model)

    disccomp = addcomponent(model, Discontinuity)

    disccomp[:wincf_weightsfactor]=[0.8, 0.8, 0.4, 0.8, 0.8, 0.6, 0.6]
    disccomp[:wdis_gdplostdisc]=0.15
    disccomp[:ipow_incomeexponent]=-0.5

    # data for distau???
