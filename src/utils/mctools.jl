"""
Create a parameter `component`_`name` with the given value,
and connect parameter `name` within `component` to this distinct global parameter.
"""

function setdistinctparameter(m::Model, component::Symbol, name::Symbol, value)
    globalname = Symbol(string(component, '_', name))
    param_dims = Mimi.parameter_dimensions(m, component, name)    
    num_dims = length(size(value))

    if num_dims == 0 #scalar case
        Mimi.set_external_scalar_param!(m.md, globalname, value)
        
    else
        if num_dims in (1, 2) && name == :time   # array case
            value = convert(Array{m.md.number_type}, value)
            
            values = Mimi.get_timestep_instance(m.md, eltype(value), num_dims, value)
            
        else
            values = value
        end
        #TODO:  this causes an error because we cannot setproperty! with a 
        #non-scalar
        Mimi.set_external_array_param!(m, globalname, values, param_dims)
    end

    # TODO:  the bug mentioned below was pointed out by previous authors before
    # conversion to the new Mimi framework... still an issue?
    #connect_parameter(m, component, name, globalname) # BUG: Cannot use this, because `checklabels` misuses globalname.  Instead, doing the below.
    Mimi.disconnect!(m.md, component, name)
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
