#!/bin/bash

bamDIR=$1
expID=$2

# remove SAM file
rm ${bamDIR}/${expID}.sam

# remove BAM and sorted.BAM left sorted.rmdup.BAM and index
rm ${bamDIR}/${expID}.bam
rm ${bamDIR}/${expID}.sorted.bam

