#!/bin/bash

# User Varibles
fq_path=$1
expID=$2
outdir=$3
ncore=$4

# Genome
genome=/staging/biology/ls807terra/0_genomes/bowtie2_index/mm10/mm10

# program
bowtie2=/opt/ohpc/Taiwania3/pkg/biology/BOWTIE/bowtie2_v2.4.2/bowtie2

# Gather read files (Incude file path)
reads_file=$(echo $(ls $fq_path/$expID | grep .fq.gz))

# Split the read_list into an array
IFS=' ' read -ra READS <<< "$reads_file"
ReadN=${#READS[@]}

## Run bowtie2
if [ $ReadN -eq 2 ]; then
fq1=$(echo $reads_file | awk '{print $1}')
fq2=$(echo $reads_file | awk '{print $2}')
$bowtie2 -p $ncore -x $genome -1 $fq_path/$expID/$fq1 -2 $fq_path/$expID/$fq2 -S $outdir/${expID}.sam
elif [ $ReadN -eq 1 ]; then
$bowtie2 -p $ncore -x $genome -U $fq_path/$expID/${reads_file} -S $outdir/${expID}.sam
fi

