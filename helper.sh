#!/bin/bash


# Rollback to a specific commit
git reset --hard d97a07a
git add .
git commit -m "Rolled back for alternate workflow"


#############################################################
#############################################################
# 
# 1). Setup Backend for Testing
# 
#############################################################
#############################################################

#############################################
#############################################
# 
# a). Document Databases
#
#  => Mongo storates
#  => Other two have their prop as a null
# 
#############################################
#############################################

# Run image
docker container run  -p 27017:27017 mongo:latest


# Run image
docker container run -e COUCHDB_USER=admin -e COUCHDB_PASSWORD=password -p 5984:5984 couchdb:latest

curl -X PUT http://admin:password@localhost:5984/tasktide_database

curl -X GET http://admin:password@localhost:5984/_all_dbs

curl -X GET http://admin:password@localhost:5984/tasktide_database/_all_docs


# Run image
docker run -d -p 8529:8529 -e ARANGO_RANDOM_ROOT_PASSWORD=password --name arangodb-instance arangodb



####################################
####################################
# 
# b). Cassandra
# 
####################################
####################################


# Run image
docker container run --name cassandra -p 7000:7000 cassandra:latest



#############################################
#############################################
# 
# c). MySQL
#  could use 'org.mariadb.jdbc:mariadb-java-client:3.3.2'
# 
#############################################
#############################################

docker run -e MARIADB_USER=admin -e MARIADB_PASSWORD=password -e MARIADB_ROOT_PASSWORD=rootpass -e MARIADB_DATABASE=tasktide_database -p 3306:3306 mariadb:latest

``` {SQL}

select ItemState, COUNT(DISTINCT id) AS 'Total', SUM(TaskCount), SUM(TaskDone) FROM WorkItem GROUP BY ItemState ORDER BY 'Total' DESC;

'''
+-----------+-------+----------------+---------------+
| ItemState | Total | SUM(TaskCount) | SUM(TaskDone) |
+-----------+-------+----------------+---------------+
| TODO      |     5 |             13 |             0 |
+-----------+-------+----------------+---------------+
'''

select ItemState, COUNT(DISTINCT id) AS 'Total', SUM(TaskCount), SUM(TaskDone) FROM WorkItem GROUP BY ItemState ORDER BY 'Total' DESC;
+-----------+-------+----------------+---------------+
| ItemState | Total | SUM(TaskCount) | SUM(TaskDone) |
+-----------+-------+----------------+---------------+
| TODO      |     3 |              7 |             0 |
| LOCKED    |     2 |              6 |             0 |
+-----------+-------+----------------+---------------+


select ItemState, COUNT(DISTINCT id) AS 'Total', SUM(TaskCount), SUM(TaskDone) FROM WorkItem GROUP BY ItemState ORDER BY 'Total' DESC;
+-----------+-------+----------------+---------------+
| ItemState | Total | SUM(TaskCount) | SUM(TaskDone) |
+-----------+-------+----------------+---------------+
| LOCKED    |     2 |              6 |             0 |
| DONE      |     2 |              3 |             3 |
| ERROR     |     1 |              4 |             3 |
+-----------+-------+----------------+---------------+

select ItemState, COUNT(DISTINCT id) AS 'Total', SUM(TaskCount), SUM(TaskDone) FROM WorkItem GROUP BY ItemState ORDER BY 'Total' DESC;
+-----------+-------+----------------+---------------+
| ItemState | Total | SUM(TaskCount) | SUM(TaskDone) |
+-----------+-------+----------------+---------------+
| DONE      |     3 |              4 |             4 |
| ERROR     |     2 |              9 |             7 |
+-----------+-------+----------------+---------------+


select ItemName, ItemState, TaskCount, TaskDone FROM WorkItem;
+-------------+-----------+-----------+----------+
| ItemName    | ItemState | TaskCount | TaskDone |
+-------------+-----------+-----------+----------+
| Ping_Test_3 | ERROR     |         4 |        3 |
| Ping_Test_2 | DONE      |         2 |        2 |
| Ping_Test_5 | DONE      |         1 |        1 |
| Ping_Test_4 | ERROR     |         5 |        4 |
| Ping_Test_1 | DONE      |         1 |        1 |
+-------------+-----------+-----------+----------+

```

#############################################################
#############################################################
# 
# 2). Running TaskTide
#
# - Print error message if target is missing
# - Export on query needs a targetFile, error message is confusing
# - Default arguments getting picked up somewheere? Summary message & Delete command
#
#  Import: Add, Append, Import
#  Export: Export, Export_Query [Problem]
#  Summary: Summary, Summarize_Each
#  Delete:  Delete, Delete_Items
#  Reset:   Item, List
#
#############################################################
#############################################################


#############################################
#############################################
# 
# a). Install
# 
#############################################
#############################################

# Copy config and zip
cd .secret/buildTesting
cp ../../tasktide/tasktide/build/distributions/tasktide-0.9.0.zip ./

# Unpack
unzip tasktide-0.9.0.zip && rm -f tasktide-0.9.0.zip


# Run: Once for import, then engine
./bin/tasktide --help


# Import tasks
./bin/tasktide \
  manager \
  --repository-type "sqlite" \
  --file-path "./itemStoreRepo/sqlite" \
  --method "Import" \
  --delimiter "|" \
  --target "WORKITEM" \
  --step-name "PingTest" \
  --target-file "../../../tasktide/tasktide/src/test/resources/singleTaskImports.txt"

echo -e "SELECT Auto_Id, Id, State, Collection FROM Items;" | sqlite3 itemStoreRepo/sqlite/WORKITEM/master
echo -e "WorkItem-4597f006-85ec-490e-821a-c949d6c6e5cb\\nWorkItem-c145263c-0456-4abf-bf7d-ed89e12b9963" > forAnno.txt

./bin/tasktide \
  manager \
  --repository-type "sqlite" \
  --file-path "./itemStoreRepo/sqlite" \
  --method "Annotation" \
  --import-string '{"Pilot Label": "WSL Test"}' \
  --target "WORKITEM" \
  --step-name "PingTest" \
  --target-file "./forAnno.txt"


echo -e "SELECT Payload FROM Items;" | sqlite3 itemStoreRepo/sqlite/WORKITEM/master | \
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
  --file-path "./itemStoreRepo/sqlite" \
  --method "Summarize" \
  --target "WORKITEM" \
  --step-name "PingTest"

./bin/tasktide \
  manager \
  --repository-type "sqlite" \
  --file-path "./itemStoreRepo/sqlite" \
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
  --file-path "./itemStoreRepo/sqlite" \
  --method "DELETE" \
  --target "WORKITEM" \
  --step-name "PingTest"



# Restart
./bin/tasktide \
  manager \
  --repository-type "sqlite" \
  --file-path "./itemStoreRepo/sqlite" \
  --target "WORKITEM" \
  --step-name "PingTest" \
  --method "Reset_Item" \
  --itemId "WorkItem-85dfcc13-d7a5-40a7-a028-1db4cfaf9774"

echo -e "SELECT * FROM Items WHERE Id = 'WorkItem-85dfcc13-d7a5-40a7-a028-1db4cfaf9774';" | sqlite3 itemStoreRepo/sqlite/WORKITEM/master
echo -e "SELECT * FROM Items WHERE Id = 'WorkItem-85dfcc13-d7a5-40a7-a028-1db4cfaf9774';" | sqlite3 itemStoreRepo/sqlite/WORKITEM/master

'''
5|WorkItem-85dfcc13-d7a5-40a7-a028-1db4cfaf9774|LOCKED|PingTest
6|WorkItem-85dfcc13-d7a5-40a7-a028-1db4cfaf9774|ToDo|PingTest

'''


# Delete
./bin/tasktide \
  manager \
  --repository-type "sqlite" \
  --file-path "./itemStoreRepo/sqlite" \
  --target "WORKITEM" \
  --step-name "PingTest" \
  --method "DELETE" \
  --import-string '{ "Item Id": "WorkItem-fa90ffc3-bd8d-46ab-9160-5f33970e4fa9", "Task Id": "ItemTask-0dac5339-e82f-4ed1-b5e1-0dc8b874ee77" }'

./bin/tasktide \
  manager \
  --repository-type "sqlite" \
  --file-path "./itemStoreRepo/sqlite" \
  --target "WORKITEM" \
  --step-name "PingTest" \
  --method "DELETE" \
  --import-string '{ "Item Id": "WorkItem-fa90ffc3-bd8d-46ab-9160-5f33970e4fa9" }'

echo -e "SELECT Payload FROM Items WHERE Id = 'WorkItem-fa90ffc3-bd8d-46ab-9160-5f33970e4fa9';" | sqlite3 itemStoreRepo/sqlite/WORKITEM/master \
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
  --file-path "./itemStoreRepo/sqlite" \
  --target "WORKITEM" \
  --step-name "PingTest" \
  --method "Export_Query" \
  --import-string '{"Parameter": "State", "Value": "ToDo"}' \
  --target-file "./todo-items.json"



#############################################################
#############################################################
# 
# 3). TaskTide Use Cases
# 
#############################################################
#############################################################

# Setup
USE_CASES=/mnt/c/Users/ithel/Documents/GitHub/TaskTide/.secret/buildTesting/use-cases
mkdir -p ${USE_CASES}/scripting-checks


#############################################
#############################################
# 
# a). Windows & Linux Scripts
# 
#############################################
#############################################


# Set workind directory
cd ${USE_CASES}/scripting-checks


####################
####################
#
# i). Linux
#
####################
####################

# Backup current profile before swapping
APP_DIR=../../tasktide-0.9.0/
CONFIG=$APP_DIR/config/META-INF/microprofile-config.properties
DB_DIR=/root/tasktide/use-cases/linux-scripts
cp $CONFIG ./


# Configure workload
echo -e """
Seq_Test_1|bash /mnt/c/Users/ithel/Documents/GitHub/TaskTide/.secret/buildTesting/use-cases/scripting-checks/linux-test.sh|1
Seq_Test_2|bash /mnt/c/Users/ithel/Documents/GitHub/TaskTide/.secret/buildTesting/use-cases/scripting-checks/linux-test.sh|2,3
Seq_Test_3|bash /mnt/c/Users/ithel/Documents/GitHub/TaskTide/.secret/buildTesting/use-cases/scripting-checks/linux-test.sh|4,5,6,dcu.ie
Seq_Test_4|bash /mnt/c/Users/ithel/Documents/GitHub/TaskTide/.secret/buildTesting/use-cases/scripting-checks/linux-test.sh|cherp,9,10,11,12
Seq_Test_5|bash /mnt/c/Users/ithel/Documents/GitHub/TaskTide/.secret/buildTesting/use-cases/scripting-checks/linux-test.sh|tudublin.ie
""" | sort | uniq | awk 'NR > 1' > $APP_DIR/config/tasks.txt


# Copy profile for manager import: Import file must be in config dir? Full file path not accepted either
cp linux-profile.properties $CONFIG
$APP_DIR/bin/tasktide


# Inspect tasks
echo -e "SELECT payload FROM Items LIMIT 1;" | sqlite3 $DB_DIR/WORKITEM/master | jq .Id

"WorkItem-726cc93a-472c-4311-800f-64f195029a89"

# Change for engine, and run
sed -i 's/tasktide\.client=manager/tasktide\.client=engine/' $CONFIG
$APP_DIR/bin/tasktide


# Inspect task
echo -e "SELECT payload FROM Items WHERE Id = 'WorkItem-726cc93a-472c-4311-800f-64f195029a89'" | sqlite3 $DB_DIR/WORKITEM/master

'''
{
  "Workload": {
    "Seq_Test_1": {
      "Task": "bash /mnt/c/Users/ithel/Documents/GitHub/TaskTide/.secret/buildTesting/use-cases/scripting-checks/linux-test.sh 1",
      "Task Log": {
        "CPU Duration": 0,
        "End Time": 1754672516211,
        "Exit Code": 0,
        "Process Id": 2023,
        "Process Log": {
          "Stderr": [
            "+ date",
            "+ seq 1",
            "+ date"
          ],
          "Stdout": [
            "Fri Aug  8 18:01:56 IST 2025",
            "1",
            "Fri Aug  8 18:01:56 IST 2025"
          ],
          "id": "ProcessLog-fe01e952-f4dc-485e-8115-8f51c96270e4"
        },
        "Start Time": 1754672516209,
        "Thread Name": "pool-3-thread-1",
        "id": "TaskLogging-1cfb16dd-18e5-4976-b17e-6b8036df6776"
      },
      "Task Name": "Seq_Test_1",
      "Task State": "COMPLETE",
      "Work Item Id": "WorkItem-726cc93a-472c-4311-800f-64f195029a89",
      "id": "ItemTask-a33d6a47-8bf7-4371-b41f-814a6d659e04",
      "state": "bash /mnt/c/Users/ithel/Documents/GitHub/TaskTide/.secret/buildTesting/use-cases/scripting-checks/linux-test.sh 1"
    }
  },
  "WorkloadType": "SINGLE",
  "earliestDone": 1754672516211,
  "id": "Workload-a31c1e54-1d26-4328-8cc9-3128bb21e338",
  "latestDone": 1754672516211,
  "workloadSize": 1
}

'''



# Try windows script
cp windows-profile.properties $CONFIG
$APP_DIR/bin/tasktide

echo -e "SELECT payload FROM Items WHERE State = 'ToDo' State LIMIT 1;" | sqlite3 $DB_DIR/WORKITEM/master | jq .Id

"WorkItem-3f8b355b-a8ac-40c6-8988-843b0c2a2d21"


# Run engine
sed -i 's/tasktide\.client=manager/tasktide\.client=engine/' $CONFIG

..\..\tasktide-0.9.0\bin\tasktide.bat # In windows