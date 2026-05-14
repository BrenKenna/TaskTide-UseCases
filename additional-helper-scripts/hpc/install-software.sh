#!/bin/bash

. ~/interactive.sh
. ~/start.sh


# Install miniconda
cd /tmp
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh -u -b -p $SOFTWARE/

# Java
rm -f $SOFT/bin/java $SOFT/bin/javac
cd $SOFT
wget https://download.oracle.com/java/24/latest/jdk-24_linux-x64_bin.tar.gz
tar -xvzf jdk-24_linux-x64_bin.tar.gz && rm -f jdk-24_linux-x64_bin.tar.gz
ln -s $SOFT/jdk-24/bin/java $SOFT/bin/java
ln -s $SOFT/jdk-24/bin/javac $SOFT/bin/javac


# AWS Cli
export SOFT=$HOME/software
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "$SOFTWARE/awscli.zip"
unzip awscli.zip  && rm -f awscli.zip
$SOFTWARE/aws/install -i $SOFTWARE/aws-cli -b $SOFTWARE/bin


# Singularity and friends
conda install -y \
    conda-forge::libpsl \
    conda-forge::jq \
    conda-forge::tree \
    conda-forge::rocksdb \
    conda-forge::python-rocksdb \
    conda-forge::julia

conda create -n singularity_env python=3.10
conda activate singularity_env
conda install -c conda-forge singularity=3.8.6


# cURL
cd $SOFT
wget https://curl.se/download/curl-8.15.0.tar.gz
tar -xvf curl-8.15.0.tar.gz && rm -f curl-8.15.0.tar.gz && cd curl-8.15.0
./configure --prefix=$SOFT --with-ssl
make -j 4
make install
cd ../ && rm -fr curl-8.15.0/


# Install facebooks rocksDB for LDB: librocksdb.so.10.6
sbatch --job-name="Install-RocksDB" \
    -t 08:00:00 -n 1 -c 8 \
    --output=$DATA_DIR/rocksdb-install.log --error=$DATA_DIR/rocksdb-install.log \
    --wrap='
    . ~/start.sh # loads all my env vars etc
    cd $SOFT
    git clone https://github.com/facebook/rocksdb.git
    cd rocksdb
    make clean  # start fresh
    make -j 8 LDFLAGS="-Wl,-rpath,$SOFT/lib"
    make install PREFIX=$SOFT
    cp ldb ../bin/
    cd .. && which ldb
    ldb --help
'

# Install HTSLib
cd $SOFT
git clone --recursive https://github.com/samtools/htslib && cd htslib
autoreconf -i
./configure --prefix=$SOFT --with-curl=$SOFT
make -j 4
make install

pkg-config --cflags --libs htslib


# Ncurses
wget https://invisible-mirror.net/archives/ncurses/current/ncurses-6.5-20241207.tgz
tar -xvf ncurses-6.5-20241207.tgz && rm -f ncurses-6.5-20241207.tgz && cd ncurses-6.5-20241207
./configure --prefix=$SOFT --with-shared --with-termlib
make -j 4
make install
pkg-config --cflags --libs ncurses
cd .. && rm -fr ncurses-6.5-20241207


# SAMtools
git clone --recursive https://github.com/samtools/samtools && cd samtools
git submodule update --init --recursive
autoreconf -i
./configure --prefix=$SOFT \
    CFLAGS="-I$SOFT/include" \
    LDFLAGS="-L$SOFT/lib" \
    LIBS="-lncursesw -ltinfo -lz -lcurl"
make -j 4
make install


# Gatk4
wget https://github.com/broadinstitute/gatk/releases/download/4.1.4.0/gatk-4.1.4.0.zip
unzip gatk-4.1.4.0.zip && rm -f gatk-4.1.4.0.zip && cd gatk-4.1.4.0
cp *jar ../bin/
cd .. && rm -fr gatk-4.1.4.0


# Samblaster
cd $SOFT
git clone https://github.com/GregoryFaust/samblaster.git && cd samblaster
make -j 2
cp samblaster $SOFT/bin
cd .. && rm -fr samblaster


# BWA Kit
cd $SOFT/bin
wget https://sourceforge.net/projects/bio-bwa/files/bwakit/bwakit-0.7.15_x64-linux.tar.bz2/download
tar -xvf download && rm -f download




#################################
#################################
## 
## a). TaskTide
## 
#################################
#################################


# Back up config
cp $TASK_TIDE_CONF $TASK_TIDE/microprofile-config.properties


# TaskTide
cd $JAVA_MODULES
# mv ~/tasktide-0.9.5.zip ./
# wget https://github.com/BrenKenna/TaskTide/releases/download/v0.9.0/tasktide-0.9.0.zip
rm -fr tasktide-0.9.0/ tasktide-0.9.5/ 
unzip tasktide-0.9.5.zip && rm -f tasktide-0.9.5.zip && cd tasktide-0.9.5
rm -f $SOFT/bin/tasktide
ln -sf $JAVA_MODULES/tasktide-0.9.5/bin/tasktide $SOFT/bin/tasktide

mkdir jnosql-libs
mv lib/jnosql-arangodb-1.1.6.jar jnosql-libs/
mv lib/jnosql-cassandra-1.1.6.jar jnosql-libs/
mv lib/jnosql-couchbase-1.1.6.jar jnosql-libs/
mv lib/jnosql-dynamodb-1.1.6.jar jnosql-libs/
mv lib/jnosql-mongodb-1.1.6.jar jnosql-libs/
mv lib/jnosql-redis-1.1.6.jar jnosql-libs/
mv lib/jnosql-couchdb-1.1.6.jar jnosql-libs/
mv lib/jnosql-mapping-graph-1.1.8.jar jnosql-libs/
mv lib/jnosql-mapping-key-value-1.1.8.jar jnosql-libs/
mv lib/jnosql-mapping-column-1.1.8.jar jnosql-libs/

cp $TASK_TIDE/microprofile-config.properties $TASK_TIDE_CONF
cd $TASK_TIDE



#################################
#################################
## 
## b). Spark
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
