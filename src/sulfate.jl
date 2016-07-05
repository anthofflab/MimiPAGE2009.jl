using Mimi

##sulfate concentration
@defcomp SulfateEmission begin
    SE_SulfateEmissions = Parameter(index = [time, location], unit = "Mtonne") #how do we handle i,j type index?
    PSE_ChangeSE_Annual = Parameter(index = [time, location], unit = "Mtonne")
    AREA = Parameter(index = [location], unit ="km^2") #do we define area here, or elsewhere?
    IND_slopeSEforcing_indirect = Parameter(unit = "W/m^2")
    #uncertain parameters?/ are the values/ distributions given somewhere?
    D_slopeSEforcing_direct = Parameter(unit = "MWyr/kg")
    SFX_SulfateFlux = Variable(index = [time, location], unit = "Tg/km^2/yr")
    NF_NaturalSFX = Parameter(index = [location], unit = "Tg/km^2/yr")
    FS_SulfateForcing = Variable(index = [time, location], unit = "W/^2")
  end

## pseudo code so far, need to index by location and time
function run_timesteps(s::SFX, t::Int64)
    v = s.Variables
    p = p.Parameters

    #eq. 17 from Hope (2006) - sulfate flux
    SFX_SulfateFlux = p.SE_SulfateEmissions * (p.PSE_ChangeSE_Annual/100) / p.AREA

    ##create loop for each region?

    #eq. 18 from Hope (2006) - sulfate radiative forcing effect
    FS_SulfateForcing = v.D_slopeSEforcing_direct * 10**6 +
        p.IND_slopeSEforcing_indirect/ln(2) *
        ln((p.NF_NaturalSFX + v.SFX_SulfateFlux) / p.NF_NaturalSFX)
end
