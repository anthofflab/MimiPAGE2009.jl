using Mimi

# SF6 defined as "linear gas" or gas 4 in PAGE 2009; equations are the same as for gas 3 (CH4) in PAGE2002
@defcomp LGemissions begin
    region=Index()

# global emissions
    e_globalLGemissions=Variable(index=[time],unit="Mtonne/year")
# baseline emissions
    e0_baselineLGemissions=Parameter(index=[region],unit="Mtonne/year")
# regional emissions
    e_regionalLGemissions=Variable(index=[time,region],unit="Mtonne/year")
# growth rate by region
    er_LGemissionsgrowth=Parameter(index=[time,region],unit="%")

end

function run_timestep(s::LGemissions,t::Int64)
    v=s.Variables
    p=s.Parameters
    d=s.Dimensions

    #eq.4 in Hope (2006) - regional LG emissions as % change from baseline
    for r in d.region
        v.e_regionalLGemissions[t,r]=p.er_LGemissionsgrowth[t,r]*p.e0_baselineLGemissions[r]/100
    end

    #eq. 5 in Hope (2006) - global LG emissions are sum of regional emissions
    v.e_globalLGemissions[t]=sum(v.e_regionalLGemissions[t,:])
end
