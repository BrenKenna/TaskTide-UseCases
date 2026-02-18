#!/bin/bash


######################################################
######################################################
## 
## 1). Manager Client
##
## - Review:
##    a). Reset all             - Should add
##    b). Delete all           <- Should add
##    c). Delete WorkItem      <- Broke
##    d). Export Query         <- No records following deletion
## 
######################################################
######################################################


####################################
####################################
##
## a). Task Imports
##
####################################
####################################


# Single item tasks
./bin/tasktide \
  manager \
  --repository-type "sqlite" \
  --file-path "./ItemStoreRepo/sqlite" \
  --method "Import" \
  --delimiter "|" \
  --target "WORKITEM" \
  --step-name "PingTest" \
  --target-file "../../../tasktide/tasktide/src/test/resources/singleTaskImports.txt"

echo -e "SELECT Auto_Id, Id, State, Collection FROM Items;" | sqlite3 ItemStoreRepo/sqlite/WORKITEM/master
echo -e "WorkItem-4597f006-85ec-490e-821a-c949d6c6e5cb\\nWorkItem-c145263c-0456-4abf-bf7d-ed89e12b9963" > forAnno.txt


# From JSON
./bin/tasktide \
  manager \
  --repository-type "sqlite" \
  --file-path "./ItemStoreRepo/sqlite" \
  --method "Import" \
  --delimiter "json" \
  --target "WORKITEM" \
  --step-name "SequenceAlignment" \
  --target-file "../../../tasktide/tasktide/src/test/resources/import-docs.json"


# Nested workload
./bin/tasktide \
  manager \
  --repository-type "sqlite" \
  --file-path "./ItemStoreRepo/sqlite" \
  --method "Import" \
  --delimiter "|" \
  --nested-delimiter "," \
  --target "WORKITEM" \
  --step-name "PingTest" \
  --target-file "../../../tasktide/tasktide/src/test/resources/nestedTaskImports.txt"



####################################
####################################
##
## b). Task Annotations
##
####################################
####################################


# Annotation
./bin/tasktide \
  manager \
  --repository-type "sqlite" \
  --file-path "./ItemStoreRepo/sqlite" \
  --method "Annotation" \
  --import-string '{"Pilot Label": "WSL Test"}' \
  --target "WORKITEM" \
  --step-name "PingTest" \
  --target-file "./forAnno.txt"


echo -e "SELECT Payload FROM Items;" | sqlite3 ItemStoreRepo/sqlite/WORKITEM/master | \
  jq '{ItemName: .ItemName, Id: .Id, Annotations: .annotations.Annotations."Pilot Label"}'

''' ---> Quite a few elections

{
  "ItemName": "Ping_Test_1",
  "Id": "WorkItem-d1ec0e17-b7d0-4ca6-812b-0af8f76bb5e8",
  "PilotLabel": null
}
{
  "ItemName": "Ping_Test_2",
  "Id": "WorkItem-b83c5350-43ca-4f76-b3e8-fc6846e11c1d",
  "PilotLabel": null
}
{
  "ItemName": "Ping_Test_4",
  "Id": "WorkItem-8f85fa38-206c-43e0-b3fb-cb6f84187589",
  "PilotLabel": null
}
{
  "ItemName": "Ping_Test_3",
  "Id": "WorkItem-551c79d9-c2dc-48a5-b146-db602a737792",
  "PilotLabel": "WSL Test"
}

'''


####################################
####################################
##
## c). Summarizing Tasks
##
####################################
####################################


# Summarize step
./bin/tasktide \
  manager \
  --repository-type "sqlite" \
  --file-path "./ItemStoreRepo/sqlite" \
  --method "Summarize" \
  --target "WORKITEM" \
  --target-file "./summaries.json" \
  --step-name "PingTest"


# Summarize each
./bin/tasktide \
  manager \
  --repository-type "sqlite" \
  --file-path "./ItemStoreRepo/sqlite" \
  --method "SUMMARIZE_EACH" \
  --target "WORKITEM" \
  --target-file "./summaries.json" \
  --step-name "PingTest"


''

2026-02-17 11:49:08 INFO  [ main -> org.tasktide.tasktide.client.TaskTideManagerClient.performClientTask ]: Displaying results: '{
    "State Summary": {
        "DONE": 0,
        "TODO": 4,
        "ERROR": 0,
        "LOCKED": 0,
        "FOR_UNLOCK": 0
    }
}'

2026-02-17 11:53:23 INFO  [ main -> org.tasktide.tasktide.client.TaskTideManagerClient.performClientTask ]: Displaying results: '{
    "WorkItem-d1ec0e17-b7d0-4ca6-812b-0af8f76bb5e8": {
        "State Summary": {
            "LOCKED": 0,
            "TODO": 1,
            "ERROR": 0,
            "FOR_UNLOCK": 0,
            "DONE": 0
        }
    },
    "WorkItem-b83c5350-43ca-4f76-b3e8-fc6846e11c1d": {
        "State Summary": {
            "LOCKED": 0,
            "TODO": 1,
            "ERROR": 0,
            "FOR_UNLOCK": 0,
            "DONE": 0
        }
    },
    "WorkItem-551c79d9-c2dc-48a5-b146-db602a737792": {
        "State Summary": {
            "LOCKED": 0,
            "TODO": 1,
            "ERROR": 0,
            "FOR_UNLOCK": 0,
            "DONE": 0
        }
    },
    "WorkItem-8f85fa38-206c-43e0-b3fb-cb6f84187589": {
        "State Summary": {
            "LOCKED": 0,
            "TODO": 1,
            "ERROR": 0,
            "FOR_UNLOCK": 0,
            "DONE": 0
        }
    }
}'

''


####################################
####################################
##
## d). Task State Management
##
####################################
####################################


# Restart specific task: Calls method on WorkItem
./bin/tasktide \
  manager \
  --repository-type "sqlite" \
  --file-path "./ItemStoreRepo/sqlite" \
  --target "WORKITEM" \
  --step-name "PingTest" \
  --method "Reset_Item" \
  --itemId "WorkItem-73121c61-90b0-4339-88e8-e41316a1a334"

echo -e "SELECT * FROM Items WHERE Id = 'WorkItem-85dfcc13-d7a5-40a7-a028-1db4cfaf9774';" | sqlite3 ItemStoreRepo/sqlite/WORKITEM/master
echo -e "SELECT * FROM Items WHERE Id = 'WorkItem-85dfcc13-d7a5-40a7-a028-1db4cfaf9774';" | sqlite3 ItemStoreRepo/sqlite/WORKITEM/master

'''
5|WorkItem-85dfcc13-d7a5-40a7-a028-1db4cfaf9774|LOCKED|PingTest
6|WorkItem-85dfcc13-d7a5-40a7-a028-1db4cfaf9774|ToDo|PingTest

'''

# Reset Item collection
echo -e "WorkItem-73121c61-90b0-4339-88e8-e41316a1a334,ItemTask-341b17f0-52a6-4a7d-8e59-0f443402c719" > ./forReset.txt

./bin/tasktide \
  manager \
  --repository-type "sqlite" \
  --file-path "./ItemStoreRepo/sqlite" \
  --target "WORKITEM" \
  --step-name "PingTest" \
  --method "Reset_Items" \
  --target-file "./forReset.txt" \
  --delimiter ","



####################################
####################################
##
## e). Task Deletion
##
####################################
####################################


# Delete WorkItem, ItemTask, List
./bin/tasktide \
  manager \
  --repository-type "sqlite" \
  --file-path "./ItemStoreRepo/sqlite" \
  --method "DELETE" \
  --target "WORKITEM" \
  --step-name "PingTest" \
  --import-string '{ "Item Id": "WorkItem-8f85fa38-206c-43e0-b3fb-cb6f84187589", "Task Name": "Ping_Test_4" }'


echo -e "WorkItem-d1ec0e17-b7d0-4ca6-812b-0af8f76bb5e8\\nWorkItem-b83c5350-43ca-4f76-b3e8-fc6846e11c1d|ItemTask-969f97c8-b78d-4c78-9f89-dfedb7505834" > ./forDeletion.txt
./bin/tasktide \
  manager \
  --repository-type "sqlite" \
  --file-path "./ItemStoreRepo/sqlite" \
  --method "DELETE_LIST" \
  --target "WORKITEM" \
  --step-name "PingTest" \
  --delimiter "|" \
  --target-file "./forDeletion.txt"


''

2026-02-17 12:28:43 INFO  [ main -> org.tasktide.tasktide.client.TaskTideManagerClient.performClientTask ]: Displaying results: '{
    "DoneDate": 0,
    "Id": "WorkItem-8f85fa38-206c-43e0-b3fb-cb6f84187589",
    "ItemName": "Ping_Test_4",
    "ItemState": "TODO",
    "ItemType": "SINGLE",
    "Job Environment Id": "",
    "LockDate": 0,
    "LockId": "",
    "StepId": "Step-c90f12f6-4b49-4ee3-9a1b-f06b5acaea39",
    "StepName": "PingTest",
    "TaskCount": 0,
    "TaskDone": 0,
    "Workload": {
        "TaskMap": {
        },
        "WorkloadType": "SINGLE",
        "earliestDone": -1,
        "id": "Workload-32773f54-3820-4210-9be8-d524abf58106",
        "latestDone": 0,
        "workloadSize": 0
    },
    "annotations": {
        "Annotations": {
        }
    },
    "collection": "PingTest",
    "workloadSize": 0
}'

''



####################################
####################################
##
## f). Task Exports
##
####################################
####################################


# Export - Drop paramter check on Validation Export
./bin/tasktide \
  manager \
  --repository-type "sqlite" \
  --file-path "./ItemStoreRepo/sqlite" \
  --target "WORKITEM" \
  --step-name "PingTest" \
  --method "Export" \
  --target-file "./ping-test-workitems.json"


./bin/tasktide \
  manager \
  --repository-type "sqlite" \
  --file-path "./ItemStoreRepo/sqlite" \
  --target "WORKITEM" \
  --step-name "PingTest" \
  --method "Export_Query" \
  --import-string '{"Parameter": "State", "Value": "ToDo"}' \
  --target-file "./todo-items-output.json"


'''

2026-02-17 12:45:13 INFO  [ main -> org.tasktide.core.manager.command.commands.ExportCommand.exportOnQuery ]: Retrieved '0' records for export to:      './todo-items-output.json'

'''


######################################################
######################################################
## 
## 2). Engine Client
##
## - Review how work is passed to threads
## 
######################################################
######################################################


####################################
####################################
##
## a). Execution Policy
##
##
####################################
####################################


# Run engine in batch mode
./bin/tasktide \
  engine \
  --repository-type "sqlite" \
  --file-path "./ItemStoreRepo/sqlite" \
  --target "WORKITEM" \
  --step-name "PingTest" \
  --work-item-threads 5

''' --> Hangs when #Threads > #Available Tasks

2026-02-17 16:29:51 INFO  [ main -> org.tasktide.tasktide.client.TaskTideEngineClient.processWorkload ]: Processing workload of size:   '4'
2026-02-17 16:29:51 INFO  [ main -> org.tasktide.engine.worker.processor.TaskTideProcessor.processChunks ]: Shuffling, and grouping workload for ExecutorService for ProcessorType:        'WorkItemProcessor'
2026-02-17 16:29:51 INFO  [ main -> org.tasktide.engine.worker.processor.WorkItemProcessor.parallelChunks ]: Fetching N = '5' batches of size '0' for WorkItem workload
2026-02-17 16:29:51 INFO  [ main -> org.tasktide.engine.worker.processor.TaskTideProcessor.processChunks ]: Submitting 'WorkItemProcessor' workload of size:    '4'        
2026-02-17 16:29:51 INFO  [ main -> org.tasktide.engine.worker.processor.TaskTideProcessor.submitParallelChunks ]: Submitting sub-workload of size:     '0'
2026-02-17 16:29:51 INFO  [ main -> org.tasktide.engine.worker.processor.TaskTideProcessor.submitParallelChunks ]: Submitting sub-workload of size:     '0'
2026-02-17 16:29:51 INFO  [ main -> org.tasktide.engine.worker.processor.TaskTideProcessor.submitParallelChunks ]: Submitting sub-workload of size:     '0'
2026-02-17 16:29:51 INFO  [ main -> org.tasktide.engine.worker.processor.TaskTideProcessor.submitParallelChunks ]: Submitting sub-workload of size:     '0'
2026-02-17 16:29:51 INFO  [ main -> org.tasktide.engine.worker.processor.TaskTideProcessor.processChunks ]: Submitted N = '0' items for workload 'WorkItemProcessor'       
2026-02-17 16:29:51 INFO  [ main -> org.tasktide.engine.TaskTideEngineUtility.waitOnExecutorTrackerWorkItem ]: Begining state monitoring of ExecutorServiceTracker:     N tasks = '0'
2026-02-17 16:29:51 INFO  [ main -> org.tasktide.engine.TaskTideEngineUtility.waitOnExecutorTrackerWorkItem ]: Letting '10000'ms elapse for state monitoring of ExecutorServiceTracker:    '0'

'''


# Run engine as a service
./bin/tasktide \
  engine \
  --repository-type "sqlite" \
  --file-path "./ItemStoreRepo/sqlite" \
  --target "WORKITEM" \
  --step-name "PingTest" \
  --execution-policy "service" \
  --work-item-threads 5


./bin/tasktide \
  manager \
  --repository-type "sqlite" \
  --file-path "./ItemStoreRepo/sqlite" \
  --method "Import" \
  --delimiter "|" \
  --target "WORKITEM" \
  --step-name "PingTest" \
  --target-file "../../../tasktide/tasktide/src/test/resources/singleTaskImports.txt"


# All tasks processed on pool-3-thread-1
echo -e "SELECT Payload FROM Items;" | \
  sqlite3 itemStoreRepo/sqlite/WORKITEM/master | \
  grep "ThreadName" | sort | uniq -c


''
 3       "ThreadName": "NA"
13       "ThreadName": "pool-3-thread-1"
     


2026-02-17 17:37:51 WARN  [ main -> org.tasktide.tasktide.client.TaskTideEngineClient.processWorkload ]: Warning, no ToDo tasks available for processing. Query below backend for more information

{Collection Name=WorkItem-Service, Model Class=WorkItem, Repository Type=Item Store}


2026-02-17 17:37:51 INFO  [ main -> org.tasktide.tasktide.client.TaskTideEngineClient.fetchAndRun ]: Processing complete for step:      'PingTest'
2026-02-17 17:37:52 INFO  [ main -> org.tasktide.tasktide.client.TaskTideEngineClient.fetchAndRun ]: Determing how to process workload
2026-02-17 17:37:52 INFO  [ main -> org.tasktide.tasktide.client.TaskTideEngineClient.fetchAndRun ]: Processing single step:    'PingTest'
2026-02-17 17:37:52 INFO  [ main -> org.tasktide.tasktide.client.TaskTideEngineClient.fetchWorkload ]: No pilot label provided, processing all tasks       

2026-02-17 17:39:09 INFO  [ main -> org.tasktide.tasktide.client.TaskTideEngineClient.processWorkload ]: Processing workload of size:   '4'
2026-02-17 17:39:09 INFO  [ main -> org.tasktide.engine.worker.processor.TaskTideProcessor.processChunks ]: Shuffling, and grouping workload for ExecutorService for ProcessorType:        'WorkItemProcessor'
2026-02-17 17:39:09 INFO  [ main -> org.tasktide.engine.worker.processor.WorkItemProcessor.parallelChunks ]: Fetching N = '5' batches of size '1' for WorkItem workload
2026-02-17 17:39:09 INFO  [ main -> org.tasktide.engine.worker.processor.TaskTideProcessor.processChunks ]: Submitting 'WorkItemProcessor' workload of size:       '4'
2026-02-17 17:39:09 INFO  [ main -> org.tasktide.engine.worker.processor.TaskTideProcessor.submitParallelChunks ]: Submitting sub-workload of size:     '1'
2026-02-17 17:39:09 INFO  [ pool-2-thread-1 -> org.tasktide.engine.worker.executor.TaskTideExecutor.runTasks ]: Begining workload processing of N = '1' tasks
2026-02-17 17:39:09 INFO  [ pool-2-thread-1 -> org.tasktide.engine.observer.worker.TimeKeeperObserver.evaluateStart ]: TimeKeeper evaluating starting of task 'WorkItem-22e95dad-2062-42c2-81c6-b1a9fd98ce71'


2026-02-17 17:47:01 WARN  [ main -> org.tasktide.tasktide.client.TaskTideEngineClient.processWorkload ]: Warning, no ToDo tasks available for processing. Query below backend for more information

{Collection Name=WorkItem-Service, Model Class=WorkItem, Repository Type=Item Store}


2026-02-17 17:47:01 INFO  [ main -> org.tasktide.tasktide.client.TaskTideEngineClient.fetchAndRun ]: Processing complete for step:      'PingTest'
''


