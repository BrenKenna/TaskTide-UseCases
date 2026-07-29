#!/bin/bash


######################################################
######################################################
## 
## a). Install Software on Rocky-10 WSL Host
## 
######################################################
######################################################

# Setup dnf
dnf update -y && dnf upgrade -y
dnf install -y epel-release
dnf -y install dnf-plugins-core jq time
dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
dnf update -y

dnf config-manager --set-enabled crb


# Install R, Python, and latest Docker
dnf install -y R python
dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
dnf install -y rocksdb rocksdb-devel


# Convenience symbolic link for python
ln -sf /bin/python3 /bin/python
chmod +x /bin/python


# Check java version and setup opt
java --version

mkdir /opt/java_modules
chmod 777 /opt/java_modules


# Install task tide
cd /opt/java_modules/
cp /mnt/c/Users/Bren/Documents/GitHub/TaskTide/tasktide/tasktide/build/distributions/tasktide-0.9.5.zip ./
unzip tasktide-0.9.5.zip && rm -f tasktide-0.9.5.zip


# Symbolic link for TaskTide
rm -f /bin/tasktide
ln -sf /opt/java_modules/tasktide-0.9.5/bin/tasktide /bin/tasktide
chmod +x /bin/tasktide


# Copy use case scripts
mkdir -p /opt/tasktide-use-case
cp /mnt/c/Users/Bren/Documents/GitHub/TaskTide/tasktide/use-cases/simple/*txt /opt/tasktide-use-case/
chown -R bren:bren /opt/tasktide-use-case/


# Spinup couchDB backend for testing
docker container run -e COUCHDB_USER=admin -e COUCHDB_PASSWORD=password -p 5984:5984 couchdb:latest
curl -X PUT http://admin:password@localhost:5984/tasktide_database

curl -X GET http://admin:password@localhost:5984/_all_dbs | jq

curl -X GET http://admin:password@localhost:5984/tasktide_database/_all_docs | jq





###################################################
###################################################
## 
## b). Import Tasks
## 
###################################################
###################################################

# Set working directory
export wrk="/opt/tasktide-use-case"
cd $wrk


# Import R version jobs
tasktide \
    manager \
        --repository-type "sqlite" \
        --file-path "$wrk/tasktide-sqlite" \
        --method "Import" \
        --delimiter "|" \
        --nested-delimiter "," \
        --target "WORKITEM" \
        --step-name "Rscript-Jobs" \
        --target-file "$wrk/stringVersionTasks.txt"



# Run engine
tasktide \
    engine \
        --repository-type "sqlite" \
        --file-path "$wrk/tasktide-sqlite" \
        --target "WORKITEM" \
        --step-name "Rscript-Jobs" \
        --worker-pool-size "3" \
        --worker-window-size "2"


tasktide \
    manager \
        --repository-type "rocksDB" \
        --file-path "$wrk/tasktide-rocksDB" \
        --method "Summarize" \
        --target "WORKITEM" \
        --step-name "Rscript-Jobs"


rm -f "$wrk/Rscript-Jobs.json"
tasktide \
    manager \
        --repository-type "rocksDB" \
        --file-path "$wrk/tasktide-rocksDB" \
        --target "WORKITEM" \
        --step-name "Rscript-Jobs" \
        --method "Export" \
        --target-file "$wrk/Rscript-Jobs.json"

seq 10

cat "$wrk/Rscript-Jobs.json"


# Import sleep jobs to evaluate engine running until jobs are done
tasktide \
    manager \
        --repository-type "sqlite" \
        --file-path "$wrk/tasktide-sqlite" \
        --method "Import" \
        --delimiter "|" \
        --target "WORKITEM" \
        --step-name "SleepJobs" \
        --target-file "$wrk/sleepTasks.txt"

echo -e "SELECT Payload FROM Items;" | \
  sqlite3 tasktide-sqlite/WORKITEM/master


# Run engine
tasktide \
    engine \
        --repository-type "sqlite" \
        --file-path "$wrk/tasktide-sqlite" \
        --target "WORKITEM" \
        --step-name "SleepJobs"



###################################################
###################################################
## 
## c). HPC Run
## 
###################################################
###################################################

# Set working directory
export wrk="$DATA_DIR/simple-use-cases"
cd $wrk


# Resource intensive: 2GiB large bean graph
$SOFT/time/time -v tasktide > $wrk/tasktide-baseline.txt 2>&1


#################################
#################################
##
## i). Short Running Jobs
##
#################################
#################################

# Short running jobs
rm -f "$wrk/short-running-tasks.txt" && touch "$wrk/short-running-tasks.txt"

for i in $( echo -e "2 4 16 32 64 128" )
do
    echo -e "ShortRunning-$i|$SOFT/bin/time -v Rscript $SOFT/bin/stringVersion.R $i" >> "$wrk/short-running-tasks.txt"
done


# Import 
tasktide \
    manager \
        --repository-type "sqlite" \
        --file-path "$wrk/tasktide-sqlite" \
        --method "Import" \
        --delimiter "|" \
        --target "WORKITEM" \
        --step-name "ShortRunningJobs" \
        --target-file "$wrk/short-running-tasks.txt"

echo -e "SELECT Id, State, Collection FROM Items;" | sqlite3 tasktide-sqlite/WORKITEM/master


# Process tasks
$SOFT/bin/job-runner-task-tide.sh \
    --repository-type "sqlite" \
    --file-path "$wrk/tasktide-sqlite" \
    --target "WORKITEM" \
    --step-name "ShortRunningJobs" \
    --worker-pool-size "3" \
    --worker-window-size "3" \
    --item-task-threads "3"



# Submit 3 jobs processing 2 tasks each
mkdir -p $wrk/job-logs
rm -f $wrk/job-logs/Short-Running.log

sbatch \
    --job-name="ShortRunningJobs" \
    --array=1-3%2 \
    -t 1:00:00 -n 1 -c 3 \
    --output=$wrk/job-logs/Short-Running.log --error=$wrk/job-logs/Short-Running.log \
        ~/software/bin/job-runner-task-tide.sh \
            --repository-type "sqlite" \
            --file-path "$wrk/tasktide-sqlite" \
            --target "WORKITEM" \
            --step-name "ShortRunningJobs" \
            --worker-pool-size "2" \
            --worker-window-size "2"


JOB_ID="425066"
squeue -u $USER -j "$JOB_ID"
sacct -j "$JOB_ID"


watch -n 3 tail -n 50 job-logs/Short-Running.log



# Summarize workflow
tasktide \
    manager \
        --repository-type "sqlite" \
        --file-path "$wrk/tasktide-sqlite" \
        --method "Summarize" \
        --target "WORKITEM" \
        --step-name "ShortRunningJobs"



# Short running nested jobs
rm -f "$wrk/short-running-nested-tasks.txt" && touch "$wrk/short-running-nested-tasks.txt"

for i in $( echo -e "2 4 16 32 64 128" )
do
    echo -e "ShortRunning-$i|$SOFT/bin/time -v Rscript $SOFT/bin/stringVersion.R|$i,$i" >> "$wrk/short-running-nested-tasks.txt"
done

tasktide \
    manager \
        --repository-type "sqlite" \
        --file-path "$wrk/tasktide-sqlite" \
        --method "Import" \
        --delimiter "|" \
        --nested-delimiter "," \
        --target "WORKITEM" \
        --step-name "ShortRunningNestedJobs" \
        --target-file "$wrk/short-running-nested-tasks.txt"


# Submit tasks
~/software/bin/job-runner-task-tide.sh \
    --repository-type "sqlite" \
    --file-path "$wrk/tasktide-sqlite" \
    --target "WORKITEM" \
    --step-name "ShortRunningNestedJobs" \
    --worker-pool-size "2" \
    --worker-window-size "2" \
    --item-task-threads "2"



# Check progress
echo -e "SELECT Id, State, Collection FROM Items WHERE Collection = 'ShortRunningNestedJobs';" | sqlite3 tasktide-sqlite/WORKITEM/master

tasktide \
    manager \
        --repository-type "sqlite" \
        --file-path "$wrk/tasktide-sqlite" \
        --method "Summarize" \
        --target "WORKITEM" \
        --step-name "ShortRunningNestedJobs"


tasktide \
    manager \
        --repository-type "sqlite" \
        --file-path "$wrk/tasktide-sqlite" \
        --method "Summarize_By_Item_Task" \
        --target "WORKITEM" \
        --step-name "ShortRunningNestedJobs"

'''

WorkItem-fb8f189f-401b-4c3f-9b72-7c5b93f73dac|ToDo|ShortRunningNestedJobs
WorkItem-123257df-124e-4fa8-9692-a38401a9ec1c|ToDo|ShortRunningNestedJobs
WorkItem-d009f091-78aa-4016-893e-d5061285419a|ToDo|ShortRunningNestedJobs
WorkItem-0278f3ed-8f9c-4651-af96-734a960b086b|ToDo|ShortRunningNestedJobs
WorkItem-d9bf6099-3d19-4f10-a438-850c3ce1412c|Locked|ShortRunningNestedJobs
WorkItem-553096fd-520a-4b1b-8564-f820ae59bf70|Done|ShortRunningNestedJobs

"State Summary": {
    "TODO": 3,
    "LOCKED": 2,
    "FOR_UNLOCK": 0,
    "ERROR": 0,
    "DONE": 1
}


"State Summary": {
    "ERROR": 0,
    "DONE": 2,
    "FOR_UNLOCK": 0,
    "TODO": 8,
    "LOCKED": 2
}


"State Summary": {
    "LOCKED": 0,
    "DONE": 6,
    "ERROR": 0,
    "FOR_UNLOCK": 0,
    "TODO": 0
}

"State Summary": {
    "FOR_UNLOCK": 0,
    "LOCKED": 0,
    "TODO": 0,
    "DONE": 12,
    "ERROR": 0
}

'''

#################################
#################################
##
## ii). Long Running Jobs
##
#################################
#################################


# Long running sleep jobs
rm -f "$wrk/sleepTasks.txt" && touch "$wrk/sleepTasks.txt"
for i in $( echo -e "2 4 16 32 64 128" )
do
    echo -e "SleepJob-$i|python $SOFT/bin/python-sleepy.py $i" >> "$wrk/sleepTasks.txt"
done


# Import and measure baseline
tasktide \
     manager \
        --repository-type "sqlite" \
        --file-path "$wrk/tasktide-sqlite" \
        --method "Import" \
        --delimiter "|" \
        --target "WORKITEM" \
        --step-name "SleepJobs" \
        --target-file "$wrk/sleepTasks.txt"



# Submit 3 jobs processing 2 tasks each
rm -f $wrk/job-logs/Long-Running.log
sbatch \
    --job-name="Long-Running-Jobs" \
    --array=1-3%2 \
    -t 96:00:00 -n 1 -c 3 \
    --output=$wrk/job-logs/Long-Running.log --error=$wrk/job-logs/Long-Running.log \
    ~/software/bin/job-runner-task-tide.sh \
        --repository-type "sqlite" \
        --file-path "$wrk/tasktide-sqlite" \
        --target "WORKITEM" \
        --step-name "SleepJobs" \
        --worker-pool-size "2" \
        --worker-window-size "2" \
        --item-task-threads "2"


# Summarize workflow
tasktide \
    manager \
        --repository-type "sqlite" \
        --file-path "$wrk/tasktide-sqlite" \
        --method "Summarize_By_Item_Task" \
        --target "WORKITEM" \
        --step-name "SleepJobs"


JOB_ID="425103"
squeue -u $USER -j "$JOB_ID"
sacct -j $JOB_ID --format=JobID,JobName,State,Elapsed,AllocCPUS,ReqMem,MaxRSS,AveRSS,MaxVMSize,AveCPU



######################################################
######################################################
## 
## d). Workflow Mode
## 
######################################################
######################################################


# Configure workload
tasktide \
    manager \
        --repository-type "nosql" \
        --nosql-database-type "document" \
        --method "Add" \
        --step-name "Rscript-Jobs" \
        --workflow-name "Simple Examples" \
        --target "STEP"

tasktide \
    manager \
        --repository-type "nosql" \
        --nosql-database-type "document" \
        --method "Add" \
        --step-name "SleepJobs" \
        --workflow-name "Simple Examples" \
        --target "STEP"


# Import R version jobs
export wrk="/opt/tasktide-use-case"
cd $wrk

tasktide \
    manager \
        --repository-type "nosql" \
        --method "Import" \
        --delimiter "|" \
        --nested-delimiter "," \
        --target "WORKITEM" \
        --step-name "Rscript-Jobs" \
        --target-file "$wrk/stringVersionTasks.txt"


tasktide \
    manager \
        --repository-type "nosql" \
        --method "Import" \
        --delimiter "|" \
        --target "WORKITEM" \
        --step-name "SleepJobs" \
        --target-file "$wrk/sleepTasks.txt"



# Run sequential scanner
tasktide \
    engine \
        --repository-type "nosql" \
        --target "WORKITEM" \
        --step-name "Rscript-Jobs,SleepJobs" \
        --execution-policy "BATCH" \
        --worker-pool-size "1" \
        --worker-window-size "1" \
        --item-task-threads "1" \
        --result-set-size "2" \
        --acquisition-mode "SCANNER" \
        --strategy-type "ROUND_ROBIN" \
        --iteration-limit 4


