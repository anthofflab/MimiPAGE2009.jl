"""
Create a parameter `component`_`name` with the given value,
and connect parameter `name` within `component` to this distinct global parameter.
"""

# TODO: This function has been altered quite a bit, pulling from set_leftover_params!
# for guidance  ... so we should double check it for correctness and consider 
# alternatives that don't dive quite so deeply into the internals.  We also may 
# want to rearrange the files if this is the only function in this file ... combine
# with mcs_RVs?
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
Change the value of an external parameter
"""
#TODO:  We wont' need these functions anymore after conversion to new mcs framework,
#and we also now have the Mimi function Mimi.update_external_param.
function update_external_param(m::Model, name::Symbol, value::Float64)
    m.md.external_params[Symbol(string(name))].value = value 
end

function update_external_param(m::Model, name::Symbol, value::AbstractArray)
    m.md.external_params[Symbol(string(name))].values = value
end
