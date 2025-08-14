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
## 1). Setup Environment
## 
#####################################################
#####################################################
 

# Start interactive session: SLURM_SUBMIT_HOST, SLURM_JOB_ID
srun -t 08:00:00 -n 1 -c 2 --mem=8G --pty bash
sbatch --output=/scratch/$USER/job.log --error=/scratch/$USER/job.log --wrap='printenv'
sbatch --output=/scratch/$USER/job-2.log --error=/scratch/$USER/job-2.log --wrap='pwd;cd $TMPDIR; pwd; cd /scratch/$SLURM_JOB_ID; pwd'
squeue -j 130245
sacct -j 130245
scontrol show job 130245


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

# TaskTide
rm -f $SOFT/bin/tasktide
cd $SOFT
wget https://github.com/BrenKenna/TaskTide/releases/download/v0.9.0/tasktide-0.9.0.zip
tar -xvzf tasktide-0.9.0.zip && rm -f tasktide-0.9.0.zip
ln -sf $SOFT/tasktide-0.9.0/bin/tasktide $SOFT/bin/tasktide

mv lib/jnosql-arangodb-1.1.6.jar jnosql/
mv lib/jnosql-cassandra-1.1.6.jar jnosql/
mv lib/jnosql-couchbase-1.1.6.jar jnosql/
mv lib/jnosql-dynamodb-1.1.6.jar jnosql/
mv lib/jnosql-mongodb-1.1.6.jar jnosql/
mv lib/jnosql-redis-1.1.6.jar jnosql/
mv lib/jnosql-couchdb-1.1.6.jar jnosql/
mv lib/jnosql-mapping-document-1.1.8.jar jnosql/
mv lib/jnosql-mapping-graph-1.1.8.jar jnosql/
mv lib/jnosql-mapping-key-value-1.1.8.jar jnosql/
mv lib/jnosql-mapping-column-1.1.8.jar jnosql/


# AWS Cli
export SOFT=$HOME/software
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "$SOFTWARE/awscli.zip"
unzip awscli.zip  && rm -f awscli.zip
$SOFTWARE/aws/install -i $SOFTWARE/aws-cli -b $SOFTWARE/bin

# Singularity
conda install conda-forge::singularity conda-forge::libpsl conda-forge::"openjdk>=23"

cd $SOFT
wget https://curl.se/download/curl-8.15.0.tar.gz
tar -xvf curl-8.15.0.tar.gz && rm -f curl-8.15.0.tar.gz && cd curl-8.15.0
./configure --prefix=$SOFT --with-ssl
make -j 4
make install
cd ../ && rm -fr curl-8.15.0/

git clone --recursive https://github.com/samtools/htslib && cd htslib
autoreconf -i
./configure --prefix=$SOFT --with-curl=$SOFT
make -j 4
make install

pkg-config --cflags --libs htslib


wget https://invisible-mirror.net/archives/ncurses/current/ncurses-6.5-20241207.tgz
tar -xvf ncurses-6.5-20241207.tgz && rm -f ncurses-6.5-20241207.tgz && cd ncurses-6.5-20241207
./configure --prefix=$SOFT --with-shared --with-termlib
make -j 4
make install
pkg-config --cflags --libs ncurses
cd .. && rm -fr ncurses-6.5-20241207

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
wget https://github.com/broadinstitute/gatk/releases/download/4.6.2.0/gatk-4.6.2.0.zip
unzip gatk-4.6.2.0.zip && rm -f gatk-4.6.2.0.zip && cd gatk-4.6.2.0
cp *jar ../bin/
cd .. && rm -fr gatk-4.6.2.0


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

#####################################################
#####################################################
## 
## 2). Setup  Reference Data
## 
#####################################################
#####################################################


# Build37 reference genome
cd $B37
wget -c ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/reference/phase2_reference_assembly_sequence/hs37d5.fa.gz
wget -c http://hgdownload.cse.ucsc.edu/goldenpath/hg19/bigZips/hg19.fa.gz


# Build38 reference data
cd $B38

wget -r -nH --cut-dirs=3 -np -R "index.html*" \
     ftp://ftp-trace.ncbi.nih.gov/1000genomes/ftp/technical/reference/GRCh38_reference_genome/

wget -r -nH --cut-dirs=3 -np -R "index.html*" \
    https://ftp-trace.ncbi.nih.gov/1000genomes/ftp/technical/reference/phase2_mapping_resources/

wget -r -nH --cut-dirs=3 -np -R "index.html" \
    https://ftp-trace.ncbi.nih.gov/1000genomes/ftp/technical/reference/exome_pull_down_targets_phases1_and_2/


# Target regions for variant calling: 130302
wget https://ftp.ensembl.org/pub/release-114/regulation/homo_sapiens/GRCh38/annotation/Homo_sapiens.GRCh38.regulatory_features.v114.gff3.gz
wget https://ftp.ensembl.org/pub/release-114/gff3/homo_sapiens/Homo_sapiens.GRCh38.114.gff3.gz
sbatch --time=08:00:00 --output=/scratch/$USER/gff-DB.log --error=/scratch/$USER/gff-DB.log --wrap='
cd /scratch/bkenna/ref/b38
gffutils-cli create Homo_sapiens.GRCh38.114.gff3.gz
'


sbatch --time=06:00:00 --output=/scratch/$USER/resource-bundle.log --error=/scratch/$USER/resource-bundle.log bash /home/people/bkenna/gatk-resource-bundle.sh


#####################################################
#####################################################
## 
## 3). Setup Sample Database
## 
#####################################################
#####################################################


# List samples
sbatch --time=06:00:00 --cpus-per-task=1 --wrap='
cd /scratch/bkenna
export KG_DATA_URL=https://ftp-trace.ncbi.nih.gov/1000genomes/ftp/technical/other_exome_alignments
wget -qO- ftp://ftp-trace.ncbi.nih.gov/1000genomes/ftp/technical/other_exome_alignments/ | \
    grep -oP "(?<=href=\")[^\"/].*" | \
    awk -F / "{ print \$(NF-3)\"\t\"\$(NF-2) }" | \
    sed "s/\">//g" \
> samples.txt

rm -f sampleTracking.txt && touch sampleTracking.txt
for sample in $(cut -f 1 samples.txt)
do
    wget -qO- "${KG_DATA_URL}/${sample}/exome_alignment/" | grep "a href" | cut -d = -f 2 | cut -d \" -f 2 | grep -ve "h
tml" > tmp
    bam=$(cat tmp | grep -e "bam$" -e "cram$")
    files=$(cat tmp | xargs)
    echo "${sample}|${KG_DATA_URL}/${sample}/exome_alignment/${bam}|${files}" >> sampleTracking.txt
done
rm tmp
'