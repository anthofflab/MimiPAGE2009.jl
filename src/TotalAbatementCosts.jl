
@defcomp TotalAbatementCosts begin
    region = Index(region)
    tct_ = Variable(index=[time,region])
    tct_per_cap_ = Variable(index=[time,region])

end
function run_timestep(s::AbatementCosts, t::Int64)
    v = s.Variables
    p = s.Parameters
    d = s.Dimensions

    for r in d.region
        v.tct_[t,r] =
        v.tct_per_cap[t,r] = v.tct_[t,r]/
    end
end

function addtotalabatementcosts(model::Model)
    totalabatementcostscomp = addcomponent(model, TotalAbatementCosts)

    totalabatementcostscomp[]

    return totalabatementcostscomp

end
