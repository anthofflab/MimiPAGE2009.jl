using Mimi
using OptiMimi
include("getpagefunction.jl")

# Create the model
m = Model()
setindex(m, :time, [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200])
setindex(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])

@defcomp AbatementScale begin
    region=Index()

    emissiongrowthfactor = Parameter(index=[time], unit="% of normal growth")

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
        v.er_CO2emissionsgrowth_new[tt, rr] = p.er_CO2emissionsgrowth[tt, rr] * p.emissiongrowthfactor[tt] / 100
        #v.er_CH4emissionsgrowth_new[tt, rr] = p.er_CH4emissionsgrowth[tt, rr] * p.emissiongrowthfactor / 100
        #v.er_N2Oemissionsgrowth_new[tt, rr] = p.er_N2Oemissionsgrowth[tt, rr] * p.emissiongrowthfactor / 100
        #v.er_LGemissionsgrowth_new[tt, rr] = p.er_LGemissionsgrowth[tt, rr] * p.emissiongrowthfactor / 100
        v.er_CH4emissionsgrowth_new[tt, rr] = p.er_CH4emissionsgrowth[tt, rr]
        v.er_N2Oemissionsgrowth_new[tt, rr] = p.er_N2Oemissionsgrowth[tt, rr]
        v.er_LGemissionsgrowth_new[tt, rr] = p.er_LGemissionsgrowth[tt, rr]
    end
end

addcomponent(m, AbatementScale)

buildpage(m)

connectparameter(m, :co2emissions, :er_CO2emissionsgrowth, :AbatementScale, :er_CO2emissionsgrowth_new)
connectparameter(m, :ch4emissions, :er_CH4emissionsgrowth, :AbatementScale, :er_CH4emissionsgrowth_new)
connectparameter(m, :n2oemissions, :er_N2Oemissionsgrowth, :AbatementScale, :er_N2Oemissionsgrowth_new)
connectparameter(m, :LGemissions, :er_LGemissionsgrowth, :AbatementScale, :er_LGemissionsgrowth_new)

# Initial value of q0propinit
setparameter(m, :AbatementScale, :emissiongrowthfactor, repmat([100.], 10))

initpage(m)
run(m)

bestpolicy(model::Model) = -model[:EquityWeighting, :te_totaleffect]

optprob = problem(m, [:AbatementScale], [:emissiongrowthfactor], repmat([0.], 10), repmat([100.0], 10), bestpolicy);
(maxf, maxx) = solution(optprob, () -> repmat([90.], 10))

# Uniform across all gases
# (-3.006562326528711e7,[0.0])
# For just CO2
# (-4.168037582735732e7,[0.0])
# Across all periods
# (-4.168037582735732e7,[1.06581e-14,8.20415e-29,1.14448e-15,1.17483e-18,4.45176e-17,1.00085e-16,1.76688e-16,1.2548e-16,6.31089e-30,1.06581e-14])

worstpolicy(model::Model) = model[:EquityWeighting, :te_totaleffect]

optprob = problem(m, [:AbatementScale], [:emissiongrowthfactor], [0.], [100.0], worstpolicy);
(maxf, maxx) = solution(optprob, () -> [90.])

# Uniform across all gases
# (2.1320245992205706e8,[100.0])
# For just CO2
# (2.1320245992205706e8,[100.0])

erfactors = convert(Vector{Float64}, linspace(0, 100, 100))
results = sensitivity(m, :AbatementScale, :emissiongrowthfactor, model -> model[:EquityWeighting, :te_totaleffect], erfactors)

using Plots
plotly()
plot(erfactors, results, xlab="Emissions Growth Factor (%)", ylab="Total Effect")
