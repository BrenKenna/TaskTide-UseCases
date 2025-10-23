# Import and inspect
using FunctionRunner


# Sanity check operation
ops = "N0pMHgQAAAA5IaJmdW5jdGlvbiBteVNlcmRlRnVuYyhwYXJhbXMuLi47IFBhcnNlVG9UeXBlOjpUeXBlPUludCkKICAgIHBhcnNlZCA9IG1hcCgKICAgICAgICBlbG0gLT4gcGFyc2UoUGFyc2VUb1R5cGUsIGVsbSksCiAgICAgICAgcGFyYW1zCiAgICApCiAgICByZXR1cm4gcHJvZChwYXJzZWQpCmVuZAo="
remoteOps = FunctionRunner.SerDe.deserializeFunction(ops)
println(methods(remoteOps))

params = "N0pMHgQAAAAhAzMgNw=="
params = FunctionRunner.SerDe.deserializeFunctionParams(params)
println(params)

println(FunctionRunner.SerDe.invokeFunction(remoteOps, params))
println(FunctionRunner.SerDe.invokeFunction(remoteOps, ["3.14", "6"]; ParseTo = Float64))