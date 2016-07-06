using Mimi

@defcomp ClimateTemperature begin
    region = Index(region)

    area = Parameter(index=[region], unit="km2")
    y_year = Parameter(index=[time], unit="year")

    sens_climatesensitivity = Parameter(unit="degreeC")
    ocean_climatehalflife = Parameter(unit="year")
    fslope_forcingslope = Parameter(unit="W/m2")

    ft_totalforcing = Parameter(index=[time], unit="W/m2")
    fs_sulfateforcing = Parameter(index=[time], unit="W/m2")

    et_equilibriumtemperature = Variable(index=[time, region], unit="degreeC")
    rt_0_realizedtemperature = Parameter(index=[region], unit="degreeC")
    rt_realizedtemperature = Variable(index=[time, region], unit="degreeC")
    grt_globaltemperature = Variable(index=[time], unit="degreeC")
end

function run_timestep(s::ClimateTemperature, tt::Int64)
    v = s.Variables
    p = s.Parameters
    d = s.Dimensions

    for rr in d.region
        v.et_equilibriumtemperature[tt, rr] = (p.sens_climatesensitivity / log(2.0)) * (p.ft_totalforcing[tt] + p.fs_sulfateforcing[tt, rr]) / p.fslope_forcingslope
    end

    if tt == 1
        for rr in d.region
            rt_realizedtemperature[tt, rr] = v.rt_0_realizedtemperature[rr] + (1 - exp((p.y_year[tt] - p.y_year[tt-1]) / p.ocean_climatehalflife)) * (v.et_equilibriumtemperature[tt, rr] - v.rt_0_realizedtemperature[rr])
        end
    else
        for rr in d.region
            rt_realizedtemperature[tt, rr] = v.rt_realizedtemperature[tt-1, rr] + (1 - exp((p.y_year[tt] - p.y_year[tt-1]) / p.ocean_climatehalflife)) * (v.et_equilibriumtemperature[tt, rr] - v.rt_realizedtemperature[tt-1, rr])
        end
    end

    grt_globaltemperature = sum(rt_tm1_realizedtemperature[tt, :]' .* area) / sum(area)
end
