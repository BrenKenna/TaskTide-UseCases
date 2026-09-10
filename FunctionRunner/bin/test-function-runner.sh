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




########################################
########################################
## 
## Test Building Container
## 
########################################
########################################


# Run session to debug installation
docker container run \
  -it --rm \
  -v "./FunctionRunner:/opt/julia" \
  -w /opt/julia julia:trixi

```

using Pkg

cd("/opt/julia")
Pkg.activate("./")
Pkg.develop(path="./")
Pkg.instantiate()
Pkg.precompile()


run(`julia --project=. ./test-invocation.jl`)

run(`
    julia --project=. ./src/FunctionRunner.jl --operation "N0pMHgQAAAA5IaJmdW5jdGlvbiBteVNlcmRlRnVuYyhwYXJhbXMuLi47IFBhcnNlVG9UeXBlOjpUeXBlPUludCkKICAgIHBhcnNlZCA9IG1hcCgKICAgICAgICBlbG0gLT4gcGFyc2UoUGFyc2VUb1R5cGUsIGVsbSksCiAgICAgICAgcGFyYW1zCiAgICApCiAgICByZXR1cm4gcHJvZChwYXJzZWQpCmVuZAo=" --parameters "N0pMHgQAAAAhAzMgNw=="
    `
)


using FunctionRunner

```


# Build, singularity does not catch ~/.julia <- Fix in the docker build, and set depot
docker image build -t function_runner:latest
docker save -o FunctionRunner.tar function_runner:latest

singularity build \
  FunctionRunner.sif \
  docker-archive://FunctionRunner.tar

singularity build --sandbox FunctionRunnerSandBox FunctionRunner.sif



singularity build --sandbox FunctionRunner_sandboxv2 FunctionRunner.sif
cp -r ./julia_depot/* FunctionRunner_sandboxv2/root/.julia/
singularity build FunctionRunner_fixed.sif FunctionRunner_sandboxv2

singularity exec --pwd /opt/julia FunctionRunner.sif ls -lhta

'''

total 14K
drwxr-xr-x 6 root root   89 Oct 23 17:23 .julia
drwxr-xr-x 4 root root  107 Oct 23 17:22 .
drwxr-xr-x 2 root root  100 Oct 23 16:16 src
-rwxr-xr-x 1 root root  677 Oct 23 15:42 test-invocation.jl
drwxr-xr-x 3 root root   28 Oct 23 13:47 ..
-rwxr-xr-x 1 root root  12K Oct 23 13:34 Manifest.toml
-rwxr-xr-x 1 root root 1.1K Oct 23 13:34 Project.toml


'''



# Bind the current working directory (PWD) to a path inside the container (e.g., /mnt)
singularity exec \
  --pwd /opt/julia \
  --env JULIA_DEPOT_PATH=/scratch/$USER/julia_depot \
  --env JULIA_PKG_PRECOMPILE_DIR=/scratch/$USER/julia_precompile \
  FunctionRunner.sif \
  julia --project=/opt/julia ./src/FunctionRunner.jl \
      --operation="N0pMHgQAAAA5IaJmdW5jdGlvbiBteVNlcmRlRnVuYyhwYXJhbXMuLi47IFBhcnNlVG9UeXBlOjpUeXBlPUludCkKICAgIHBhcnNlZCA9IG1hcCgKICAgICAgICBlbG0gLT4gcGFyc2UoUGFyc2VUb1R5cGUsIGVsbSksCiAgICAgICAgcGFyYW1zCiAgICApCiAgICByZXR1cm4gcHJvZChwYXJzZWQpCmVuZAo=" \
      --parameters="N0pMHgQAAAAhBDE4IDc="


# Make writable once to pull in packages etc, then fine after that
singularity exec \
  --writable \
  --pwd /opt/julia \
  --env JULIA_DEPOT_PATH=/opt/julia/.julia \
  --env JULIA_PKG_PRECOMPILE_DIR=/opt/julia/.julia/compiled \
  FunctionRunnerSandBox \
  julia --project=/opt/julia ./src/FunctionRunner.jl \
      --operation="N0pMHgQAAAA5IaJmdW5jdGlvbiBteVNlcmRlRnVuYyhwYXJhbXMuLi47IFBhcnNlVG9UeXBlOjpUeXBlPUludCkKICAgIHBhcnNlZCA9IG1hcCgKICAgICAgICBlbG0gLT4gcGFyc2UoUGFyc2VUb1R5cGUsIGVsbSksCiAgICAgICAgcGFyYW1zCiAgICApCiAgICByZXR1cm4gcHJvZChwYXJzZWQpCmVuZAo=" \
      --parameters="N0pMHgQAAAAhBDE4IDc="

'''

2025-10-23 17:41:19 INFO  [ FunctionRunner.jl -> FunctionRunner.main ]:         Parsing command-line arguments
2025-10-23 17:41:20 INFO  [ FunctionRunner.jl -> FunctionRunner.main ]:         Deserializing function
WARNING: Detected access to binding `FunctionRunnerSerDe.mySerdeFunc` in a world prior to its definition world.
  Julia 1.12 has introduced more strict world age semantics for global bindings.
  !!! This code may malfunction under Revise.
  !!! This code will error in future versions of Julia.
Hint: Add an appropriate `invokelatest` around the access to this binding.
To make this warning an error, and hence obtain a stack trace, use `julia --depwarn=error`.
2025-10-23 17:41:20 INFO  [ FunctionRunner.jl -> FunctionRunner.main ]:         Deserializied function shown below:  mySerdeFunc

# 1 method for generic function "mySerdeFunc" from Main.FunctionRunner.FunctionRunnerSerDe:
 [1] mySerdeFunc(params...; ParseToType)
     @ none:1

2025-10-23 17:41:20 INFO  [ FunctionRunner.jl -> FunctionRunner.main ]:         Deserializing function parameters
2025-10-23 17:41:21 INFO  [ FunctionRunner.jl -> FunctionRunner.main ]:         SubString{String}["18", "7"]
2025-10-23 17:41:21 INFO  [ FunctionRunner.jl -> FunctionRunner.main ]:         Determining whether to serialize results
2025-10-23 17:41:21 INFO  [ FunctionRunner.jl -> FunctionRunner.main ]:         Determining where to direct results to
2025-10-23 17:41:21 INFO  [ FunctionRunner.jl -> FunctionRunner.main ]:         No target file provided, returning result
2025-10-23 17:41:21 INFO  [ FunctionRunner.jl -> FunctionRunner.main ]:         --- FUNCTION RUNNER OUTPUT ---

126

--- FUNCTION RUNNER OUTPUT ---
2025-10-23 17:41:21 INFO  [ FunctionRunner.jl -> FunctionRunner.main ]:         Processing completed

'''



# Run unit test, and FunctionRunner
docker container run --rm function_runner:latest --project="." test-invocation.jl
docker container run --rm function_runner:latest --project="." ./src/FunctionRunner.jl --operation="N0pMHgQAAAA5IaJmdW5jdGlvbiBteVNlcmRlRnVuYyhwYXJhbXMuLi47IFBhcnNlVG9UeXBlOjpUeXBlPUludCkKICAgIHBhcnNlZCA9IG1hcCgKICAgICAgICBlbG0gLT4gcGFyc2UoUGFyc2VUb1R5cGUsIGVsbSksCiAgICAgICAgcGFyYW1zCiAgICApCiAgICByZXR1cm4gcHJvZChwYXJzZWQpCmVuZAo=" --parameters="N0pMHgQAAAAhBDE4IDc="


docker container run --rm function_runner:latest FunctionRunner --operation="N0pMHgQAAAA5IaJmdW5jdGlvbiBteVNlcmRlRnVuYyhwYXJhbXMuLi47IFBhcnNlVG9UeXBlOjpUeXBlPUludCkKICAgIHBhcnNlZCA9IG1hcCgKICAgICAgICBlbG0gLT4gcGFyc2UoUGFyc2VUb1R5cGUsIGVsbSksCiAgICAgICAgcGFyYW1zCiAgICApCiAgICByZXR1cm4gcHJvZChwYXJzZWQpCmVuZAo=" --parameters="N0pMHgQAAAAhBDE4IDc="

'''

# 1 method for generic function "mySerdeFunc" from FunctionRunner.FunctionRunnerSerDe:
 [1] mySerdeFunc(params...; ParseToType)
     @ none:1
SubString{String}["3", "7"]
21
18.84


2025-10-23 15:02:15 INFO  [ FunctionRunner.jl -> FunctionRunner.main ]:         Parsing command-line arguments
2025-10-23 15:02:17 INFO  [ FunctionRunner.jl -> FunctionRunner.main ]:         Deserializing function
2025-10-23 15:02:17 INFO  [ FunctionRunner.jl -> FunctionRunner.main ]:         Deserializied function shown below:  mySerdeFunc

# 1 method for generic function "mySerdeFunc" from Main.FunctionRunner.FunctionRunnerSerDe:
 [1] mySerdeFunc(params...; ParseToType)
     @ none:1

2025-10-23 15:02:17 INFO  [ FunctionRunner.jl -> FunctionRunner.main ]:         Deserializing function parameters
2025-10-23 15:02:17 INFO  [ FunctionRunner.jl -> FunctionRunner.main ]:         SubString{String}["18", "7"]
2025-10-23 15:02:17 INFO  [ FunctionRunner.jl -> FunctionRunner.main ]:         Determining whether to serialize results
2025-10-23 15:02:17 INFO  [ FunctionRunner.jl -> FunctionRunner.main ]:         Determining where to direct results to
2025-10-23 15:02:17 INFO  [ FunctionRunner.jl -> FunctionRunner.main ]:         No target file provided, returning result
2025-10-23 15:02:17 INFO  [ FunctionRunner.jl -> FunctionRunner.main ]:         --- FUNCTION RUNNER OUTPUT ---

126

--- FUNCTION RUNNER OUTPUT ---
2025-10-23 15:02:17 INFO  [ FunctionRunner.jl -> FunctionRunner.main ]:         Processing completed

'''