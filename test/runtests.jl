tests = ["ClimateTemperature","CH4cycle","CO2emissions","CH4emissions"]

for t in tests
    fp = joinpath("test_$t.jl")
    println("$fp ...")
    include(fp)
end
