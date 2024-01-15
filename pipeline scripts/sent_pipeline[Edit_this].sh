#!/bin/bash

## User varibles (Example)

# File name before *_R1.fastq.gz or *_R2.fastq.gz
expID=SC-BLM
fastqDIR=../fastq

# Do configure
sh 0_Configure_Setting.sh c.0_ChIPseq.cfg

# Sent pipeline, start from fastq file
sh 0.0_ps_ChIPseq_Pipeline_v1.sh $expID is-dump $fastqDIR

