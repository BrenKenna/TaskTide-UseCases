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
    echo -e "ShortRunning-$i|$SOFT/time/time -v Rscript $SOFT/bin/stringVersion.R $i" >> "$wrk/short-running-tasks.txt"
done


# Import 
$SOFT/time/time -v \
    tasktide \
        manager \
            --repository-type "sqlite" \
            --file-path "$wrk/tasktide-sqlite" \
            --method "Import" \
            --delimiter "|" \
            --target "WORKITEM" \
            --step-name "ShortRunningJobs" \
            --target-file "$wrk/short-running-tasks.txt" \
> $wrk/import-baseline.txt 2>&1

echo -e "SELECT Id, State, Collection FROM Items;" | sqlite3 tasktide-sqlite/WORKITEM/master


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


squeue -u $USER -j 422785
sacct -j 422785


watch -n 10 tail -n 50 job-logs/Short-Running.log 


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
    echo -e "SleepJob-$i|$SOFT/time/time -v python $SOFT/bin/python-sleepy.py $i" >> "$wrk/sleepTasks.txt"
done



# Import and measure baseline
$SOFT/time/time -v \
    tasktide \
        manager \
            --repository-type "sqlite" \
            --file-path "$wrk/tasktide-sqlite" \
            --method "Import" \
            --delimiter "|" \
            --target "WORKITEM" \
            --step-name "SleepJobs" \
            --target-file "$wrk/sleepTasks.txt" \
> $wrk/import-baseline.txt 2>&1



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
        --worker-window-size "2"

