
# using OptiMimi


@defcomp TaxDrivenGrowth begin
    region = Index()

    taxrate = Parameter(index=[time], unit="\$/tonne")

    # From external files
    e0_baselineemissions = Parameter(index=[region], unit= "Mtonne/year")

    # From the AbatementCostParameters
    zc_zerocostemissions = Parameter(index=[time, region], unit= "%")
    q0_absolutecutbacksatnegativecost = Parameter(index=[time, region], unit= "Mtonne")
    blo = Parameter(index=[time, region], unit = "per Mtonne")
    alo = Parameter(index=[time, region], unit = "\$/tonne")
    bhi = Parameter(index=[time, region], unit = "per Mtonne")
    ahi = Parameter(index=[time, region], unit = "\$/tonne")

    # Outputs to AbatementCosts
    er_emissionsgrowth = Variable(index=[time,region],unit="%")

    function run_timestep(p, v, d, t)

        for rr in d.region
            # Invert equation for mc_marginalcost from AbatementCosts
            # Assume zc_zerocostemissions > er_emissionsgrowth (otherwise not reduced)

            # If cbe_absoluteemissionreductions < q0_absolutecutbacksatnegativecost
            if p.alo[t, rr] + 1 > 0
                er_lowside = p.zc_zerocostemissions[t, rr] - (log(p.taxrate[t] / p.alo[t, rr] + 1) / p.blo[t, rr] + p.q0_absolutecutbacksatnegativecost[t, rr]) / (p.e0_baselineemissions[rr]/100)
                cbe_lowside = (p.zc_zerocostemissions[t, rr] - er_lowside) * p.e0_baselineemissions[rr]/100
            else
                cbe_lowside = Inf
            end

            # Else
            if p.ahi[t, rr] + 1 > 0
                er_highside = p.zc_zerocostemissions[t, rr] - (log(p.taxrate[t] / p.ahi[t, rr] + 1) / p.bhi[t, rr] + p.q0_absolutecutbacksatnegativecost[t, rr]) / (p.e0_baselineemissions[rr]/100)
                cbe_highside = (p.zc_zerocostemissions[t, rr] - er_highside) * p.e0_baselineemissions[rr]/100
            else
                cbe_highside = -Inf
            end

            if cbe_lowside < p.q0_absolutecutbacksatnegativecost[t, rr]
                v.er_emissionsgrowth[t, rr] = er_lowside
            elseif cbe_highside >= p.q0_absolutecutbacksatnegativecost[t, rr]
                v.er_emissionsgrowth[t, rr] = er_highside
            else
                v.er_emissionsgrowth[t, rr] = 100.
            end
        end
    end
end

function addtaxdrivengrowth(model::Model, class::Symbol)
    componentname = Symbol("TaxDrivenGrowth$class")
    add_comp!(model, TaxDrivenGrowth, componentname, after=Symbol("AbatementCostParameters$class"))

    if class == :CO2
        update_param!(model, componentname, :e0_baselineemissions, readpagedata(model, "data/e0_baselineCO2emissions.csv"))
    elseif class == :CH4
        update_param!(model, componentname, :e0_baselineemissions, readpagedata(model, "data/e0_baselineCH4emissions.csv"))
    elseif class == :N2O
        update_param!(model, componentname, :e0_baselineemissions, readpagedata(model, "data/e0_baselineN2Oemissions.csv"))
    elseif class == :Lin
        update_param!(model, componentname, :e0_baselineemissions, readpagedata(model,"data/e0_baselineLGemissions.csv"))
    else
        error("Unknown class of abatement costs.")
    end
end

@defcomp UniformTaxDrivenGrowth begin
    region=Index()

    uniformtax = Parameter(index=[time], unit="\$/tonne")

    taxrate_CO2 = Variable(index=[time], unit="\$/tonne")
    taxrate_CH4 = Variable(index=[time], unit="\$/tonne")
    taxrate_N2O = Variable(index=[time], unit="\$/tonne")
    taxrate_Lin = Variable(index=[time], unit="\$/tonne")

    function run_timestep(p, v, d, t)

        v.taxrate_CO2[t] = p.uniformtax[t]
        v.taxrate_CH4[t] = p.uniformtax[t]
        v.taxrate_N2O[t] = p.uniformtax[t]
        v.taxrate_Lin[t] = p.uniformtax[t]
    end
end

"""Construct a model with a uniform (global and all gases, but time-varying) tax."""
function getuniformtaxmodel()
    m = Model()
    set_dimension!(m, :time, [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200])
    set_dimension!(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])

    buildpage(m)

    add_comp!(m, UniformTaxDrivenGrowth, after=:GDP) # before all abatement costs parameters
    update_param!(m, :UniformTaxDrivenGrowth, :uniformtax, zeros(10))

    for class in [:CO2, :CH4, :N2O, :Lin]
        addtaxdrivengrowth(m, class)
        taxgrowth = Symbol("TaxDrivenGrowth$class")
        abateparams = Symbol("AbatementCostParameters$class")
        connect_param!(m, taxgrowth => :zc_zerocostemissions, abateparams => :zc_zerocostemissions)
        connect_param!(m, taxgrowth => :q0_absolutecutbacksatnegativecost, abateparams =>:q0_absolutecutbacksatnegativecost)
        connect_param!(m, taxgrowth => :blo, abateparams => :blo)
        connect_param!(m, taxgrowth => :alo, abateparams => :alo)
        connect_param!(m, taxgrowth => :bhi, abateparams => :bhi)
        connect_param!(m, taxgrowth => :ahi, abateparams => :ahi)
        connect_param!(m, taxgrowth => :taxrate, :UniformTaxDrivenGrowth => Symbol("taxrate_$class"))
        connect_param!(m, Symbol("AbatementCosts$class"), :er_emissionsgrowth, taxgrowth, :er_emissionsgrowth)
    end

    initpage(m)

    return m
end