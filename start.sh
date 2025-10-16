#!/bin/bash

#####################################
#####################################
## 
## 1). Load Modules
## 
#####################################
#####################################

# Installing software
echo "Importing software modules"
module load automake 
module load autoconf
module load go
module load gmake
module load cmake
module load libseccomp

# Java-17, r4.4
module load java
module load R/4.4.2
# module load julia/1.11.3
module load cuda/12.9


#####################################
#####################################
## 
## 2). Export Environment
## 
#####################################
#####################################


# Organizing software
echo "Exporting internally managed environment"
export SOFT=$HOME/software
export CMAKE_PREFIX_PATH=$SOFT:$CMAKE_PREFIX_PATH
export CMAKE_INSTALL_PREFIX=$SOFT
export PATH=$SOFT/bin:$PATH
export LD_LIBRARY_PATH=$SOFT/lib:$LD_LIBRARY_PATH
export PKG_CONFIG_PATH=$SOFT/lib/pkgconfig:$PKG_CONFIG_PATH
export CPPFLAGS="-I$SOFT/include $CPPFLAGS"
export LDFLAGS="-L$SOFT/lib $LDFLAGS"
export PKG_CONFIG_PATH="$SOFT/lib/pkgconfig:$PKG_CONFIG_PATH"
export PREFIX=$SOFT
export CONDA_PREFIX=$SOFT

export CUSTOM_MODULES=$SOFT/opt
export PYTHON_MODULES=$CUSTOM_MODULES/python
export R_MODULES=$CUSTOM_MODULES/r
export R_LIBS=$R_MODULES

export JAVA_MODULES=$CUSTOM_MODULES/java
export JULIA_MODULES=$CUSTOM_MODULES/julia
export JULIA_LOAD_PATH="$JULIA_MODULES:@:@stdlib"
export JULIA_DEPOT_PATH=$JULIA_MODULES
export JULIA_PROJECT=@.

# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/software/el9/julia/1.11.3/lib

export ROCKS_CLI=$SOFT/rocksdb

export PYTHONPATH=$PYTHON_MODULES:$PYTHONPATH
export R_LIBS_USER=$R_MODULES
export R_LIBS=$R_MODULES:$R_LIBS

export CLASSPATH=$JAVA_MODULES:$CLASSPATH

export GATK=$SOFT/bin/gatk-package-4.6.2.0-local.jar
export BWA_DIR=$SOFT/bin/bwa


# Spark
export SPARK_HOME=$SOFT/spark-3.5.6
export PATH=$SPARK_HOME/bin:$SPARK_HOME/sbin:$PATH
export SPARK_JAR_PATH=$SPARK_HOME/jars


# Sanity some programs
echo "Sanity checking software config"
parallel --version
java --version
conda --version
singularity --version
aws --version


#####################################
#####################################
## 
## 3). Data Directories
## 
#####################################
#####################################


# Scratch
export DATA_DIR="/scratch/bkenna"
export TMPDIR=/tmp/bkenna
export JOBDIR=$DATA_DIR/jobs
export REF=$DATA_DIR/ref
export B37=$REF/b37
export B38=$REF/b38
mkdir -p $TMPDIR


# Result directories
export BAM=$DATA_DIR/bam
export GVCF=$DATA_DIR/gVCF
export SAMPLE_META_DATA=$DATA_DIR/samples


# Reference data
export b37_REF=$B37/hs37d5.fa.gz
export hg19_REF=$B37/hg19.fa.gz

export b38_REF=$B38/GRCh38_full_analysis_set_plus_decoy_hla.fa
export dbSNP=$B38/ALL_20141222.dbSNP142_human_GRCh38.snps.vcf.gz
export OMNI=$B38/1000G_omni2.5.hg38.vcf.gz
export MILLS=$B38/Mills_and_1000G_gold_standard.indels.b38.primary_assembly.vcf.gz
export HAPMAP=$B38/hapmap_3.3.hg38.vcf.gz
export KG_GOLD=$B38/1000G_phase1.snps.high_confidence.hg38.vcf.gz
export KNOWN_INDELS=$B38/Homo_sapiens_assembly38.known_indels.vcf.gz
export EXON_BED=$B38/b38-exons.bed
export TGT=$B38/b38-exons-loci.bed


# Source Data
export KG_DATA_URL=https://ftp-trace.ncbi.nih.gov/1000genomes/ftp/technical/other_exome_alignments


# Task tide
export TASK_TIDE=$DATA_DIR/TaskTide
export TASK_TIDE_CONF=$JAVA_MODULES/tasktide-0.9.0/config/META-INF/microprofile-config.properties
export ITEMSTORE_SQL=$TASK_TIDE/itemStore/sqlite
export ITEMSTORE_ROCKS=$TASK_TIDE/itemStore/rocksDB