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
  --work-item-threads 8 \
  --item-task-threads 8

# 32 for task execution, but 81 for TimeKeeper starting
grep "2026" logs/tasktide/TaskTide.log | grep "Successful execution of task"  | cut -d \: -f 5- | sort | uniq | wc -l
grep "2026" logs/tasktide/TaskTide.log | \
    grep "org.tasktide.engine.observer.worker.TimeKeeperObserver.evaluateStart" | \
    grep "TimeKeeper evaluating starting of task" | grep -c "WorkItem"

grep "2026" logs/tasktide/TaskTide.log | \
    grep "org.tasktide.engine.observer.worker.TimeKeeperObserver.evaluateStart" | \
    grep "TimeKeeper evaluating starting of task" | \
    awk '{ print $NF }' | sort | grep "WorkItem" | sort | \
    uniq | wc -l


'''
32 executions occured for 32 tasks
81 TimeKeeper evaluateStart occured
    49 from WorkItem, collections disributed twice
        -> For WorkItem-fc07559b-ae9b-4514-82e2-8b764e576906
        -> pool-2-thread-5 locked and processed
        -> pool-2-thread-4 tried, but verification showed no open tasks
        -> The main thread fetches the workload, then splits its list
        -> 32 were distributed, 17 were duplicated.
        -> Problem lies in chunking method
    32 from ItemTask

  _____         _      _____ _     _      
 |_   _|_ _ ___| | __ |_   _(_) __| | ___ 
   | |/ _` / __| |/ /   | | | |/ _` |/ _ \
   | | (_| \__ \   <    | | | | (_| |  __/
   |_|\__,_|___/_|\_\   |_| |_|\__,_|\___|

TaskTide-v0.9.5
_________________________________________________

2026-02-18 14:20:01 INFO  [ main -> org.tasktide.tasktide.TaskTide.main ]: Configuring the CDI Container Provider
2026-02-18 14:20:01 INFO  [ main -> org.tasktide.tasktide.client.TaskTideClientUtility.configureCdiInstance ]: Starting 'Weld' container

2026-02-18 14:20:27 INFO  [ main -> org.tasktide.tasktide.client.TaskTideEngineClient.fetchAndRun ]: Processing complete for step:      'FunctionRunner'
2026-02-18 14:20:27 INFO  [ main -> org.tasktide.tasktide.client.TaskTideEngineClient.fetchAndRun ]: Determing how to process workload
2026-02-18 14:20:27 INFO  [ main -> org.tasktide.tasktide.client.TaskTideEngineClient.fetchAndRun ]: Processing single step:    'FunctionRunner'       
2026-02-18 14:20:27 INFO  [ main -> org.tasktide.tasktide.client.TaskTideEngineClient.fetchWorkload ]: No pilot label provided, processing all tasks   
2026-02-18 14:20:31 WARN  [ main -> org.tasktide.tasktide.client.TaskTideEngineClient.processWorkload ]: Warning, no ToDo tasks available for processing. Query below backend for more information

{Collection Name=WorkItem-Service, Model Class=WorkItem, Repository Type=Item Store}

2026-02-18 14:20:31 INFO  [ main -> org.tasktide.tasktide.client.TaskTideEngineClient.fetchAndRun ]: Processing complete for step:      'FunctionRunner'

2026-02-18 14:26:18 INFO  [ main -> org.tasktide.tasktide.client.TaskTideEngineClient.processWorkload ]: Processing workload of size:   '32'
2026-02-18 14:26:18 INFO  [ main -> org.tasktide.engine.worker.processor.TaskTideProcessor.processChunks ]: Shuffling, and grouping workload for ExecutorService for ProcessorType:      'WorkItemProcessor'
2026-02-18 14:26:18 INFO  [ main -> org.tasktide.engine.worker.processor.WorkItemProcessor.parallelChunks ]: Fetching N = '8' batches of size '4' for WorkItem workload
2026-02-18 14:26:18 INFO  [ main -> org.tasktide.engine.worker.processor.TaskTideProcessor.processChunks ]: Submitting 'WorkItemProcessor' workload of size:    '8'

2026-02-18 14:27:01 INFO  [ pool-3-thread-1 -> org.tasktide.engine.worker.executor.ItemTaskExecutor.executeTask ]: Executing task on thread 'pool-3-thread-1':bash /home/people/bkenna/software/bin/singularity-runner.sh --debug "/opt/julia/src/FunctionRunner.jl" --operation="N0pMHgQAAAA5IaJmdW5jdGlvbiBteVNlcmRlRnVuYyhwYXJhbXMuLi47IFBhcnNlVG9UeXBlOjpUeXBlPUludCkKICAgIHBhcnNlZCA9IG1hcCgKICAgICAgICBlbG0gLT4gcGFyc2UoUGFyc2VUb1R5cGUsIGVsbSksCiAgICAgICAgcGFyYW1zCiAgICApCiAgICByZXR1cm4gcHJvZChwYXJzZWQpCmVuZAo=" --parameters="N0pMHgQAAAAhAzggNQ==" --output="/scratch/bkenna/function-runner/data/results/Multiplication-11.txt"

2026-02-18 14:28:14 INFO  [ pool-3-thread-3 -> org.tasktide.engine.worker.executor.ItemTaskExecutor.executeTask ]: Executing task on thread 'pool-3-thread-3':bash /home/people/bkenna/software/bin/singularity-runner.sh --debug "/opt/julia/src/FunctionRunner.jl" --operation="N0pMHgQAAAA5IaJmdW5jdGlvbiBteVNlcmRlRnVuYyhwYXJhbXMuLi47IFBhcnNlVG9UeXBlOjpUeXBlPUludCkKICAgIHBhcnNlZCA9IG1hcCgKICAgICAgICBlbG0gLT4gcGFyc2UoUGFyc2VUb1R5cGUsIGVsbSksCiAgICAgICAgcGFyYW1zCiAgICApCiAgICByZXR1cm4gcHJvZChwYXJzZWQpCmVuZAo=" --parameters="N0pMHgQAAAAhBDE0IDQ=" --output="/scratch/bkenna/function-runner/data/results/Multiplication-17.txt"

2026-02-18 14:31:34 INFO  [ pool-3-thread-7 -> org.tasktide.engine.worker.executor.ProcessExecutor.execute ]: Successful execution of task:     bash /home/people/bkenna/software/bin/singularity-runner.sh --debug "/opt/julia/src/FunctionRunner.jl" --operation="N0pMHgQAAAA5IaJmdW5jdGlvbiBteVNlcmRlRnVuYyhwYXJhbXMuLi47IFBhcnNlVG9UeXBlOjpUeXBlPUludCkKICAgIHBhcnNlZCA9IG1hcCgKICAgICAgICBlbG0gLT4gcGFyc2UoUGFyc2VUb1R5cGUsIGVsbSksCiAgICAgICAgcGFyYW1zCiAgICApCiAgICByZXR1cm4gcHJvZChwYXJzZWQpCmVuZAo=" --parameters="N0pMHgQAAAAhBDE4IDk=" --output="/scratch/bkenna/function-runner/data/results/Multiplication-27.txt"
2026-02-18 14:31:34 INFO  [ pool-3-thread-7 -> org.tasktide.engine.worker.executor.ItemTaskExecutor.executeTask ]: Task 'Multiplication' successful on thread 'pool-3-thread-7' with exit code 0

2026-02-18 14:31:34 ERROR [ pool-3-thread-7 -> org.tasktide.engine.worker.executor.ItemTaskExecutor.executeTask ]: Error applying results annotation, displaying stack trace:    'Cannot invoke "java.util.Map.get(Object)" because "this.anno" is null'
java.lang.NullPointerException: Cannot invoke "java.util.Map.get(Object)" because "this.anno" is null
        at org.tasktide.core.model.CustomAnnotation.getKey(CustomAnnotation.java:104)
        at org.tasktide.core.model.CustomAnnotation.hasKey(CustomAnnotation.java:115)
        at org.tasktide.engine.worker.executor.ItemTaskExecutor.annotateResults(ItemTaskExecutor.java:124)
        at org.tasktide.engine.worker.executor.ItemTaskExecutor.executeTask(ItemTaskExecutor.java:89)
        at org.tasktide.engine.worker.executor.ItemTaskExecutor.executeTask(ItemTaskExecutor.java:42)
        at org.tasktide.engine.worker.executor.TaskTideExecutor.runTasks(TaskTideExecutor.java:81)
        at org.tasktide.engine.worker.processor.TaskTideProcessor.process(TaskTideProcessor.java:98)
        at org.tasktide.engine.worker.processor.TaskTideProcessor.lambda$submitSubTask$0(TaskTideProcessor.java:136)
        at java.base/java.util.concurrent.Executors$RunnableAdapter.call(Executors.java:539)
        at java.base/java.util.concurrent.FutureTask.run(FutureTask.java:264)
        at java.base/java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1136)
        at java.base/java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:635)
        at java.base/java.lang.Thread.run(Thread.java:840)

2026-02-18 14:31:34 INFO  [ pool-3-thread-7 -> org.tasktide.engine.worker.executor.TaskTideExecutor.runTasks ]: Completed task 'ItemTask-00bd91b4-7117-46ba-9deb-0cc7eb591c36', global count: 13


2026-02-18 14:30:51 INFO  [ pool-2-thread-5 -> org.tasktide.engine.observer.worker.TimeKeeperObserver.evaluateStart ]: TimeKeeper evaluating starting of task 'WorkItem-fc07559b-ae9b-4514-82e2-8b764e576906'
2026-02-18 14:30:51 INFO  [ pool-2-thread-5 -> org.tasktide.engine.observer.worker.TimeKeeperObserver.evaluateStart ]: Atomic TimeKeeper for task 'WorkItem-fc07559b-ae9b-4514-82e2-8b764e576906' set on thread 'pool-2-thread-5'
2026-02-18 14:30:51 INFO  [ pool-2-thread-5 -> org.tasktide.engine.observer.worker.TimeKeeperObserver.onTaskStart ]: TimeKeeper evaluated time left for processing as 'true' for ItemTask:       'WorkItem-fc07559b-ae9b-4514-82e2-8b764e576906'
2026-02-18 14:35:18 INFO  [ pool-2-thread-5 -> org.tasktide.engine.worker.executor.WorkItemExecutor.executeTask ]: Configuring ItemTaskProcessor for Workload of size '1' on thread 'pool-2-thread-5' for WorkItem:      'WorkItem-fc07559b-ae9b-4514-82e2-8b764e576906'
2026-02-18 14:35:18 INFO  [ pool-2-thread-5 -> org.tasktide.engine.worker.executor.WorkItemExecutor.executeTask ]: Processor configured, processing workload for WorkItem:       'WorkItem-fc07559b-ae9b-4514-82e2-8b764e576906'
2026-02-18 14:35:18 INFO  [ pool-2-thread-5 -> org.tasktide.engine.worker.executor.WorkItemExecutor.executeTask ]: ExecutorObserver polling ItemTaskStateSummary for WorkItem:   'WorkItem-fc07559b-ae9b-4514-82e2-8b764e576906'
2026-02-18 14:35:18 INFO  [ pool-2-thread-5 -> org.tasktide.engine.observer.worker.executor.WorkItemExecutorObserver.pollUntilDone ]: Begining state monitoring of WorkItem:     'WorkItem-fc07559b-ae9b-4514-82e2-8b764e576906'
2026-02-18 14:35:18 INFO  [ pool-2-thread-5 -> org.tasktide.engine.observer.worker.executor.WorkItemExecutorObserver.pollUntilDone ]: Letting '10000'ms elapse for state monitoring of WorkItem: 'WorkItem-fc07559b-ae9b-4514-82e2-8b764e576906'
2026-02-18 14:35:28 INFO  [ pool-2-thread-5 -> org.tasktide.engine.observer.worker.executor.WorkItemExecutorObserver.pollUntilDone ]: Displaying Iter-'0' StateSummary of WorkItem:      'WorkItem-fc07559b-ae9b-4514-82e2-8b764e576906'
2026-02-18 14:35:28 INFO  [ pool-2-thread-5 -> org.tasktide.engine.observer.worker.executor.WorkItemExecutorObserver.pollUntilDone ]: Letting '10000'ms elapse for state monitoring of WorkItem: 'WorkItem-fc07559b-ae9b-4514-82e2-8b764e576906'
2026-02-18 14:35:38 INFO  [ pool-2-thread-5 -> org.tasktide.engine.observer.worker.executor.WorkItemExecutorObserver.pollUntilDone ]: Displaying Iter-'1' StateSummary of WorkItem:      'WorkItem-fc07559b-ae9b-4514-82e2-8b764e576906'
2026-02-18 14:35:38 INFO  [ pool-2-thread-5 -> org.tasktide.engine.observer.worker.executor.WorkItemExecutorObserver.pollUntilDone ]: Letting '10000'ms elapse for state monitoring of WorkItem: 'WorkItem-fc07559b-ae9b-4514-82e2-8b764e576906'
2026-02-18 14:35:48 INFO  [ pool-2-thread-5 -> org.tasktide.engine.observer.worker.executor.WorkItemExecutorObserver.pollUntilDone ]: Displaying Iter-'2' StateSummary of WorkItem:      'WorkItem-fc07559b-ae9b-4514-82e2-8b764e576906'
2026-02-18 14:35:48 INFO  [ pool-2-thread-5 -> org.tasktide.engine.observer.worker.executor.WorkItemExecutorObserver.pollUntilDone ]: Letting '10000'ms elapse for state monitoring of WorkItem: 'WorkItem-fc07559b-ae9b-4514-82e2-8b764e576906'
2026-02-18 14:35:58 INFO  [ pool-2-thread-5 -> org.tasktide.engine.observer.worker.executor.WorkItemExecutorObserver.pollUntilDone ]: Displaying Iter-'3' StateSummary of WorkItem:      'WorkItem-fc07559b-ae9b-4514-82e2-8b764e576906'
2026-02-18 14:35:58 INFO  [ pool-2-thread-5 -> org.tasktide.engine.observer.worker.executor.WorkItemExecutorObserver.pollUntilDone ]: Letting '8000'ms elapse for state monitoring of WorkItem:  'WorkItem-fc07559b-ae9b-4514-82e2-8b764e576906'
2026-02-18 14:36:06 INFO  [ pool-2-thread-5 -> org.tasktide.engine.observer.worker.executor.WorkItemExecutorObserver.pollUntilDone ]: Displaying Iter-'4' StateSummary of WorkItem:      'WorkItem-fc07559b-ae9b-4514-82e2-8b764e576906'
2026-02-18 14:36:06 INFO  [ pool-2-thread-5 -> org.tasktide.engine.observer.worker.executor.WorkItemExecutorObserver.pollUntilDone ]: Letting '16000'ms elapse for state monitoring of WorkItem: 'WorkItem-fc07559b-ae9b-4514-82e2-8b764e576906'
2026-02-18 14:36:22 INFO  [ pool-2-thread-5 -> org.tasktide.engine.observer.worker.executor.WorkItemExecutorObserver.pollUntilDone ]: Displaying Iter-'5' StateSummary of WorkItem:      'WorkItem-fc07559b-ae9b-4514-82e2-8b764e576906'
2026-02-18 14:36:22 INFO  [ pool-2-thread-5 -> org.tasktide.engine.observer.worker.executor.WorkItemExecutorObserver.pollUntilDone ]: Letting '32000'ms elapse for state monitoring of WorkItem: 'WorkItem-fc07559b-ae9b-4514-82e2-8b764e576906'
2026-02-18 14:36:54 INFO  [ pool-2-thread-5 -> org.tasktide.engine.observer.worker.executor.WorkItemExecutorObserver.pollUntilDone ]: Displaying Iter-'6' StateSummary of WorkItem:      'WorkItem-fc07559b-ae9b-4514-82e2-8b764e576906'
2026-02-18 14:36:54 INFO  [ pool-2-thread-5 -> org.tasktide.engine.worker.executor.WorkItemExecutor.executeTask ]: Task processing complete on WorkItem:        WorkItem-fc07559b-ae9b-4514-82e2-8b764e576906'
2026-02-18 14:36:54 INFO  [ pool-2-thread-5 -> org.tasktide.engine.worker.executor.TaskTideExecutor.runTasks ]: Completed task 'WorkItem-fc07559b-ae9b-4514-82e2-8b764e576906', global count: 18
2026-02-18 14:36:54 INFO  [ pool-2-thread-5 -> org.tasktide.engine.observer.worker.TimeKeeperObserver.onTaskEnd ]: Measuring the elapsed time of task 'WorkItem-fc07559b-ae9b-4514-82e2-8b764e576906',
2026-02-18 14:36:54 INFO  [ pool-2-thread-5 -> org.tasktide.engine.observer.worker.TimeKeeperObserver.onTaskEnd ]: Task 'WorkItem-fc07559b-ae9b-4514-82e2-8b764e576906' completed in 363280ms
2026-02-18 14:36:54 INFO  [ pool-2-thread-5 -> org.tasktide.engine.observer.worker.TimeKeeperObserver.onTaskEnd ]: TimeKeeper evaluated time left next 'false' with ItemTask:    'WorkItem-fc07559b-ae9b-4514-82e2-8b764e576906'
2026-02-18 14:38:35 INFO  [ pool-2-thread-5 -> org.tasktide.engine.observer.worker.executor.WorkItemExecutorObserver.onTaskEnd ]: Unlocked N = '0' sub tasks for WorkItem:       'WorkItem-fc07559b-ae9b-4514-82e2-8b764e576906'
2026-02-18 15:05:17 INFO  [ pool-2-thread-4 -> org.tasktide.engine.observer.worker.TimeKeeperObserver.evaluateStart ]: TimeKeeper evaluating starting of task 'WorkItem-fc07559b-ae9b-4514-82e2-8b764e576906'
2026-02-18 15:05:17 INFO  [ pool-2-thread-4 -> org.tasktide.engine.observer.worker.TimeKeeperObserver.evaluateStart ]: Atomic TimeKeeper for task 'WorkItem-fc07559b-ae9b-4514-82e2-8b764e576906' set on thread 'pool-2-thread-4'
2026-02-18 15:05:17 INFO  [ pool-2-thread-4 -> org.tasktide.engine.observer.worker.TimeKeeperObserver.onTaskStart ]: TimeKeeper evaluated time left for processing as 'true' for ItemTask:       'WorkItem-fc07559b-ae9b-4514-82e2-8b764e576906'
2026-02-18 15:07:13 WARN  [ pool-2-thread-4 -> org.tasktide.engine.observer.worker.executor.WorkItemExecutorObserver.onTaskStart ]: Warning, no open tasks detected for WorkItem:        'WorkItem-fc07559b-ae9b-4514-82e2-8b764e576906'
2026-02-18 15:07:13 WARN  [ pool-2-thread-4 -> org.tasktide.engine.observer.ObserverChain.onTaskStart ]: Task 'WorkItem-fc07559b-ae9b-4514-82e2-8b764e576906' failed onTaskStart Observation 'WorkItemExecutorObserver' check
2026-02-18 15:07:13 WARN  [ pool-2-thread-4 -> org.tasktide.engine.worker.executor.TaskTideExecutor.runTasks ]: Warning, skipping task failing Observer Preprocessing checks for task:   'WorkItem-fc07559b-ae9b-4514-82e2-8b764e576906'
'

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


'''


  _____         _      _____ _     _
 |_   _|_ _ ___| | __ |_   _(_) __| | ___
   | |/ _` / __| |/ /   | | | |/ _` |/ _ \
   | | (_| \__ \   <    | | | | (_| |  __/
   |_|\__,_|___/_|\_\   |_| |_|\__,_|\___|

TaskTide-v0.9.0
_________________________________________________
'

2026-02-18 14:24:02 INFO  [ main -> org.tasktide.tasktide.TaskTide.main ]: Configuring the CDI Container Provider
2026-02-18 14:24:02 INFO  [ main -> org.tasktide.tasktide.client.TaskTideClientUtility.configureCdiInstance ]: Starting 'Weld' container
Feb 18, 2026 2:24:02 PM org.eclipse.jnosql.mapping.Databases lambda$addDatabase$1
INFO: Found the type DOCUMENT to metadata DOCUMENT@
Feb 18, 2026 2:24:05 PM org.eclipse.jnosql.mapping.reflection.ClassGraphClassScanner <init>
INFO: The following repositories are not supported: []
Feb 18, 2026 2:24:06 PM org.eclipse.jnosql.mapping.document.spi.DocumentExtension onAfterBeanDiscovery
INFO: Processing Document extension: 1 databases crud 0 found, custom repositories: 0
Feb 18, 2026 2:24:06 PM org.eclipse.jnosql.mapping.document.spi.DocumentExtension onAfterBeanDiscovery
INFO: Processing repositories as a Document implementation: []
2026-02-18 14:24:06 INFO  [ main -> org.tasktide.tasktide.TaskTide.main ]: Fetching TaskTide configs
2026-02-18 14:24:06 INFO  [ main -> org.tasktide.tasktide.client.TaskTideClientUtility.fetchRepoType ]: Querying configured repo type:  'sqlite'
2026-02-18 14:24:06 INFO  [ main -> org.tasktide.tasktide.TaskTide.main ]: Fetching the TaskTideServiceManager for 'Item Store' Repository
2026-02-18 14:24:06 INFO  [ main -> org.tasktide.tasktide.client.TaskTideClientUtility.initServiceManager ]: Configuring ItemStore ServiceManager
2026-02-18 14:24:06 INFO  [ main -> org.tasktide.core.repository.itemstore_repo.ItemStoreRepositoryUtility.fetchItemStoreMap ]: Prcessing ItemStore from under: '/scratch/bkenna/function-runner/ItemStoreRepository/sqlite'
2026-02-18 14:24:06 INFO  [ main -> org.tasktide.itemstore.SqliteStore.initItemStore ]: Initializing DB
2026-02-18 14:24:06 INFO  [ main -> org.tasktide.itemstore.AbstractItemStore.waitForMutex ]: Acquiring mutex
2026-02-18 14:24:10 INFO  [ main -> org.tasktide.itemstore.AbstractItemStore.waitForMutex ]: Mutex acquired
SLF4J(W): No SLF4J providers were found.
SLF4J(W): Defaulting to no-operation (NOP) logger implementation
SLF4J(W): See https://www.slf4j.org/codes.html#noProviders for further details.
2026-02-18 14:24:11 INFO  [ main -> org.tasktide.itemstore.AbstractItemStore.releaseMutex ]: Releasing mutex
2026-02-18 14:24:11 INFO  [ main -> org.tasktide.itemstore.AbstractItemStore.releaseMutex ]: Released mutex
2026-02-18 14:24:11 WARN  [ main -> org.tasktide.itemstore.AbstractItemStore.<init> ]: Mutex already configured
2026-02-18 14:24:11 INFO  [ main -> org.tasktide.itemstore.SqliteStore.initItemStore ]: Initializing DB under active mutex
2026-02-18 14:24:11 WARN  [ main -> org.tasktide.itemstore.AbstractItemStore.<init> ]: Mutex already configured
2026-02-18 14:24:11 INFO  [ main -> org.tasktide.itemstore.SqliteStore.initItemStore ]: Initializing DB under active mutex
2026-02-18 14:24:11 WARN  [ main -> org.tasktide.itemstore.AbstractItemStore.<init> ]: Mutex already configured
2026-02-18 14:24:11 INFO  [ main -> org.tasktide.itemstore.SqliteStore.initItemStore ]: Initializing DB under active mutex
2026-02-18 14:24:11 WARN  [ main -> org.tasktide.itemstore.AbstractItemStore.<init> ]: Mutex already configured
2026-02-18 14:24:11 INFO  [ main -> org.tasktide.itemstore.SqliteStore.initItemStore ]: Initializing DB under active mutex
2026-02-18 14:24:11 WARN  [ main -> org.tasktide.itemstore.AbstractItemStore.<init> ]: Mutex already configured
2026-02-18 14:24:11 INFO  [ main -> org.tasktide.itemstore.SqliteStore.initItemStore ]: Initializing DB under active mutex
2026-02-18 14:24:11 INFO  [ main -> org.tasktide.itemstore.AbstractItemStore.releaseMutex ]: Releasing mutex
2026-02-18 14:24:11 INFO  [ main -> org.tasktide.itemstore.AbstractItemStore.releaseMutex ]: Released mutex
2026-02-18 14:24:11 INFO  [ main -> org.tasktide.tasktide.TaskTide.main ]: ServiceManager state is now: 'true'
2026-02-18 14:24:11 INFO  [ main -> org.tasktide.tasktide.TaskTide.main ]: Constructing client: 'Manager'
2026-02-18 14:24:11 INFO  [ main -> org.tasktide.tasktide.client.TaskTideManagerClient.performClientTask ]: Executing ManagerCommand:
'{
    "Command Spec": {
        "File Path": "/scratch/bkenna/function-runner/data/Multiplication-tasks.json",
        "Options": {
            "Item Id": "",
            "Delimiter": "JSON",
            "Step Name": "FunctionRunner",
            "Nested Delimiter": "\",\""
        },
        "Query String": "\"\""
    },
    "Command Type": "BATCH_CREATE",
    "Manager Action": "IMPORT",
    "Manager Target": "MANAGERTASK"
}'
2026-02-18 14:24:11 INFO  [ main -> org.tasktide.core.manager.command.commands.ImportCommand.importFile ]: Importing JSON file
2026-02-18 14:24:11 INFO  [ main -> org.tasktide.core.manager.command.commands.ImportCommand.importFile ]: Importing ManagerTask for WorkItem
2026-02-18 14:24:11 INFO  [ main -> org.tasktide.core.manager.command.commands.ImportCommand.importWorkItemFromManagerTaskJson ]: Attempting to read JSON file: '/scratch/bkenna/function-runner/data/Multiplication-tasks.json'
2026-02-18 14:24:11 INFO  [ main -> org.tasktide.core.manager.command.commands.ImportCommand.importWorkItemFromManagerTaskJson ]: Streaming JSON data into WorkItem list
2026-02-18 14:24:11 INFO  [ main -> org.tasktide.itemstore.AbstractItemStore.waitForMutex ]: Acquiring mutex
2026-02-18 14:24:13 INFO  [ main -> org.tasktide.itemstore.AbstractItemStore.waitForMutex ]: Mutex acquired
2026-02-18 14:24:13 INFO  [ main -> org.tasktide.itemstore.AbstractItemStore.releaseMutex ]: Releasing mutex
2026-02-18 14:24:13 INFO  [ main -> org.tasktide.itemstore.AbstractItemStore.releaseMutex ]: Released mutex
2026-02-18 14:24:13 INFO  [ main -> org.tasktide.core.manager.TaskTideManagerUtility.fetchStepId ]: No step detected, begining creation for:
'FunctionRunner'
2026-02-18 14:24:13 INFO  [ main -> org.tasktide.core.manager.TaskTideManagerUtility.handleWorkflowForStep ]: No workflow assigned to step, proceeding with StepName:
'{
    "StepCount": 0,
    "StepId": "Step-0093c5db-a3ae-4982-83d7-42ee8a2a1675",
    "StepName": "FunctionRunner",
    "StepState": "PENDING",
    "StepsDone": 0,
    "StepsError": 0,
    "StepsLocked": 0,
    "StepsToDo": 0,
    "annotations": {
        "Annotations": {
        },
        "id": "CustomAnnotation-3d400f64-8ad7-437a-9c5e-2b7fa6a1be35"
    }
}'
2026-02-18 14:24:13 INFO  [ main -> org.tasktide.itemstore.AbstractItemStore.waitForMutex ]: Acquiring mutex
2026-02-18 14:24:16 INFO  [ main -> org.tasktide.itemstore.AbstractItemStore.waitForMutex ]: Mutex acquired
2026-02-18 14:24:16 INFO  [ main -> org.tasktide.itemstore.AbstractItemStore.releaseMutex ]: Releasing mutex
2026-02-18 14:24:16 INFO  [ main -> org.tasktide.itemstore.AbstractItemStore.releaseMutex ]: Released mutex
2026-02-18 14:24:16 INFO  [ main -> org.tasktide.core.manager.TaskTideManagerUtility.handleWorkflowForStep ]: No workflow detected, configuring for:    'FunctionRunner'
2026-02-18 14:24:16 INFO  [ main -> org.tasktide.core.manager.TaskTideManagerUtility.fetchWorkflowId ]: Fetching workflow for query:    'FunctionRunner'

'

2026-02-18 14:26:15 INFO  [ main -> org.tasktide.tasktide.client.TaskTideManagerClient.performClientTask ]: Displaying results: 'true'
2026-02-18 14:26:15 INFO  [ main -> org.tasktide.tasktide.TaskTide.main ]: TaskTideClient completed, tearing down container
Process(`/home/people/bkenna/software/bin/tasktide manager --repository-type sqlite --file-path /scratch/bkenna/function-runner/ItemStoreRepository/sqlite --step-name FunctionRunner --delimiter JSON --method Import --target ManagerTask --target-file /scratch/bkenna/function-runner/data/Multiplication-tasks.json`, ProcessExited(0))

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
'

2026-02-18 14:29:12 INFO  [ main -> org.tasktide.tasktide.TaskTide.main ]: Configuring the CDI Container Provider
2026-02-18 14:29:12 INFO  [ main -> org.tasktide.tasktide.client.TaskTideClientUtility.configureCdiInstance ]: Starting 'Weld' container
Feb 18, 2026 2:29:12 PM org.eclipse.jnosql.mapping.Databases lambda$addDatabase$1
INFO: Found the type DOCUMENT to metadata DOCUMENT@
Feb 18, 2026 2:29:15 PM org.eclipse.jnosql.mapping.reflection.ClassGraphClassScanner <init>
INFO: The following repositories are not supported: []
Feb 18, 2026 2:29:15 PM org.eclipse.jnosql.mapping.document.spi.DocumentExtension onAfterBeanDiscovery
INFO: Processing Document extension: 1 databases crud 0 found, custom repositories: 0
Feb 18, 2026 2:29:15 PM org.eclipse.jnosql.mapping.document.spi.DocumentExtension onAfterBeanDiscovery
INFO: Processing repositories as a Document implementation: []
2026-02-18 14:29:16 INFO  [ main -> org.tasktide.tasktide.TaskTide.main ]: Fetching TaskTide configs
2026-02-18 14:29:16 INFO  [ main -> org.tasktide.tasktide.client.TaskTideClientUtility.fetchRepoType ]: Querying configured repo type:  'sqlite'
2026-02-18 14:29:16 INFO  [ main -> org.tasktide.tasktide.TaskTide.main ]: Fetching the TaskTideServiceManager for 'Item Store' Repository
2026-02-18 14:29:16 INFO  [ main -> org.tasktide.tasktide.client.TaskTideClientUtility.initServiceManager ]: Configuring ItemStore ServiceManager
2026-02-18 14:29:16 INFO  [ main -> org.tasktide.core.repository.itemstore_repo.ItemStoreRepositoryUtility.fetchItemStoreMap ]: Prcessing ItemStore from under: '/scratch/bkenna/function-runner/ItemStoreRepository/sqlite'
2026-02-18 14:29:16 INFO  [ main -> org.tasktide.itemstore.SqliteStore.initItemStore ]: Initializing DB
2026-02-18 14:29:16 INFO  [ main -> org.tasktide.itemstore.AbstractItemStore.waitForMutex ]: Acquiring mutex
2026-02-18 14:29:20 INFO  [ main -> org.tasktide.itemstore.AbstractItemStore.waitForMutex ]: Mutex acquired
SLF4J(W): No SLF4J providers were found.
SLF4J(W): Defaulting to no-operation (NOP) logger implementation
SLF4J(W): See https://www.slf4j.org/codes.html#noProviders for further details.
2026-02-18 14:29:20 INFO  [ main -> org.tasktide.itemstore.AbstractItemStore.releaseMutex ]: Releasing mutex
2026-02-18 14:29:20 INFO  [ main -> org.tasktide.itemstore.AbstractItemStore.releaseMutex ]: Released mutex
2026-02-18 14:29:20 WARN  [ main -> org.tasktide.itemstore.AbstractItemStore.<init> ]: Mutex already configured
2026-02-18 14:29:20 INFO  [ main -> org.tasktide.itemstore.SqliteStore.initItemStore ]: Initializing DB under active mutex
2026-02-18 14:29:20 WARN  [ main -> org.tasktide.itemstore.AbstractItemStore.<init> ]: Mutex already configured
2026-02-18 14:29:20 INFO  [ main -> org.tasktide.itemstore.SqliteStore.initItemStore ]: Initializing DB under active mutex
2026-02-18 14:29:20 WARN  [ main -> org.tasktide.itemstore.AbstractItemStore.<init> ]: Mutex already configured
2026-02-18 14:29:20 INFO  [ main -> org.tasktide.itemstore.SqliteStore.initItemStore ]: Initializing DB under active mutex
2026-02-18 14:29:20 WARN  [ main -> org.tasktide.itemstore.AbstractItemStore.<init> ]: Mutex already configured
2026-02-18 14:29:20 INFO  [ main -> org.tasktide.itemstore.SqliteStore.initItemStore ]: Initializing DB under active mutex
2026-02-18 14:29:20 WARN  [ main -> org.tasktide.itemstore.AbstractItemStore.<init> ]: Mutex already configured
2026-02-18 14:29:20 INFO  [ main -> org.tasktide.itemstore.SqliteStore.initItemStore ]: Initializing DB under active mutex
2026-02-18 14:29:20 INFO  [ main -> org.tasktide.itemstore.AbstractItemStore.releaseMutex ]: Releasing mutex
2026-02-18 14:29:20 INFO  [ main -> org.tasktide.itemstore.AbstractItemStore.releaseMutex ]: Released mutex
2026-02-18 14:29:20 INFO  [ main -> org.tasktide.tasktide.TaskTide.main ]: ServiceManager state is now: 'true'
2026-02-18 14:29:20 INFO  [ main -> org.tasktide.tasktide.TaskTide.main ]: Constructing client: 'Manager'
2026-02-18 14:29:20 INFO  [ main -> org.tasktide.tasktide.client.TaskTideManagerClient.performClientTask ]: Executing ManagerCommand:
'{
    "Command Spec": {
        "File Path": "\"/scratch/bkenna/TaskTide/managerTargets\"",
        "Options": {
            "Item Id": "",
            "Delimiter": "\"|\"",
            "Step Name": "FunctionRunner",
            "Nested Delimiter": "\",\""
        },
        "Query String": "\"\""
    },
    "Command Type": "SELECT",
    "Manager Action": "SUMMARIZE",
    "Manager Target": "WORKITEM"
}'
2026-02-18 14:29:20 INFO  [ main -> org.tasktide.core.manager.command.commands.SummarizeCommand.runCommand ]: Summarizing collection
2026-02-18 14:29:20 INFO  [ main -> org.tasktide.itemstore.AbstractItemStore.waitForMutex ]: Acquiring mutex
2026-02-18 14:29:25 INFO  [ main -> org.tasktide.itemstore.AbstractItemStore.waitForMutex ]: Mutex acquired
2026-02-18 14:29:25 INFO  [ main -> org.tasktide.itemstore.AbstractItemStore.releaseMutex ]: Releasing mutex
2026-02-18 14:29:25 INFO  [ main -> org.tasktide.itemstore.AbstractItemStore.releaseMutex ]: Released mutex
2026-02-18 14:29:25 INFO  [ main -> org.tasktide.itemstore.AbstractItemStore.waitForMutex ]: Acquiring mutex
2026-02-18 14:29:30 INFO  [ main -> org.tasktide.itemstore.AbstractItemStore.waitForMutex ]: Mutex acquired
2026-02-18 14:29:30 INFO  [ main -> org.tasktide.itemstore.AbstractItemStore.releaseMutex ]: Releasing mutex
2026-02-18 14:29:30 INFO  [ main -> org.tasktide.itemstore.AbstractItemStore.releaseMutex ]: Released mutex
2026-02-18 14:29:30 INFO  [ main -> org.tasktide.core.manager.command.commands.SummarizeCommand.directOutput ]: Directing output to '"/scratch/bkenna/TaskTide/managerTargets"'
2026-02-18 14:29:30 INFO  [ main -> org.tasktide.core.manager.command.commands.SummarizeCommand.runCommand ]: Directing results to stdout
2026-02-18 14:29:30 INFO  [ main -> org.tasktide.tasktide.client.TaskTideManagerClient.performClientTask ]: Displaying results: '{
    "State Summary": {
        "LOCKED": 3,
        "FOR_UNLOCK": 0,
        "TODO": 29,
        "ERROR": 0,
        "DONE": 0
    }
}'
2026-02-18 14:29:30 INFO  [ main -> org.tasktide.tasktide.TaskTide.main ]: TaskTideClient completed, tearing down container
Process(`/home/people/bkenna/software/bin/tasktide manager --repository-type sqlite --file-path /scratch/bkenna/function-runner/ItemStoreRepository/sqlite --step-name FunctionRunner --method Summarize --target WORKITEM`, ProcessExited(0))

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