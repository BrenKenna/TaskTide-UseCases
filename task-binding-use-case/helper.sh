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
mv FunctionRunner/ projects/
mv example-shell.jl projects/FunctionRunner/


# Install image analysis app
mv



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

"""


R version 4.4.2 (2024-10-31) -- "Pile of Leaves"
Copyright (C) 2024 The R Foundation for Statistical Computing
Platform: x86_64-pc-linux-gnu

R is free software and comes with ABSOLUTELY NO WARRANTY.
You are welcome to redistribute it under certain conditions.
Type 'license()' or 'licence()' for distribution details.

R is a collaborative project with many contributors.
Type 'contributors()' for more information and
'citation()' on how to cite R or R packages in publications.

Type 'demo()' for some demos, 'help()' for on-line help, or
'help.start()' for an HTML browser interface to help.
Type 'q()' to quit R.

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


SparkSession Web UI available at http://sonicgpu6:4040
SparkSession available as 'spark'(master = local[*], app id = local-1760459486521).
During startup - Warning message:
package ‘SparkR’ was built under R version 4.5.0

"""