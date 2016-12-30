using Mimi

@defcomp TotalAbatementCosts begin
    region = Index(region)

    tc_totalcosts_co2 = Parameter(index=[time, region], unit="\$million")
    tc_totalcosts_ch4 = Parameter(index=[time, region], unit="\$million")
    tc_totalcosts_n2o = Parameter(index=[time, region], unit="\$million")
    tc_totalcosts_linear = Parameter(index=[time, region], unit="\$million")
    pop_population = Parameter(index=[time, region], unit= "million person")

    tct_totalcosts = Variable(index=[time,region], unit= "\$million")
    tct_per_cap_totalcostspercap = Variable(index=[time,region], unit= "\$")

end

function run_timestep(s::TotalAbatementCosts, t::Int64)
    v = s.Variables
    p = s.Parameters
    d = s.Dimensions

    for r in d.region
        v.tct_totalcosts[t,r] = p.tc_totalcosts_co2[t,r] + p.tc_totalcosts_n2o[t,r] + p.tc_totalcosts_ch4[t,r] + p.tc_totalcosts_linear[t,r]
        v.tct_per_cap_totalcostspercap[t,r] = v.tct_totalcosts[t,r]/p.pop_population[t,r]
    end
end

function addtotalabatementcosts(model::Model)
    totalabatementcostscomp = addcomponent(model, TotalAbatementCosts)

    return totalabatementcostscomp
end
