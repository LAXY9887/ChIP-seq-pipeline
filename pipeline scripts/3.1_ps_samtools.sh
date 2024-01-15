#!/bin/bash

inDIR=$1
expID=$2
ncore=$3

# Programs
samtools=/opt/ohpc/Taiwania3/pkg/biology/SAMTOOLS/SAMTOOLS_v1.13/bin/samtools

# sam to bam
$samtools view \
 --threads $ncore \
 -b ${inDIR}/${expID}.sam \
 > ${inDIR}/${expID}.bam

# sorted bam
$samtools sort \
 --threads $ncore \
 -O bam ${inDIR}/${expID}.bam \
 -o ${inDIR}/${expID}.sorted.bam

# remove duplicate
$samtools rmdup \
 ${inDIR}/${expID}.sorted.bam \
 ${inDIR}/${expID}.sorted.rmdup.bam

# build index           
$samtools index \
 -@ $ncore \
 ${inDIR}/${expID}.sorted.rmdup.bam \
 ${inDIR}/${expID}.sorted.rmdup.bam.bai

# mapping ratio
$samtools flagstat \
 --threads $ncore \
 ${inDIR}/${expID}.sorted.bam \
 > ${inDIR}/${expID}.sorted.bam.flagstat.txt

# rmdup mapping ratio
$samtools flagstat \
 --threads $ncore \
 ${inDIR}/${expID}.sorted.rmdup.bam \
 > ${inDIR}/${expID}.sorted.rmdup.bam.flagstat.txt

