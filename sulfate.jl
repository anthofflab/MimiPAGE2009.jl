Pkg.add("Mimi")
using Mimi

##sulfate concentration
@defcomp SulfateEmission begin
    SE_SulfateEmissions = Parameter(index = [time][location], unit = "Mtonne") #how do we handle i,j type index?
    PSE_ChangeSE_Annual = Parameter(index = [time][location], unit = "Mtonne")
    AREA = Parameter(index = [location], unit ="km^2") #do we define area here, or elsewhere?
    D_slopeSEforcing_direct = Variable(unit = "MWyear/kg")
    IND_slopeSEforcing_indirect = Variable(unit = "W/m^2")
    NF_NaturalSFX = Parameter(index = [location], unit = "Tg/km^2/year")
  end

## pseudo code so far, need to index by location and time
function run_timesteps(s::SFX, t::Int64)
    v = s.Variables
    p = p.Parameters

    #eq. 17 from Hope (2006) - sulfate flux
    SFX_SulfateFlux = p.SE_SulfateEmissions * p.(PSE_ChangeSE_Annual/100) / p.AREA

    ##create loop for each region?

    #eq. 18 from Hope (2006) - sulfate radiative forcing effect
    FS_SulfateForcing = v.D_slopeSEforcing_direct * 10**6 +
        IND_slopeSEforcing_indirect/ln(2) *
        ln((NF + SFX) / NF)

Pkg.update()
