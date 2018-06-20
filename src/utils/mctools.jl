"""
Create a parameter `component`_`name` with the given value,
and connect parameter `name` within `component` to this distinct global parameter.
"""

#TODO: This function has been altered quite a bit, pulling from set_leftover_params!
#for guidance ... talk this one through. 

function setdistinctparameter(m::Model, component::Symbol, name::Symbol, value)
    globalname = Symbol(lowercase(string(component, '_', name)))
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

    #TODO:  don't use Nullable!  modifiing the model instance really isn't part
    #of the API
    #m.mi = Nullable{Mimi.ModelInstance}()
    nothing
end

"""
Change the value of an external parameter
"""
function update_external_param(m::Model, name::Symbol, value::Float64)
    m.md.external_params[Symbol(lowercase(string(name)))].value = value
end

function update_external_param(m::Model, name::Symbol, value::AbstractArray)
    m.md.external_params[Symbol(lowercase(string(name)))].values = value
end
