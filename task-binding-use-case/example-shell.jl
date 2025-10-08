"""
`Example-Shell.jl`

Julia script to demonstrate early-task binding use-case of
 TaskTide
"""
using Pkg
Pkg.activate("./FunctionRunner")
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
    myFunc(x, y) = return x * y
"""

annotation = Dict(
    "Pilot Label" => "Function-Runner-Label"
)
params = FunctionRunner.Utils.randomNumbers(8, 3, 21)
FunctionRunner.Utils.writeTasksToJsonFile(
    pwd(), "Multiplication", STEP_NAME, 
    annotation, funcSrc, params
)


# Sanity check operation
ops = "N0pMGgQAAAA5ISAgICAgbXlGdW5jKHgsIHkpID0gcmV0dXJuIHggKiB5Cg=="
remoteOps = FunctionRunner.SerDe.deserializeFunction(ops)
methods(remoteOps)
"""
# 1 method for generic function "myFunc" from FunctionRunner.FunctionRunnerSerDe:
 [1] myFunc(x, y)
     @ none:1
"""

params = "N0pMGgQAAAAhBTEwIDEy"
FunctionRunner.SerDe.deserializeFunctionParams(params)

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
        --target-file "$(pwd())/FunctionRunnerTasks.json"
`
result = run(importCmd)


# Query state
summarizeCmd = `
    tasktide.bat \
        manager \
          --repository-type "$REPOSITORY_TYPE" \
          --file-path "$REPOSITORY" \
          --step-name "$STEP_NAME" \
          --method "Summarize" \
          --target "WORKITEM"
`
result = run(pipeline(
      summarizeCmd,
      stdout = stdout,
      stderr = stderr
))


# Gather list of files
resultFiles = [
    joinpath(root, file)
    for (root, dirs, files) in walkdir("$WORKING_DIRECTORY/results")
        for file in files
]


# Aggregate into table
results =  [
    Dict(
        "Results" => CSV.read(file, DataFrame) |> Tables.columntable
    )
]


# Sink to file
FunctionRunner.sinkToFile(results, "$WORKING_DIRECTORY/results.txt")