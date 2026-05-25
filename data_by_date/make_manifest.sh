#!/usr/bin/bash

## Script to generate QIIME2 manifest files

set -euo pipefail

# Inputs and outputs
# Input dir from CLI, e.g., 05_Nov_2025
run_dir="$1" 

# Ouput dir from subset_metadata.sh, containing relevant activation codes
out="${2:-$run_dir/meta_subset}"
# Manifest path
manifest="${3:-$run_dir/fq-manifest.tsv}"

# Relevant codes from subsetting
stems="$out/stems.txt"
codes_raw="$out/codes_raw.txt"
missing="$out/missing.txt"

# Activation codes present in metadata for this run
comm -23 "$codes_raw" "$missing" > "$out/codes_ok.txt"

# Header line
echo -e "sample-id\tforward-absolute-filepath\treverse-absolute-filepath" > "$manifest"

while read -r stem; do
  # Activation code from stem
  code="${stem:0:6}"
  # Verifying code present in the current run
  grep -qx "$code" "$out/codes_ok.txt" || continue

  # Getting the forward and reverse paths
  # TODO: add the eddie path
  f="$run_dir/raw_data/${stem}"_R1*.fastq.gz
  r="$run_dir/raw_data/${stem}"_R2*.fastq.gz
  
  printf "%s\t%s\t%s\n" \
	  "$stem" \
	  "$(realpath $f)" \
	  "$(realpath $r)" \
	  >> "$manifest"
done < "$stems"
