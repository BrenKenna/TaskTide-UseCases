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
module load automake autoconf go gmake cmake libseccomp

# Java-17, r4.4
module load openjdk R/4.4.2


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
export CONDA_PREFIX=$SOFT

export CUSTOM_MODULES=$SOFT/opt
export PYTHON_MODULES=$CUSTOM_MODULES/python
export R_MODULES=$CUSTOM_MODULES/r
export JAVA_MODULES=$CUSTOM_MODULES/java

export PYTHONPATH=$PYTHON_MODULES:$PYTHONPATH
export R_LIBS_USER=$R_MODULES
export R_LIBS=$R_MODULES:$R_LIBS

export CLASSPATH=$JAVA_MODULES:$CLASSPATH


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
export REF=$DATA_DIR/ref
export B37=$REF/b37
export B38=$REF/b38

# Result directories
export BAM=$KG_PROCESSING/bam
export GVCF=$KG_PROCESSING/GVCF
export SAMPLE_META_DATA=$KG_PROCESSING/samples


# Source Data
export KG_DATA_URL=https://ftp-trace.ncbi.nih.gov/1000genomes/ftp/technical/other_exome_alignments/
