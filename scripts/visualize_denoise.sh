#!/bin/bash -l

## A script to generate visualization files for the denoising outputs

set -euo pipefail

base="$1"
# e.g. 05_Nov_2025

# Activating the conda environment
. /etc/profile.d/modules.sh
module load anaconda
conda activate rachis-qiime2-2026.4

# Generating visualization files
# Denoising stats
qiime metadata tabulate \
  --m-input-file "../denoise/${base}_denoising_stats.qza" \
  --o-visualization "../denoise/${base}_denoising_stats.qzv"

# Feature table summary
qiime feature-table summarize \
  --i-table "../denoise/${base}_asv_table.qza" \
  --o-visualization "../denoise/${base}_asv_table.qzv"

# Representative sequences
qiime feature-table tabulate-seqs \
  --i-data "../denoise/${base}_asv.qza" \
  --o-visualization "../denoise/${base}_asv.qzv"

