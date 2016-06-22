using Mimi

@defcomp co2cycle begin
    globalco2emissions=Parameter(index=[time],unit="Mtonne")
    co2concentration=Variable(index=[time],unit="ppbv")
end

function run_timestep(s::co2cycle,t::Int64)
    v=s.Variables
    p=s.Parameters
    v.co2concentration[t]=380
end
