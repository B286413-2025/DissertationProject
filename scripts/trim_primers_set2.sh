#!/bin/bash 

## Script for primer trimming

set -euo pipefail

infile="$1"
# e.g. ../visualization/05_Nov_2025.qza

outfile="$2"
# e.g. ../trimmed/05_Nov_2025_trimmed.qza

cores="${NSLOTS:-1}"

. /etc/profile.d/modules.sh
module load anaconda
conda activate rachis-qiime2-2026.4

# Removing primers 515f-806r and possible degenerate codes
# And possible adapter readthroughs
# From: https://support-docs.illumina.com/SHARE/AdapterSequences/Content/UDIndexes.htm
qiime cutadapt trim-paired \
  --i-demultiplexed-sequences "${infile}" \
  --p-front-f NGTGCCAGCMGCCGCGGTAA \
  --p-front-f GTGCCAGCMGCCGCGGTAA \
  --p-front-r NGGACTACHVGGGTWTCTAAT \
  --p-front-r GGACTACHVGGGTWTCTAAT \
  --p-adapter-f AGATCGGAAGAGCACACGTCTGAACTCCAGTCA \
  --p-adapter-r AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT \
  --p-match-adapter-wildcards \
  --p-overlap 8 \
  --p-cores "${cores}" \
  --o-trimmed-sequences "${outfile}"

# Optional stricter filtering - to drop reads lacking primers:
#  --p-discard-untrimmed

# Optional tuning if too many reads are being lost due to primer mismatches:
# --p-error-rate 0.12 (default 0.1)
