#!/bin/bash -l
#$ -cwd
#$ -t 1-3
#$ -N qiime2_vis_denoise
#$ -l h_rt=02:00:00
#$ -o ../logs/$JOB_NAME.$TASK_ID.out
#$ -e ../logs/$JOB_NAME.$TASK_ID.err

## Batch script for visualization of the second denoised dataset

set -euo pipefail

# List of file names
base=$(sed -n "${SGE_TASK_ID}p" filestoprocess_set2.txt)

./visualize_denoise_set2_short.sh "${base}"
