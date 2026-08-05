#!/bin/bash -l
#$ -cwd
#$ -N otu_prep
#$ -t 1-11
#$ -l h_rt=48:00:00
#$ -pe sharedmem 8
#$ -l h_vmem=8G
#$ -o ../logs/$JOB_NAME.$TASK_ID.out
#$ -e ../logs/$JOB_NAME.$TASK_ID.err

## Batch script for OTU prepping

set -euo pipefail
mkdir -p ../logs ../otu_prep_set2

# List of file names
base=$(sed -n "${SGE_TASK_ID}p" filestoprocess_otu.txt)

in_qza="../trimmed/${base}_trimmed.qza"
out_prefix="../otu_prep_set2/${base}"

./otu_prep.sh "${in_qza}" "${out_prefix}"

