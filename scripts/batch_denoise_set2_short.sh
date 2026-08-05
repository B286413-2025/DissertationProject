#!/bin/bash -l
# Grid Engine options
#$ -cwd
#$ -t 1-3
#$ -N qiime2_denoise
# Runtime limit
#$ -l h_rt=12:00:00
#$ -pe sharedmem 12
#$ -o ../logs/$JOB_NAME.$TASK_ID.out
#$ -e ../logs/$JOB_NAME.$TASK_ID.err

## Batch script for denoising second dataset (ASV pipeline)

set -euo pipefail
mkdir -p ../logs
mkdir -p ../denoise_set2_short

# List of file names
file_base=$(sed -n "${SGE_TASK_ID}p" filestoprocess_set2.txt)
infile="../trimmed/${file_base}_trimmed.qza"
outfile="../denoise_set2_short/${file_base}"

./denoise_set2_short.sh "${infile}" "${outfile}"

# To run: qsub batch_denoise.sh
