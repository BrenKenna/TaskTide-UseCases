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
## 1). Install TaskTide & Use-Case
## 
#####################################################
#####################################################


#################################
#################################
## 
## a). TaskTide
## 
#################################
#################################


# TaskTide
cd $JAVA_MODULES
mv ~/tasktide-0.9.0.zip ./
# wget https://github.com/BrenKenna/TaskTide/releases/download/v0.9.0/tasktide-0.9.0.zip
rm -fr tasktide-0.9.0
unzip tasktide-0.9.0.zip && rm -f tasktide-0.9.0.zip && cd tasktide-0.9.0
rm -f $SOFT/bin/tasktide
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

cp $TASK_TIDE/microprofile-config.properties $TASK_TIDE_CONF
cd $TASK_TIDE



#################################
#################################
## 
## b). Task Binding Use Case
## 
#################################
#################################


# Install FunctionRunner
cd $JULIA_MODULES

tar -xvf FunctionRunnerSandBox.tar.gz

singularity --version
singularity exec \
  --writable \
  --pwd /opt/julia \
  --env JULIA_DEPOT_PATH=/opt/julia/.julia \
  --env JULIA_PKG_PRECOMPILE_DIR=/opt/julia/.julia/compiled \
  $JULIA_MODULES/FunctionRunnerSandBox \
  julia --project=/opt/julia ./src/FunctionRunner.jl \
      --operation="N0pMHgQAAAA5IaJmdW5jdGlvbiBteVNlcmRlRnVuYyhwYXJhbXMuLi47IFBhcnNlVG9UeXBlOjpUeXBlPUludCkKICAgIHBhcnNlZCA9IG1hcCgKICAgICAgICBlbG0gLT4gcGFyc2UoUGFyc2VUb1R5cGUsIGVsbSksCiAgICAgICAgcGFyYW1zCiAgICApCiAgICByZXR1cm4gcHJvZChwYXJzZWQpCmVuZAo=" \
      --parameters="N0pMHgQAAAAhBDE4IDc="

'''

singularity version 3.8.6

2025-10-24 11:52:58 INFO  [ FunctionRunner.jl -> FunctionRunner.main ]:         Parsing command-line arguments
2025-10-24 11:52:59 INFO  [ FunctionRunner.jl -> FunctionRunner.main ]:         Deserializing function
2025-10-24 11:53:00 INFO  [ FunctionRunner.jl -> FunctionRunner.main ]:         Deserializied function shown below:  mySerdeFunc

# 1 method for generic function "mySerdeFunc" from Main.FunctionRunner.FunctionRunnerSerDe:
 [1] mySerdeFunc(params...; ParseToType)
     @ none:1

2025-10-24 11:53:00 INFO  [ FunctionRunner.jl -> FunctionRunner.main ]:         Deserializing function parameters
2025-10-24 11:53:01 INFO  [ FunctionRunner.jl -> FunctionRunner.main ]:         SubString{String}["18", "7"]
2025-10-24 11:53:01 INFO  [ FunctionRunner.jl -> FunctionRunner.main ]:         Determining whether to serialize results
2025-10-24 11:53:01 INFO  [ FunctionRunner.jl -> FunctionRunner.main ]:         Determining where to direct results to
2025-10-24 11:53:01 INFO  [ FunctionRunner.jl -> FunctionRunner.main ]:         No target file provided, returning result
2025-10-24 11:53:01 INFO  [ FunctionRunner.jl -> FunctionRunner.main ]:         --- FUNCTION RUNNER OUTPUT ---

126

--- FUNCTION RUNNER OUTPUT ---
2025-10-24 11:53:01 INFO  [ FunctionRunner.jl -> FunctionRunner.main ]:         Processing completed

'''



# Install image analysis app
conda-forge::r-devtools

cd GitHub/TaskTide/tasktide/use-cases/task-binding-use-case/imageAnalysis
export SPARK_HOME="~/Documents/Spark/spark-3.5.6"
export R_LIBS="~/DpcumentsSpark/spark-3.5.6/R/lib"


```{r-base}

# Locally
setwd("C:/Users/Brendan Kenna/Documents/GitHub/TaskTide/tasktide/use-cases/task-binding-use-case/imageAnalysis")
.libPaths("C:/Users/Brendan Kenna/Documents/Spark/spark-3.5.6/R/lib")
devtools::document()

library(imageAnalysis)

logger = Logger$new()
logger$logFormat("MOCK-INFO", "Test", "main", "I can format")
logger$info("Test", "main", "I can print INFO")
logger$warn("Test", "main", "I can print WARN")
logger$error("Test", "main", "I can print ERROR")


# Installation
devtools::install(
    "/home/people/bkenna/software/opt/r/imageAnalysis",
    lib = "/home/people/bkenna/software/opt/r"
)
library(imageAnalysis)

ls(
    getNamespace("imageAnalysis"),
    all.names = TRUE
)


logger <- imageAnalysis:::Logger$new()
logger$info("Test", "main", "I can print INFO")
logger$warn("Test", "main", "I can print WARN")
logger$error("Test", "main", "I can print ERROR")

'''
2025-10-17 16:25:32 INFO  [ Test.main ]:        I can print INFO
2025-10-17 16:25:32 WARN  [ Test.main ]:        I can print WARN
2025-10-17 16:25:32 ERROR [ Test.main ]:        I can print ERROR
'''

```


#################################
#################################
## 
## c). Spark
## 
#################################
#################################


# Install spark
cd $SOFT
wget https://archive.apache.org/dist/spark/spark-3.5.6/spark-3.5.6-bin-hadoop3-scala2.13.tgz
tar -xzf spark-3.5.6-bin-hadoop3-scala2.13.tgz \
    && mv spark-3.5.6-bin-hadoop3-scala2.13 spark-3.5.6


# Fetch RAPIDS and XGBoost
wget https://repo1.maven.org/maven2/com/nvidia/rapids-4-spark_2.13/25.08.0/rapids-4-spark_2.13-25.08.0.jar
wget https://repo1.maven.org/maven2/com/nvidia/xgboost4j-spark_3.0/1.4.2-0.3.0/xgboost4j-spark_3.0-1.4.2-0.3.0.jar
mv rapids-4-spark_2.13-25.08.0.jar spark-3.5.6/jars/
mv xgboost4j-spark_3.0-1.4.2-0.3.0.jar spark-3.5.6/jars/


# Start rapids backed session
sparkR \
    --conf spark.plugins=com.nvidia.spark.SQLPlugin \
    --conf spark.rapids.sql.enabled=true



'''
R version 4.4.2 (2024-10-31) -- "Pile of Leaves"
Copyright (C) 2024 The R Foundation for Statistical Computing
Platform: x86_64-pc-linux-gnu

Launching java with spark-submit command /home/people/bkenna/software/spark-3.5.6/bin/spark-submit   "--conf" "spark.rapids.sql.enabled=true" "--conf" "spark.plugins=com.nvidia.spark.SQLPlugin" "sparkr-shell" /tmp/bkenna/Rtmpf4UhUo/backend_port15b4ce25d8b5e4
Setting default log level to "WARN".
To adjust logging level use sc.setLogLevel(newLevel). For SparkR, use setLogLevel(newLevel).
25/10/14 17:31:25 WARN NativeCodeLoader: Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
25/10/14 17:31:26 WARN RapidsPluginUtils: RAPIDS Accelerator 25.08.0 using cudf 25.08.0, private revision f4b467339f0ea78b7e2a862be97a63bc239e0b07
25/10/14 17:31:26 WARN RapidsPluginUtils: RAPIDS Accelerator is enabled, to disable GPU support set `spark.rapids.sql.enabled` to false.
25/10/14 17:31:26 WARN RapidsPluginUtils: spark.rapids.sql.explain is set to `NOT_ON_GPU`. Set it to 'NONE' to suppress the diagnostics logging about the query placement on the GPU.

Welcome to
      ____              __
     / __/__  ___ _____/ /__
    _\ \/ _ \/ _ `/ __/  '_/
   /___/ .__/\_,_/_/ /_/\_\   version 3.5.6
      /_/
'

SparkSession Web UI available at http://sonicgpu6:4040
SparkSession available as spark(master = local[*], app id = local-1760459486521).
During startup - Warning message:
package SparkR was built under R version 4.5.0

'''




#####################################################
#####################################################
## 
## 2). Image Analysis Use Case
##
##   -> Can see two Spark stages
##   -> Order is screwy atm even after arrange
## 
#####################################################
#####################################################


#################################
#################################
##
## a). ImageScrambler
##
#################################
#################################


# From HPC
sparkR

```{r-base}
library(imageAnalysis)

# Trial with data image
setwd("imageAnalysis/data")
runImageProcessor("dell-icon.png", "grayscaled.png", mode = 1)

'''

R version 4.3.1 (2023-06-16) -- "Beagle Scouts"
Copyright (C) 2023 The R Foundation for Statistical Computing
Platform: x86_64-conda-linux-gnu (64-bit)

Launching java with spark-submit command /home/people/bkenna/software/spark-3.5.6/bin/spark-submit   "sparkr-shell" /tmp/bkenna/RtmpvPr9Hu/backend_porta3aa51d198fc
d_porta3aa51d198fc
Setting default log level to "WARN".
Setting default log level to "WARN".
To adjust logging level use sc.setLogLevel(newLevel). For SparkR, use setLogLevel(newLevel).
25/10/21 12:03:00 WARN NativeCodeLoader: Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
 

Welcome to
      ____              __
     / __/__  ___ _____/ /__
    _\ \/ _ \/ _ `/ __/  '_/
   /___/ .__/\_,_/_/ /_/\_\   version 3.5.6
      /_/
'

SparkSession Web UI available at http://sonicmem4.compute:4040
SparkSession available as 'spark'(master = local[*], app id = local-1761044581036).
During startup - Warning message:
package SparkR was built under R version 4.5.0



2025-10-21 12:03:08 INFO  [ UseCases.ImageAnalysis.AppRunner.runImageProcessor ]:       Begining execution with 'dell-icon.png' directing results to 'grayscaled.png'
2025-10-21 12:03:08 INFO  [ UseCases.ImageAnalysis.ImageProcessor.run ]:        ================ Initiating ImageProcessor Job ================
2025-10-21 12:03:08 INFO  [ UseCases.ImageAnalysis.ImageProcessor.startSpark ]:         Starting Spark session with RAPIDS enabled
2025-10-21 12:03:08 INFO  [ UseCases.ImageAnalysis.ImageProcessor.loadImage ]:  Loading input image: dell-icon.png
2025-10-21 12:03:08 INFO  [ UseCases.ImageAnalysis.ImageProcessor.toDataFrame ]:        Converting image matrix into Spark DataFrame
2025-10-21 12:03:08 INFO  [ UseCases.ImageAnalysis.ImageProcessor.run ]:        Grayscaling image.
2025-10-21 12:03:08 INFO  [ UseCases.ImageAnalysis.ImageProcessor.computeGrayScale ]:   Executing GrayScale transformation via Spark SQL
25/10/21 12:03:09 WARN TaskSetManager: Stage 0 contains a task of very large size (1847 KiB). The maximum recommended task size is 1000 KiB.
[Stage 0:>                                                          (0 + 1) / 1]
25/10/21 12:03:09 WARN TaskSetManager: Stage 0 contains a task of very large size (1847 KiB). The maximum recommended task size is 1000 KiB.
2025-10-21 12:03:15 INFO  [ UseCases.ImageAnalysis.ImageProcessor.saveImage ]:  Saving processed output to: grayscaled.png
2025-10-21 12:03:15 INFO  [ UseCases.ImageAnalysis.ImageProcessor.run ]:        ================ Completed ImageProcessor Successfully ================
2025-10-21 12:03:15 INFO  [ UseCases.ImageAnalysis.AppRunner.runImageProcessor ]:       Execution complete see results in 'grayscaled.png'




'''

```



#################################
#################################
##
## b). ImageStacker
##
#################################
#################################



# From HPC
sparkR

```{r-base}
library(imageAnalysis)

setwd("imageAnalysis/data")
runImageStacker(
    redExpr = "CAST(xVals * 255 / 3000 AS INT)", greenExpr = "0", blueExpr = "0",
    parquetPath = "./stacker-parquet", imagePath = "./red-gradient-horizon.png"
)


library(imageAnalysis)

setwd("imageAnalysis/data")
runImageStacker(
    redExpr = "0", greenExpr = "CAST(xVals * 255 / 3000 AS INT)", blueExpr = "CAST(yVals * 255 / 1500 AS INT)",
    parquetPath = "./stacker-parquet", imagePath = "./green-blue-blend.png"
)


'''
25/10/21 18:18:03 WARN NativeCodeLoader: Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
Welcome to
      ____              __ 
     / __/__  ___ _____/ /__ 
    _\ \/ _ \/ _ `/ __/  '_/
   /___/ .__/\_,_/_/ /_/\_\   version 3.5.6 
      /_/
'

SparkSession Web UI available at http://sonicmem3:4040
SparkSession available as 'spark'(master = local[*], app id = local-1761067083906).
During startup - Warning message:
package ‘SparkR’ was built under R version 4.5.0


2025-10-21 18:18:15 INFO  [ UseCases.ImageAnalysis.AppRunner.runImageStacker ]:         Begining ImageStacker execution directing results to './red-gradient-horizon.png'
2025-10-21 18:18:15 INFO  [ UseCases.ImageAnalysis.ImageStacker.run ]:  ================ Initiating ImageStacker Job ================
2025-10-21 18:18:15 INFO  [ UseCases.ImageAnalysis.ImageStacker.startSpark ]:   Starting Spark session with RAPIDS enabled
2025-10-21 18:18:15 INFO  [ UseCases.ImageAnalysis.ImageStacker.run ]:  Creating pixel grid
2025-10-21 18:18:16 INFO  [ UseCases.ImageAnalysis.ImageStacker.run ]:  Colorizing image
2025-10-21 18:18:16 INFO  [ UseCases.ImageAnalysis.ImageStacker.run ]:  Stiching image for parquet/png export
2025-10-21 18:18:16 INFO  [ UseCases.ImageAnalysis.ImageStacker.run ]:  Storing image to parquet
[Stage 0:>                                                          (0 + 1) / 1]
2025-10-21 18:18:24 INFO  [ UseCases.ImageAnalysis.ImageStacker.run ]:  Saving image from parquet to file
2025-10-21 18:19:03 INFO  [ UseCases.ImageAnalysis.ImageStacker.run ]:  ================ Completed ImageStacker Job Successfully ================




2025-10-21 18:29:12 INFO  [ UseCases.ImageAnalysis.AppRunner.runImageStacker ]:         Begining ImageStacker execution directing results to './green-blue-blend.png'
2025-10-21 18:29:12 INFO  [ UseCases.ImageAnalysis.ImageStacker.run ]:  ================ Initiating ImageStacker Job ================
2025-10-21 18:29:12 INFO  [ UseCases.ImageAnalysis.ImageStacker.startSpark ]:   Starting Spark session with RAPIDS enabled
2025-10-21 18:29:12 INFO  [ UseCases.ImageAnalysis.ImageStacker.run ]:  Creating pixel grid
2025-10-21 18:29:13 INFO  [ UseCases.ImageAnalysis.ImageStacker.run ]:  Colorizing image
2025-10-21 18:29:13 INFO  [ UseCases.ImageAnalysis.ImageStacker.run ]:  Stiching image for parquet/png export
2025-10-21 18:29:13 INFO  [ UseCases.ImageAnalysis.ImageStacker.run ]:  Storing image to parquet
[Stage 0:>                                                          (0 + 1) / 1]
2025-10-21 18:29:21 INFO  [ UseCases.ImageAnalysis.ImageStacker.run ]:  Saving image from parquet to file
2025-10-21 18:30:00 INFO  [ UseCases.ImageAnalysis.ImageStacker.run ]:  ================ Completed ImageStacker Job Successfully ================
2025-10-21 18:30:00 INFO  [ UseCases.ImageAnalysis.AppRunner.runImageStacker ]:         Execution complete see results in './green-blue-blend.png'


'''

```


