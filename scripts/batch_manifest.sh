#!/bin/bash -l
# Grid Engine options
#$ -cwd
#$ -t 1-13
#$ -N manifest_generation
# Runtime limit
#$ -l h_rt=05:00:00
#$ -o ../logs/$JOB_NAME.$TASK_ID.out
#$ -e ../logs/$JOB_NAME.$TASK_ID.err

## Batch script for QIIME2 manifest generation

set -euo pipefail
mkdir -p ../logs

# List of directories
run_dir=$(sed -n "${SGE_TASK_ID}p" filestoprocess.txt)
./make_manifest.sh "../data_by_date/$run_dir"

# To run: qsub batch_manifest.sh
