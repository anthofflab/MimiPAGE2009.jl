using Mimi

@defcomp Population begin
    region = Index()

    # Parameters
    y_year_0 = Parameter(unit="year")
    y_year = Parameter(index=[time], unit="year")
    popgrw_populationgrowth = Parameter(index=[time, region], unit="%/year", default=readpagedata(model, "data/popgrw_populationgrowth.csv")) # From p.32 of Hope 2009
    pop0_initpopulation = Parameter(index=[region], unit="million person", default=readpagedata(model, "data/pop0_initpopulation.csv")) # Population in y_year_0

    # Variables
    pop_population = Variable(index=[time, region], unit="million person")
        
    function run_timestep(p, v, d, tt)

        for rr in d.region
            # Eq.28 in Hope 2002 (defined for GDP, but also applies to population)
            if tt == 1
                v.pop_population[tt, rr] = p.pop0_initpopulation[rr] * (1 + p.popgrw_populationgrowth[tt, rr]/100)^(p.y_year[tt] - p.y_year_0)
            else
                v.pop_population[tt, rr] = v.pop_population[tt-1, rr] * (1 + p.popgrw_populationgrowth[tt, rr]/100)^(p.y_year[tt] - p.y_year[tt-1])
            end
        end
    end
end
