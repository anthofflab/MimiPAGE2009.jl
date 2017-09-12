using Mimi
using OptiMimi
include("getpagefunction.jl")

do_stochastic = true

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

initpage(m)
run(m)

bestpolicy(model::Model) = -model[:EquityWeighting, :te_totaleffect]

if do_stochastic
    optprob = uncertainproblem(m, [:AbatementScale, :AbatementScale, :AbatementScale, :AbatementScale], [:emissiongrowthfactor_CO2, :emissiongrowthfactor_CH4, :emissiongrowthfactor_N2O, :emissiongrowthfactor_LG], repmat([0.], 40), repmat([100.0], 40), bestpolicy)
    results = try
        readtable("stochastic-solutions.csv")
    catch
        nothing
    end
    for samplemult in [1, 2]
        for mcperlife in [5, 10]
            if results != nothing && sum((results[:mcperlife] .== mcperlife) & (results[:samplemult] .== samplemult) & (results[:algorithm] .== "social")) == 0
                @time soln = solution(optprob, () -> repmat([100.], 40), :social, mcperlife, samplemult)
                if results == nothing
                    results = DataFrame(algorithm=["social"], mcperlife=[mcperlife], samplemult=[samplemult])
                    for gas in [:CO2,:CH4,:N2O,:LG]
                        for ii in 1:10
                            results[Symbol("$gas$ii")] = [soln.xmean[ii]]
                        end
                    end
                else
                    push!(results, ["social"; mcperlife; samplemult; soln.xmean])
                end

                writetable("stochastic-solutions.csv", results)
            end

            if sum((results[:mcperlife] .== mcperlife) & (results[:samplemult] .== samplemult) & (results[:algorithm] .== "biological")) == 0
                @time soln = solution(optprob, () -> repmat([100.], 40), :biological, mcperlife, 100000*samplemult)
                push!(results, ["biological"; mcperlife; samplemult; soln.xmean])

                writetable("stochastic-solutions.csv", results)
            end

            if sum((results[:mcperlife] .== mcperlife) & (results[:samplemult] .== samplemult) & (results[:algorithm] .== "sampled")) == 0
                @time soln = solution(optprob, () -> repmat([100.], 40), :sampled, mcperlife, 60*samplemult)
                push!(results, ["sampled"; mcperlife; samplemult; soln.xmean])

                writetable("stochastic-solutions.csv", results)
            end
        end
    end
else
    optprob = problem(m, [:AbatementScale, :AbatementScale, :AbatementScale, :AbatementScale], [:emissiongrowthfactor_CO2, :emissiongrowthfactor_CH4, :emissiongrowthfactor_N2O, :emissiongrowthfactor_LG], repmat([0.], 40), repmat([100.0], 40), bestpolicy)
    (maxf, maxx) = solution(optprob, () -> repmat([100.], 40))

    results = DataFrame(time=repeat(copy(getindexvalues(m, :time)),outer=4), control=repeat([:CO2,:CH4,:N2O,:LG],inner=10), level=maxx)

    using Plots
    plotly()

    using StatPlots

    plot(results, :time, :level, group=:control, xlabel="Time", ylabel="Emissions growth allowed")

    #plot emissions instead of emissions growth
    emissions=DataFrame(time=repeat(copy(getindexvalues(m, :time)),outer=4),control=repeat(["CO2 (billion tons per year)","CH4 (million tons per year)","N2O (million tons per year)","LG (million tons per year)"],inner=10),level=[m[:co2emissions,:e_globalCO2emissions]/1000; m[:ch4emissions,:e_globalCH4emissions]; m[:n2oemissions,:e_globalN2Oemissions]; m[:LGemissions,:e_globalLGemissions]])
    plot(emissions, :time, :level, group=:control, xlabel="Time", ylabel="Emissions")

    #plot emissions in terms of CO2 equivalents - note problem with LG emissions - seem like they are a factor of 1000 too big
    emissions=DataFrame(time=repeat(copy(getindexvalues(m, :time)),outer=4),control=repeat(["CO2 (GWP=1)","CH4 (GWP=25)","N2O (GWP=298)","LG (GWP=500)"],inner=10),level=[m[:co2emissions,:e_globalCO2emissions]/1000; m[:ch4emissions,:e_globalCH4emissions]*25/1000; m[:n2oemissions,:e_globalN2Oemissions]*298/1000; m[:LGemissions,:e_globalLGemissions]*500/1000000])
    plot(emissions, :time, :level, group=:control, xlabel="Time", ylabel="Emissions (billion tons CO2 equivalents per year)")
end
