#!/bin/bash


###################################################################################
###################################################################################
## 
## Notes in the form of shell script for Bioinformatic Use Case Tests
## 
###################################################################################
###################################################################################


. ~/interactive.sh
. ~/start.sh


#####################################################
#####################################################
## 
## 1). Test TaskTide Sequence Alignment
##
## How would config validator look?
## Configure log dirs 
## 
#####################################################
#####################################################


# Configure tasks
cd $SAMPLE_META_DATA
sqlite3 $SAMPLE_META_DATA/sample-meta-data.db <<EOF

-- Clear Previous Run
DROP TABLE IF EXISTS AlignmentQueue;

-- Create queue
CREATE TABLE IF NOT EXISTS AlignmentQueue (
    WorkItemId TEXT,
    TaskScript TEXT
);

-- Insert Records
INSERT INTO AlignmentQueue
    SELECT
        CONCAT(SampleId, '-Alignment') AS 'WorkItemId',
        CONCAT(
            'bash /home/people/bkenna/software/bin/alignment-scripts/Alignment.sh ',
            CONCAT(
                SampleId,
                CONCAT(
                    ' ',
                    SourceBam
                )
            )
        ) AS 'Task'
    FROM
        SampleTracking 
    WHERE
        RealignedCram IS NULL
    ORDER BY
        RANDOM()
;


-- Sanity queue config
SELECT * FROM AlignmentQueue LIMIT 10;

EOF


# Fetch first two for testing
mkdir -p $DATA_DIR/logs/Alignment

echo -e "SELECT WorkItemId, TaskScript FROM AlignmentQueue ORDER BY RANDOM() LIMIT 200;" | \
  sqlite3 $SAMPLE_META_DATA/sample-meta-data.db \
> $SAMPLE_META_DATA/alignment-test-tasks.txt



# Import data
cd $DATA_DIR/jobs
rm -fr $TASK_TIDE/Bioinformatics/sqlite-repo
mkdir -p $TASK_TIDE/Bioinformatics/sqlite-repo

tasktide \
  manager \
    --repository-type "sqlite" \
    --file-path $TASK_TIDE/Bioinformatics/sqlite-repo \
    --step-name SequenceAlignment \
    --target-file $SAMPLE_META_DATA/alignment-test-tasks.txt \
    --delimiter '|' \
    --method "import"


# Sanity check before deployment
~/software/bin/job-runner-task-tide.sh \
  --repository-type "sqlite" \
  --file-path "$TASK_TIDE/Bioinformatics/sqlite-repo" \
  --target "WORKITEM" \
  --step-name "SequenceAlignment" \
  --worker-pool-size "1" \
  --worker-window-size "2"



# Submit jobs:  428716
rm -fr $JOBDIR/SequenceAlignment && \
  mkdir -p $JOBDIR/SequenceAlignment
rm -f $JOBDIR/SequenceAlignment-Pilot.log

sbatch \
    --job-name="SequenceAlignment" \
    --array=1-120%30 \
    -t "72:00:00" -n 1 -c 8 \
    --output=$JOBDIR/SequenceAlignment/SequenceAlignment-Pilot-%A_%a.log \
    --error=$JOBDIR/SequenceAlignment/SequenceAlignment-Pilot-%A_%a.log \
        ~/software/bin/job-runner-task-tide.sh \
            --repository-type "sqlite" \
            --file-path "$TASK_TIDE/Bioinformatics/sqlite-repo" \
            --target "WORKITEM" \
            --step-name "SequenceAlignment" \
            --worker-pool-size "2" \
            --worker-window-size "4"



# Check in on tasks on job:   439849
JOB_ID="439849"
squeue -u $USER -j "$JOB_ID"

sacct -j $JOB_ID --format=JobID,JobName,State,Elapsed,AllocCPUS,ReqMem,MaxRSS,AveRSS,MaxVMSize,AveCPU


echo -e "SELECT Payload FROM Items;" | \
  sqlite3 $TASK_TIDE/Bioinformatics/sqlite-repo/WORKITEM/master | \
    jq -s '[ .[] | {id: .Id, "ItemState": ."ItemState"} ]'


echo -e "SELECT Payload FROM Items;" | \
  sqlite3 $TASK_TIDE/Bioinformatics/sqlite-repo/WORKITEM/master | \
    jq -s '[ .[].Workload.Workload[]| {id: .id, "Task State": ."Task State"} ]'


echo "SELECT Id, State FROM Items WHERE State != 'ToDo';" | \
  sqlite3 $TASK_TIDE/Bioinformatics/sqlite-repo/WORKITEM/master


echo "SELECT State, COUNT(DISTINCT Id) as 'N Tasks' FROM Items WHERE Collection = 'SequenceAlignment' GROUP BY State;" | \
  sqlite3 $TASK_TIDE/Bioinformatics/sqlite-repo/WORKITEM/master


tasktide \
    manager \
        --repository-type "sqlite" \
        --file-path "$TASK_TIDE/Bioinformatics/sqlite-repo/" \
        --method "Summarize" \
        --target "WORKITEM" \
        --step-name "SequenceAlignment"



# Add column for samples previously fetched
echo -e "ALTER TABLE AlignmentQueue ADD COLUMN PreviouslyFetched INT DEFAULT 0;" | \
  sqlite3 $SAMPLE_META_DATA/sample-meta-data.db

for i in $( cat $SAMPLE_META_DATA/alignment-test-tasks.txt | cut -d \| -f 1)
do
  echo -e "UPDATE AlignmentQueue SET PreviouslyFetched = 0;" | \
    sqlite3 $SAMPLE_META_DATA/sample-meta-data.db
done



# Checkin on auto-enqueue
echo -e "SELECT Collection, State, COUNT(DISTINCT Id) FROM Items GROUP BY Collection, State;" | \
  sqlite3 $TASK_TIDE/Bioinformatics/sqlite-repo/WORKITEM/master 

grep "org.sqlite.SQLiteException"

'''

DedupBQSR|ToDo|24
SequenceAlignment|Done|24
SequenceAlignment|Locked|47
SequenceAlignment|ToDo|129



DedupBQSR|ToDo|193
SequenceAlignment|Done|193
SequenceAlignment|Error|2
SequenceAlignment|Locked|5

'''



#####################################################
#####################################################
## 
## 3). Test TaskTide DedupBQSR
##
## -> How would config validator look?
## -> Configure log dirs 
## -> Open resetting by step
## -> Add step label to ItemStore
## 
#####################################################
#####################################################


# Summarize State
echo "SELECT State, COUNT(DISTINCT Id) as 'N Tasks' FROM Items GROUP BY State;" | sqlite3 $TASK_TIDE/Bioinformatics/sqlite-repo/WORKITEM/master


# Fetch done
rm -f $SAMPLE_META_DATA/bams.txt
touch $SAMPLE_META_DATA/bams.txt
for cram in $(tree -fish $BAM | grep "cram$" | grep -ve "[0-9]K" -ve "gatk" | cut -d " " -f 3)
do
  if [ -f $cram.crai ]
  then
    base=$(basename $cram)
    id=$(echo $base | cut -d \. -f 1)
    echo -e "$id\t$base\t$cram" >> $SAMPLE_META_DATA/bams.txt
  fi
done


# Import data manifest
sqlite3 $SAMPLE_META_DATA/sample-meta-data.db <<EOF
CREATE TABLE IF NOT EXISTS BAM (
  IID TEXT,
  BASE TEXT,
  CRAM TEXT
);

.mode tabs
.separator "\t"
.import $SAMPLE_META_DATA/bams.txt BAM
SELECT * FROM BAM ORDER BY RANDOM() LIMIT 10;

EOF


# Annotate sample tracker
sqlite3 $SAMPLE_META_DATA/sample-meta-data.db <<EOF

-- Annotate Aligned Samples
UPDATE SampleTracking
  SET RealignedCram = (
    SELECT CRAM
      FROM BAM
      WHERE
        BAM.IID = SampleTracking.SampleId
  )
;


-- Clear Previous Run
DROP TABLE IF EXISTS DedupQueue;


-- Create queue
CREATE TABLE IF NOT EXISTS DedupQueue (
    WorkItemId TEXT,
    TaskScript TEXT
);


-- Insert Records
INSERT INTO DedupQueue
    SELECT
        CONCAT(SampleId, '-Dedup') AS 'WorkItemId',
        CONCAT(
            'bash /home/people/bkenna/software/bin/alignment-scripts/Dedup-BQSR.sh ',
            CONCAT(
                SampleId,
                CONCAT(
                    ' ',
                    RealignedCram
                )
            )
        ) AS 'Task'
    FROM
        SampleTracking 
    WHERE
        RealignedCram IS NOT NULL
    ORDER BY
        RANDOM()
;

EOF


# Fetch first two for testing
cd $TASK_TIDE
echo -e "SELECT * FROM DedupQueue ORDER BY RANDOM();" | sqlite3 $SAMPLE_META_DATA/sample-meta-data.db | while read i
do
  cram=$(echo $i | awk ' { print $NF} ')
  if [ -f $cram ]; then echo $i; fi
done > $SOFT/opt/java/tasktide-0.9.0/config/dedup-test-tasks.txt

wc -l $JAVA_MODULES/tasktide-0.9.0/config/dedup-test-tasks.txt

''' --> Just for reference
HG00701-Dedup|bash /home/people/bkenna/software/bin/alignment-scripts/Dedup-BQSR.sh HG00701 
HG01383-Dedup|bash /home/people/bkenna/software/bin/alignment-scripts/Dedup-BQSR.sh HG01383

10 /home/people/bkenna/software/opt/java/tasktide-0.9.0/config/dedup-test-tasks.txt


sqlite3 $TASK_TIDE/Bioinformatics/sqlite-repo/WORKITEM/master << EOF
DELETE FROM Items
WHERE Id IN (
  'WorkItem-99fc10f4-f4d7-4216-af09-dbe0a194524e',
  'WorkItem-5d05262a-d954-4cc2-8751-824e08efd8e1',
  'WorkItem-52877928-37da-48a0-8292-b419961bb4b7',
  'WorkItem-a5353a77-75f5-4619-8600-38217c113c2d',
  'WorkItem-315c5efd-2e19-48e5-a3aa-095fda27e6fc',
  'WorkItem-4f0a43d4-6f74-4922-9465-8ddc661595bc',
  'WorkItem-f1281be9-f42d-49d0-b6b8-d87f54227380',
  'WorkItem-81509708-13ab-4a02-9420-ac3b9f82f639',
  'WorkItem-2e2dc37d-53f4-4ad6-917a-021af028abbd',
  'WorkItem-0b559821-b68f-477a-9ab9-b5ad0075d491',
  'WorkItem-d82cc435-7b55-4455-9c03-9ff463017866',
  'WorkItem-fc7fa563-b3f9-42a5-a6a6-f5fefb901a96'
);
EOF


'''


# Import tasks
cd $TASK_TIDE
sed -i 's/tasktide.client=engine/tasktide.client=manager/' $TASK_TIDE_CONF
sed -i 's/tasktide.engine.step=Alignment/tasktide.engine.step=DedupBQSR/' $TASK_TIDE_CONF
sed -i 's/tasktide.manager.targetStep=Alignment/tasktide.manager.targetStep=DedupBQSR/' $TASK_TIDE_CONF
sed -i 's/tasktide.manager.inputFile=alignment.txt/tasktide.manager.inputFile=dedup-test-tasks.txt/g' $TASK_TIDE_CONF

tasktide


# Run engine
sed -i 's/tasktide.client=manager/tasktide.client=engine/' $TASK_TIDE_CONF

tasktide


# Run job:    131652
sbatch \
    --job-name="TaskTide-DedupBQSR-Test" \
    --array="1-10%3" \
    -t 72:00:00 -n 1 -c 9 \
    --output=$TASK_TIDE/logs/DedupBQSR-%a.log --error=$TASK_TIDE/logs/DedupBQSR-%a.log \
    $SOFT/bin/job-runner-task-tide.sh


# Check in on jobs: Index Step for ItemStore
sacct -j 131523
squeue -j 131523

echo -e "SELECT Payload FROM Items;" | sqlite3 $TASK_TIDE/Bioinformatics/sqlite-repo/WORKITEM/master | \
    jq -s '[ .[] | {id: .Id, "ItemState": ."ItemState"} ]'

echo -e "SELECT Payload FROM Items;" | sqlite3 $TASK_TIDE/Bioinformatics/sqlite-repo/WORKITEM/master | \
    jq -s '[ .[].Workload.Workload[]| {id: .id, "Task State": ."Task State"} ]'

echo "SELECT Id, State FROM Items WHERE State != 'ToDo';" | sqlite3 $TASK_TIDE/Bioinformatics/sqlite-repo/WORKITEM/master

echo "SELECT State, COUNT(DISTINCT Id) as 'N Tasks' FROM Items GROUP BY State;" | sqlite3 $TASK_TIDE/Bioinformatics/sqlite-repo/WORKITEM/master





# Sanity check script
coords=chr21:31659666-31668931
test=$BAM/HG01187/HG01187.sorted.cram
SM=HG01187

cd $BAM/HG01187/
rm -f HG01187.bqsr.log HG01187-Dedup.log HG01187.dedupMetrics.txt HG01187.dedup-sorted.bam HG01187.dedup-sorted.bam.bai

samtools view -T $b38_REF -hC $test $coords > $BAM/$SM/$SM.cram
samtools index $BAM/$SM/$SM.cram


bash $SOFT/bin/alignment-scripts/Dedup-BQSR.sh $SM $BAM/$SM/$SM.cram


bash $SOFT/bin/alignment-scripts/VariantCalling.sh HG01187 /scratch/bkenna/bam/HG01187/HG01187.final-gatk.cram





#####################################################
#####################################################
## 
## 4). General Use of TaskTide
##
## -> How would config validator look?
## -> Configure log dirs 
## -> Open resetting by step
## -> Add step label to ItemStore
## -> Custom annotations?
## -> Import file as Path, not resource stream
## 
#####################################################
#####################################################


# Databases
sampleDB=$SAMPLE_META_DATA/sample-meta-data.db
workItemDB=$TASK_TIDE/Bioinformatics/sqlite-repo/WORKITEM/master
taskDB=$TASK_TIDE/itemStore/client-args


# Run engine vs manager client
cd $TASK_TIDE
echo -e "SELECT * FROM AlignmentQueue ORDER BY RANDOM() LIMIT 13;" | sqlite3 $sampleDB > $TASK_TIDE/test-imports.txt


tasktide \
  manager \
  --repository-type "sqlite" \
  --file-path $taskDB \
  --step-name SequenceAlignment \
  --target-file $TASK_TIDE/test-imports.txt \
  --delimiter '|' \
  --method "import"



# Only sees to import?
tasktide \
  manager \
  --repository-type "sqlite" \
  --file-path $taskDB \
  --method "export" \
  --target "workItem" \
  --target-file $TASK_TIDE/workitems.json

wc workitems.json

rm -fr $taskDB/WORKITEM/*
tasktide \
  manager \
  --repository-type "sqlite" \
  --file-path $taskDB \
  --method "import" \
  --target "workItem" \
  --delimiter "json" \
  --target-file $TASK_TIDE/workitems.json

'''
0   235 19047 workitems.json
2025-08-21 16:48:00 INFO  [ main -> org.tasktide.tasktide.client.TaskTideManagerClient.importJson ]: Attempting to read JSON file:      '/scratch/bkenna/TaskTide/workitems.json'
2025-08-21 16:48:00 INFO  [ main -> org.tasktide.tasktide.client.TaskTideManagerClient.importJson ]: Streaming JSON data into WorkItem list
2025-08-21 16:48:00 INFO  [ main -> org.tasktide.tasktide.client.TaskTideManagerClient.importJson ]: Streamed JSON data into WorkItem list
2025-08-21 16:48:00 INFO  [ main -> org.tasktide.tasktide.client.TaskTideManagerClient.handleImport ]: Importing '13' workitems
2025-08-21 16:48:00 INFO  [ main -> org.tasktide.tasktide.client.TaskTideManagerClient.handleImport ]: Import status 'true'
'''

# Import single task
tasktide \
  manager \
  --repository-type "sqlite" \
  --file-path "$taskDB" \
  --step-name "Dedup" \
  --method "Add" \
  --import-string '{ "Task Name": "NA11892-Dedup", "Task Script": "bash /home/people/bkenna/software/bin/alignment-scripts/Dedup-BQSR.sh NA11892 /scratch/bkenna/bam/NA11892/NA11892.sorted.cram" }'

echo "SELECT Payload FROM Items WHERE Step = 'Step-7354b1fc-191b-4a50-aa88-041a4022e52d' LIMIT 1;" | \
  sqlite3 $taskDB/WORKITEM/master | \
  jq '{ Id: .Id, ItemName: .ItemName}'

'''

2|Step-7354b1fc-191b-4a50-aa88-041a4022e52d|PENDING|Workflow-303f6dbe-d687-4b14-9405-d593252bda44|{
    "StepCount": 0,
    "StepId": "Step-7354b1fc-191b-4a50-aa88-041a4022e52d",
    "StepName": "Dedup",
    "StepState": "PENDING",
    "StepsDone": 0,
    "StepsError": 0,
    "StepsLocked": 0,
    "StepsToDo": 0,
    "WorkflowId": "Workflow-303f6dbe-d687-4b14-9405-d593252bda44",
    "collection": "Workflow-303f6dbe-d687-4b14-9405-d593252bda44"
}

{
  "Id": "WorkItem-7d9c02bc-07c9-4602-8fa8-32014ce491ad",
  "ItemName": "NA11892-Dedup"
}
'''


# Append to work item
tasktide \
  manager \
  --repository-type "sqlite" \
  --file-path $taskDB \
  --method "Append" \
  --import-string '{ "WorkItemId": "WorkItem-cf1ffbbe-4bc3-408f-81ed-139e029ce249", "Task Name": "NA11892-Dedup", "Task Script": "bash /home/people/bkenna/software/bin/alignment-scripts/Dedup-BQSR.sh NA11892 /scratch/bkenna/bam/NA11892/NA11892.sorted.cram" }'

echo "SELECT Payload FROM Items WHERE Id = 'WorkItem-cf1ffbbe-4bc3-408f-81ed-139e029ce249';" | sqlite3 $taskDB/WORKITEM/master  | \
  jq '{ItemName: .ItemName, Id:.Id, TaskCount: .TaskCount, TaskName: [.Workload.Workload[]."Task Name"]}'

'''
{
  "ItemName": "NA11892-Alignment",
  "Id": "WorkItem-cf1ffbbe-4bc3-408f-81ed-139e029ce249",
  "TaskCount": 2,
  "TaskName": [
    "NA11892-Dedup",
    "NA11892-Alignment"
  ]
}
'''


# Run engine
tasktide \
  engine \
  --repository-type "sqlite" \
  --file-path $taskDB \
  --step-name SequenceAlignment




# Scoping DB
echo -e "SELECT Id, State, Step FROM Items LIMIT 3;" | sqlite3 $taskDB/WORKITEM/master

'''
WorkItem-7dbdabb1-1344-476b-8021-cc02b035d9fa|ToDo|SequenceAlignment
WorkItem-42963db2-1021-4acc-8b10-c33308ec1f21|ToDo|SequenceAlignment
WorkItem-40c5f03d-d21f-442a-b356-70a70420996c|ToDo|SequenceAlignment

WorkItem-9674ab7d-0f76-40e8-97f3-e37a17275a09|Locked|SequenceAlignment
'''


# Restart
tasktide \
  manager \
  --repository-type "sqlite" \
  --file-path "$taskDB" \
  --step-name "SequenceAlignment" \
  --method "Reset_Item" \
  --itemId "WorkItem-9674ab7d-0f76-40e8-97f3-e37a17275a09"

echo -e "SELECT Id, State, Step FROM Items WHERE Id = 'WorkItem-9674ab7d-0f76-40e8-97f3-e37a17275a09';" | sqlite3 $taskDB/WORKITEM/master


echo -e "SELECT Id FROM Items ORDER BY RANDOM() LIMIT 3;" | sqlite3 $taskDB/WORKITEM/master > $TASK_TIDE/reset-workitems.txt
tasktide \
  manager \
  --repository-type "sqlite" \
  --file-path "$taskDB" \
  --step-name "SequenceAlignment" \
  --method "Reset_Items" \
  --target-file $TASK_TIDE/reset-workitems.txt



'''
WorkItem-9674ab7d-0f76-40e8-97f3-e37a17275a09|ToDo|SequenceAlignment

'''
