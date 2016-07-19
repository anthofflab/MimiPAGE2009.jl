tests = ["ClimateTemperature","CO2forcing"]

for t in tests
    fp = joinpath("test_$t.jl")
    println("$fp ...")
    include(fp)
end
