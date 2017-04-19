using Distributions

include("getpagefunction.jl")
getpage()
run(m)
temp=[m[:ClimateTemperature,:rt_g_globaltemperature][10]]

#Define uncertin parameters based on PAGE 2009 documentation
uncertain_params=Dict()
uncertain_params[:co2cycle,:res_CO2atmlifetime]=TriangularDist(50., 100., 70.)

nit=50
@time for i in 1:nit
    for ((p_comp, p_name), p_dist) in uncertain_params
        v = rand(p_dist)
        setparameter(m, p_comp,p_name, v)
    end
    run(m)
    push!(temp, m[:ClimateTemperature,:rt_g_globaltemperature][10])
end
