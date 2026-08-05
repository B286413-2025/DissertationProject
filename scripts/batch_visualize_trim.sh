#!/bin/bash -l
#$ -cwd
#$ -t 1-13
#$ -N qiime2_visualize_trimmed
#$ -l h_rt=02:00:00
#$ -pe sharedmem 1
#$ -o ../logs/$JOB_NAME.$TASK_ID.out
#$ -e ../logs/$JOB_NAME.$TASK_ID.err

## Batch script for visualization of the trimmed samples

set -euo pipefail

# List of file names
file_base=$(sed -n "${SGE_TASK_ID}p" filestoprocess.txt)

infile="../trimmed/${file_base}_trimmed.qza"
outfile="../trimmed/${file_base}_trimmed.qzv"

./visualize_trimmed.sh "${infile}" "${outfile}"

