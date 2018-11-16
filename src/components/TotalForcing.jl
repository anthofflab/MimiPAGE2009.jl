using Mimi

@defcomp TotalForcing begin
    f_CO2forcing = Parameter(index=[time], unit="W/m2")
    f_CH4forcing = Parameter(index=[time], unit="W/m2")
    f_N2Oforcing = Parameter(index=[time], unit="W/m2")
    f_lineargasforcing = Parameter(index=[time], unit="W/m2")
    exf_excessforcing = Parameter(index=[time], unit="W/m2")

    ft_totalforcing = Variable(index=[time], unit="W/m2")

    function run_timestep(p, v, d, tt)

        # From equation 16 of Hope (2006)
        v.ft_totalforcing[tt] = p.f_CO2forcing[tt] + p.f_CH4forcing[tt] + p.f_N2Oforcing[tt] + p.f_lineargasforcing[tt] + p.exf_excessforcing[tt]
    end
end

