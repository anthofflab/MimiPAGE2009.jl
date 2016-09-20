using Mimi

@defcomp Discontinuity begin
  idis_discontimpact=Variable(index=[time], unit ="%/degreeC")
  rt_realizedtemperature = Variable(index=[time, region], unit="degreeC") # unadjusted temperature
  tdis_tolerablediscont=Variable(index=[time], unit="%/degreeC")
  wdis_GDPlostdiscont=Variable(index=[region], unit="%")

  # ended with WF - parameter? 

end
