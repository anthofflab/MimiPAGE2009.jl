using Mimi
include("../src/load_parameters.jl")
include("../src/CH4emissions.jl")

m = Model()
setindex(m, :time, [2009.,2010.,2020.,2030.,2040., 2050., 2075., 2100., 2150., 2200.])
setindex(m, :region, ["EU", "USA", "OECD","USSR","China","SEAsia","Africa","LatAmerica"])

addcomponent(m, ch4emissions)

setparameter(m, :ch4emissions, :e0_baselineCH4emissions, readpagedata(m, "data/e0_baselineCH4emissions.csv")) #PAGE 2009 documentation pp38
setparameter(m, :ch4emissions, :er_CH4emissionsgrowth, readpagedata(m, "data/er_CH4emissionsgrowth.csv"))

##running Model
run(m)

# Generated data
emissions= m[:ch4emissions,  :e_regionalCH4emissions]

# Recorded data
emissions_compare=readpagedata(m, joinpath(dirname(@__FILE__), "validationdata","e_regionalCH4emissions.csv"))

@test emissions ≈ emissions_compare rtol=1e-3
