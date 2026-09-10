# imageAnalysis

An R data-science and matrix manipulation package tailored for scientific image analysis workloads. This package is structured as a fully compliant R ecosystem module designed to operate as an external computational task orchestrated by the TaskTide engine.

---

## 🔬 Research Significance & Pipeline Integration
Image analysis routines represent some of the heaviest and most frequent execution blocks inside modern scientific computing frameworks (such as bio-imaging, spatial geography data meshes, and astronomical signal processing). 

The `imageAnalysis` package demonstrates how researchers can seamlessly couple native R matrix structures and image extraction algorithms directly into a distributed runtime environment. By executing this module via the **TaskTide Workflow Orchestration Engine**, researchers can safely track execution state, log pipeline lifecycles, and maintain strict data reproducibility without relying on heavy cloud configuration daemons.

* **Core Platform Engine:** Powered by [TaskTide](https://github.tasktide.org).
* **Documentation Portal:** Review complete deployment schemas at [tasktide.org](https://tasktide.org).

---

## 🚀 Installation & Prerequisites

### System Prerequisites
To run the automated analysis components, ensure you have an active R environment installed on your machine:
* **R:** Version `>= 4.0.0` is highly recommended.

### Package Installation
Because this repository is formatted natively using a valid standard R package layout (`DESCRIPTION` and `NAMESPACE` files), you can install it and its underlying dependencies directly through your R console environment:

```R
# Inside an active R Console or RStudio session:
install.packages("remotes")
remotes::install_local(".")
```

Alternatively, you can compile the package binary directly from your command-line terminal:
```bash
R CMD build .
R CMD INSTALL imageAnalysis_*.tar.gz
```

---

## 💻 Running the Program

### 1. Manual Script Execution
You can invoke individual structural matrix workflows or call the background computational script explicitly using `Rscript`:
```bash
spark-submit \
    --master local[*] \
    ./image-generator.R \
        ./stacker-image-rscript.png \
        ./stacker-parquet-rscript \
        "0" \
        "CAST(xVals * 255 / 3000 AS INT)" \
        "CAST(yVals * 255 / 1500 AS INT)"
```


### ⚙️ TaskTide CLI Orchestration Examples
To append this image processing suite directly into a broader data architecture mesh managed by TaskTide, map your runtime inputs via the CLI layer:


Register ***ImageStacker*** step under ***ImageAnalysis*** workflow.
```bash
tasktide \
    manager \
        --repository-type "nosql" \
        --nosql-database-type "document" \
        --method "Add" \
        --step-name "ImageStacker" \
        --workflow-name "ImageAnalysis" \
        --target "STEP"
```

Configure a set of 300 random image stacker tasks for TaskTide
```bash

# Configure params
export wrk=$DATA_DIR/image-analysis
step="ImageStacker"
width="325"
heigth="650"

cd $wrk
mkdir -p $wrk/results/parquet/ $wrk/results/images/


# Grid a set of tasks
rm -f $wrk/tasks.txt && touch $wrk/tasks.txt
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
```


Register first few tasks and sanity checking deployment
```bash

# Register first 4
rm -fr "$wrk/tasktide-rocksDB" "$wrk/tasktide-sqlite"
head -n 4 "$wrk/tasks.txt" > $wrk/confirm.txt
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
```


Deploy full workload under a pilot job fleet on HPC using de-centralized leader election against SQLite repository.
```bash
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


# Configure pilot job fleet
rm -fr \
    $JOBDIR/ImageAnalysis  rm -f $JOBDIR/ImageAnalysis-Pilot.log
mkdir -p $JOBDIR/ImageAnalysis
sbatch \
    --job-name="ImageAnalysis" \
    --array=1-10%5 \
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
squeue -u $USER -j "$JOB_ID"
sacct -j $JOB_ID --format=JobID,JobName,State,Elapsed,AllocCPUS,ReqMem,MaxRSS,AveRSS,MaxVMSize,AveCPU
```
---

## 🔗 Resources & Connected Ecosystem
* **Official Website:** [TaskTide Core Systems](https://tasktide.org)
* **Core Source Code Infrastructure:** [TaskTide GitHub](https://github.tasktide.org)
* **Developer API Documentation:** [TaskTide System Architecture Docs](https://api-docs.tasktide.org)
