#!/bin/bash

## Software
bamcoverage=/opt/ohpc/Taiwania3/pkg/biology/deepTools/deepTools_v3.3.1/bin/bamCoverage
bigwig2bdg=/staging/biology/ls807terra/0_Programs/UCSC_tools/bigWigToBedGraph

## Inputs
BAM=$1

## User variables
ncore=$2
outdir=$3
expID=$4

# Do without strand
$bamcoverage \
 -b $BAM \
 --normalizeUsing CPM \
 -p $ncore \
 -o ${outdir}/${expID}.CPM.bigwig \
 -of bigwig

# Bigwig to bedgraph
$bigwig2bdg ${outdir}/${expID}.CPM.bigwig ${outdir}/${expID}.CPM.bedgraph
