"""
`FunctionSerDe.jl`

Module containing (de)serialization and invocation logic
"""
module FunctionRunnerSerDe
using Serialization, Base64

PACKAGE_DIR = @__DIR__
export serializeToBase64, deserializeFunction,
    deserializeFunctionParams, invokeFunction

"""
`deserializeFunction(operation::String) -> function`

Deserialize function base64 encoded byte array 
"""
function deserializeFunction(operation)
    ioBuff = IOBuffer(base64decode(operation))
    funcMeta = Meta.parse(deserialize(ioBuff))
    return eval(funcMeta)
end


"""
`deserializeFunctionParams(params::Tuple{Vararg{Any}})`

Deserialize parameter base64 encoded byte array to tuple
"""
function deserializeFunctionParams(params)
    if isnothing(params)
        return ()
    end
    bytes = base64decode(params)
    ioBuff = IOBuffer(bytes)
    return split(deserialize(ioBuff))
end


"""
`serializeToBase64(input::Any) -> String`

Serailize argument to base64 encoded byte array
"""
function serializeToBase64(input)
    ioBuff = IOBuffer()
    serialize(ioBuff, input)
    return base64encode(take!(ioBuff))
end


"""
`
invokeFunction(func::function, args::Tuple{Vararg{Any}}; ParseTo::Type=Nothing) -> Any

Invokes function returing results. Optionally providing the data type
  to parse the splattened arguments to.
`
"""
function invokeFunction(func, args; ParseTo::Type=Nothing)
    if ParseTo === Nothing
        return func(args...)
    else
        return func(args...; ParseToType=ParseTo)
    end
end

# Close module
end