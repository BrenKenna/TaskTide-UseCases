#!/bin/bash

. ~/interactive.sh
. ~/start.sh


#####################################################
#####################################################
## 
## 1). Setup  Reference Data
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
sbatch \
    --time=06:00:00 \
    --output=/scratch/$USER/resource-bundle.log --error=/scratch/$USER/resource-bundle.log \
    bash /home/people/bkenna/gatk-resource-bundle.sh



#####################################################
#####################################################
## 
## 2). Setup Sample Database
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


# Create tables
sqlite3 $SAMPLE_META_DATA/sample-meta-data.db << EOF

-- Sample Info Table

CREATE TABLE IF NOT EXISTS SampleData (
    SampleId TEXT PRIMARY KEY,
    Gender TEXT,
    AltId TEXT,
    Population TEXT,
    PopulationName TEXT,
    SuperPopulation TEXT,
    SuperPopulationName TEXT,
    ElasticId TEXT,
    DataCollections TEXT
);

-- Sample Mappings
CREATE TABLE IF NOT EXISTS SampleMappings (
    SampleId TEXT PRIMARY KEY,
    MappedId TEXT
);

-- Sample Tracking
CREATE TABLE IF NOT EXISTS SampleTracking (
    SampleId TEXT PRIMARY KEY,
    SourceBam TEXT,
    SourceDirFiles TEXT,
    RealignedCram TEXT,
    RealignedGvcf Text,
    Status
);

EOF


# Import data
cd $SAMPLE_META_DATA/input

sqlite3 $SAMPLE_META_DATA/sample-meta-data.db << EOF
.mode tabs
.import sample-info.txt SampleData
EOF

sqlite3 $SAMPLE_META_DATA/sample-meta-data.db << EOF
.mode tabs
.separator "\t"
.import samples.txt SampleMappings
EOF

sqlite3 $SAMPLE_META_DATA/sample-meta-data.db << EOF
.mode tabs
.separator "|"
.import sampleTracking.txt SampleTracking
EOF


# Apply indexes
sqlite3 $SAMPLE_META_DATA/sample-meta-data.db << EOF

-- SampleData Indexes
CREATE INDEX sample_data_gender_idx ON SampleData(Gender);
CREATE INDEX sample_data_pop_idx ON SampleData(Population);
CREATE INDEX sample_data_super_pop_idx ON SampleData(SuperPopulation);

EOF


# Move input data
mkdir -p $SAMPLE_META_DATA/input
mv $SAMPLE_META_DATA/*txt $SAMPLE_META_DATA/input/


# Sanity check tables
for tbl in $( echo ".tables" | sqlite3 $SAMPLE_META_DATA/sample-meta-data.db)
do
    echo -e ".headers on\nSELECT * FROM $tbl LIMIT 3;" | sqlite3 $SAMPLE_META_DATA/sample-meta-data.db
done

