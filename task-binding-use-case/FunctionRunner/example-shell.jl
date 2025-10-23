"""
`Example-Shell.jl`

Julia script to demonstrate early-task binding use-case of
 TaskTide
"""
using Pkg
Pkg.activate("FunctionRunner")
#Pkg.instantiate()

using JSON
using CSV
using DataFrames
using Printf

# Import and inspect
using FunctionRunner
# names(FunctionRunner, all=true)


# Set standard variables
REPOSITORY_TYPE = "sqlite"
WORKING_DIRECTORY = "./Early-Task-Binding"
REPOSITORY = "$WORKING_DIRECTORY/ItemStoreRepo/$REPOSITORY_TYPE"
STEP_NAME = "FunctionRunner"
TASK_DELIMITER = "JSON"

mkpath(REPOSITORY)
mkpath("$WORKING_DIRECTORY/results")
cd(WORKING_DIRECTORY)


# Setup tasks: function should also parse
funcSrc = """
function mySerdeFunc(params...; ParseToType::Type=Int)
    parsed = map(
        elm -> parse(ParseToType, elm),
        params
    )
    return prod(parsed)
end
"""

annotation = Dict(
    "Pilot Label" => "Function-Runner-Label"
)
params = FunctionRunner.Utils.randomNumbers(30, 3, 21)
FunctionRunner.Utils.writeTasksToJsonFile(
    pwd(), "Multiplication", STEP_NAME, 
    annotation, funcSrc, params
)


# Sanity check operation
ops = "N0pMHgQAAAA5IaJmdW5jdGlvbiBteVNlcmRlRnVuYyhwYXJhbXMuLi47IFBhcnNlVG9UeXBlOjpUeXBlPUludCkKICAgIHBhcnNlZCA9IG1hcCgKICAgICAgICBlbG0gLT4gcGFyc2UoUGFyc2VUb1R5cGUsIGVsbSksCiAgICAgICAgcGFyYW1zCiAgICApCiAgICByZXR1cm4gcHJvZChwYXJzZWQpCmVuZAo="
remoteOps = FunctionRunner.SerDe.deserializeFunction(ops)
methods(remoteOps)

params = """N0pMHgQAAAAhBTEwIDE2"""
params = FunctionRunner.SerDe.deserializeFunctionParams(params)

FunctionRunner.SerDe.invokeFunction(remoteOps, params)
FunctionRunner.SerDe.invokeFunction(remoteOps, ["3.14", "6"]; ParseTo = Float64)

"""
# 1 method for generic function "mySerdeFunc" from FunctionRunner.FunctionRunnerSerDe:
 [1] mySerdeFunc(params...; ParseToType)
     @ none:1


2-element Vector{SubString{String}}:
 "6"
 "10"

60
18.84

"""



# Import tasks
importCmd = `
    tasktide
       manager
        --repository-type "$REPOSITORY_TYPE"
        --file-path "$REPOSITORY"
        --step-name "$STEP_NAME"
        --delimiter "$TASK_DELIMITER"
        --method "Import"
        --target "ManagerTask"
        --target-file "/home/bren/Early-Task-Binding/Multiplication-tasks.json"
`
result = run(importCmd)


# Query state
summarizeCmd = `
    tasktide \
        manager \
          --repository-type "$REPOSITORY_TYPE" \
          --file-path "$REPOSITORY" \
          --step-name "$STEP_NAME" \
          --method "Summarize" \
          --target "WORKITEM"
`
result = run(summarizeCmd)


# Gather list of files
resultFiles = [
    joinpath(root, file)
    for (root, dirs, files) in walkdir("$WORKING_DIRECTORY/results")
        for file in files
]


# Aggregate into table
results =  [
    let result = parse(Float64, strip(read(file, String)))
        rm(file)
        Dict(
            "Result" => result,
            "File" => file
        )
    end
    for file in resultFiles
]


# Sink to file
FunctionRunner.Utils.writeJson("result", results, WORKING_DIRECTORY)
sum( [ elm["Result"] for elm in results ] )

"""
Tasks written to:       '/home/bren/Early-Task-Binding/result-tasks.json'
4780.0
"""