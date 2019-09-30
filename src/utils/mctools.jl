using Query

"""
Create a parameter `component`_`name` with the given value,
and connect parameter `name` within `component` to this distinct global parameter.
"""
function setdistinctparameter(m::Model, component::Symbol, name::Symbol, value)
    globalname = Symbol(string(component, '_', name))
    # @info "setdistinctparameter: globalname=$globalname"

    param_dims = Mimi.parameter_dimensions(m, component, name)    

    Mimi.set_external_param!(m, globalname, value; param_dims = param_dims)
    
    # Added keywd arg to bypass checking labels
    connect_param!(m.md, component, name, globalname; check_labels=false)
    
    nothing
end

"""
Load raw RV output into reformat_RV_outputs 
"""
function load_RV(filename::String, RVname::String; 
                    output_path::String = joinpath(@__DIR__, "../../output/"), 
                    time_filter::Int = 2200,
                    region_filter::String = "LatAmerica")
    
    df = DataFrame(load(joinpath(output_path, "$filename.csv")))
    cols = names(df)
    
    #apply filters if necessary, currently the function supports a time filter 
    #of a single time value and a region filter of a single region
    if in(:time, cols)

        if in(:region, cols) 
            filtered_df = df |> @query(i, begin
                @where i.time == time_filter
                @where i.region == region_filter
                @select i
                end) |> DataFrame

        else
            filtered_df = df |> @query(i, begin
                @where i.time == time_filter
                @select i
                end) |> DataFrame
        end

        return filtered_df[!, Symbol(RVname)]
          
    #no filters applied
    else
        return df[!, Symbol(RVname)]
    end

end
