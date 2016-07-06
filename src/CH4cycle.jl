using Mimi

@defcomp ch4cycle begin
    region=Index()

    e_globalch4emissions=Parameter(index=[time],unit="Mtonne/year")
    c_ch4concentration=Variable(index=[time],unit="ppbv")
    pic_preindustconcCH4=Parameter(unit="ppbv")
    exc_excessconcCH4=Variable(unit="ppbv")
    c0_ch4concbaseyr=Parameter(unit="ppbv")
    re_remainCH4=Variable(index=[time],unit="ppbv")
    nte_natCH4emissions=Variable(index=[time],unit="Mtonne/year")
    air_ch4fractioninatm=Parameter(unit="%")
    tea_ch4emissionstoatm=Variable(index=[time],unit="Mtonne/year")
    teay_ch4emissionstoatm=Variable(index=[time],unit="Mtonne/year")
    y_year=Parameter(index=[time],unit="year")
    y0_startyear=Parameter(unit="year")
    res_ch4atmlifetime=Parameter(unit="year")
    den_CH4density=Parameter(unit="Mtonne/ppbv")
    stim_emissionfeedback=Parameter(unit="Mtonne/degree C")
    area_area= Parameter(index = [region], unit ="km2")
    rt_regionaltemp=Parameter(index=[time,region],unit="degreeC")
    rt0_baseregionaltemp=Parameter(index=[region],unit="degreeC")
end

function run_timestep(s::ch4cycle,t::Int64)
    v=s.Variables
    p=s.Parameters
    d=s.Dimensions

    #eq.3 from Hope (2006) - natural emissions (carbon cycle) feedback
    if t>1
        v.nte_natCH4emissions[t]=p.stim_emissionfeedback*sum(vec(p.rt_regionaltemp[t-1,:]).*p.area_area)/sum(p.area_area)
    else
        v.nte_natCH4emissions[t]=p.stim_emissionfeedback*sum(p.rt0_baseregionaltemp.*p.area_area)/sum(p.area_area)
    end

    #eq.6 from Hope (2006) - emissions to atmosphere depend on the sum of natural and anthropogenic emissions
    v.tea_ch4emissionstoatm[t]=(p.e_globalch4emissions[t]+v.nte_natCH4emissions[t])*p.air_ch4fractioninatm/100

    #eq.7 from Hope (2006) - average emissions to atm over time period
    if t>1
        v.teay_ch4emissionstoatm[t]=(v.tea_ch4emissionstoatm[t]+v.tea_ch4emissionstoatm[t-1])*(p.y_year[t]-p.y_year[t-1])/2
    else
        #unclear how calculated in first time period - assume emissions from period 1 are used
        v.teay_ch4emissionstoatm[t]=v.tea_ch4emissionstoatm[t]
    end

    if t==1
        #adapted from eq.1 in Hope(2006) - calculate excess concentration in base year
        v.exc_excessconcCH4=p.c0_ch4concbaseyr-p.pic_preindustconcCH4
    end

    #eq.10 from Hope (2006) - remaining emissions in atmosphere
    if t>1
        v.re_remainCH4[t]=v.re_remainCH4[t-1]*exp(-(p.y_year[t]-p.y_year[t-1])/p.res_ch4atmlifetime)+
            v.teay_ch4emissionstoatm[t]*p.res_ch4atmlifetime*(1-exp(-(p.y_year[t]-p.y_year[t-1])/p.res_ch4atmlifetime))/(p.y_year[t]-p.y_year[t-1])
    else
        #Eq. 2 from Hope (2006) - base-year remaining emissions
        re_remainCH4base=v.exc_excessconcCH4*p.den_CH4density
        v.re_remainCH4[t]=re_remainCH4base*exp(-(p.y_year[t]-p.y0_startyear)/p.res_ch4atmlifetime)+
            v.teay_ch4emissionstoatm[t]*p.res_ch4atmlifetime*(1-exp(-(p.y_year[t]-p.y0_startyear)/p.res_ch4atmlifetime))/(p.y_year[t]-p.y0_startyear)
    end

    #eq.11 from Hope(2006) - CH4 concentration
    v.c_ch4concentration[t]=p.pic_preindustconcCH4+v.exc_excessconcCH4*v.re_remainCH4[t]/v.re_remainCH4[1]

end
