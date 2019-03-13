

@defcomp TotalAdaptationCosts begin
    region = Index()
    #Total Adaptation Costs
    pop_population = Parameter(index=[time, region], unit= "million person")
    ac_adaptationcosts_economic = Parameter(index=[time, region], unit="\$million")
    ac_adaptationcosts_noneconomic = Parameter(index=[time, region], unit="\$million")
    ac_adaptationcosts_sealevelrise = Parameter(index=[time, region], unit="\$million")

    act_adaptationcosts_total = Variable(index=[time, region], unit="\$million")
    act_percap_adaptationcosts = Variable(index=[time, region], unit="\$/person")

    function run_timestep(p, v, d, t)

        for r in d.region
            v.act_adaptationcosts_total[t,r] = p.ac_adaptationcosts_economic[t,r] + p.ac_adaptationcosts_sealevelrise[t,r] + p.ac_adaptationcosts_noneconomic[t,r]
            v.act_percap_adaptationcosts[t,r] = v.act_adaptationcosts_total[t,r]/p.pop_population[t,r]
        end
    end
end
