#!/bin/bash

## User varibles (Example)
expID=SRR20995189

# Do configure
sh 0_Configure_Setting.sh c.0_ChIPseq.cfg

# Sent pipeline, start from SRA file
sh 0.0_ps_ChIPseq_Pipeline_v1.sh $expID

