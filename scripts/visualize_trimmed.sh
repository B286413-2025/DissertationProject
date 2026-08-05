#!/bin/bash -l

## A script to visualize the trimmed reads
set -euo pipefail

infile="$1"
# e.g. ../trimmed/05_Nov_2025_trimmed.qza
outfile="${2:-${infile%.qza}.qzv}" 
# Same path, .qzv extension

. /etc/profile.d/modules.sh
module load anaconda
conda activate rachis-qiime2-2026.4

qiime demux summarize \
  --i-data "${infile}" \
  --o-visualization "${outfile}"
