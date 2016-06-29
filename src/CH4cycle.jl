using Mimi

@defcomp ch4cycle begin
    e_globalch4emissions=Parameter(index=[time],unit="Mtonne")
    c_ch4concentration=Variable(index=[time],unit="ppbv")
    pic_preindustconcCH4=Parameter(unit="ppbv")
    exc_excessconcCH4=Variable(unit="ppbv")
    c0_ch4concbaseyr=Parameter(unit="ppbv")
    re_remainCH4=Variable(index=[time],unit="ppbv")
    nte_natCH4emissions=Parameter(index=[time],unit="Mtonne")
    air_ch4fractioninatm=Parameter(unit="%")
    tea_ch4emissionstoatm=Variable(index=[time],unit="Mtonne")
    teay_ch4emissionstoatm=Variable(index=[time],unit="Mtonne")
    y_year=Parameter(index=[time],unit="year")
    res_ch4atmlifetime=Parameter(unit="year")
end

function run_timestep(s::ch4cycle,t::Int64)
    v=s.Variables
    p=s.Parameters

    #eq.6 from Hope (2006) - emissions to atmosphere
    v.tea_ch4emissionstoatm[t]=(p.e_globalch4emissions[t]+p.nte_natCH4emissions[t])*p.air_ch4fractioninatm/100

    #eq.7 from Hope (2006) - average emissions to atm over time period
    if t==1
        #unclear how calculated in first time period - assume emissions from period 1 are used
        v.teay_ch4emissionstoatm[t]=v.tea_ch4emissionstoatm[t]
    end
    if t>1
        v.teay_ch4emissionstoatm[t]=(v.tea_ch4emissionstoatm[t]+v.tea_ch4emissionstoatm[t-1])*(p.y_year[t]-p.y_year[t-1])/2
    end

    #eq.10 from Hope (2006) - remaining emissions in atmosphere
    if t==1
        #unclear how remaining emissions in first time period are calculated
        v.re_remainCH4[t]=???
    end
    if t>1
        v.re_remainCH4[t]=v.re_remainCH4[t-1]*exp(-(p.y_year[t]-p.y_year[t-1])/p.res_ch4atmlifetime)+
            v.teay_ch4emissionstoatm[t]*p.res_ch4atmlifetime*(1-exp(-(p.y_year[t]-p.y_year[t-1])/p.res_ch4atmlifetime))/(p.y_year[t]-p.y_year[t-1])
    end

    if t==1
        #adapted from eq.1 in Hope(2006)
        v.exc_excessconcCH4=p.c0_ch4concbaseyr-p.pic_preindustconcCH4
    end

    #eq.11 from Hope(2006) - CH4 concentration
    v.c_ch4concentration[t]=p.pic_preindustconcCH4+v.exc_excessconcCH4*v.re_remainCH4[t]/v.re_remainCH4[1]

end
