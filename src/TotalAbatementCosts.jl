
@defcomp TotalAbatementCosts begin
    region = Index(region)

    tc_totalcosts_co2 = Parameter(index=[time, region], unit="\$million")
    tc_totalcosts_ch4 = Parameter(index=[time, region], unit="\$million")
    tc_totalcosts_n2o = Parameter(index=[time, region], unit="\$million")
    tc_totalcosts_linear = Parameter(index=[time, region], unit="\$million")
    population = Parameter(index=[region], unit= "million person")
    pop_grw_populationgrowth = Parameter(index=[time, region], unit="%/year")

    pop_ulation = Variable(index=[time, region], unit="million person")
    tct_totalcosts = Variable(index=[time,region])
    tct_per_cap_totalcostspercap = Variable(index=[time,region])

end

function run_timestep(s::AbatementCosts, t::Int64)
    v = s.Variables
    p = s.Parameters
    d = s.Dimensions

    for r in d.region
        if t==1
            v.pop_ulation[t,r] = p.population[r]
        else
            v.pop_ulation[t,r] = v.pop_ulation[t-1]*p.pop_grw_populationgrowth[t,r]
        end
        v.tct_totalcosts[t,r] = p.tc_totalcosts_co2[t,r] + p.tc_totalcosts_n2o[t,r] + p.tc_totalcosts_ch4[t,r] + p.tc_totalcosts_linear[t,r]
        v.tct_per_cap_totalcostspercap[t,r] = v.tct_totalcosts[t,r]/v.pop_ulation[t,r]
    end
end

function addtotalabatementcosts(model::Model)
    totalabatementcostscomp = addcomponent(model, TotalAbatementCosts)

    return totalabatementcostscomp
end
