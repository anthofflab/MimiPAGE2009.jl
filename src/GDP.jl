using Mimi

@defcomp GDP begin
# GDP: Gross domestic product $M
# GRW: GDP growth rate %/year
    region            = Index()

    # Variables
    gdp               = Variable(index=[time, region], unit="\$M")
    cons_consumption  = Variable(index=[time, region], unit="\$million")
    cons_percap_consumption = Variable(index=[time, region], unit="\$")
    yagg_periodspan = Variable(index=[time], unit="year")

    # Parameters
    y_year_0          = Parameter(unit="year")
    y_year            = Parameter(index=[time], unit="year")
    grw_gdpgrowthrate = Parameter(index=[time, region], unit="%/year") #From p.32 of Hope 2009
    gdp_0             = Parameter(index=[region], unit="\$M") #GDP in y_year_0
    save_savingsrate  = Parameter(unit="%")
    pop_population    = Parameter(index=[time,region],unit="million person")

end

function run_timestep(s::GDP, t::Int64)
  v = s.Variables
  p = s.Parameters
  d = s.Dimensions

  # Analysis period ranges - required for abatemnt costs and equity weighting, from Hope (2006)
  if t == 1
      ylo_periodstart = p.y_year_0
  else
      ylo_periodstart = (p.y_year[t] + p.y_year[t-1]) / 2
  end

  if t == length(p.y_year)
      yhi_periodend = p.y_year[t]
  else
      yhi_periodend = (p.y_year[t] + p.y_year[t+1]) / 2
  end

  v.yagg_periodspan[t] = yhi_periodend- ylo_periodstart


  for r in d.region
    #eq.28 in Hope 2002
    if t == 1
      v.gdp[t, r] = p.gdp_0[r] * (1 + (p.grw_gdpgrowthrate[t,r]/100))^(p.y_year[t] - p.y_year_0)
      else
        v.gdp[t, r] = v.gdp[t-1, r] * (1 + (p.grw_gdpgrowthrate[t,r]/100))^(p.y_year[t] - p.y_year[t-1])
    end
    v.cons_consumption[t, r] = v.gdp[t, r] * (1 - p.save_savingsrate / 100)
    v.cons_percap_consumption[t, r] = v.cons_consumption[t, r] / p.pop_population[t, r]
  end
end

function addgdp(model::Model)
    gdpcomp = addcomponent(model, GDP)

    gdpcomp[:save_savingsrate] = 15.00

    return gdpcomp
end
