using Test

m = test_page_model()
include("../src/components/CH4emissions.jl")

add_comp!(m, ch4emissions)

p = load_parameters(m)
update_param!(m, :ch4emissions, :e0_baselineCH4emissions, p[:shared][:e0_baselineCH4emissions]) #PAGE 2009 documentation pp38
update_param!(m, :ch4emissions, :er_CH4emissionsgrowth, p[:shared][:er_CH4emissionsgrowth])

##running Model
run(m)

# Generated data
emissions= m[:ch4emissions,  :e_regionalCH4emissions]

# Recorded data
emissions_compare=readpagedata(m, "test/validationdata/e_regionalCH4emissions.csv")

@test emissions ≈ emissions_compare rtol=1e-3
