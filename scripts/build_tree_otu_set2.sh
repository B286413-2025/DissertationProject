#!/bin/bash -l
#$ -N build_tree
#$ -cwd
#$ -l h_rt=06:00:00
#$ -pe sharedmem 12
#$ -o ../logs/$JOB_NAME.out
#$ -e ../logs/$JOB_NAME.err

set -euo pipefail

mkdir -p ../logs
mkdir -p ../phylogeny_otu_set2

# Activiating conda environment
. /etc/profile.d/modules.sh
module load anaconda
conda activate rachis-qiime2-2026.4

threads="${NSLOTS:-1}"

qiime phylogeny align-to-tree-mafft-fasttree \
  --i-sequences ../otu_otus_set2/otu97_repseq_lenfilt.qza \
  --p-n-threads "${threads}" \
  --o-alignment ../phylogeny_otu_set2/otu97_aligned.qza \
  --o-masked-alignment ../phylogeny_otu_set2/otu97_masked.qza \
  --o-tree ../phylogeny_otu_set2/otu97_unrooted.qza \
  --o-rooted-tree ../phylogeny_otu_set2/otu97_rooted.qza
