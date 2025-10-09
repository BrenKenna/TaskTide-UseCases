#!/bin/bash


# Works fine, see exit code 1 on tasks though
cd ~
julia \
    "./FunctionRunner/src/FunctionRunner.jl" \
    --operation="N0pMHgQAAAA5IaJmdW5jdGlvbiBteVNlcmRlRnVuYyhwYXJhbXMuLi47IFBhcnNlVG9UeXBlOjpUeXBlPUludCkKICAgIHBhcnNlZCA9IG1hcCgKICAgICAgICBlbG0gLT4gcGFyc2UoUGFyc2VUb1R5cGUsIGVsbSksCiAgICAgICAgcGFyYW1zCiAgICApCiAgICByZXR1cm4gcHJvZChwYXJzZWQpCmVuZAo=" \
    --parameters="N0pMHgQAAAAhBDcgMTI="

"""

2025-10-09 16:56:37 INFO  [ FunctionRunner.jl -> FunctionRunner.main ]:         Parsing command-line arguments
2025-10-09 16:56:39 INFO  [ FunctionRunner.jl -> FunctionRunner.main ]:         Deserializing function
WARNING: Detected access to binding `FunctionRunnerSerDe.mySerdeFunc` in a world prior to its definition world.
  Julia 1.12 has introduced more strict world age semantics for global bindings.
  !!! This code may malfunction under Revise.
  !!! This code will error in future versions of Julia.
Hint: Add an appropriate `invokelatest` around the access to this binding.
To make this warning an error, and hence obtain a stack trace, use `julia --depwarn=error`.
2025-10-09 16:56:39 INFO  [ FunctionRunner.jl -> FunctionRunner.main ]:         Deserializied function shown below:  mySerdeFunc

# 1 method for generic function "mySerdeFunc" from Main.FunctionRunner.FunctionRunnerSerDe:
 [1] mySerdeFunc(params...; ParseToType)
     @ none:1

2025-10-09 16:56:39 INFO  [ FunctionRunner.jl -> FunctionRunner.main ]:         Deserializing function parameters
2025-10-09 16:56:39 INFO  [ FunctionRunner.jl -> FunctionRunner.main ]:         SubString{String}["7", "12"]
2025-10-09 16:56:39 INFO  [ FunctionRunner.jl -> FunctionRunner.main ]:         Determining whether to serialize results
2025-10-09 16:56:39 INFO  [ FunctionRunner.jl -> FunctionRunner.main ]:         Determining where to direct results to
2025-10-09 16:56:39 INFO  [ FunctionRunner.jl -> FunctionRunner.main ]:         No target file provided, returning result
2025-10-09 16:56:39 INFO  [ FunctionRunner.jl -> FunctionRunner.main ]:         --- FUNCTION RUNNER OUTPUT ---

84

--- FUNCTION RUNNER OUTPUT ---
2025-10-09 16:56:39 INFO  [ FunctionRunner.jl -> FunctionRunner.main ]:         Processing completed

"""