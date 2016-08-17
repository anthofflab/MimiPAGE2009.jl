using DataFrames
using ExcelReaders

# datadir = "data"
datadir = joinpath(dirname(@__FILE__), "..", "data")

data = readxlsheet(DataFrame, joinpath(datadir, "regioninfo.xlsx"), "Sheet1")

names = Dict(:area => "Area",
             :gdp => "GDP",
             :population => "Pop",
             :co2emit => "CO2 emit",
             :ch4emit => "CH4 emit",
             :n2oemit => "N2O emit",
             :linemit => "Lin emit",
             :semit => "S emit",
             :naturals => "Natural S",
             :rt => "RT",
             :latitude => "Latitude")

for key in keys(names)
    println(key)
    unit = data[1, symbol(names[key])]

    open(joinpath(datadir, "$key.csv"), "w") do fp
        write(fp, "# Index: region\n")
        write(fp, "# Unit: $unit\n")
        write(fp, "Region,\"$(names[key])\"\n")

        df = DataFrame(region=data[2:end, symbol("Abbr.")], value=data[2:end, symbol(names[key])])
        writedlm(fp, convert(DataMatrix, df), ",", header=false)
    end
end
