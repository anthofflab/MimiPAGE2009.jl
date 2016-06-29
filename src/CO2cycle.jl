using Mimi

@defcomp co2cycle begin
    e_globalco2emissions=Parameter(index=[time],unit="Mtonne")
    c_co2concentration=Variable(index=[time],unit="ppbv")
    pic_preindustconcCO2=Parameter(unit="ppbv")
    exc_excessconcCO2=Variable(unit="ppbv")
    c0_co2concbaseyr=Parameter(unit="ppbv")
    re_remainCO2=Variable(index=[time],unit="ppbv")
end

function run_timestep(s::co2cycle,t::Int64)
    v=s.Variables
    p=s.Parameters
    if t==1
      # adapted from eq.1 of Hope (2006)
      v.exc_excessconcCO2 = p.c0_co2concbaseyr - p.pic_preindustconcCO2
    end

    # eq.12 from Hope (2006)
    v.c_co2concentration[t]= p.pic_preindustconcCO2 +
      v.exc_excessconcCO2 * v.re_remainCO2[t]/v.re_remainCO2[1]


end
