using Mimi
using OptiMimi
include("getpagefunction.jl")

# Create the model
m = Model()
setindex(m, :time, [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200])
setindex(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])

@defcomp AbatementScale begin
    region=Index()

    emissiongrowthfactor_CO2 = Parameter(index=[time], unit="% of normal growth")
    emissiongrowthfactor_CH4 = Parameter(index=[time], unit="% of normal growth")
    emissiongrowthfactor_N2O = Parameter(index=[time], unit="% of normal growth")
    emissiongrowthfactor_LG = Parameter(index=[time], unit="% of normal growth")

    er_CO2emissionsgrowth = Parameter(index=[time,region],unit="%")
    er_CH4emissionsgrowth = Parameter(index=[time,region],unit="%")
    er_N2Oemissionsgrowth = Parameter(index=[time,region],unit="%")
    er_LGemissionsgrowth = Parameter(index=[time,region],unit="%")

    er_CO2emissionsgrowth_new = Variable(index=[time,region],unit="%")
    er_CH4emissionsgrowth_new = Variable(index=[time,region],unit="%")
    er_N2Oemissionsgrowth_new = Variable(index=[time,region],unit="%")
    er_LGemissionsgrowth_new = Variable(index=[time,region],unit="%")
end

function run_timestep(s::AbatementScale, tt::Int64)
    v = s.Variables
    p = s.Parameters
    d = s.Dimensions

    for rr in d.region
        v.er_CO2emissionsgrowth_new[tt, rr] = p.er_CO2emissionsgrowth[tt, rr] * p.emissiongrowthfactor_CO2[tt] / 100
        v.er_CH4emissionsgrowth_new[tt, rr] = p.er_CH4emissionsgrowth[tt, rr] * p.emissiongrowthfactor_CH4[tt] / 100
        v.er_N2Oemissionsgrowth_new[tt, rr] = p.er_N2Oemissionsgrowth[tt, rr] * p.emissiongrowthfactor_N2O[tt] / 100
        v.er_LGemissionsgrowth_new[tt, rr] = p.er_LGemissionsgrowth[tt, rr] * p.emissiongrowthfactor_LG[tt] / 100
    end
end

addcomponent(m, AbatementScale)

buildpage(m)

connectparameter(m, :co2emissions, :er_CO2emissionsgrowth, :AbatementScale, :er_CO2emissionsgrowth_new)
connectparameter(m, :ch4emissions, :er_CH4emissionsgrowth, :AbatementScale, :er_CH4emissionsgrowth_new)
connectparameter(m, :n2oemissions, :er_N2Oemissionsgrowth, :AbatementScale, :er_N2Oemissionsgrowth_new)
connectparameter(m, :LGemissions, :er_LGemissionsgrowth, :AbatementScale, :er_LGemissionsgrowth_new)

connectparameter(m, :AbatementCostsCO2, :er_emissionsgrowth, :AbatementScale, :er_CO2emissionsgrowth_new)
connectparameter(m, :AbatementCostsCH4, :er_emissionsgrowth, :AbatementScale, :er_CH4emissionsgrowth_new)
connectparameter(m, :AbatementCostsN2O, :er_emissionsgrowth, :AbatementScale, :er_N2Oemissionsgrowth_new)
connectparameter(m, :AbatementCostsLin, :er_emissionsgrowth, :AbatementScale, :er_LGemissionsgrowth_new)

setparameter(m, :AbatementScale, :emissiongrowthfactor_CO2, repmat([100.], 10))
setparameter(m, :AbatementScale, :emissiongrowthfactor_CH4, repmat([100.], 10))
setparameter(m, :AbatementScale, :emissiongrowthfactor_N2O, repmat([100.], 10))
setparameter(m, :AbatementScale, :emissiongrowthfactor_LG, repmat([100.], 10))
