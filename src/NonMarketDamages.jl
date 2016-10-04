include("load_parameters.jl")

@defcomp NonMarketDamages begin
    region = Index(region)

    y_year = Parameter(index=[time], unit="year")

    #incoming parameters from Climate
    rt_realizedtemperature = Parameter(index=[time, region], unit="degreeC")

    #tolerability parameters
    plateau_increaseintolerableplateaufromadaptation = Parameter(index=[region], unit="degreeC")
    pstart_startdateofadaptpolicy = Parameter(index=[region], unit="year")
    pyears_yearstilfulleffect = Parameter(index=[region], unit="year")
    impred_eventualpercentreduction = Parameter(index=[region], unit= "%")
    impmax_maxtempriseforadaptpolicy = Parameter(index=[region], unit= "degreeC")
    istart_startdate = Parameter(index=[region], unit = "year")
    iyears_yearstilfulleffect = Parameter(index=[region], unit= "year")

    #tolerability variables
    atl_adjustedtolerableleveloftemprise = Variable(index=[time,region], unit="degreeC")
    imp_actualreduction = Variable(index=[time, region], unit= "%")
    i_regionalimpact = Variable(index=[time, region], unit="degreeC")

    #impact Parameters
    rcons_per_cap_MarketRemainConsumption = Parameter(index=[time, region], unit = "")
    rgdp_per_cap_MarketRemainGDP = Parameter(index=[time, region], unit = "")
    SAVE_savingsrate = Parameter(unit= "%")
    WINCF_ =Parameter()
    W2_ =Parameter()
    pow2_ =Parameter()
    scal_ = Parameter()
    GDP_per_cap_focus_0_ = Parameter()

    #impact variables
    rcons_per_capNonMarketRemainConsumption = Parameter(index=[time, region], unit = "")
    rgdp_per_cap_NonMarketRemainGDP = Parameter(index=[time, region], unit = "")
    iref_=Variable(index=[time, region])
    igdp_=Variable(index=[time, region])
    isat_= Variable(index=[time,region])
    isat_per_cap_ = Variable(index=[time,region])
end

function run_timestep(s::NonMarketDamages, t::Int64)
    v = s.Variables
    p = s.Parameters
    d = s.Dimensions

    for r in d.region
        #calculate tolerability
        if (p.y_year[t] - p.pstart_startdateofadaptpolicy[r]) < 0
            v.atl_adjustedtolerableleveloftemprise[t,r]= 0
        elseif ((p.y_year[t]-p.pstart_startdateofadaptpolicy[r])/p.pyears_yearstilfulleffect[r])<1.
            v.atl_adjustedtolerableleveloftemprise[t,r]=
                ((p.y_year[t]-p.pstart_startdateofadaptpolicy[r])/p.pyears_yearstilfulleffect[r]) *
                p.plateau_increaseintolerableplateaufromadaptation[r]
        else
            p.plateau_increaseintolerableplateaufromadaptation[r]
        end

        if (p.y_year[t]- p.istart_startdate[r]) < 0
            v.imp_actualreduction[t,r] = 0
        elseif ((p.y_year[t]-istart_a[r])/iyears_a[r]) < 1
            v.imp_actualreduction[t,r] =
                (p.y_year[t]-p.istart_startdate[r])/p.iyears_yearstilfulleffect[r]*
                p.impred_eventualpercentreduction[r]
        else
            v.imp_actualreduction[t,r] = p.impred_eventualpercentreduction[r]
        end

        if (p.rt_realizedtemperature[t,r]-v.atl_adjustedtolerableleveloftemprise[t,r]) < 0
            v.i_regionalimpact[t,r] = 0
        else
            v.i_regionalimpact[t,r] = p.rt_realizedtemperature[t,r]-v.atl_adjustedtolerableleveloftemprise[t,r]
        end

        v.iref_[t,r]= p.WINCF_[r]*((p.W2_ + p.iben2_ * p.scal_)*(v.i_regionalimpact[t,r]/p.scal_)^p.pow2_ - v.i_regionalimpact[t,r] * p.iben2_)

        v.igdp_[t,r]= v.iref_[t,r]*(p.rgdp_per_cap_MarketRemainGDP[t,r]/p.GDP_per_cap_focus_0_)^p.pow2_


        ISATG=ISAT*(1‐p.SAVE_savingsrate/100)

        if v.igdp_[t,r]<ISATG
            v.isat_[t,r] = v._igdp[t,r]
        elseif v.i_regionalimpact[t,r]<v.impmax_maxtempriseforadaptpolicy[r]
            v.isat_[t,r] = ISATG+((100-p.SAVE_savingsrate)-ISATG)*((v.igdp_[t,r]-ISATG)/
                (((100-p.SAVE_savingsrate)-ISATG)+ (v.igdp_[t,r]*ISATG)))*(1-v.imp_actualreduction/100)
        else
            v.isat_[t,r] = ISATG+((100-p.SAVE_savingsrate)-ISATG) * ((v.igdp_[t,r]-ISATG)/
                (((100-p.SAVE_savingsrate)-ISATG)+ (v.igdp_[t,r] * ISATG))) * (1-(v.imp_actualreduction/100)*
                v.impmax_maxtempriseforadaptpolicy[r] / v.i_regionalimpact[t,r])
        end

        v.isat_per_cap_[t,r] = (v.isat[t,r]/100)*p.rgdp_per_cap_MarketRemainGDP[t,r]
        v.rcons_per_cap_NonMarketRemainConsumption[t,r] = p.rcons_per_cap_MarketRemainConsumption[t,r] - v.isat_per_cap_[t,r]
        v.rgdp_per_cap_NonMarketRemainGDP[t,r] = v.rcons_per_cap_NonMarketRemainConsumption[t,r]/(1-p.SAVE_savingsrate/100)

    end
end

function addnonmarketdamages(model::Model)
    nonmarketdamagescomp = addcomponent(model, NonMarketDamages, :NonMarketTolerability)

    nonmarketdamagescomp[:plateau_increaseintolerableplateaufromadaptation] = readpagedata(model, "../data/nonmarket_plateau.csv")
    nonmarketdamagescomp[:pstart_startdateofadaptpolicy] = readpagedata(model, "../data/nonmarketadaptstart.csv")
    nonmarketdamagescomp[:pyears_yearstilfulleffect] = readpagedata(model, "../data/nonmarkettimetoadapt.csv")
    nonmarketdamagescomp[:impred_eventualpercentreduction] = readpagedata(model, "../data/nonmarketimpactreduction.csv")
    nonmarketdamagescomp[:impmax_maxtempriseforadaptpolicy] = readpagedata(model, "../data/nonmarketmaxtemprise.csv")
    nonmarketdamagescomp[:istart_startdate] = readpagedata(model, "../data/nonmarketadaptstart.csv")
    nonmarketdamagescomp[:iyears_yearstilfulleffect] = readpagedata(model, "../data/nonmarketimpactyearstoeffect.csv")

    nonmarketdamagescomp[:_scal]
    nonmarketdamagescomp[:_WINCF]
    nonmarketdamagescomp[:_W2]
    nonmarketdamagescomp[:_iben2]
    nonmarketdamagescomp[:_pow2]
    nonmarketdamagescomp[:SAVE_savingsrate]= 15.



    return nonmarketdamagescomp
end
