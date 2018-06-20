#TODO:  double check that this function operates correctl and efficiently
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
        #TODO:  TBD add @modelgate for dim_keys so don't have to reference model.md?
        region_keys = Mimi.dim_keys(model.md, :region)
        if region_keys[ii] != regions[ii] && !in(regions[ii], regionaliases[region_keys[ii]])
            error("Region indices in $file do not match expectations: $(model.indices_values[:region][ii]) <> $(regions[ii]).")
        end
    end
end

#TODO:  double check that this function operates correctl and efficiently
function checktimeorder(model::Model, times, file)
    for ii in 1:length(times)
        if Mimi.time_labels(model)[ii] != times[ii]
            error("Time indices in $file do not match expectations: $(model.indices_values[:time][ii]) <> $(times[ii]).")
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
        data = readcsv(filepath, header=true)

        # Check that regions are in the right order
        checkregionorder(model, data[1][:, 1], basename(filepath))

        return convert(Vector{Float64},vec(data[1][:, 2]))
    elseif firstline == "# Index: time"
        data = readcsv(filepath, header=true)

        # Check that the times are in the right order
        checktimeorder(model, data[1][:, 1], basename(filepath))

        return convert(Vector{Float64}, vec(data[1][:, 2]))
    elseif firstline == "# Index: time, region"
        data = readcsv(filepath, header=true)

        # Check that both dimension match
        checktimeorder(model, data[1][:, 1], basename(filepath))
        checkregionorder(model, data[2][2:end], basename(filepath))

        return convert(Array{Float64}, data[1][:, 2:end])
    else
        error("Unknown header in parameter file $filepath.")
    end
end

function load_parameters(model::Model, policy::String="policy-a")
    parameters = Dict{Any, Any}()

    parameter_directory = joinpath(dirname(@__FILE__), "..", "..", "data")
    for file in filter(q->splitext(q)[2]==".csv", readdir(parameter_directory))
        parametername = splitext(file)[1]

        if policy != "policy-a" && isfile(joinpath(parameter_directory, policy, file))
            filepath = joinpath(parameter_directory, policy, file)
        else
            filepath = joinpath(parameter_directory, file)
        end

        parameters[parametername] = readpagedata(model, filepath)
    end
    return parameters
end
