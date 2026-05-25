#!/usr/bin/bash

## Script to subset metadata into files based on sequencing runs 
set -euo pipefail

# Input and output directories
# Inputs are provided on the CLI

# Input dir, e.g., 05_Nov_2025
run_dir="$1"
# Metadata file, e.g., metadata_updated.csv
meta="$2"
# Output dir for summary files
out="${3:-$run_dir/meta_subset}"

mkdir -p "$out"

# Unique sample stems (collapses paired reads)
ls -1 "$run_dir/raw_data" \
| awk -F'_R' '{print $1}' \
| sort -u > "$out/stems.txt"

# Unique activation codes (first 6 chars)
cut -c1-6 "$out/stems.txt" | sort -u > "$out/codes_raw.txt"

# Duplicates in raw (e.g. -01/-02)
awk '{print substr($0,1,6)}' "$out/stems.txt" \
| sort | uniq -c | awk '$1>1{print $2 "\t" $1}' > "$out/dups_raw.tsv"

# Activation codes in metadata (col 1, skip header)
awk -F, 'NR>1{print $1}' "$meta" | sort -u > "$out/codes_meta.txt"

# Missing in metadata, comparing files
comm -23 "$out/codes_raw.txt" "$out/codes_meta.txt" > "$out/missing.txt"

# Duplicates in metadata
awk -F, 'NR>1{print $1}' "$meta" | sort | uniq -c | awk '$1>1{print $2 "\t" $1}' > "$out/dups_meta.tsv"

# Subsetting metadata (with header)
awk -F, -v ids="$out/codes_raw.txt" '
  BEGIN { while((getline<ids)>0) keep[$1]=1; close(ids) }
  NR==1 || ($1 in keep)
' "$meta" > "$run_dir/metadata_subset.csv"
