using Mimi

@defcomp GDP begin
# GDP: Gross domestic product $M
# GRW: GDP growth rate %/year
    region=Index()

    # Variables
    gdp = Variable(index=[time, region], unit="\$M")

    # Parameters
    y0_baselineyear = Parameter(unit="year")
    y_year = Parameter(index=[time], unit="year")

end

function run_timestep(s::GDP, t::Int64)
  v = s.Variables
  p = s.Parameters
  d = s.Dimensions

  #Hope 2002:Growth rate is assumed to apply from the previous analysis year
  if t==1
      v.grw[tt,rr] = 0.0
    else
      v.grw[tt,rr] = (v.gdp[tt, rr] - v.gdp[tt-1, rr])/v.gdp[tt-1, rr]
  end

  #eq.28 in Hope 2002
  v.gdp[tt, rr] = v.gdp[tt-1, rr] * (1 + (p.grw[tt,rr]/100))^(p.y_year[tt] - p.y0_baselineyear)

end
