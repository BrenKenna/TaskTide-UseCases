# TaskTide Task Binding Use Case: FunctionRunner.jl

`FunctionRunner` is a structured Julia computation package engineered for low-overhead, daemon-less execution of mathematical functions and arbitrary script bindings orchestrated by TaskTide.

This package provides a concrete model for running compiled, performance-critical scientific workflows across High-Performance Computing (HPC) environments and Edge grids.

---

## 📊 Scientific Workflow Orchestration
In academic and research computing pipelines, executing isolated subroutines efficiently without cluster configuration bloat is critical. `FunctionRunner` hooks into TaskTide's native Pilot Job execution model, enabling tasks to scale from low-resource edge sensors up to heavy data grid infrastructures while preserving environment reproducible state via Julia's tracking files.

* **Core Framework:** Powered by the [TaskTide Workflow Engine](https://tasktide.org).
* **Reference System:** Review deployment schemas via the [TaskTide Documentation](https://docs.tasktide.org/).

---

## 🚀 Installation & Setup

### Prerequisites
* [Julia 1.9+](https://julialang.org) installed and accessible on your system `PATH`.

### Environment Initialization
Navigate to this directory and instantiate the package dependencies from the explicit lockfiles (`Project.toml` and `Manifest.toml`):

```bash
julia --project=. -e 'using Pkg; Pkg.instantiate()'
```

---

## 💻 Running the Program

### Executing a Task Script Locally
You can run the underlying processing engine or individual mathematical subroutines via the project environment:
```bash
julia --project=. src/FunctionRunner.jl
```

### Triggering via TaskTide Runtime Engine
To register and monitor this Julia pipeline execution runtime directly through the TaskTide daemon-less infrastructure:

Register ***FunctionRunner*** workflow with a ***EarlyTaskBinding*** step to for enacting the serialized function and parameters.

```bash
# Register workflow
tasktide \
    manager \
        --repository-type "nosql" \
        --nosql-database-type "document" \
        --method "Add" \
        --step-name "EarlyTaskBinding" \
        --workflow-name "FunctionRunner" \
        --target "STEP"
```

Starts TaskTide-Engine as a service scanning for work on the registered workflow step

```bash
# Load variables etc
. helper-scripts/start.sh
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
```


Start julia session as pass computational work to engine instances scanning for these work.

```bash
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
```


In this case doing math, and includes standardized operations for checking on the progress of these tasks. Before aggregating these results for the required context. Must be noted that Spark-Hadoop is superior technology for this, merely demonstrative.

```julia
# Within the above session
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


# Reduce the individual multiplations with a summation
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
'''

```


---

## 🔗 Resources
* **TaskTide Platform:** [TaskTide Home](https://tasktide.org)
* **Main Infrastructure:** [BrenKenna/TaskTide GitHub](https://github.tasktide.org)
