#!/bin/bash -l
#$ -cwd
#$ -N otu_merge
#$ -l h_rt=12:00:00
#$ -l h_vmem=64G
#$ -o ../logs/$JOB_NAME.out
#$ -e ../logs/$JOB_NAME.err

## Script for merging the OTU artifacts

set -euo pipefail
mkdir -p ../logs ../otu_otus_set2

. /etc/profile.d/modules.sh
module load anaconda
conda activate rachis-qiime2-2026.4

## Merging artifacts
# Tables
qiime feature-table merge \
  --i-tables ../otu_prep_set2/*_nonchim_table.qza \
  --o-merged-table ../otu_otus_set2/derep_nonchim_table.qza

qiime feature-table summarize \
  --i-table ../otu_otus_set2/derep_nonchim_table.qza \
  --o-summary ../otu_otus_set2/derep_nonchim_table.qzv \
  --o-sample-frequencies ../otu_otus_set2/nonchim_sample_frequencies.qza \
  --o-feature-frequencies ../otu_otus_set2/nonchim_feature_frequencies.qza

# Sequences
qiime feature-table merge-seqs \
  --i-data ../otu_prep_set2/*_nonchim_seqs.qza \
  --o-merged-data ../otu_otus_set2/derep_nonchim_seqs.qza

qiime feature-table tabulate-seqs \
  --i-data ../otu_otus_set2/derep_nonchim_seqs.qza \
  --o-visualization ../otu_otus_set2/derep_nonchim_seqs.qzv
