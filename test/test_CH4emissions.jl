using Mimi
include("../src/load_parameters.jl")
include("../src/CH4emissions.jl")

m = Model()
setindex(m, :time, [2009.,2010.,2020.,2030.,2040., 2050., 2075., 2100., 2150., 2200.])
setindex(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])

addcomponent(m, ch4emissions)

setparameter(m, :ch4emissions, :e0_baselineCH4emissions, [24.,29., 22., 38., 56., 71., 66., 58.]) #PAGE 2009 documentation pp38
setparameter(m, :ch4emissions, :er_CH4emissionsgrowth, readpagedata(m, joinpath(dirname(@__FILE__), "..","data","er_CH4emissionsgrowth.csv")))
#    SLRDamagescomp[:impmax_maxSLRforadaptpolicySLR] = readpagedata(model, "../data/sealevelmaxrise.csv")

##running Model
run(m)

#@test !isna(m[:ch4emissions, :e_globalCH4emissions][10])

# Generated data
pop= m[:ch4emissions,  :e_globalCH4emissions]

# Recorded data
#pop_compare = readpagedata(m, "validationdata/e_globalCH4emissions.csv")
temp=readpagedata(m, joinpath(dirname(@__FILE__), "validationdata","e_globalCH4emissions.csv"))
pop_compare=vec(sum(temp,2))

@test_approx_eq_eps pop pop_compare 1e0
