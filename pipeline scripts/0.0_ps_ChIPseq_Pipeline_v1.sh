#!/bin/bash

# SLURM setting
partition=186
memory=186
ncore=28

## User varibles
expID=$1
isDump=$2
fqPath=$3

## Please change the workdir in configure file!
workdir=../

## A function to create folder
function mkFolder(){
folder_name=$1
if [ ! -d $workdir/$folder_name ]
then
mkdir $workdir/$folder_name
fi
}

## Create reports folder
if [ ! -d reports ]
then
mkdir reports
fi

## Check if expID was provided.
RED='\033[0;31m'
NC='\033[0m' # No Color
if [ -z $expID ]; then
 echo -e "${RED}Error:${NC} Please provide sample id!"
 exit 1
fi

## Check if need to perform fastq-dump
check_dump="not-dump"
if [ ! -z $isDump ]; then
 if [ $isDump == "is-dump" ]; then
  check_dump="dumped"
 else
  echo -e "${RED}Warning:${NC} is-dump flag was set, it must be 'is-dump' !"
  echo -e "${RED}Warning:${NC} Process was terminated!"
  exit 1
 fi
fi

## Check if fastq directory is set when isDump
fastqDIR=${workdir}/fastq
if [ $check_dump == "dumped" ] ; then
 if [ -z $fqPath ]; then
  echo -e "${RED}Error:${NC} is-dump flag was set but fastq path was not provided!"
  exit 1
 else
  fastqDIR=$fqPath
 fi
fi

## Check if need to perform fastq-dump
if [ $check_dump == "not-dump" ] ; then
 ## Run fastq-dump
 mkFolder fastq # create folder
 jid_fqdump=$(sbatch\
  -A MST109178\
  -p ngs${partition}G\
  -J fq-dump_$expID\
  -o reports/fq-dump_$expID.o.txt\
  -e reports/fq-dump_$expID.e.txt\
  -c $ncore --mem=${memory}g\
  0_ps_SRA_dump.sh ${workdir}/SRA/${expID}.sra ${workdir}/fastq)

 ## Run Trimgalore
 mkFolder trimed_fq # create folder
 jid_Trim=$(sbatch\
  -A MST109178\
  -p ngs${partition}G\
  -J trim_$expID\
  -o reports/trim_$expID.o.txt\
  -e reports/trim_$expID.e.txt\
  -c $ncore --mem=${memory}g\
  --dependency=afterok:${jid_fqdump/"Submitted batch job "/}\
  1_ps_trimQC.sh $expID $workdir/trimed_fq $fastqDIR $ncore)
else
 mkFolder trimed_fq # create folder
 jid_Trim=$(sbatch\
  -A MST109178\
  -p ngs${partition}G\
  -J trim_$expID\
  -o reports/trim_$expID.o.txt\
  -e reports/trim_$expID.e.txt\
  -c $ncore --mem=${memory}g\
  1_ps_trimQC.sh $expID $workdir/trimed_fq $fastqDIR $ncore)
fi

## Run STAR alignment************
mkFolder BAM_files # create folder
jid_Bowtie=$(sbatch\
 -A MST109178\
 -p ngs${partition}G\
 -J bowtie2_$expID\
 -o reports/bowtie2_$expID.o.txt\
 -e reports/bowtie2_$expID.e.txt\
 -c $ncore --mem=${memory}g\
 --dependency=afterok:${jid_Trim/"Submitted batch job "/}\
 2_ps_bowtie2.sh\
 $workdir/trimed_fq $expID $workdir/BAM_files $ncore)

## Run samtools
jid_SAMTOOLS=$(sbatch\
 -A MST109178\
 -p ngs${partition}G\
 -J samtools_$expID\
 -o reports/samtools_$expID.o.txt\
 -e reports/samtools_$expID.e.txt\
 -c $ncore --mem=${memory}g\
 --dependency=afterok:${jid_Bowtie/"Submitted batch job "/}\
 3.1_ps_samtools.sh $workdir/BAM_files $expID $ncore)

## Clean up files
jid_CleanUP=$(sbatch\
 -A MST109178\
 -p ngs${partition}G\
 -J clean_$expID\
 -o reports/samtools_clean_$expID.o.txt\
 -e reports/samtools_clean_$expID.e.txt\
 -c $ncore --mem=${memory}g\
 --dependency=afterok:${jid_SAMTOOLS/"Submitted batch job "/}\
 3.2_ps_clear_tmp_files.sh $workdir/BAM_files $expID)

## Run bamcoverage
mkFolder bamcoverage
jid_BamCOV=$(sbatch\
 -A MST109178\
 -p ngs${partition}G\
 -J bamCov_$expID\
 -o reports/bamCov_$expID.o.txt\
 -e reports/bamCov_$expID.e.txt\
 -c $ncore --mem=${memory}g\
 --dependency=afterok:${jid_SAMTOOLS/"Submitted batch job "/}\
 4_ps_bamcoverage.sh $workdir/BAM_files/$expID*.sorted.rmdup.bam $ncore $workdir/bamcoverage $expID)

## Run BBduk for telomeric repeat contents
mkFolder bbduk_telo
jid_BBduk=$(sbatch\
 -A MST109178\
 -p ngs${partition}G\
 -J bbduk_telo_$expID\
 -o reports/bbduk_telo_$expID.o.txt\
 -e reports/bbduk_telo_$expID.e.txt\
 -c $ncore --mem=${memory}g\
 --dependency=afterok:${jid_Trim/"Submitted batch job "/}\
 5_ps_bbduk_telo_contents.sh $expID $workdir/bbduk_telo $workdir/trimed_fq/${expID} $ncore)

## Report
CYAN='\033[0;36m'
echo -e ${CYAN}Pipeline sent at${NC} $(date "+%Y-%m-%d %H:%M:%S")

