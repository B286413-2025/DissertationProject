#!/bin/bash -l
#$ -cwd
#$ -t 1-3
#$ -N qiime2_trim_primers
#$ -l h_rt=05:00:00
#$ -pe sharedmem 12
#$ -o ../logs/$JOB_NAME.$TASK_ID.out
#$ -e ../logs/$JOB_NAME.$TASK_ID.err

## Batch script for primer trimming of the second dataset

set -euo pipefail

# List of file names
file_base=$(sed -n "${SGE_TASK_ID}p" filestoprocess_set2.txt)

infile="../visualization/${file_base}.qza"
outfile="../trimmed/${file_base}_trimmed.qza"

./trim_primers_set2.sh "${infile}" "${outfile}"
