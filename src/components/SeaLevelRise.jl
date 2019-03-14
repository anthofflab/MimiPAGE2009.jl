

@defcomp SeaLevelRise begin

  # Parameters

  rt_g_globaltemperature = Parameter(index=[time], unit="degreeC")
  sltemp_SLtemprise=Parameter(unit = "m-degreeC", default=1.7333333333333334)
  sla_SLbaselinerise=Parameter(unit = "m", default=1.00)
  sltau_SLresponsetime=Parameter(unit = "years", default=1000.)
  s0_initialSL=Parameter(unit = "m", default=0.15)
  y_year=Parameter(index=[time], unit="year")
  y_year_0=Parameter(unit="year")

  # Variables

  es_equilibriumSL=Variable(index=[time], unit = "m")
  s_sealevel=Variable(index=[time], unit = "m")
  expfs_exponential=Variable(index=[time], unit = "unitless")
  yp_timestep=Variable(index=[time], unit = "years")


  function run_timestep(p, v, d, t)
    if is_first(t)
      v.yp_timestep[t]=p.y_year[1] - p.y_year_0
      v.es_equilibriumSL[t]=p.sltemp_SLtemprise*p.rt_g_globaltemperature[t] + p.sla_SLbaselinerise
      v.expfs_exponential[t]=exp(-v.yp_timestep[t]/p.sltau_SLresponsetime)
      v.s_sealevel[t]=p.s0_initialSL + (v.es_equilibriumSL[t] - p.s0_initialSL)*(1-v.expfs_exponential[t])

    else
      v.yp_timestep[t]=p.y_year[t] - p.y_year[t-1]
      v.es_equilibriumSL[t]=p.sltemp_SLtemprise*p.rt_g_globaltemperature[t] + p.sla_SLbaselinerise
      v.expfs_exponential[t]=exp(-v.yp_timestep[t]/p.sltau_SLresponsetime)
      v.s_sealevel[t]=v.s_sealevel[t-1] + (v.es_equilibriumSL[t] - v.s_sealevel[t-1])*(1-v.expfs_exponential[t])

    end
  end
end

