using DelimitedFiles

function checkregionorder(model::Model, regions, file)
    regionaliases = Dict{AbstractString, Vector{AbstractString}}("EU" => [],
                                                                 "USA" => ["US"],
                                                                 "OECD" => ["OT"],
                                                                 "Africa" => ["AF"],
                                                                 "China" => ["CA"],
                                                                 "SEAsia" => ["IA"],
                                                                 "LatAmerica" => ["LA"],
                                                                 "USSR" => ["EE"])

    for ii in 1:length(regions)
        region_keys = Mimi.dim_keys(model.md, :region)
        if region_keys[ii] != regions[ii] && !in(regions[ii], regionaliases[region_keys[ii]])
            error("Region indices in $file do not match expectations: $(region_keys[ii]) <> $(regions[ii]).")
        end
    end
end

function checktimeorder(model::Model, times, file)
    for ii in 1:length(times)
        if Mimi.time_labels(model)[ii] != times[ii]
            error("Time indices in $file do not match expectations: $(Mimi.time_labels(model)[ii]) <> $(times[ii]).")
        end
    end
end

function readpagedata(model::Model, filepath::AbstractString)
    # Handle relative paths
    if filepath[1] ∉ ['.', '/'] && !isfile(filepath)
        filepath = joinpath(@__DIR__, "..", "..", filepath)
    end

    content = readlines(filepath)

    firstline = chomp(content[1])
    if firstline == "# Index: region"
        data = readdlm(filepath, ',', header=true, comments=true)

        # Check that regions are in the right order
        checkregionorder(model, data[1][:, 1], basename(filepath))

        return convert(Vector{Float64},vec(data[1][:, 2]))
    elseif firstline == "# Index: time"
        data = readdlm(filepath, ',', header=true, comments=true)

        # Check that the times are in the right order
        checktimeorder(model, data[1][:, 1], basename(filepath))

        return convert(Vector{Float64}, vec(data[1][:, 2]))
    elseif firstline == "# Index: time, region"
        data = readdlm(filepath, ',', header=true, comments = true)

        # Check that both dimension match
        checktimeorder(model, data[1][:, 1], basename(filepath))
        checkregionorder(model, data[2][2:end], basename(filepath))

        return convert(Array{Float64}, data[1][:, 2:end])
    else
        error("Unknown header in parameter file $filepath.")
    end
end


"""
Reads parameter csvs from data directory into a dictionary with two keys:
* :shared => (parameter_name => default_value) for parameters shared in the model
* :unshared => ((component_name, parameter_name) => default_value) for component specific parameters that are not shared
""" 
function load_parameters(model::Model; policy::String="policy-a")

    unshared_parameters = Dict{Tuple{Symbol, Symbol}, Any}()
    shared_parameters = Dict{Symbol, Any}()

    # Load unshared parameters
    parameter_directory = joinpath(dirname(@__FILE__), "..", "..", "data", "unshared_parameters")
    for file in filter(q->splitext(q)[2]==".csv", readdir(parameter_directory))
        if policy != "policy-a" && isfile(joinpath(parameter_directory, policy, file))
            filepath = joinpath(parameter_directory, policy, file)
        else
            filepath = joinpath(parameter_directory, file)
        end

        param_info = Symbol.(split(splitext(file)[1], "-"))
        unshared_parameters[(param_info[1], param_info[2])] = readpagedata(model, filepath)
    end

    # Load shared parameters
    parameter_directory = joinpath(dirname(@__FILE__), "..", "..", "data", "shared_parameters")
    for file in filter(q->splitext(q)[2]==".csv", readdir(parameter_directory))
        if policy != "policy-a" && isfile(joinpath(parameter_directory, policy, file))
            filepath = joinpath(parameter_directory, policy, file)
        else
            filepath = joinpath(parameter_directory, file)
        end
        paramname = Symbol.(splitext(file)[1])
        shared_parameters[paramname] = readpagedata(model, filepath)
    end

    return Dict(:shared => shared_parameters, :unshared => unshared_parameters)
end
