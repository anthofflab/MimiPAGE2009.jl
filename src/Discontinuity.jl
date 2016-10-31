using Mimi

@defcomp Discontinuity begin
  irefeqdis_discimpact=Variable(index=[region], unit="%")
  wincf_weightsfactor=Parameter(index=[region], unit="unitless")
  wdis_gdplostdisc=Variable(index=[region], unit="%")
  igdpeqdis_discimpactactualgdp=Variable(index=[time,region], unit="%")

# end 10/24
  rgdppercap_realgdppercapita=Parameter(index=[time,region], unit="\$") # probably wrong

# old shit
  rt_g_globaltemperature = Variable(index=[time], unit="degreeC") # Global mean realized temperature
  tdis_tolerabledisc=Parameter(unit="degreeC")
  wdis_GDPlostdisc=Variable(index=[region], unit="%")
  wdis_0_GDPlostdisc=Parameter(index=[region], unit="%")
  wf_weightsfactor=Parameter(index=[region], unit="unitless")
  widis_weighteddiscimpact=Variable(index=[time, region], unit="\$M") # Note: discuss with group if we need to specify the price level of dollars
  pdis_discprobability=Parameter(unit="%/degreeC")
  gdp = Parameter(index=[time, region], unit="\$M")

end

run_timestep(s::Discontinuity, tt::Int64)
  v = s.Variables
  p = s.Parameters
  d = s.Dimensions

  v.idis_discimpact[t] = max([0, (v.rt_g_globaltemperature[t] - p.tdis_tolerabledisc)])
  v.wdis_GDPlostdisc[r] = min([1, ((p.wdis_0_GDPlostdisc[r]*p.wf_weightsfactor[r])/100)])
  v.widis_weighteddiscimpact[t,r] = v.idis_discimpact[t] * (p.pdis_discprobability/100) * v.wdis_GDPlostdisc[r] * p.gdp[t,r]


  # for weights data:
  # using Distributions
  # x = TriangularDist(min, max, mode)    put in actual data
  # mean(x)
  # construct a vector of triangular distributions
  # data = [TriangularDist(46, 74, 60), Normal(4.,3.)]
  # mean.(data)
