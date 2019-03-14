

@defcomp Population begin
    region = Index()

    # Parameters
    y_year_0 = Parameter(unit="year")
    y_year = Parameter(index=[time], unit="year")
    popgrw_populationgrowth = Parameter(index=[time, region], unit="%/year") # From p.32 of Hope 2009
    pop0_initpopulation = Parameter(index=[region], unit="million person") # Population in y_year_0

    # Variables
    pop_population = Variable(index=[time, region], unit="million person")
        
    function run_timestep(p, v, d, tt)

        for rr in d.region
            # Eq.28 in Hope 2002 (defined for GDP, but also applies to population)
            if is_first(tt)
                v.pop_population[tt, rr] = p.pop0_initpopulation[rr] * (1 + p.popgrw_populationgrowth[tt, rr]/100)^(p.y_year[tt] - p.y_year_0)
            else
                v.pop_population[tt, rr] = v.pop_population[tt-1, rr] * (1 + p.popgrw_populationgrowth[tt, rr]/100)^(p.y_year[tt] - p.y_year[tt-1])
            end
        end
    end
end

# Still need this function in order to set the parameters than depend on 
# readpagedata, which takes model as an input. These cannot be set using 
# the default keyword arg for now.
function addpopulation(model::Model)
    populationcomp = add_comp!(model, Population)

    populationcomp[:popgrw_populationgrowth]=readpagedata(model, "data/popgrw_populationgrowth.csv")
    populationcomp[:pop0_initpopulation]=readpagedata(model, "data/pop0_initpopulation.csv")

    return populationcomp
end
