#!/bin/bash -l
# Grid Engine options
#$ -cwd
#$ -t 1-13
#$ -N qiime2_import
# Runtime limit
#$ -l h_rt=05:00:00
#$ -o ../logs/$JOB_NAME.$TASK_ID.out
#$ -e ../logs/$JOB_NAME.$TASK_ID.err

## Batch script for QIIME2 importing

set -euo pipefail
mkdir -p ../logs

# List of directories
run_dir=$(sed -n "${SGE_TASK_ID}p" filestoprocess.txt)
./import.sh "../data_by_date/$run_dir"

# To run: qsub batch_import.sh

