using Distributions

include("getpagefunction.jl")
getpage()
run(m)
temp=m[:ClimateTemperature,:rt_g_globaltemperature][10]

#Define uncertin parameters based on PAGE 2009 documentation
uncertain_params=Dict()
uncertain_params[:res_CO2atmlifetime]=TriangularDist(50., 100., 70.)

nit=2
for i in 1:nit
    for (p_name, p_dist) in uncertain_params
        v = rand(p_dist)
        setparameter(m, p_name, v)
    end
    run(m)
    push!(temp, m[:ClimateTemperature,:rt_g_globaltemperature][10])
end
