#!/bin/bash -l
#$ -cwd
#$ -t 1-9
#$ -N qiime2_vis_denoise
#$ -l h_rt=02:00:00
#$ -o ../logs/$JOB_NAME.$TASK_ID.out
#$ -e ../logs/$JOB_NAME.$TASK_ID.err

set -euo pipefail

base=$(sed -n "${SGE_TASK_ID}p" filestoprocess_v4.txt)

./visualize_denoise_outputs.sh "${base}"
