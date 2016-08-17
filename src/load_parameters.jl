function load_parameters()
    parameters = Dict{Any, Any}()

    parameter_directory = joinpath(dirname(@__FILE__), "..", "data")
    for file in filter(q->splitext(q)[2]==".csv", readdir(parameter_directory))
        parametername = splitext(file)[1]
        full_filename = joinpath(parameter_directory, file)
        content = readlines(full_filename)

        firstline = chomp(content[1])
        if firstline == "# Index: region"
            data = readcsv(full_filename, header=true)

            parametervalue = convert(Vector{Float64},vec(data[1][:,2]))
        else
            error("Unknown header in parameter file.")
        end

        parameters[parametername] = parametervalue
    end
    return parameters
end
