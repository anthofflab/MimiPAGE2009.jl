using Query

"""
Create a parameter `component`_`name` with the given value,
and connect parameter `name` within `component` to this distinct global parameter.
"""

function setdistinctparameter(m::Model, component::Symbol, name::Symbol, value)
    globalname = Symbol(string(component, '_', name))

    param_dims = Mimi.parameter_dimensions(m, component, name)    

    Mimi.set_external_param!(m, globalname, value; param_dims = param_dims)
    
    #connect_param!(m, component, name, globalname) # BUG: Cannot use this, because `checklabels` misuses globalname.  Instead, doing the below.
    Mimi.disconnect_param!(m.md, component, name)
    x = Mimi.ExternalParameterConnection(component, name, globalname)
    push!(m.md.external_param_conns, x)

    nothing
end

"""
Load raw RV output into reformat_RV_outputs 
"""

function load_RV(name::String; 
                    output_path::String = joinpath(@__DIR__, "../../output/"), 
                    time_filter::Int = 2200,
                    region_filter::String = "LatAmerica")
    
    df = DataFrame(load(joinpath(output_path, "$name.csv")))
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

        return filtered_df[convert(Symbol, name)]
          
    #no filters applied
    else
        return df[convert(Symbol, name)]
    end

end
