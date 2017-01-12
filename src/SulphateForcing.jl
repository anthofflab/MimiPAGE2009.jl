using Mimi

@defcomp SulphateForcing begin
    region = Index()

    se0_sulphateemissionsbase = Parameter(index=[region], unit="TgS/year")
    pse_sulphatevsbase = Parameter(index=[time, region], unit="%")
    se_sulphateemissions = Variable(index=[time, region], unit="TgS/year")
    area = Parameter(index=[region], unit ="km^2")

    sfx_sulphateflux = Variable(index=[time, region], unit="TgS/km^2/yr")

    d_sulphateforcingbase = Parameter(unit="W/m2")
    ind_slopeSEforcing_indirect = Parameter(unit="W/m2")
    nf_naturalsfx = Parameter(index=[region], unit="TgS/km^2/yr")

    fs_sulphateforcing = Variable(index=[time, region], unit="W/m2")
end

function run_timestep(s::SulphateForcing, tt::Int64)
    v = s.Variables
    p = s.Parameters
    d = s.Dimensions

    bigSFX0 = p.se0_sulphateemissionsbase ./ p.area

    for rr in d.region
        v.se_sulphateemissions[tt, rr] = p.se0_sulphateemissionsbase[rr] * p.pse_sulphatevsbase[tt, rr] / 100

        # Eq.17 from Hope (2006) - sulfate flux
        v.sfx_sulphateflux[tt,rr] = v.se_sulphateemissions[tt,rr] / p.area[rr]
        # Update for Eq. 18 from Hope (2009) - sulfate radiative forcing effect
        bigSFD0 = p.d_sulphateforcingbase * bigSFX0[rr] / sum(bigSFX0) #check with Chris Hope - this contradicts documentation for PAGE2009
        fsd_term = bigSFD0 * v.sfx_sulphateflux[tt,rr] / bigSFX0[rr]
        fsi_term = p.ind_slopeSEforcing_indirect/log(2) * log((p.nf_naturalsfx[rr] + v.sfx_sulphateflux[tt, rr]) / p.nf_naturalsfx[rr])

        # NOTE: These numbers seem 2-3 x higher than reality
        v.fs_sulphateforcing[tt, rr] = fsd_term + fsi_term
    end
end

function addsulphatecomp(model::Model)
    sulphatecomp = addcomponent(model, SulphateForcing)

    sulphatecomp[:d_sulphateforcingbase] = -0.47
    sulphatecomp[:ind_slopeSEforcing_indirect] = -0.40

    return sulphatecomp
end
