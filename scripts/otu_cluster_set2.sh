#!/bin/bash -l
#$ -cwd
#$ -N otu_cluster
#$ -l h_rt=48:00:00
#$ -pe sharedmem 12
#$ -l h_vmem=8G
#$ -o ../logs/$JOB_NAME.out
#$ -e ../logs/$JOB_NAME.err

## A script to perform de-novo OTU clustering of the joined reads and taxonomic assignment
## Can only run after otu_prep.sh has finished!

#  Inspiration from: https://docs.qiime2.org/2024.10/tutorials/otu-clustering/

set -euo pipefail
mkdir -p ../logs ../otu_otus_set2

# Loading QIIME2
. /etc/profile.d/modules.sh
module load anaconda
conda activate rachis-qiime2-2026.4

threads="${NSLOTS:-1}"
classifier="../classifier/silva-138.2-ssu-nr99-515f-806r-classifier.qza"

# Clustering OTUs to 97% identity 
# TODO: possibly change percentage
qiime vsearch cluster-features-de-novo \
  --i-table ../otu_otus_set2/derep_nonchim_table.qza \
  --i-sequences ../otu_otus_set2/derep_nonchim_seqs.qza \
  --p-perc-identity 0.97 \
  --p-threads "${threads}" \
  --o-clustered-table ../otu_otus_set2/otu97_table.qza \
  --o-clustered-sequences ../otu_otus_set2/otu97_repseq.qza

# Length filtering
qiime rescript filter-seqs-length \
  --i-sequences ../otu_otus_set2/otu97_repseq.qza \
  --p-global-min 200 \
  --o-filtered-seqs ../otu_otus_set2/otu97_repseq_lenfilt.qza \
  --o-discarded-seqs ../otu_otus_set2/otu97_repseq_discarded.qza

qiime feature-table filter-features \
  --i-table ../otu_otus_set2/otu97_table.qza \
  --m-metadata-file ../otu_otus_set2/otu97_repseq_lenfilt.qza \
  --o-filtered-table ../otu_otus_set2/otu97_table_lenfilt.qza

# Summaries
# OTU stats
qiime feature-table summarize \
  --i-table ../otu_otus_set2/otu97_table_lenfilt.qza \
  --o-feature-frequencies ../otu_otus_set2/otu97_feature_frequencies.qza \
  --o-sample-frequencies ../otu_otus_set2/otu97_sample_frequencies.qza \
  --o-summary ../otu_otus_set2/otu97_table.qzv

qiime feature-table tabulate-seqs \
  --i-data ../otu_otus_set2/otu97_repseq_lenfilt.qza \
  --o-visualization ../otu_otus_set2/otu97_repseq.qzv

# Taxonomic assignment
qiime feature-classifier classify-sklearn \
  --i-classifier "${classifier}" \
  --i-reads ../otu_otus_set2/otu97_repseq_lenfilt.qza \
  --p-n-jobs "${threads}" \
  --o-classification ../otu_otus_set2/otu97_taxonomy.qza

qiime metadata tabulate \
  --m-input-file ../otu_otus_set2/otu97_taxonomy.qza \
  --o-visualization ../otu_otus_set2/otu97_taxonomy.qzv

qiime taxa barplot \
  --i-table ../otu_otus_set2/otu97_table_lenfilt.qza \
  --i-taxonomy ../otu_otus_set2/otu97_taxonomy.qza \
  --o-visualization ../otu_otus_set2/otu97_taxa_barplot.qzv
