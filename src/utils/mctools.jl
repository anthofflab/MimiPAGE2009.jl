"""
Create a parameter `component`_`name` with the given value,
and connect parameter `name` within `component` to this distinct global parameter.
"""

#TODO: This function has been altered quite a bit, pulling from set_leftover_params!
#for guidance ... talk this one through. 

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
        Mimi.set_external_array_param!(m, globalname, values, param_dims)
    end

    #connect_parameter(m, component, name, globalname) # BUG: Cannot use this, because `checklabels` misuses globalname.  Instead, doing the below.
    Mimi.disconnect!(m.md, component, name)
    x = Mimi.ExternalParameterConnection(component, name, globalname)
    push!(m.md.external_param_conns, x)

    nothing
end

"""
Change the value of an external parameter
"""
#TODO:  somewhere we are getting both lowercase and uppercase external param names,
#where are we enforcing lowercase?  see Mimi connections.jl changes ... but these
#break things in other places ...

function update_external_param(m::Model, name::Symbol, value::Float64)
    # try
        # m.md.external_params[Symbol(lowercase(string(name)))].value = value
    # catch
        m.md.external_params[Symbol(string(name))].value = value
    # end
    
end

function update_external_param(m::Model, name::Symbol, value::AbstractArray)
    # try
        # m.md.external_params[Symbol(lowercase(string(name)))].values = value
    # catch
        m.md.external_params[Symbol(string(name))].values = value
    # end
    
end
