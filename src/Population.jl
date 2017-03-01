using Mimi

@defcomp Population begin
    region = Index()

    # Parameters
    y_year_0 = Parameter(unit="year")
    y_year = Parameter(index=[time], unit="year")
    popgrw_populationgrowth = Parameter(index=[time, region], unit="%/year") # From p.32 of Hope 2009
    pop0_initpopulation = Parameter(index=[region], unit="million person") # Population in y_year_0

    # Variables
    pop_population = Variable(index=[time, region], unit="million person")
end

function run_timestep(s::Population, tt::Int64)
    v = s.Variables
    p = s.Parameters
    d = s.Dimensions

    # Check with Chris Hope

    for rr in d.region
        # Eq.28 in Hope 2002 (defined for GDP, but also applies to population)
        if tt == 1
            v.pop_population[tt, rr] = p.pop0_initpopulation[rr] * (1 + p.popgrw_populationgrowth[tt, rr]/100)^(p.y_year[tt] - p.y_year_0)
        else
            v.pop_population[tt, rr] = v.pop_population[tt-1, rr] * (1 + p.popgrw_populationgrowth[tt, rr]/100)^(p.y_year[tt] - p.y_year[tt-1])
        end
        println([p.pop0_initpopulation[rr], p.popgrw_populationgrowth[tt,rr], p.y_year[tt], p.y_year_0])
    end
end

function addpopulation(model::Model)
    populationcomp = addcomponent(model, Population)

    populationcomp[:popgrw_populationgrowth]=readpagedata(model,"../data/popgrw_populationgrowth.csv")
    populationcomp[:pop0_initpopulation]=readpagedata(model,"../data/pop0_initpopulation.csv")

    return populationcomp
end
