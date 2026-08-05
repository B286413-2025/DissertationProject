#!/bin/bash -l
#$ -cwd
#$ -N otu_cluster_cr
#$ -l h_rt=30:00:00
#$ -pe sharedmem 12
#$ -l h_vmem=8G
#$ -o ../logs/$JOB_NAME.out
#$ -e ../logs/$JOB_NAME.err

## Closed-reference OTU clustering, matched to the de-novo pipeline.
## Uses the same merged, chimera-filtered inputs (must run AFTER otu_prep.sh) and the SAME 97% identity.

# Inspiration from: https://docs.qiime2.org/2024.10/tutorials/otu-clustering/

set -euo pipefail
mkdir -p ../logs ../otu_otus_cr_set2

# Loading QIIME2
. /etc/profile.d/modules.sh
module load anaconda
conda activate rachis-qiime2-2026.4

threads="${NSLOTS:-1}"

# References sequences for clustering
ref_seqs="../classifier/silva-138.2-ssu-nr99-seqs-515f-806r-uniq.qza"
classifier="../classifier/silva-138.2-ssu-nr99-515f-806r-classifier.qza"

## Reusing the merged, chimera-filtered artifacts produced by the de-novo run
## otu_cluster.sh must run first

# Closed-reference OTU clustering at 97% identity
# TODO: perhaps change percentage
qiime vsearch cluster-features-closed-reference \
  --i-table ../otu_otus_set2/derep_nonchim_table.qza \
  --i-sequences ../otu_otus_set2/derep_nonchim_seqs.qza \
  --i-reference-sequences "${ref_seqs}" \
  --p-perc-identity 0.97 \
  --p-threads "${threads}" \
  --o-clustered-table ../otu_otus_cr_set2/otu97cr_table.qza \
  --o-clustered-sequences ../otu_otus_cr_set2/otu97cr_repseq.qza \
  --o-unmatched-sequences ../otu_otus_cr_set2/otu97cr_unmatched.qza

# Filtering length
qiime rescript filter-seqs-length \
  --i-sequences ../otu_otus_cr_set2/otu97cr_repseq.qza \
  --p-global-min 200 \
  --o-filtered-seqs ../otu_otus_cr_set2/otu97cr_repseq_lenfilt.qza \
  --o-discarded-seqs ../otu_otus_cr_set2/otu97cr_repseq_discarded.qza

qiime feature-table filter-features \
  --i-table ../otu_otus_cr_set2/otu97cr_table.qza \
  --m-metadata-file ../otu_otus_cr_set2/otu97cr_repseq_lenfilt.qza \
  --o-filtered-table ../otu_otus_cr_set2/otu97cr_table_lenfilt.qza

# Summaries of clustered OTUs
qiime feature-table summarize \
  --i-table ../otu_otus_cr_set2/otu97cr_table_lenfilt.qza \
  --o-summary ../otu_otus_cr_set2/otu97cr_table.qzv \
  --o-sample-frequencies ../otu_otus_cr_set2/otu97cr_sample_frequencies.qza \
  --o-feature-frequencies ../otu_otus_cr_set2/otu97cr_feature_frequencies.qza

qiime feature-table tabulate-seqs \
  --i-data ../otu_otus_cr_set2/otu97cr_repseq_lenfilt.qza \
  --o-visualization ../otu_otus_cr_set2/otu97cr_repseq.qzv

# Inspecting how many reads failed to match the reference
qiime feature-table tabulate-seqs \
  --i-data ../otu_otus_cr_set2/otu97cr_unmatched.qza \
  --o-visualization ../otu_otus_cr_set2/otu97cr_unmatched.qzv

# Taxonomic assignment
# Using same classify-sklearn as de-novo for comparability
qiime feature-classifier classify-sklearn \
  --i-classifier "${classifier}" \
  --i-reads ../otu_otus_cr_set2/otu97cr_repseq_lenfilt.qza \
  --p-n-jobs "${threads}" \
  --o-classification ../otu_otus_cr_set2/otu97cr_taxonomy.qza

qiime metadata tabulate \
  --m-input-file ../otu_otus_cr_set2/otu97cr_taxonomy.qza \
  --o-visualization ../otu_otus_cr_set2/otu97cr_taxonomy.qzv

qiime taxa barplot \
  --i-table ../otu_otus_cr_set2/otu97cr_table_lenfilt.qza \
  --i-taxonomy ../otu_otus_cr_set2/otu97cr_taxonomy.qza \
  --o-visualization ../otu_otus_cr_set2/otu97cr_taxa_barplot.qzv
