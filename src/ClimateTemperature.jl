using Mimi
using Distributions
include("mctools.jl")

@defcomp ClimateTemperature begin
    region = Index(region)

    # Basic parameters
    area = Parameter(index=[region], unit="km2")
    y_year_0 = Parameter(unit="year")
    y_year = Parameter(index=[time], unit="year")

    # Climate sensitivity calculations
    tcr_transientresponse = Parameter(unit="degreeC")
    frt_warminghalflife = Parameter(unit="year")

    sens_climatesensitivity = Variable(unit="degreeC")

    # Unadjusted temperature calculations
    fslope_CO2forcingslope = Parameter(unit="W/m2")

    ft_totalforcing = Parameter(index=[time], unit="W/m2")
    fs_sulfateforcing = Parameter(index=[time, region], unit="W/m2")

    et_equilibriumtemperature = Variable(index=[time, region], unit="degreeC")
    rt_realizedtemperature = Variable(index=[time, region], unit="degreeC") # unadjusted temperature

    # Adjusted temperature calculations
    pole_polardifference = Parameter(unit="degreeC") # near 1 degC, the temperature increase difference between equator and pole
    lat_latitude = Parameter(index=[region], unit="degreeLatitude")
    lat_g_meanlatitude = Parameter(unit="degreeLatitude") # Area-weighted average latitude
    rlo_ratiolandocean = Parameter(unit="unitless") # near 1.4, the ratio between mean land and ocean temperature increases

    rtl_0_realizedtemperature = Parameter(index=[region], unit="degreeC")
    rtl_realizedtemperature = Variable(index=[time, region], unit="degreeC")

    # Global outputs
    rtl_g_landtemperature = Variable(index=[time], unit="degreeC")
    rto_g_oceantemperature = Variable(index=[time], unit="degreeC")
    rt_g_globaltemperature = Variable(index=[time], unit="degreeC")
    rt_g0_baseglobaltemp=Variable(unit="degreeC") #needed for feedback in CO2 cycle component
    rtl_g0_baselandtemp=Variable(unit="degreeC") #needed for feedback in CH4 and N2O cycles
end

function init(s::ClimateTemperature)
    #calculate global baseline temperature from initial regional temperatures
    v = s.Variables
    p = s.Parameters
    d = s.Dimensions

    ocean_prop_ortion = 1. - sum(p.area) / 510000000.

    # Equation 21 from Hope (2006): initial global land temperature
    v.rtl_g0_baselandtemp = sum(p.rtl_0_realizedtemperature' .* p.area') / sum(p.area)

    # initial ocean and global temperatures
    rto_g0_baseoceantemp = v.rtl_g0_baselandtemp[1]/ p.rlo_ratiolandocean
    v.rt_g0_baseglobaltemp = ocean_prop_ortion * rto_g0_baseoceantemp + (1. - ocean_prop_ortion) * v.rtl_g0_baselandtemp[1]
end

function run_timestep(s::ClimateTemperature, tt::Int64)
    v = s.Variables
    p = s.Parameters
    d = s.Dimensions

    # Inclusion of transient climate response from Hope (2009)
    if tt == 1 # only calculate once
        v.sens_climatesensitivity = p.tcr_transientresponse / (1. - (p.frt_warminghalflife / 70.) * (1. - exp(-70. / p.frt_warminghalflife)))
    end

    ## Adjustment for latitude and land
    ocean_prop_ortion = 1. - (sum(p.area) / 510000000.)
    rt_adj_temperatureadjustment = (p.pole_polardifference / 90.) * (abs(p.lat_latitude) - p.lat_g_meanlatitude)

    ## Unadjusted realized temperature

    # Equation 19 from Hope (2006): equilibrium temperature estimate
    for rr in d.region
        v.et_equilibriumtemperature[tt, rr] = (v.sens_climatesensitivity / log(2.0)) * (p.ft_totalforcing[tt] + p.fs_sulfateforcing[tt, rr]) / p.fslope_CO2forcingslope
    end

    # Equation 20 from Hope (2006): realized temperature estimate
    # Hope (2009) replaced OCEAN with FRT
    if tt == 1
        # Calculate baseline realized temperature by subtracting off adjustment
        rt_0_realizedtemperature = (p.rtl_0_realizedtemperature - rt_adj_temperatureadjustment) * (1. + (ocean_prop_ortion / p.rlo_ratiolandocean) - ocean_prop_ortion)
        for rr in d.region
            v.rt_realizedtemperature[tt, rr] = rt_0_realizedtemperature[rr] + (1 - exp(-(p.y_year[tt] - p.y_year_0) / p.frt_warminghalflife)) * (v.et_equilibriumtemperature[tt, rr] - rt_0_realizedtemperature[rr])
        end
    else
        for rr in d.region
            v.rt_realizedtemperature[tt, rr] = v.rt_realizedtemperature[tt-1, rr] + (1 - exp(-(p.y_year[tt] - p.y_year[tt-1]) / p.frt_warminghalflife)) * (v.et_equilibriumtemperature[tt, rr] - v.rt_realizedtemperature[tt-1, rr])
        end
    end

    ## Adjusted realized temperature

    # Adding adjustment, from Hope (2009)
    for rr in d.region
        v.rtl_realizedtemperature[tt, rr] = v.rt_realizedtemperature[tt, rr] / (1. + (ocean_prop_ortion / p.rlo_ratiolandocean) - ocean_prop_ortion) + rt_adj_temperatureadjustment[rr]
    end

    # Equation 21 from Hope (2006): global realized temperature estimate
    v.rtl_g_landtemperature[tt] = sum(v.rtl_realizedtemperature[tt, :]' .* p.area') / sum(p.area)

    # Ocean and global average temperature from Hope (2009)
    v.rto_g_oceantemperature[tt] = v.rtl_g_landtemperature[tt] / p.rlo_ratiolandocean
    v.rt_g_globaltemperature[tt] = ocean_prop_ortion * v.rto_g_oceantemperature[tt] + (1. - ocean_prop_ortion) * v.rtl_g_landtemperature[tt]
end

function addclimatetemperature(model::Model)
    climatetemperaturecomp = addcomponent(model, ClimateTemperature)

    climatetemperaturecomp[:rlo_ratiolandocean] = 1.40
    climatetemperaturecomp[:pole_polardifference] = 1.50
    climatetemperaturecomp[:lat_g_meanlatitude] =  30.21989459076828
    climatetemperaturecomp[:fslope_CO2forcingslope] = 5.5
    climatetemperaturecomp[:tcr_transientresponse] = 1.70
    climatetemperaturecomp[:frt_warminghalflife] = 35.00

    return climatetemperaturecomp
end

function randomizeclimatetemperature(model::Model)
    update_external_parameter(model, :rlo_ratiolandocean, rand(TriangularDist(1.2, 1.6, 1.4)))
    update_external_parameter(model, :pole_polardifference, rand(TriangularDist(1, 2, 1.5)))
    update_external_parameter(model, :frt_warminghalflife, rand(TriangularDist(10, 65, 30)))
    update_external_parameter(model, :tcr_transientresponse, rand(TriangularDist(1, 2.8, 1.3)))
end
