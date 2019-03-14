@defcomp AbatementCosts begin
    region = Index()

   # From the AbatementCostParameters
    zc_zerocostemissions = Parameter(index=[time, region], unit= "%")
    q0_absolutecutbacksatnegativecost = Parameter(index=[time, region], unit= "Mtonne")
    blo = Parameter(index=[time, region], unit = "per Mtonne")
    alo = Parameter(index=[time, region], unit = "\$/tonne")
    bhi = Parameter(index=[time, region], unit = "per Mtonne")
    ahi = Parameter(index=[time, region], unit = "\$/tonne")

    # Driver of abatement costs
    e0_baselineemissions = Parameter(index=[region], unit= "Mtonne/year")
    er_emissionsgrowth = Parameter(index=[time, region], unit= "%")

    # Intermediate outputs
    cb_reductionsfromzerocostemissions = Variable(index=[time, region], unit= "%")
    cbe_absoluteemissionreductions = Variable(index=[time, region], unit="Mtonne") # Goes to AbatementCostParameters

    # Main costs results
    mc_marginalcost = Variable(index=[time, region], unit = "\$/tonne")
    tcq0 = Variable(index=[time, region], unit = "\$million")
    tc_totalcost = Variable(index=[time, region], unit= "\$million")

    function run_timestep(p, v, d, t)

        for r in d.region
            v.cb_reductionsfromzerocostemissions[t,r] = max(p.zc_zerocostemissions[t,r] - p.er_emissionsgrowth[t,r], 0)
            v.cbe_absoluteemissionreductions[t,r] = v.cb_reductionsfromzerocostemissions[t,r]* p.e0_baselineemissions[r]/100

            if v.cbe_absoluteemissionreductions[t,r]< p.q0_absolutecutbacksatnegativecost[t,r]
                v.mc_marginalcost[t,r] = p.alo[t,r]* (exp(p.blo[t,r]*(v.cbe_absoluteemissionreductions[t,r]- p.q0_absolutecutbacksatnegativecost[t,r]))-1)
            else
                v.mc_marginalcost[t,r] = p.ahi[t,r]*(exp(p.bhi[t,r]*(v.cbe_absoluteemissionreductions[t,r]- p.q0_absolutecutbacksatnegativecost[t,r]))-1)
            end

            if p.q0_absolutecutbacksatnegativecost[t,r] == 0.
                v.tcq0[t,r] = 0.
            else
                v.tcq0[t,r] = (p.alo[t,r]/p.blo[t,r])*(1-exp(-p.blo[t,r]* p.q0_absolutecutbacksatnegativecost[t,r]))- p.alo[t,r]*p.q0_absolutecutbacksatnegativecost[t,r]
            end

            if v.cbe_absoluteemissionreductions[t,r]<p.q0_absolutecutbacksatnegativecost[t,r]
                v.tc_totalcost[t,r] = (p.alo[t,r]/p.blo[t,r])*(exp(p.blo[t,r]*(v.cbe_absoluteemissionreductions[t,r]- p.q0_absolutecutbacksatnegativecost[t,r]))- exp(-p.blo[t,r]*p.q0_absolutecutbacksatnegativecost[t,r])) - p.alo[t,r]*v.cbe_absoluteemissionreductions[t,r]
            else
                v.tc_totalcost[t,r] = (p.ahi[t,r]/p.bhi[t,r])* (exp(p.bhi[t,r]*(v.cbe_absoluteemissionreductions[t,r]-p.q0_absolutecutbacksatnegativecost[t,r]))-1) - p.ahi[t,r]*(v.cbe_absoluteemissionreductions[t,r] - p.q0_absolutecutbacksatnegativecost[t,r]) + v.tcq0[t,r]
            end
        end 
    end       
end

function addabatementcosts(model::Model, class::Symbol, policy::String="policy-a")
    componentname = Symbol("AbatementCosts$class")
    abatementcostscomp = add_comp!(model, AbatementCosts, componentname)

    if class == :CO2
        setdistinctparameter(model, componentname, :e0_baselineemissions, readpagedata(model, "data/e0_baselineCO2emissions.csv"))
        if policy == "policy-a"
            setdistinctparameter(model, componentname, :er_emissionsgrowth, readpagedata(model, "data/er_CO2emissionsgrowth.csv"))
        else
            setdistinctparameter(model, componentname, :er_emissionsgrowth, readpagedata(model, "data/$policy/er_CO2emissionsgrowth.csv"))
        end
    elseif class == :CH4
        setdistinctparameter(model, componentname, :e0_baselineemissions, readpagedata(model, "data/e0_baselineCH4emissions.csv"))
        if policy == "policy-a"
            setdistinctparameter(model, componentname, :er_emissionsgrowth, readpagedata(model, "data/er_CH4emissionsgrowth.csv"))
        else
            setdistinctparameter(model, componentname, :er_emissionsgrowth, readpagedata(model, "data/$policy/er_CH4emissionsgrowth.csv"))
        end
    elseif class == :N2O
        setdistinctparameter(model, componentname, :e0_baselineemissions, readpagedata(model, "data/e0_baselineN2Oemissions.csv"))
        if policy == "policy-a"
            setdistinctparameter(model, componentname, :er_emissionsgrowth, readpagedata(model, "data/er_N2Oemissionsgrowth.csv"))
        else
            setdistinctparameter(model, componentname, :er_emissionsgrowth, readpagedata(model, "data/$policy/er_N2Oemissionsgrowth.csv"))
        end
    elseif class == :Lin
        setdistinctparameter(model, componentname, :e0_baselineemissions, readpagedata(model,"data/e0_baselineLGemissions.csv"))
        if policy == "policy-a"
            setdistinctparameter(model, componentname, :er_emissionsgrowth, readpagedata(model,"data/er_LGemissionsgrowth.csv"))
        else
            setdistinctparameter(model, componentname, :er_emissionsgrowth, readpagedata(model,"data/$policy/er_LGemissionsgrowth.csv"))
        end
    else
        error("Unknown class of abatement costs.")
    end
    
    return abatementcostscomp
end
