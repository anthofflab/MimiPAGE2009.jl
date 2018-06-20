using Mimi
using Distributions
include("../utils/mctools.jl")

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
  yp_timestep=Variable(index=[time], unit = "years")

end

function run_timestep(s::SeaLevelRise,t::Int64)
  v=s.Variables
  p=s.Parameters

  if t == 1
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

function addSLR(model::Model)
    slrcomp = addcomponent(model, SeaLevelRise)

    slrcomp[:sltemp_SLtemprise] = 1.7333333333333334
    slrcomp[:sla_SLbaselinerise] = 1.00
    slrcomp[:sltau_SLresponsetime] = 1000.
    slrcomp[:s0_initialSL] = 0.15

    return slrcomp
end

function randomizeSLR(model::Model)
    update_external_param(model, :s0_initialSL, rand(TriangularDist(0.1, 0.2, 0.15)))
    update_external_param(model, :sltemp_SLtemprise, rand(TriangularDist(0.7, 3., 1.5)))
    update_external_param(model, :sla_SLbaselinerise, rand(TriangularDist(0.5, 1.5, 1.)))
    update_external_param(model, :sltau_SLresponsetime, rand(TriangularDist(500, 1500, 1000)))
end
