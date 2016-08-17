using Base.Test
using Mimi

include("../src/SulphateForcing.jl")

m = Model()
setindex(m, :time, 10)
setindex(m, :region, ["Region 1", "Region 2", "Region 3"])

sulphateforcing = addcomponent(m, SulphateForcing)

sulphateforcing[:se_sulphateemissions] = ones(10, 3)
sulphateforcing[:se0_sulphateemissionsbase] = ones(10)
sulphateforcing[:pse_sulphatevsbase] = ones(10, 3)
sulphateforcing[:area] = ones(10)

sulphateforcing[:d_sulphateforcingbase] = 1.
sulphateforcing[:ind_slopeSEforcing_indirect] = 1.
sulphateforcing[:nf_naturalsfx] = ones(10)

run(m)
