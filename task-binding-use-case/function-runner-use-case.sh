#!/bin/bash


# Load variables etc
. ~/start.sh
. ~/conda-env.sh

conda activate singularity_env


# Working directory
export FUNC_DIR="$DATA_DIR/function-runner"
mkdir -p $DATA_DIR/function-runner $DATA_DIR/data/ \
    && cd $FUNC_DIR


# Start engine
tasktide \
    engine \
    --repository-type "rocksDB" \
    --file-path "$DATA_DIR/TaskTide/FunctionRunner/rocksDB" \
    --target "WORKITEM" \
    --step-name "FunctionRunner" \
    --execution-policy "service" \
    --worker-pool-size "2" \
    --worker-window-size "4" \
    --item-task-threads "2"

'''

2026-06-24 09:45:10 INFO  [ pool-3-thread-1 -> org.tasktide.engine.observer.ObserverChain.onTaskProcessing ]: Evaluating Observer 'ItemTaskStateObserver' for task 'ItemTask-154559ac-8f0c-46ba-87c9-638ac352d975' with onTaskProcessing result 'true'
2026-06-24 09:45:10 DEBUG [ pool-3-thread-1 -> org.tasktide.engine.executor.ProcessExecutor.execute ]: Beginning execution of task:     
    bash /home/people/bkenna/software/bin/singularity-runner.sh --debug "/opt/julia/src/FunctionRunner.jl" 
    --operation="N0pMHgQAAAA5IaJmdW5jdGlvbiBteVNlcmRlRnVuYyhwYXJhbXMuLi47IFBhcnNlVG9UeXBlOjpUeXBlPUludCkKICAgIHBhcnNlZCA9IG1hcCgKICAgICAgICBlbG0gLT4gcGFyc2UoUGFyc2VUb1R5cGUsIGVsbSksCiAgICAgICAgcGFyYW1zCiAgICApCiAgICByZXR1cm4gcHJvZChwYXJzZWQpCmVuZAo="
    --parameters="N0pMHgQAAAAhBTE5IDEy" --output="./data/results/Multiplication-10.txt"

2026-06-24 10:26:40 INFO  [ main -> org.tasktide.engine.worker.TaskTideEngineWorker.fetchAndRun ]: No active tasks, engine worker shutting down after '0' iterations
'''


# Start julia session
singularity exec \
    --writable \
    --bind $DATA_DIR:$DATA_DIR \
    --bind /opt/software/el9/spack:/opt/software/el9/spack \
    --pwd /opt/julia \
    --env JULIA_DEPOT_PATH=/opt/julia/.julia \
    --env JULIA_PKG_PRECOMPILE_DIR=/opt/julia/.julia/compiled \
    $JULIA_MODULES/FunctionRunnerSandBox \
    julia --project=.



```{julia}

using FunctionRunner

REPOSITORY_TYPE = "rocksDB"
DATA_DIR = ENV["DATA_DIR"]
WORKING_DIRECTORY = ENV["FUNC_DIR"]
REPOSITORY = "$DATA_DIR/TaskTide/FunctionRunner/rocksDB"
STEP_NAME = "FunctionRunner"
TASK_DELIMITER = "JSON"

mkpath(REPOSITORY)
mkpath("$WORKING_DIRECTORY/data")
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
params = FunctionRunner.Utils.randomNumbers(32, 3, 21)
FunctionRunner.Utils.writeTasksToJsonFile(
    "$WORKING_DIRECTORY/data", "Multiplication", STEP_NAME, 
    annotation, funcSrc, params, true
)



# Import tasks
BIN_DIR = ENV["SOFT"]
importCmd = `
    $BIN_DIR/bin/tasktide
       manager
        --repository-type "$REPOSITORY_TYPE"
        --file-path "$REPOSITORY"
        --step-name "$STEP_NAME"
        --delimiter "$TASK_DELIMITER"
        --method "Import"
        --target "ManagerTask"
        --target-file "$WORKING_DIRECTORY/data/Multiplication-tasks.json"
`
result = run(importCmd)


# Query state
summarizeCmd = `
    $BIN_DIR/bin/tasktide \
        manager \
          --repository-type "$REPOSITORY_TYPE" \
          --file-path "$REPOSITORY" \
          --step-name "$STEP_NAME" \
          --method "Summarize" \
          --target "WORKITEM"
`
result = run(summarizeCmd)

'''
2026-06-24 08:47:31 INFO  [ main -> org.tasktide.tasktide.client.TaskTideManagerClient.performClientTask ]: Displaying results: '{
    "State Summary": {
        "FOR_UNLOCK": 0,
        "TODO": 28,
        "ERROR": 0,
        "LOCKED": 2,
        "DONE": 2
    }
}'
2026-06-24 08:47:31 INFO  [ main -> org.tasktide.tasktide.TaskTide.main ]: TaskTideClient completed, tearing down container
'

'''


# Gather and summarize results:     5040.0
resultFiles = [
    joinpath(root, file)
    for (root, dirs, files) in walkdir("$WORKING_DIRECTORY/data/results")
        for file in files
]

results =  [
    let result = parse(Float64, strip(read(file, String)))
        Dict(
            "Result" => result,
            "File" => file
        )
    end
    for file in resultFiles
]

FunctionRunner.Utils.writeJson("result", results, "$WORKING_DIRECTORY/data")
sum( [ elm["Result"] for elm in results ] )



'''
32-element Vector{String}:
 "./data/results/Multiplication-11.txt"
 "./data/results/Multiplication-17.txt"
 "./data/results/Multiplication-20.txt"
 "./data/results/Multiplication-22.txt"
 .
 .
 .

32-element Vector{Dict{String, Any}}:
 Dict("Result" => 121.0, "File" => "./data/results/Multiplication-0.txt")
 Dict("Result" => 136.0, "File" => "./data/results/Multiplication-1.txt")
 Dict("Result" => 228.0, "File" => "./data/results/Multiplication-10.txt")
 Dict("Result" => 252.0, "File" => "./data/results/Multiplication-11.txt")
 Dict("Result" => 39.0, "File" => "./data/results/Multiplication-12.txt")


Tasks written to:       './data/result-tasks.json'

5040.0


```