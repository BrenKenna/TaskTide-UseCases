#!/bin/bash


######################################################
######################################################
## 
## 1). Manager Client
## 
######################################################
######################################################

# Import tasks
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

'''

1|WorkItem-4597f006-85ec-490e-821a-c949d6c6e5cb|ToDo|PingTest
2|WorkItem-1466ab2c-755f-4c33-9902-98fc33d33278|ToDo|PingTest
3|WorkItem-c145263c-0456-4abf-bf7d-ed89e12b9963|ToDo|PingTest
4|WorkItem-f30cc4ec-3514-46fc-95bb-485a44db2be2|ToDo|PingTest

{
  "ItemName": "Ping_Test_1",
  "Id": "WorkItem-4597f006-85ec-490e-821a-c949d6c6e5cb",
  "Annotations": "WSL Test"
}
{
  "ItemName": "Ping_Test_3",
  "Id": "WorkItem-c145263c-0456-4abf-bf7d-ed89e12b9963",
  "Annotations": "WSL Test"
}

'''


# Summarize - 
./bin/tasktide \
  manager \
  --repository-type "sqlite" \
  --file-path "./ItemStoreRepo/sqlite" \
  --method "Summarize" \
  --target "WORKITEM" \
  --target-file "./summaries.json" \
  --step-name "FunctionRunner"

./bin/tasktide \
  manager \
  --repository-type "sqlite" \
  --file-path "./ItemStoreRepo/sqlite" \
  --method "SUMMARIZE_EACH" \
  --target "WORKITEM" \
  --target-file "./summaries.json" \
  --step-name "PingTest"


'''


'''


# 
./bin/tasktide \
  manager \
  --repository-type "sqlite" \
  --file-path "./ItemStoreRepo/sqlite" \
  --method "DELETE" \
  --target "WORKITEM" \
  --step-name "PingTest"



# Restart
./bin/tasktide \
  manager \
  --repository-type "sqlite" \
  --file-path "./ItemStoreRepo/sqlite" \
  --target "WORKITEM" \
  --step-name "PingTest" \
  --method "Reset_Item" \
  --itemId "WorkItem-85dfcc13-d7a5-40a7-a028-1db4cfaf9774"

echo -e "SELECT * FROM Items WHERE Id = 'WorkItem-85dfcc13-d7a5-40a7-a028-1db4cfaf9774';" | sqlite3 ItemStoreRepo/sqlite/WORKITEM/master
echo -e "SELECT * FROM Items WHERE Id = 'WorkItem-85dfcc13-d7a5-40a7-a028-1db4cfaf9774';" | sqlite3 ItemStoreRepo/sqlite/WORKITEM/master

'''
5|WorkItem-85dfcc13-d7a5-40a7-a028-1db4cfaf9774|LOCKED|PingTest
6|WorkItem-85dfcc13-d7a5-40a7-a028-1db4cfaf9774|ToDo|PingTest

'''


# Delete
./bin/tasktide \
  manager \
  --repository-type "sqlite" \
  --file-path "./ItemStoreRepo/sqlite" \
  --target "WORKITEM" \
  --step-name "PingTest" \
  --method "DELETE" \
  --import-string '{ "Item Id": "WorkItem-fa90ffc3-bd8d-46ab-9160-5f33970e4fa9", "Task Id": "ItemTask-0dac5339-e82f-4ed1-b5e1-0dc8b874ee77" }'

./bin/tasktide \
  manager \
  --repository-type "sqlite" \
  --file-path "./ItemStoreRepo/sqlite" \
  --target "WORKITEM" \
  --step-name "PingTest" \
  --method "DELETE" \
  --import-string '{ "Item Id": "WorkItem-fa90ffc3-bd8d-46ab-9160-5f33970e4fa9" }'

echo -e "SELECT Payload FROM Items WHERE Id = 'WorkItem-fa90ffc3-bd8d-46ab-9160-5f33970e4fa9';" | sqlite3 ItemStoreRepo/sqlite/WORKITEM/master \
  | jq '{ Id: .Id, Workload: .Workload}'

''' 
{
  "Id": "WorkItem-fa90ffc3-bd8d-46ab-9160-5f33970e4fa9",
  "Workload": {
    "TaskMap": {},
    "WorkloadType": "SINGLE",
    "earliestDone": -1,
    "id": "Workload-d1f77fb1-947f-4b71-a212-1b76d5c55b38",
    "latestDone": 0,
    "workloadSize": 0
  }
}

'''


# Export - Drop paramter check on Validation Export
./bin/tasktide \
  manager \
  --repository-type "sqlite" \
  --file-path "./ItemStoreRepo/sqlite" \
  --target "WORKITEM" \
  --step-name "PingTest" \
  --method "Export_Query" \
  --import-string '{"Parameter": "State", "Value": "ToDo"}' \
  --target-file "./todo-items.json"




######################################################
######################################################
## 
## 2). Engine Client
## 
######################################################
######################################################


# Run engine in batch mode
tasktide \
  engine \
  --repository-type "sqlite" \
  --file-path "./ItemStoreRepo/sqlite" \
  --target "WORKITEM" \
  --step-name "FunctionRunner" \
  --work-item-threads 8



# Run engine as a service
tasktide \
  engine \
  --repository-type "sqlite" \
  --file-path "./ItemStoreRepo/sqlite" \
  --target "WORKITEM" \
  --step-name "FunctionRunner" \
  --execution-policy "service" \
  --work-item-threads 8

