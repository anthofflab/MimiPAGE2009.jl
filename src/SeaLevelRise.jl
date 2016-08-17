using Mimi

@defcomp SeaLevelRise begin

# Parameters

  rt_g_globaltemperature = Parameter(index=[time], unit="degreeC")
  sltemp_SLtemprise=Parameter(unit = "m-degreeC")
  sla_SLbaselinerise=Parameter(unit = "m")
  sltau_SLresponsetime=Parameter(unit = "years")
  s0_initialSL=Parameter(unit = "m")
  y_year=Parameter(index=[time], unit="year")
  y_year_0=Parameter(unit="year")

# Variables

  es_equilibriumSL=Variable(index=[time], unit = "m")
  s_sealevel=Variable(index=[time], unit = "m")
  expfs_exponential=Variable(index=[time], unit = "unitless")

end

function run_timestep(s::SeaLevelRise,t::Int64)
  v=s.Variables
  p=s.Parameters

  if t == 1
    yp=p.y_year[1] - p.y_year_0
    v.es_equilibriumSL[t]=p.sltemp_SLtemprise*p.rt_g_globaltemperature[t] + p.sla_SLbaselinerise
    v.expfs_exponential[t]=exp(-yp/p.sltau_SLresponsetime)
    v.s_sealevel[t]=p.s0_initialSL + (v.es_equilibriumSL[t] - p.s0_initialSL)*(1-v.expfs_exponential[t])

  else
    yp=p.y_year[t] - p.y_year[t-1]
    v.es_equilibriumSL[t]=p.sltemp_SLtemprise*p.rt_g_globaltemperature[t] + p.sla_SLbaselinerise
    v.expfs_exponential[t]=exp(-yp/p.sltau_SLresponsetime)
    v.s_sealevel[t]=v.s_sealevel[t-1] + (v.es_equilibriumSL[t] - v.s_sealevel[t-1])*(1-v.expfs_exponential[t])

  end

end

function addSLR(model::Model)
    slrcomp = addcomponent(model, SeaLevelRise)

    slrcomp[:sltemp_SLtemprise] = 1.73
    slrcomp[:sla_SLbaselinerise] = 0.15
    slrcomp[:sltau_SLresponsetime] = 1000.
    slrcomp[:s0_initialSL] = 3000.

    slrcomp
end
