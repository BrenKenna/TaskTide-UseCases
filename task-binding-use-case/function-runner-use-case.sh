#!/bin/bash

#####################################################
#####################################################
## 
## 1). Setup Env
##
##   -> Can see two Spark stages
##   -> Order is screwy atm even after arrange
## 
#####################################################
#####################################################

# Load variables etc
. ~/interactive.sh
. ~/start.sh
. ~/conda-env.sh

conda activate singularity_env


# Working directory
export FUNC_DIR="$DATA_DIR/function-runner"
mkdir -p $DATA_DIR/function-runner && cd $FUNC_DIR
mkdir -p ItemStoreRepository/ data/


#
# Start task tide engine
#  - RocksDB error when multi-threaded
#  - Service requires restart to process new work
#       but it is seen
#  - Each thread looping through same list, instead of chunk?
# 
tasktide \
  engine \
  --repository-type "sqlite" \
  --file-path "/scratch/bkenna/function-runner/ItemStoreRepository/sqlite" \
  --target "WORKITEM" \
  --step-name "FunctionRunner" \
  --execution-policy "service" \
  --work-item-threads 8


'''

  _____         _      _____ _     _      
 |_   _|_ _ ___| | __ |_   _(_) __| | ___ 
   | |/ _` / __| |/ /   | | | |/ _` |/ _ \
   | | (_| \__ \   <    | | | | (_| |  __/
   |_|\__,_|___/_|\_\   |_| |_|\__,_|\___|

TaskTide-v0.9.0
_________________________________________________

2025-10-24 15:19:47 INFO  [ main -> org.tasktide.tasktide.TaskTide.main ]: Configuring the CDI Container Provider
2025-10-24 15:19:47 INFO  [ main -> org.tasktide.tasktide.client.TaskTideClientUtility.configureCdiInstance ]: Starting 'Weld' container



2025-10-24 15:20:58 INFO  [ main -> org.tasktide.tasktide.client.TaskTideEngineClient.fetchAndRun ]: Processing complete for step:      'FunctionRunner'
2025-10-24 15:21:02 INFO  [ main -> org.tasktide.tasktide.client.TaskTideEngineClient.fetchAndRun ]: Determing how to process workload
2025-10-24 15:21:02 INFO  [ main -> org.tasktide.tasktide.client.TaskTideEngineClient.fetchAndRun ]: Processing single step:    'FunctionRunner'
2025-10-24 15:21:02 INFO  [ main -> org.tasktide.tasktide.client.TaskTideEngineClient.fetchWorkload ]: No pilot label provided, processing all tasks
2025-10-24 15:21:02 WARN  [ main -> org.tasktide.tasktide.client.TaskTideEngineClient.processWorkload ]: Warning, no ToDo tasks available for processing. Query below backend for more information  

{Collection Name=WorkItem-Service, Model Class=WorkItem, Repository Type=Item Store}


2025-10-24 15:21:02 INFO  [ main -> org.tasktide.tasktide.client.TaskTideEngineClient.fetchAndRun ]: Processing complete for step:      'FunctionRunner'

...

2025-10-24 15:21:48 WARN  [ main -> org.tasktide.tasktide.client.TaskTideEngineClient.processWorkload ]: Warning, no ToDo tasks available for processing. Query below backend for more information

{Collection Name=WorkItem-Service, Model Class=WorkItem, Repository Type=Item Store}


2025-10-24 15:21:48 INFO  [ main -> org.tasktide.tasktide.client.TaskTideEngineClient.fetchAndRun ]: Processing complete for step:      'FunctionRunner'
2025-10-24 15:21:51 INFO  [ main -> org.tasktide.tasktide.client.TaskTideEngineClient.fetchAndRun ]: Determing how to process workload
2025-10-24 15:21:51 INFO  [ main -> org.tasktide.tasktide.client.TaskTideEngineClient.fetchAndRun ]: Processing single step:    'FunctionRunner'
2025-10-24 15:21:51 INFO  [ main -> org.tasktide.tasktide.client.TaskTideEngineClient.fetchWorkload ]: No pilot label provided, processing all tasks
2025-10-24 15:21:51 WARN  [ main -> org.tasktide.tasktide.client.TaskTideEngineClient.processWorkload ]: Warning, no ToDo tasks available for processing. Query below backend for more information  

{Collection Name=WorkItem-Service, Model Class=WorkItem, Repository Type=Item Store}


2025-10-24 15:21:51 INFO  [ main -> org.tasktide.tasktide.client.TaskTideEngineClient.fetchAndRun ]: Processing complete for step:      'FunctionRunner'
2025-10-24 15:21:59 INFO  [ main -> org.tasktide.tasktide.client.TaskTideEngineClient.fetchAndRun ]: Determing how to process workload
2025-10-24 15:21:59 INFO  [ main -> org.tasktide.tasktide.client.TaskTideEngineClient.fetchAndRun ]: Processing single step:    'FunctionRunner'
2025-10-24 15:21:59 INFO  [ main -> org.tasktide.tasktide.client.TaskTideEngineClient.fetchWorkload ]: No pilot label provided, processing all tasks
2025-10-24 15:21:59 INFO  [ main -> org.tasktide.tasktide.client.TaskTideEngineClient.processWorkload ]: Processing workload of size:   '60'
2025-10-24 15:21:59 INFO  [ main -> org.tasktide.engine.EngineUtility.waitOnExecutorTrackerWorkItem ]: Begining state monitoring of ExecutorServiceTracker:     N tasks = '0'
2025-10-24 15:21:59 INFO  [ main -> org.tasktide.engine.EngineUtility.waitOnExecutorTrackerWorkItem ]: Letting '10000'ms elapse for state monitoring of ExecutorServiceTracker: '0'
2025-10-24 15:22:09 INFO  [ main -> org.tasktide.engine.EngineUtility.waitOnExecutorTrackerWorkItem ]: Displaying Iter-'0' StateSummary of ExecutorServiceTracker:

Total='0', Remaining='0', Done='0', Expected='60'
2025-10-24 15:22:09 INFO  [ main -> org.tasktide.engine.EngineUtility.waitOnExecutorTrackerWorkItem ]: Letting '10000'ms elapse for state monitoring of ExecutorServiceTracker: '0'
2025-10-24 15:22:19 INFO  [ main -> org.tasktide.engine.EngineUtility.waitOnExecutorTrackerWorkItem ]: Displaying Iter-'1' StateSummary of ExecutorServiceTracker:

...

2025-10-24 15:23:33 INFO  [ main -> org.tasktide.engine.EngineUtility.waitOnExecutorTrackerWorkItem ]: Begining state monitoring of ExecutorServiceTracker:     N tasks = '60'
2025-10-24 15:23:33 INFO  [ main -> org.tasktide.engine.EngineUtility.waitOnExecutorTrackerWorkItem ]: Letting '10000'ms elapse for state monitoring of ExecutorServiceTracker: '60'
2025-10-24 15:23:33 INFO  [ pool-2-thread-1 -> org.tasktide.engine.worker.executor.TaskTideExecutor.runTasks ]: Begining workload processing of N = '1' tasks
2025-10-24 15:23:33 INFO  [ pool-2-thread-1 -> org.tasktide.engine.observer.worker.TimeKeeperObserver.evaluateStart ]: TimeKeeper evaluating starting of task 'WorkItem-0071d7de-1843-4e40-a99e-c7816d0fe877'
2025-10-24 15:23:33 INFO  [ pool-2-thread-1 -> org.tasktide.engine.observer.worker.TimeKeeperObserver.evaluateStart ]: Atomic TimeKeeper for task 'WorkItem-0071d7de-1843-4e40-a99e-c7816d0fe877' set on thread 'pool-2-thread-1'
2025-10-24 15:23:33 INFO  [ pool-2-thread-1 -> org.tasktide.engine.observer.worker.TimeKeeperObserver.onTaskStart ]: TimeKeeper evaluated time left for processing as 'true' for ItemTask:      'WorkItem-0071d7de-1843-4e40-a99e-c7816d0fe877'
2025-10-24 15:23:36 INFO  [ pool-2-thread-1 -> org.tasktide.engine.worker.executor.WorkItemExecutor.executeTask ]: Configuring ItemTaskProcessor for Workload of size '1' on thread 'pool-2-thread-1' for WorkItem: 'WorkItem-0071d7de-1843-4e40-a99e-c7816d0fe877'


--> SQLite fine after ~1min

2025-10-24 15:34:19 INFO  [ pool-2-thread-3 -> org.tasktide.engine.worker.executor.TaskTideExecutor.runTasks ]:

Workload processing complete, displaying summary:
Thread Total = '1', Thread Done = '0', Done = '36', Failed = '0', Skipped = '0'

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

REPOSITORY_TYPE = "sqlite"
WORKING_DIRECTORY = ENV["FUNC_DIR"]
REPOSITORY = "$WORKING_DIRECTORY/ItemStoreRepository/$REPOSITORY_TYPE"
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
params = FunctionRunner.Utils.randomNumbers(60, 3, 21)
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


'''

  _____         _      _____ _     _
 |_   _|_ _ ___| | __ |_   _(_) __| | ___
   | |/ _` / __| |/ /   | | | |/ _` |/ _ \
   | | (_| \__ \   <    | | | | (_| |  __/
   |_|\__,_|___/_|\_\   |_| |_|\__,_|\___|

TaskTide-v0.9.0
_________________________________________________

2025-10-24 14:21:51 INFO  [ main -> org.tasktide.tasktide.TaskTide.main ]: Configuring the CDI Container Provider
2025-10-24 14:21:51 INFO  [ main -> org.tasktide.tasktide.client.TaskTideClientUtility.configureCdiInstance ]: Starting 'Weld' container
Oct 24, 2025 2:21:51 PM org.eclipse.jnosql.mapping.Databases lambda$addDatabase$1
INFO: Found the type DOCUMENT to metadata DOCUMENT@
Oct 24, 2025 2:21:54 PM org.eclipse.jnosql.mapping.reflection.ClassGraphClassScanner <init>
INFO: The following repositories are not supported: []
Oct 24, 2025 2:21:54 PM org.eclipse.jnosql.mapping.document.spi.DocumentExtension onAfterBeanDiscovery
INFO: Processing Document extension: 1 databases crud 0 found, custom repositories: 0
Oct 24, 2025 2:21:54 PM org.eclipse.jnosql.mapping.document.spi.DocumentExtension onAfterBeanDiscovery
INFO: Processing repositories as a Document implementation: []
2025-10-24 14:21:54 INFO  [ main -> org.tasktide.tasktide.TaskTide.main ]: Fetching TaskTide configs
2025-10-24 14:21:54 INFO  [ main -> org.tasktide.tasktide.client.TaskTideClientUtility.fetchRepoType ]: Querying configured repo type:  'rocksdb'
2025-10-24 14:21:54 INFO  [ main -> org.tasktide.tasktide.TaskTide.main ]: Fetching the TaskTideServiceManager for 'Item Store' Repository
2025-10-24 14:21:54 INFO  [ main -> org.tasktide.tasktide.client.TaskTideClientUtility.initServiceManager ]: Configuring ItemStore ServiceManager
2025-10-24 14:21:54 INFO  [ main -> org.tasktide.core.repository.itemstore_repo.ItemStoreRepositoryUtility.fetchItemStoreMap ]: Prcessing ItemStore from under: '/scratch/bkenna/function-runner/ItemStoreRepository/rocksdb'
2025-10-24 14:21:55 INFO  [ main -> org.tasktide.tasktide.TaskTide.main ]: ServiceManager state is now: 'true'
2025-10-24 14:21:55 INFO  [ main -> org.tasktide.tasktide.TaskTide.main ]: Constructing client: 'Manager'
2025-10-24 14:21:55 INFO  [ main -> org.tasktide.tasktide.client.TaskTideManagerClient.performClientTask ]: Executing ManagerCommand:
'{
    "Command Spec": {
        "File Path": "/scratch/bkenna/function-runner/data/Multiplication-tasks.json",
        "Options": {
            "Item Id": "",
            "Delimiter": "JSON",
            "Step Name": "FunctionRunner",
            "Nested Delimiter": ""
        },
        "Query String": ""
    },
    "Command Type": "BATCH_CREATE",
    "Manager Action": "IMPORT",
    "Manager Target": "MANAGERTASK"
}'
2025-10-24 14:21:55 INFO  [ main -> org.tasktide.core.manager.command.commands.ImportCommand.importFile ]: Importing JSON file
2025-10-24 14:21:55 INFO  [ main -> org.tasktide.core.manager.command.commands.ImportCommand.importFile ]: Importing ManagerTask for WorkItem
2025-10-24 14:21:55 INFO  [ main -> org.tasktide.core.manager.command.commands.ImportCommand.importWorkItemFromManagerTaskJson ]: Attempting to read JSON file: '/scratch/bkenna/function-runner/data/Multiplication-tasks.json'
2025-10-24 14:21:55 INFO  [ main -> org.tasktide.core.manager.command.commands.ImportCommand.importWorkItemFromManagerTaskJson ]: Streaming JSON data into WorkItem list
2025-10-24 14:21:56 INFO  [ main -> org.tasktide.core.manager.command.commands.ImportCommand.importWorkItemFromManagerTaskJson ]: Streamed JSON data into WorkItem list
2025-10-24 14:21:56 INFO  [ main -> org.tasktide.tasktide.client.TaskTideManagerClient.performClientTask ]: Displaying results: 'true'
2025-10-24 14:21:56 INFO  [ main -> org.tasktide.tasktide.TaskTide.main ]: TaskTideClient completed, tearing down container
Process(`/home/people/bkenna/software/bin/tasktide manager --repository-type rocksdb --file-path /scratch/bkenna/function-runner/ItemStoreRepository/rocksdb --step-name FunctionRunner --delimiter JSON --method Import --target ManagerTask --target-file /scratch/bkenna/function-runner/data/Multiplication-tasks.json`, ProcessExited(0))

'

'''



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

  _____         _      _____ _     _      
 |_   _|_ _ ___| | __ |_   _(_) __| | ___ 
   | |/ _` / __| |/ /   | | | |/ _` |/ _ \
   | | (_| \__ \   <    | | | | (_| |  __/
   |_|\__,_|___/_|\_\   |_| |_|\__,_|\___|

TaskTide-v0.9.0
_________________________________________________

2025-10-24 14:24:54 INFO  [ main -> org.tasktide.tasktide.TaskTide.main ]: Configuring the CDI Container Provider
2025-10-24 14:24:54 INFO  [ main -> org.tasktide.tasktide.client.TaskTideClientUtility.configureCdiInstance ]: Starting 'Weld' container

Oct 24, 2025 2:24:54 PM org.eclipse.jnosql.mapping.Databases lambda$addDatabase$1
INFO: Found the type DOCUMENT to metadata DOCUMENT@
Oct 24, 2025 2:24:57 PM org.eclipse.jnosql.mapping.reflection.ClassGraphClassScanner <init>
INFO: The following repositories are not supported: []
Oct 24, 2025 2:24:57 PM org.eclipse.jnosql.mapping.document.spi.DocumentExtension onAfterBeanDiscovery
INFO: Processing Document extension: 1 databases crud 0 found, custom repositories: 0
Oct 24, 2025 2:24:57 PM org.eclipse.jnosql.mapping.document.spi.DocumentExtension onAfterBeanDiscovery
INFO: Processing repositories as a Document implementation: []
2025-10-24 14:24:57 INFO  [ main -> org.tasktide.tasktide.TaskTide.main ]: Fetching TaskTide configs
2025-10-24 14:24:57 INFO  [ main -> org.tasktide.tasktide.client.TaskTideClientUtility.fetchRepoType ]: Querying configured repo type:  'rocksdb'
2025-10-24 14:24:57 INFO  [ main -> org.tasktide.tasktide.TaskTide.main ]: Fetching the TaskTideServiceManager for 'Item Store' Repository
2025-10-24 14:24:57 INFO  [ main -> org.tasktide.tasktide.client.TaskTideClientUtility.initServiceManager ]: Configuring ItemStore ServiceManager
2025-10-24 14:24:57 INFO  [ main -> org.tasktide.core.repository.itemstore_repo.ItemStoreRepositoryUtility.fetchItemStoreMap ]: Prcessing ItemStore from under: '/scratch/bkenna/function-runner/ItemStoreRepository/rocksdb'
2025-10-24 14:24:58 INFO  [ main -> org.tasktide.tasktide.TaskTide.main ]: ServiceManager state is now: 'true'
2025-10-24 14:24:58 INFO  [ main -> org.tasktide.tasktide.TaskTide.main ]: Constructing client: 'Manager'
2025-10-24 14:24:58 INFO  [ main -> org.tasktide.tasktide.client.TaskTideManagerClient.performClientTask ]: Executing ManagerCommand:
'{
    "Command Spec": {
        "File Path": "",
        "Options": {
            "Item Id": "",
            "Delimiter": "|",
            "Step Name": "FunctionRunner",
            "Nested Delimiter": ""
        },
        "Query String": ""
    },
    "Command Type": "SELECT",
    "Manager Action": "SUMMARIZE",
    "Manager Target": "WORKITEM"
}'
2025-10-24 14:24:58 INFO  [ main -> org.tasktide.core.manager.command.commands.SummarizeCommand.runCommand ]: Summarizing collection
2025-10-24 14:24:58 INFO  [ main -> org.tasktide.core.manager.command.commands.SummarizeCommand.runCommand ]: Directing results to stdout
2025-10-24 14:24:58 INFO  [ main -> org.tasktide.tasktide.client.TaskTideManagerClient.performClientTask ]: Displaying results: '{
    "State Summary": {
        "ERROR": 0,
        "TODO": 53,
        "LOCKED": 1,
        "FOR_UNLOCK": 0,
        "DONE": 6
    }
}'
2025-10-24 14:24:58 INFO  [ main -> org.tasktide.tasktide.TaskTide.main ]: TaskTideClient completed, tearing down container
Process(`/home/people/bkenna/software/bin/tasktide manager --repository-type rocksdb --file-path /scratch/bkenna/function-runner/ItemStoreRepository/rocksdb --step-name FunctionRunner --method Summarize --target WORKITEM`, ProcessExited(0))

2025-10-24 14:36:02 INFO  [ main -> org.tasktide.tasktide.client.TaskTideManagerClient.performClientTask ]: Displaying results: '{
    "State Summary": {
        "TODO": 29,
        "LOCKED": 1,
        "ERROR": 0,
        "FOR_UNLOCK": 0,
        "DONE": 30
    }
}'

2025-10-24 14:40:37 INFO  [ main -> org.tasktide.tasktide.client.TaskTideManagerClient.performClientTask ]: Displaying results: '{
    "State Summary": {
        "DONE": 60,
        "ERROR": 0,
        "TODO": 0,
        "FOR_UNLOCK": 0,
        "LOCKED": 0
    }
}'

'

'''


# Gather list of files
resultFiles = [
    joinpath(root, file)
    for (root, dirs, files) in walkdir("$WORKING_DIRECTORY/data/results")
        for file in files
]

'''
60-element Vector{String}:
 "/scratch/bkenna/function-runner/data/results/Multiplication-11.txt"
 "/scratch/bkenna/function-runner/data/results/Multiplication-17.txt"
 "/scratch/bkenna/function-runner/data/results/Multiplication-20.txt"
 "/scratch/bkenna/function-runner/data/results/Multiplication-22.txt"
'''

# Aggregate into table
results =  [
    let result = parse(Float64, strip(read(file, String)))
        Dict(
            "Result" => result,
            "File" => file
        )
    end
    for file in resultFiles
]

'''
60-element Vector{Dict{String, Any}}:
 Dict("Result" => 315.0, "File" => "/scratch/bkenna/function-runner/data/results/Multiplication-0.txt")
 Dict("Result" => 120.0, "File" => "/scratch/bkenna/function-runner/data/results/Multiplication-1.txt")
 Dict("Result" => 180.0, "File" => "/scratch/bkenna/function-runner/data/results/Multiplication-10.txt")
 Dict("Result" => 160.0, "File" => "/scratch/bkenna/function-runner/data/results/Multiplication-11.txt")
 Dict("Result" => 200.0, "File" => "/scratch/bkenna/function-runner/data/results/Multiplication-12.txt")
 Dict("Result" => 32.0, "File" => "/scratch/bkenna/function-runner/data/results/Multiplication-13.txt")
 Dict("Result" => 65.0, "File" => "/scratch/bkenna/function-runner/data/results/Multiplication-14.txt")

'''


# Sink to file
FunctionRunner.Utils.writeJson("result", results, "$WORKING_DIRECTORY/data")
sum( [ elm["Result"] for elm in results ] )


"""
Tasks written to:       '/scratch/bkenna/function-runner/data/result-tasks.json'
9651.0

"""


```