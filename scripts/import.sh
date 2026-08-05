#!/bin/bash -l

## Worker script for importing into QIIME2

set -euo pipefail

# Running directory from the CLI
run_dir="$1"   # e.g., 05_Nov_2025

. /etc/profile.d/modules.sh
module load anaconda
conda activate rachis-qiime2-2026.4

# Input and output directories
manifest="$run_dir/fq-manifest.tsv"
out_qza="$run_dir/demux-paired-end.qza"
out_qzv="$run_dir/demux-paired-end.qzv"

# Importing according to manifest
qiime tools import \
  --type 'SampleData[PairedEndSequencesWithQuality]' \
  --input-path "$manifest" \
  --output-path "$out_qza" \
  --input-format PairedEndFastqManifestPhred33V2

# Visualization output
qiime demux summarize \
  --i-data "$out_qza" \
  --o-visualization "$out_qzv"

