using Mimi
using OptiMimi
include("../getpagefunction.jl")

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
end

function run_timestep(s::TaxDrivenGrowth, tt::Int64)
    v = s.Variables
    p = s.Parameters
    d = s.Dimensions

    for rr in d.region
        # Invert equation for mc_marginalcost from AbatementCosts
        # Assume zc_zerocostemissions > er_emissionsgrowth (otherwise not reduced)

        # If cbe_absoluteemissionreductions < q0_absolutecutbacksatnegativecost
        if p.alo[tt, rr] + 1 > 0
            er_lowside = p.zc_zerocostemissions[tt, rr] - (log(p.taxrate[tt] / p.alo[tt, rr] + 1) / p.blo[tt, rr] + p.q0_absolutecutbacksatnegativecost[tt, rr]) / (p.e0_baselineemissions[rr]/100)
            cbe_lowside = (p.zc_zerocostemissions[tt, rr] - er_lowside) * p.e0_baselineemissions[rr]/100
        else
            cbe_lowside = Inf
        end
        
        # Else
        if p.ahi[tt, rr] + 1 > 0
            er_highside = p.zc_zerocostemissions[tt, rr] - (log(p.taxrate[tt] / p.ahi[tt, rr] + 1) / p.bhi[tt, rr] + p.q0_absolutecutbacksatnegativecost[tt, rr]) / (p.e0_baselineemissions[rr]/100)
            cbe_highside = (p.zc_zerocostemissions[tt, rr] - er_highside) * p.e0_baselineemissions[rr]/100
        else
            cbe_highside = -Inf
        end

        if cbe_lowside < p.q0_absolutecutbacksatnegativecost[tt, rr]
            v.er_emissionsgrowth[tt, rr] = er_lowside
        elseif cbe_highside >= p.q0_absolutecutbacksatnegativecost[tt, rr]
            v.er_emissionsgrowth[tt, rr] = er_highside
        else
            v.er_emissionsgrowth[tt, rr] = 100.
        end
    end
end

function addtaxdrivengrowth(model::Model, class::Symbol)
    componentname = Symbol("TaxDrivenGrowth$class")
    addcomponent(model, TaxDrivenGrowth, componentname, after=Symbol("AbatementCostParameters$class"))

    if class == :CO2
        setdistinctparameter(model, componentname, :e0_baselineemissions, readpagedata(model, "data/e0_baselineCO2emissions.csv"))
    elseif class == :CH4
        setdistinctparameter(model, componentname, :e0_baselineemissions, readpagedata(model, "data/e0_baselineCH4emissions.csv"))
    elseif class == :N2O
        setdistinctparameter(model, componentname, :e0_baselineemissions, readpagedata(model, "data/e0_baselineN2Oemissions.csv"))
    elseif class == :Lin
        setdistinctparameter(model, componentname, :e0_baselineemissions, readpagedata(model,"data/e0_baselineLGemissions.csv"))
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
end

function run_timestep(s::UniformTaxDrivenGrowth, tt::Int64)
    v = s.Variables
    p = s.Parameters
    d = s.Dimensions

    v.taxrate_CO2[tt] = p.uniformtax[tt]
    v.taxrate_CH4[tt] = p.uniformtax[tt]
    v.taxrate_N2O[tt] = p.uniformtax[tt]
    v.taxrate_Lin[tt] = p.uniformtax[tt]
end

"""Construct a model with a uniform (global and all gases, but time-varying) tax."""
function getuniformtaxmodel()
    m = Model()
    setindex(m, :time, [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200])
    setindex(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])

    buildpage(m)

    addcomponent(m, UniformTaxDrivenGrowth, after=:GDP) # before all abatement costs parameters
    setparameter(m, :UniformTaxDrivenGrowth, :uniformtax, zeros(10))
    
    for class in [:CO2, :CH4, :N2O, :Lin]
        addtaxdrivengrowth(m, class)
        taxgrowth = Symbol("TaxDrivenGrowth$class")
        abateparams = Symbol("AbatementCostParameters$class")
        connectparameter(m, taxgrowth, :zc_zerocostemissions, abateparams, :zc_zerocostemissions)
        connectparameter(m, taxgrowth, :q0_absolutecutbacksatnegativecost, abateparams, :q0_absolutecutbacksatnegativecost)
        connectparameter(m, taxgrowth, :blo, abateparams, :blo)
        connectparameter(m, taxgrowth, :alo, abateparams, :alo)
        connectparameter(m, taxgrowth, :bhi, abateparams, :bhi)
        connectparameter(m, taxgrowth, :ahi, abateparams, :ahi)
        connectparameter(m, taxgrowth, :taxrate, :UniformTaxDrivenGrowth, Symbol("taxrate_$class"))
        connectparameter(m, Symbol("AbatementCosts$class"), :er_emissionsgrowth, taxgrowth, :er_emissionsgrowth)
    end

    initpage(m)

    return m
end
