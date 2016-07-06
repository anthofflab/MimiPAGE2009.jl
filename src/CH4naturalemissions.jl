using Mimi

@defcomp CH4naturalemissions begin
    nte_natCH4emissions=Variable(index=[time],unit="Mtonne")
    stim_emissionfeedback=Parameter(unit="Mtonne per degree C")
    AREA = Parameter(index = [location], unit ="km^2")
    rt_regionaltemp=Parameter(index=[time][location],unit="degree C")
    rt0_baseregionaltemp=Parameter(index=[location],unit="degree C")
end

function run_timestep(s::CH4naturalemissions,t::Int64,r::Int64)
    v=s.Variables
    p=s.Parameters

    if(t==1)
        v.nte_natCH4emissions=p.stim_emissionfeedback*

end
