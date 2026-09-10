#!/bin/bash


######################################################
######################################################
## 
## 1). Sanity Check
## 
######################################################
######################################################


# Configure
. ~/interactive.sh
. ~/start.sh

cd $DATA_DIR/image-analysis


# Start session
sparkR \
    --master local[*] \
    --deploy-mode client


```{r-base}

library(imageAnalysis)


imagePath = "./stacker-image.png"
parquetPath = "./stacker-parquet"
height = 350
width = 625


app <- imageAnalysis:::ImageStacker$new(
    output_image = imagePath,
    height = height,
    width = width
)


app$run(
    redExpr = "0",
    greenExpr = "CAST(xVals * 255 / 3000 AS INT)",
    blueExpr = "CAST(yVals * 255 / 1500 AS INT)",
    parquetPath = parquetPath,
    imagePath = imagePath
)


'''

2026-06-04 14:48:05 INFO  [ UseCases.ImageAnalysis.ImageStacker.run ]:  ================ Initiating ImageStacker Job ================
2026-06-04 14:48:05 INFO  [ UseCases.ImageAnalysis.ImageStacker.startSpark ]:   Starting Spark session with RAPIDS enabled
2026-06-04 14:48:06 INFO  [ UseCases.ImageAnalysis.ImageStacker.run ]:  Creating pixel grid
2026-06-04 14:48:07 INFO  [ UseCases.ImageAnalysis.ImageStacker.run ]:  Colorizing image
2026-06-04 14:48:07 INFO  [ UseCases.ImageAnalysis.ImageStacker.run ]:  Stiching image for parquet/png export
2026-06-04 14:48:07 INFO  [ UseCases.ImageAnalysis.ImageStacker.run ]:  Storing image to parquet
2026-06-04 14:48:17 INFO  [ UseCases.ImageAnalysis.ImageStacker.run ]:  Saving image from parquet to file
2026-06-04 14:48:47 INFO  [ UseCases.ImageAnalysis.ImageStacker.run ]:  ================ Completed ImageStacker Job Successfully ================

'''

```


# From script
spark-submit \
    --master local[*] \
    ~/software/bin/image-generator.R \
        ./stacker-image-rscript.png \
        ./stacker-parquet-rscript \
        "0" \
        "CAST(xVals * 255 / 3000 AS INT)" \
        "CAST(yVals * 255 / 1500 AS INT)"


'''

Spark package found in SPARK_HOME: /home/people/bkenna/software/spark-3.5.6
26/06/05 12:23:09 INFO SparkContext: Running Spark version 3.5.6
26/06/05 12:23:09 INFO SparkContext: OS info Linux, 5.14.0-570.33.2.el9_6.x86_64, amd64
26/06/05 12:23:09 INFO SparkContext: Java version 17.0.11
26/06/05 12:23:10 WARN NativeCodeLoader: Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
26/06/05 12:23:10 INFO ResourceUtils: ==============================================================
26/06/05 12:23:10 INFO ResourceUtils: No custom resources configured for spark.driver.
26/06/05 12:23:10 INFO ResourceUtils: ==============================================================
26/06/05 12:23:10 INFO SparkContext: Submitted application: SparkR

Java ref type org.apache.spark.sql.SparkSession id 1 
2026-06-05 12:23:13 INFO  [ UseCases.ImageAnalysis.ImageStacker.run ]:  ================ Initiating ImageStacker Job ================
2026-06-05 12:23:13 INFO  [ UseCases.ImageAnalysis.ImageStacker.startSpark ]:   Starting Spark session with RAPIDS enabled
2026-06-05 12:23:13 INFO  [ UseCases.ImageAnalysis.ImageStacker.run ]:  Creating pixel grid
2026-06-05 12:23:15 INFO  [ UseCases.ImageAnalysis.ImageStacker.run ]:  Colorizing image
2026-06-05 12:23:15 INFO  [ UseCases.ImageAnalysis.ImageStacker.run ]:  Stiching image for parquet/png export
2026-06-05 12:23:15 INFO  [ UseCases.ImageAnalysis.ImageStacker.run ]:  Storing image to parquet

'''



######################################################
######################################################
## 
## 2). Configure Workload
## 
######################################################
######################################################


############################################
############################################
##
## a). Setup Tasks
##
############################################
############################################


# Configure params
export wrk=$DATA_DIR/image-analysis
step="ImageStacker"
width="325"
heigth="650"

cd $wrk
mkdir -p $wrk/results/parquet/ $wrk/results/images/


# Grid a set of tasks
rm -f $wrk/tasks.txt
touch $wrk/tasks.txt
for i in $( seq 300 )
do
    redExpr=$(( RANDOM % 255 ))
    greenExpr=$(( RANDOM % 255 ))
    blueExpr=$(( RANDOM % 255 ))
    parquetPath=$wrk/results/parquet/image-$i
    imagePath=$wrk/results/images/image-$i.png

    taskName="ImageAnalysis-$i"
    taskScript="bash $SOFT/bin/ImageAnalysis-Runner.sh"
    taskArgs=$(printf \
        "\"%s\" \"%s\" \"%s\" \"%s\" \"%s\" " \
        "$imagePath" "$parquetPath" \
        "$redExpr" "$greenExpr" "$blueExpr"
    )

    echo "$taskName|$taskScript $taskArgs" >> $wrk/tasks.txt
done




############################################
############################################
##
## b). Sanity Check With A Few
##
############################################
############################################


# Fetch first few
rm -fr "$wrk/tasktide-rocksDB" "$wrk/tasktide-sqlite"
sort -R "$wrk/tasks.txt" | head -n 4 > $wrk/confirm.txt

tasktide \
    manager \
    --repository-type "sqlite" \
    --file-path "$wrk/tasktide-sqlite" \
    --target "WORKITEM" \
    --step-name "$step" \
    --method "Import" \
    --target-file "$wrk/confirm.txt"


# Run engine
tasktide \
    engine \
    --repository-type "sqlite" \
    --file-path "$wrk/tasktide-sqlite" \
    --target "WORKITEM" \
    --step-name "$step" \
    --worker-pool-size "1" \
    --worker-window-size "2"



# Export workload
rm -f "$wrk/$step.json"
tasktide \
    manager \
    --repository-type "rocksDB" \
    --file-path "$wrk/tasktide-rocksDB" \
    --target "WORKITEM" \
    --step-name "$step" \
    --method "Export" \
    --target-file "$wrk/$step.json"






######################################################
######################################################
## 
## 2). Deploy Workload
## 
######################################################
######################################################



############################################
############################################
##
## a). Task Scheduling
## 
############################################
############################################


# Configure paths
mkdir -p \
    $TASK_TIDE/ImageAnalysis $JOBDIR/ImageAnalysis

tasktide \
    manager \
    --repository-type "sqlite" \
    --file-path "$TASK_TIDE/ImageAnalysis/sqlite-repo" \
    --target "WORKITEM" \
    --step-name "ImageAnalysis" \
    --method "Import" \
    --target-file "$wrk/tasks.txt"



############################################
############################################
##
## b). Job Submission
## 
## - 30 Jobs, 10 at a time
## - Short queue, light resource use
## 
############################################
############################################


# Configure pilot job
rm -fr \
    $JOBDIR/ImageAnalysis  rm -f $JOBDIR/ImageAnalysis-Pilot.log

mkdir -p $JOBDIR/ImageAnalysis


# Submit pilot job
sbatch \
    --job-name="ImageAnalysis" \
    --array=1-30%10 \
    -t "1:00:00" -n 1 -c 8 \
    --output=$JOBDIR/ImageAnalysis/ImageAnalysis-Pilot-%A_%a.log \
    --error=$JOBDIR/ImageAnalysis/ImageAnalysis-Pilot-%A_%a.log \
        ~/software/bin/job-runner-task-tide.sh \
            --repository-type "sqlite" \
            --file-path "$TASK_TIDE/ImageAnalysis/sqlite-repo" \
            --target "WORKITEM" \
            --step-name "ImageAnalysis" \
            --worker-pool-size "2" \
            --worker-window-size "4"


# Monitor job
JOB_ID="440033"
squeue -u $USER -j "$JOB_ID"

sacct -j $JOB_ID --format=JobID,JobName,State,Elapsed,AllocCPUS,ReqMem,MaxRSS,AveRSS,MaxVMSize,AveCPU
