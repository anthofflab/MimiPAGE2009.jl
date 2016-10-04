using Mimi

@defcomp Discontinuity begin
  idis_discimpact=Variable(index=[time], unit ="%/degreeC")
  rt_g_globaltemperature = Variable(index=[time], unit="degreeC") # Global mean realized temperature
  tdis_tolerabledisc=Parameter(unit="degreeC")
  wdis_GDPlostdisc=Variable(index=[region], unit="%")
  wdis_0_GDPlostdisc=Parameter(index=[region], unit="%")
  wf_weightsfactor=Parameter(index=[region], unit="unitless")
  widis_weighteddiscimpact=Variable(index=[time, region], unit="\$M") # Note: discuss with group if we need to specify the price level of dollars
  pdis_discprobability=Parameter(unit="%/degreeC")
  gdp = Parameter(index=[time, region], unit="\$M")

end

  # for weights data:
  # using Distributions
  # x = TriangularDist(min, max, mode)    put in actual data
  # mean(x)
  # construct a vector of triangular distributions
  # data = [TriangularDist(46, 74, 60), Normal(4.,3.)]
  # mean.(data)

end
