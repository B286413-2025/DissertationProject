#!/bin/bash -l
#$ -N build_tree
#$ -cwd
#$ -l h_rt=06:00:00
#$ -pe sharedmem 12
#$ -o ../logs/$JOB_NAME.out
#$ -e ../logs/$JOB_NAME.err

## Script for building a phylogenetic tree, second dataset (ASV pipeline)

set -euo pipefail

mkdir -p ../logs
mkdir -p ../phylogeny_set2_short

# Activiating conda environment
. /etc/profile.d/modules.sh
module load anaconda
conda activate rachis-qiime2-2026.4

threads="${NSLOTS:-1}"

qiime phylogeny align-to-tree-mafft-fasttree \
  --i-sequences ../denoise_set2_short/merged_asv.qza \
  --p-n-threads "${threads}" \
  --o-alignment ../phylogeny_set2_short/aligned_asv.qza \
  --o-masked-alignment ../phylogeny_set2_short/masked_aligned_asv.qza \
  --o-tree ../phylogeny_set2_short/unrooted_tree.qza \
  --o-rooted-tree ../phylogeny_set2_short/rooted_tree.qza
