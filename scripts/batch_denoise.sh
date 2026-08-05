#!/bin/bash -l
# Grid Engine options
#$ -cwd
#$ -t 1-9
#$ -N qiime2_denoise
# Runtime limit
#$ -l h_rt=24:00:00
#$ -pe sharedmem 12
#$ -o ../logs/$JOB_NAME.$TASK_ID.out
#$ -e ../logs/$JOB_NAME.$TASK_ID.err

## Batch script for denoising

set -euo pipefail
mkdir -p ../logs
mkdir -p ../denoise

# List of file names
file_base=$(sed -n "${SGE_TASK_ID}p" filestoprocess_v4.txt)
infile="../trimmed/${file_base}_trimmed.qza"
outfile="../denoise/${file_base}"

./denoise.sh "${infile}" "${outfile}"

# To run: qsub batch_denoise.sh
