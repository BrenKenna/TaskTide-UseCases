#!/bin/bash


###################################################################################
###################################################################################
## 
## Notes in the form of shell script for Bioinformatic Use Case Tests
## 
###################################################################################
###################################################################################


#####################################################
#####################################################
## 
## 1). Install TaskTide
## 
#####################################################
#####################################################


# TaskTide
rm -f $SOFT/bin/tasktide
cd $JAVA_MODULES
wget https://github.com/BrenKenna/TaskTide/releases/download/v0.9.0/tasktide-0.9.0.zip
tar -xvzf tasktide-0.9.0.zip
ln -sf $JAVA_MODULES/tasktide-0.9.0/bin/tasktide $SOFT/bin/tasktide

mkdir jnosql
mv lib/jnosql-arangodb-1.1.6.jar jnosql/
mv lib/jnosql-cassandra-1.1.6.jar jnosql/
mv lib/jnosql-couchbase-1.1.6.jar jnosql/
mv lib/jnosql-dynamodb-1.1.6.jar jnosql/
mv lib/jnosql-mongodb-1.1.6.jar jnosql/
mv lib/jnosql-redis-1.1.6.jar jnosql/
mv lib/jnosql-couchdb-1.1.6.jar jnosql/
mv lib/jnosql-mapping-graph-1.1.8.jar jnosql/
mv lib/jnosql-mapping-key-value-1.1.8.jar jnosql/
mv lib/jnosql-mapping-column-1.1.8.jar jnosql/


#####################################################
#####################################################
## 
## 2). Test TaskTide Installation
## 
#####################################################
#####################################################


# Test then clear zip
which tasktide
tasktide
rm -f tasktide-0.9.0.zip


# Check imported 
echo -e ".tables\n.schema" | sqlite3 $ITEMSTORE_SQL/WORKITEM/master
echo -e "SELECT Payload FROM Items;" | sqlite3 $ITEMSTORE_SQL/WORKITEM/master | jq -s '[.[] | { Id: .Id, ItemState: .ItemState }]'

'''
Items

CREATE TABLE Items(
        Auto_Id INTEGER PRIMARY KEY AUTOINCREMENT,
        Id TEXT UNIQUE NOT NULL,
        State TEXT NOT NULL,
        Payload TEXT NOT NULL
    );
CREATE TABLE sqlite_sequence(name,seq);

[
  {
    "Id": "WorkItem-5af2a975-7e51-4a6b-90e3-0b19be4b20a8",
    "ItemState": "TODO"
  },
  {
    "Id": "WorkItem-6d75e71a-dabb-4c63-add7-99b36146147c",
    "ItemState": "TODO"
  },
  {
    "Id": "WorkItem-2d2c58c7-17f4-47bf-9586-ae3c6d592319",
    "ItemState": "TODO"
  },
  {
    "Id": "WorkItem-0b4d7a4c-d0fe-462e-9284-b344531044d6",
    "ItemState": "TODO"
  },
  {
    "Id": "WorkItem-43aa6caf-5940-41d0-a477-e34077ee86bb",
    "ItemState": "TODO"
  }
]
'''


# Launch engine in a job
sed -i 's/^tasktide\.client=manager$/tasktide.client=engine/' $TASK_TIDE_CONF

sbatch \
    --job-name="TaskTide-Engine-Test" \
    -t 08:00:00 -n 1 -c 3 \
    --output=$TASK_TIDE/logs/Batch-Job.log --error=$TASK_TIDE/logs/Batch-Job.log \
    job-runner-task-tide.sh


# Check in on tasks on job
echo -e "SELECT Payload FROM Items;" | sqlite3 $ITEMSTORE_SQL/WORKITEM/master | \
    jq -s '[ .[] | .Workload.Workload[] | {id: .id, "Task State": ."Task State"} ]'


squeue -j 130700
sacct -j 130700
scontrol show job 130700


''' --> Worked perfectly

JobID           JobName  Partition    Account  AllocCPUS      State ExitCode 
------------ ---------- ---------- ---------- ---------- ---------- --------
130700       TaskTide-+     shared shared_acc          3  COMPLETED      0:0
130700.batch      batch            shared_acc          3  COMPLETED      0:0
130700.exte+     extern            shared_acc          3  COMPLETED      0:0


[
  {
    "Id": "ItemTask-0d4d4f91-17e8-4e06-be15-2693e7b2e50e",
    "Task": "seq 3",
    "Task State": "COMPLETE"
  },
  {
    "Id": "ItemTask-1f7e4a0f-b259-4ae9-a2d0-e9b870e016c9",
    "Task": "seq 10",
    "Task State": "COMPLETE"
  },
  {
    "Id": "ItemTask-acf491cc-b55b-42a7-92e9-08622da5dfb6",
    "Task": "seq cherp",
    "Task State": "ERROR"
  },
  {
    "Id": "ItemTask-3df9c4ef-cc53-4fff-8f5d-7421da3e1d60",
    "Task": "seq dcu.ie",
    "Task State": "ERROR"
  }
]

'''


# Run with rocksDB
sed -i 's/^tasktide\.client=manager$/tasktide.client=engine/' $TASK_TIDE_CONF

sbatch \
    --job-name="TaskTide-Engine-Test-RocksDB" \
    -t 08:00:00 -n 1 -c 3 \
    --output=$TASK_TIDE/logs/Batch-Job-RocksDB.log --error=$TASK_TIDE/logs/Batch-Job-RocksDB.log \
    job-runner-task-tide.sh


sacct -j 130707
$ROCKS_CLI/ldb --db=$ITEMSTORE_ROCKS/WORKITEM dump | jq | head


''' --> Should also be fine now

JobID           JobName  Partition    Account  AllocCPUS      State ExitCode 
------------ ---------- ---------- ---------- ---------- ---------- --------
130707       TaskTide-+     shared shared_acc          3  COMPLETED      0:0
130707.batch      batch            shared_acc          3  COMPLETED      0:0
130707.exte+     extern            shared_acc          3  COMPLETED      0:0


'''




#####################################################
#####################################################
## 
## 2). Test TaskTide Sequence Alignment
##
## How would config validator look?
## Configure log dirs 
## 
#####################################################
#####################################################


# Configure tasks
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
cd $TASK_TIDE
echo -e "SELECT * FROM AlignmentQueue LIMIT 30;" | sqlite3 $SAMPLE_META_DATA/sample-meta-data.db > $SOFT/opt/java/tasktide-0.9.0/config/alignment-test-tasks.txt
wc -l $SOFT/opt/java/tasktide-0.9.0/config/alignment-test-tasks.txt

''' --> Just for reference
HG00626-Alignment|bash /home/people/bkenna/software/bin/alignment-scripts/Alignment.sh HG00626 https://ftp-trace.ncbi.nih.gov/1000genomes/ftp/technical/other_exome_alignments/HG00626/exome_alignment/HG00626.mapped.illumina.mosaik.CHS.exome.20111114.bam
HG00335-Alignment|bash /home/people/bkenna/software/bin/alignment-scripts/Alignment.sh HG00335 https://ftp-trace.ncbi.nih.gov/1000genomes/ftp/technical/other_exome_alignments/HG00335/exome_alignment/HG00335.mapped.illumina.mosaik.FIN.exome.20111114.bam

2 /scratch/bkenna/TaskTide/alignment-test-tasks.txt
'''


# Import data
cp $TASK_TIDE_CONF.bak $TASK_TIDE_CONF 
cp $TASK_TIDE_CONF $TASK_TIDE_CONF.bak

sed -i 's/tasktide.client=engine/tasktide.client=manager/' $TASK_TIDE_CONF
sed -i 's#tasktide.manager.inputFile=singleTaskImports.txt#tasktide.manager.inputFile=alignment-test-tasks.txt#g' $TASK_TIDE_CONF

sed -i 's/tasktide.manager.targetStep=myStep/tasktide.manager.targetStep=Alignment/' $TASK_TIDE_CONF
sed -i 's/tasktide.manager.nestedDelimiter=,//' $TASK_TIDE_CONF

sed -i 's/tasktide.core.repository.type=rocksDB/tasktide.core.repository.type=sqlite/' $TASK_TIDE_CONF
sed -i 's#tasktide.core.repository.file-path=/scratch/bkenna/TaskTide/itemStore/rocksDB#tasktide.core.repository.file-path=/scratch/bkenna/TaskTide/itemStore/sqlite#' $TASK_TIDE_CONF

sed -i 's/tasktide.engine.step=derp,myStep,berp/tasktide.engine.step=Alignment/' $TASK_TIDE_CONF


# Import tasks
cd $TASK_TIDE
rm -fr itemStore/ sqliteDbStore/
sed -i 's/tasktide.client=engine/tasktide.client=manager/' $TASK_TIDE_CONF
tasktide

''' --> Needs some work here, JSON  vs FILE as format, display where. 

## - Argument Handling
## - Table backup before action? Towards oopsies

2025-08-15 16:53:57 INFO  [ main -> org.tasktide.core.repository.itemstore_repo.ItemStoreRepositoryUtility.fetchItemStore ]: ItemStore Directory created under: 'sqliteDbStore/STEP'
2025-08-15 16:53:57 INFO  [ main -> org.tasktide.core.repository.itemstore_repo.ItemStoreRepositoryUtility.fetchItemStore ]: ItemStore Directory created under: 'sqliteDbStore/WORKFLOW'        
2025-08-15 16:53:57 INFO  [ main -> org.tasktide.tasktide.TaskTide.main ]: ServiceManager state is now: 'true'
2025-08-15 16:53:57 INFO  [ main -> org.tasktide.tasktide.TaskTide.main ]: Constructing client: 'Manager'
2025-08-15 16:53:57 INFO  [ main -> org.tasktide.tasktide.client.TaskTideManagerClient.importFile ]: Evaluating nested delimiter of value 'null'
2025-08-15 16:53:57 INFO  [ main -> org.tasktide.tasktide.client.TaskTideManagerClient.handleImport ]: Importing '2' workitems
2025-08-15 16:53:57 INFO  [ main -> org.tasktide.tasktide.client.TaskTideManagerClient.handleImport ]: Import status 'true'
2025-08-15 16:53:57 INFO  [ main -> org.tasktide.tasktide.TaskTide.main ]: TaskTideClient completed, tearing down container

'''


# Run engine as two separate elements in job array: Left out engine.step
sed -i 's/tasktide.client=manager/tasktide.client=engine/' $TASK_TIDE_CONF

sbatch \
    --job-name="TaskTide-DedupBQSR-Test" \
    --array="1-10%3" \
    -t 48:00:00 -n 1 -c 9 \
    --output=$TASK_TIDE/logs/DedupBQSR-%a.log --error=$TASK_TIDE/logs/DedupBQSR-%a.log \
    $SOFT/bin/job-runner-task-tide.sh

sacct -j 131125
squeue -j 131125

''' --> Arbitray does get pulled

JobID           JobName  Partition    Account  AllocCPUS      State ExitCode 
------------ ---------- ---------- ---------- ---------- ---------- --------
131079_1     TaskTide-+     shared shared_acc          8    RUNNING      0:0
131079_1.ba+      batch            shared_acc          8    RUNNING      0:0
131079_1.ex+     extern            shared_acc          8    RUNNING      0:0
131079_2     TaskTide-+     shared shared_acc          0    PENDING      0:0

2025-08-15 17:02:44 INFO  [ main -> org.tasktide.tasktide.TaskTide.main ]: ServiceManager state is now: 'true'
2025-08-15 17:02:44 INFO  [ main -> org.tasktide.tasktide.TaskTide.main ]: Constructing client: 'Engine'
2025-08-15 17:02:44 INFO  [ main -> org.tasktide.tasktide.client.TaskTideEngineClient.fetchAndRun ]: Determing how to process workload
2025-08-15 17:02:44 INFO  [ main -> org.tasktide.tasktide.client.TaskTideEngineClient.fetchAndRun ]: Processing single step:    'Arbitrary'
2025-08-15 17:02:44 WARN  [ main -> org.tasktide.tasktide.client.TaskTideEngineClient.processWorkload ]: Warning, no ToDo tasks available for processing. Query below backend for more information

{Collection Name=WorkItem-Service, Model Class=WorkItem, Repository Type=Item Store}


2025-08-15 17:02:44 INFO  [ main -> org.tasktide.tasktide.client.TaskTideEngineClient.fetchAndRun ]: Processing complete for step:      'Arbitrary'
2025-08-15 17:02:44 INFO  [ main -> org.tasktide.tasktide.TaskTide.main ]: TaskTideClient completed, tearing down container

'''


# Check in on tasks on job: Single threaded run
sacct -j 131125
squeue -j 131125


echo -e "SELECT Payload FROM Items;" | sqlite3 $ITEMSTORE_SQL/WORKITEM/master | \
    jq -s '[ .[] | {id: .Id, "ItemState": ."ItemState"} ]'

echo -e "SELECT Payload FROM Items;" | sqlite3 $ITEMSTORE_SQL/WORKITEM/master | \
    jq -s '[ .[].Workload.Workload[]| {id: .id, "Task State": ."Task State"} ]'

echo "SELECT Id, State FROM Items WHERE State != 'ToDo';" | sqlite3 $ITEMSTORE_SQL/WORKITEM/master

echo "SELECT State, COUNT(DISTINCT Id) as 'N Tasks' FROM Items GROUP BY State;" | sqlite3 $ITEMSTORE_SQL/WORKITEM/master


ls -lht /tmp/bkenna/130860/*/*

''' --> All is well, logs do not immediately start to write. Takes a while for files to write

             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
   131091_[4-10%3]    shared TaskTide   bkenna PD       0:00      1 (JobArrayTaskLimit)
          131091_1    shared TaskTide   bkenna  R      12:49      1 sonic52
          131091_2    shared TaskTide   bkenna  R      12:49      1 sonic72
          131091_3    shared TaskTide   bkenna  R      12:49      1 sonic60


WorkItem-e7735a39-ee78-4c3b-a8cc-9b76d0462b52|Locked
WorkItem-e5356468-b062-4c1a-8cfc-e87fba026cf6|Locked
WorkItem-950a4034-01ea-4173-84cf-45db4169947f|Locked

/tmp/bkenna/130860/HG00626-Alignment:
total 1.5G
-rw-r--r--. 1 bkenna shared 1.5G Aug 15 17:46 HG00626.mapped.illumina.mosaik.CHS.exome.20111114.bam

/tmp/bkenna/130860/HG00335-Alignment:
total 0

Done|26
Locked|4

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
echo "SELECT State, COUNT(DISTINCT Id) as 'N Tasks' FROM Items GROUP BY State;" | sqlite3 $ITEMSTORE_SQL/WORKITEM/master


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


sqlite3 $ITEMSTORE_SQL/WORKITEM/master << EOF
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

echo -e "SELECT Payload FROM Items;" | sqlite3 $ITEMSTORE_SQL/WORKITEM/master | \
    jq -s '[ .[] | {id: .Id, "ItemState": ."ItemState"} ]'

echo -e "SELECT Payload FROM Items;" | sqlite3 $ITEMSTORE_SQL/WORKITEM/master | \
    jq -s '[ .[].Workload.Workload[]| {id: .id, "Task State": ."Task State"} ]'

echo "SELECT Id, State FROM Items WHERE State != 'ToDo';" | sqlite3 $ITEMSTORE_SQL/WORKITEM/master

echo "SELECT State, COUNT(DISTINCT Id) as 'N Tasks' FROM Items GROUP BY State;" | sqlite3 $ITEMSTORE_SQL/WORKITEM/master





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
workItemDB=$ITEMSTORE_SQL/WORKITEM/master
taskDB=$TASK_TIDE/itemStore/client-args


# Run engine vs manager client
echo -e "SELECT * FROM AlignmentQueue ORDER BY RANDOM() LIMIT 10;" | sqlite3 $sampleDB > $JAVA_MODULES/tasktide-0.9.0/config/test-imports.txt


tasktide \
  --client manager \
  --repository-type "sqlite" \
  --inputFile $JAVA_MODULES/tasktide-0.9.0/config/test-imports.txt \
  --target-step SequenceAlignment \
  --delimiter '|' \
  --method "input"


# Only sees to import?
tasktide \
  --client manager \
  --repository-type "sqlite" \
  --method export \
  --output-file $JAVA_MODULES/tasktide-0.9.0/config/test-exports.txt \
  --target-step SequenceAlignment



# Run engine
tasktide \
  --client engine \
  --repository-type "sqlite" \
  --step SequenceAlignment


