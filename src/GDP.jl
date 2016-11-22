using Mimi

@defcomp GDP begin
# GDP: Gross domestic product $M
# GRW: GDP growth rate %/year
    region            = Index()

    # Variables
    gdp               = Variable(index=[time, region], unit="\$M")

    # Parameters
    y_year_0          = Parameter(unit="year")
    y_year            = Parameter(index=[time], unit="year")
    grw_gdpgrowthrate = Parameter(index=[time, region], unit="%") #From p.32 of Hope 2009
    gdp_0             = Parameter(index=[region], unit="\$M") #GDP in y_year_0

end

function run_timestep(s::GDP, t::Int64)
  v = s.Variables
  p = s.Parameters
  d = s.Dimensions

  for r in d.region
    #eq.28 in Hope 2002
    if t == 1
      v.gdp[t, r] = p.gdp_0[r]
      else
        v.gdp[t, r] = v.gdp[t-1, r] * (1 + (p.grw_gdpgrowthrate[t,r]/100))^(p.y_year[t] - p.y_year_0)
    end
  end
end
