using Mimi

@defcomp ClimateTemperature begin
    region = Index(region)

    area = Parameter(index=[region], unit="km2")
    y_year_0 = Parameter(unit="year")
    y_year = Parameter(index=[time], unit="year")

    sens_climatesensitivity = Parameter(unit="degreeC")
    ocean_climatehalflife = Parameter(unit="year")
    fslope_forcingslope = Parameter(unit="W/m2")

    ft_totalforcing = Parameter(index=[time], unit="W/m2")
    fs_sulfateforcing = Parameter(index=[time, region], unit="W/m2")

    et_equilibriumtemperature = Variable(index=[time, region], unit="degreeC")
    rt_0_realizedtemperature = Parameter(index=[region], unit="degreeC")
    rt_realizedtemperature = Variable(index=[time, region], unit="degreeC")
    grt_globaltemperature = Variable(index=[time], unit="degreeC")
end

function run_timestep(s::ClimateTemperature, tt::Int64)
    v = s.Variables
    p = s.Parameters
    d = s.Dimensions

    # Equation 19 from Hope (2006): equilibrium temperature estimate
    for rr in d.region
        v.et_equilibriumtemperature[tt, rr] = (p.sens_climatesensitivity / log(2.0)) * (p.ft_totalforcing[tt] + p.fs_sulfateforcing[tt, rr]) / p.fslope_forcingslope
    end

    # Equation 20 from Hope (2006): realized temperature estimate
    if tt == 1
        for rr in d.region
            v.rt_realizedtemperature[tt, rr] = p.rt_0_realizedtemperature[rr] + (1 - exp((p.y_year[tt] - p.y_year_0) / p.ocean_climatehalflife)) * (v.et_equilibriumtemperature[tt, rr] - p.rt_0_realizedtemperature[rr])
        end
    else
        for rr in d.region
            v.rt_realizedtemperature[tt, rr] = v.rt_realizedtemperature[tt-1, rr] + (1 - exp((p.y_year[tt] - p.y_year[tt-1]) / p.ocean_climatehalflife)) * (v.et_equilibriumtemperature[tt, rr] - v.rt_realizedtemperature[tt-1, rr])
        end
    end

    # Equation 21 from Hope (2006): global realized temperature estimate
    v.grt_globaltemperature[tt] = sum(v.rt_realizedtemperature[tt, :]' .* p.area) / sum(p.area)
end
