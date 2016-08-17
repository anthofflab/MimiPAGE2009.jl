using DataFrames
using ExcelReaders

# datadir = "data"
datadir = joinpath(dirname(@__FILE__), "..", "data")

data = readxlsheet(DataFrame, joinpath(datadir, "regioninfo.xlsx"), "Sheet1")

columns = Dict(:area => "Area",
             :gdp => "GDP",
             :population => "Pop",
             :e0_baselineCO2emissions => "CO2 emit",
             :e0_baselineCH4emissions => "CH4 emit",
             :e0_baselineN2Oemissions => "N2O emit",
             :e0_baselineLGemissions => "Lin emit",
             :se0_sulphateemissionsbase => "S emit",
             :nf_naturalsfx => "Natural S",
             :rtl_0_realizedtemperature => "RT",
             :lat_latitude => "Latitude")

for key in keys(columns)
    println(key)
    unit = data[1, symbol(columns[key])]
    if unit == "Mtonne" || unit == "TgS"
        unit = "Mtonne/year"
    end
    if unit == "Tg/km2"
        unit = "Tg/km^2/yr"
    end
    if unit == "degree"
        unit = "degreeLatitude"
    end

    open(joinpath(datadir, "$key.csv"), "w") do fp
        write(fp, "# Index: region\n")
        write(fp, "# Unit: $unit\n")
        write(fp, "Region,\"$(columns[key])\"\n")

        df = DataFrame(region=data[2:end, symbol("Abbr.")], value=data[2:end, symbol(columns[key])])
        writedlm(fp, convert(DataMatrix, df), ",", header=false)
    end
end
