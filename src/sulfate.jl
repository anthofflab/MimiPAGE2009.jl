using Mimi

##sulfate concentration
@defcomp SulfateForcing begin
    region = Index()
    SE_SulfateEmissions = Parameter(index = [time, region], unit = "Mtonne/t") #how do we handle i,j type index?
    PSE_ChangeSE_Annual = Parameter(index = [time, region], unit = "Mtonne/t")
    AREA = Parameter(index = [region], unit ="km^2")
    IND_slopeSEforcing_indirect = Parameter(unit = "W/m^2")
    #uncertain parameters?/ are the values/ distributions given somewhere?
    D_slopeSEforcing_direct = Parameter(unit = "MWyr/kg")
    SFX_SulfateFlux = Variable(index = [time, region], unit = "Tg/km^2/yr")
    NF_NaturalSFX = Parameter(index = [region], unit = "Tg/km^2/yr")
    FS_SulfateForcing = Variable(index = [time, region], unit = "W/^2")
  end

## pseudo code so far, need to index by region and time
function run_timesteps(s::SulfateForcing, t::Int64)
    v = s.Variables
    p = p.Parameters
    d = d.Dimensions

    ##add base sulfate?
    if t == 1
      for r in d.region
          v.SFX_SulfateFlux[t,r] = p.SE_SulfateEmissions[t,r]
      end

    else
      #eq.17 from Hope (2006) - sulfate flux
      for r in d.region
      v.SFX_SulfateFlux[t,r] = p.SE_SulfateEmissions[t,r] *
      (p.PSE_ChangeSE_Annual[t,r]/100) / p.AREA
    end
    ##create loop for each region?

    #eq. 18 from Hope (2006) - sulfate radiative forcing effect
    FS_SulfateForcing = v.D_slopeSEforcing_direct * 10**6 +
        p.IND_slopeSEforcing_indirect/ln(2) *
        ln((p.NF_NaturalSFX + v.SFX_SulfateFlux[t]) / p.NF_NaturalSFX)
end
