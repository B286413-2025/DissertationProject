#!/bin/sh

## Script for classifier training
# From: https://forum.qiime2.org/t/processing-filtering-and-evaluating-the-silva-database-and-other-reference-sequence-data-with-rescript/15494

# Grid Engine options
#$ -N classifier_training
#$ -cwd
#$ -l h_rt=05:00:00

# Loading QIIME2
. /etc/profile.d/modules.sh

module load anaconda
conda activate rachis-qiime2-2026.4

# Getting the SILVA database
qiime rescript get-silva-data \
  --p-version '138.2' \
  --p-target 'SSURef_NR99' \
  --o-silva-sequences silva-138.2-ssu-nr99-rna-seqs.qza \
  --o-silva-taxonomy silva-138.2-ssu-nr99-tax.qza

# Reverse transcription
qiime rescript reverse-transcribe \
  --i-rna-sequences silva-138.2-ssu-nr99-rna-seqs.qza
  --o-dna-sequences silva-138.2-ssu-nr99-seqs.qza

# Removing low-quality sequences
# Default settings: 5 or more ambiguous bases, homopolymers 8 bases or longer
qiime rescript cull-seqs \
  --i-sequences silva-138.2-ssu-nr99-seqs.qza \
  --o-clean-sequences silva-138.2-ssu-nr99-seqs-cleaned.qza

# Filtering sequences by length by taxon
qiime rescript filter-seqs-length-by-taxon \
  --i-sequences silva-138.2-ssu-nr99-seqs-cleaned.qza \
  --i-taxonomy silva-138.2-ssu-nr99-tax.qza \
  --p-labels Archaea Bacteria Eukaryota \
  --p-min-lens 900 1200 1400 \
  --o-filtered-seqs silva-138.2-ssu-nr99-seqs-filt.qza \
  --o-discarded-seqs silva-138.2-ssu-nr99-seqs-discard.qza

# Dereplication for efficiency, only non-unique labels are collapsed
# TODO: by default: --p-rank-handles 'domain'  'phylum'  'class'  'order'  'family'  'genus'  'species'
# Species might be irrelevant in this case of the short reads
qiime rescript dereplicate \
  --i-sequences silva-138.2-ssu-nr99-seqs-filt.qza  \
  --i-taxa silva-138.2-ssu-nr99-tax.qza \
  --p-mode 'uniq' \
  --o-dereplicated-sequences silva-138.2-ssu-nr99-seqs-derep-uniq.qza \
  --o-dereplicated-taxa silva-138.2-ssu-nr99-tax-derep-uniq.qza

# Training amplicon-specific classifiers
# TODO: perhpas expand on regions to account for non-primer sequences
qiime feature-classifier extract-reads \
  --i-sequences silva-138.2-ssu-nr99-seqs-derep-uniq.qza \
  --p-f-primer GTGYCAGCMGCCGCGGTAA \
  --p-r-primer GGACTACNVGGGTWTCTAAT \
  --p-n-jobs 2 \
  --p-read-orientation 'forward' \
  --o-reads silva-138.2-ssu-nr99-seqs-515f-806r.qza

# Some more dereplication
qiime rescript dereplicate \
  --i-sequences silva-138.2-ssu-nr99-seqs-515f-806r.qza \
  --i-taxa silva-138.2-ssu-nr99-tax-derep-uniq.qza \
  --p-mode 'uniq' \
  --o-dereplicated-sequences silva-138.2-ssu-nr99-seqs-515f-806r-uniq.qza \
  --o-dereplicated-taxa  silva-138.2-ssu-nr99-tax-515f-806r-derep-uniq.qza

# Actually training the classifier
qiime feature-classifier fit-classifier-naive-bayes \
  --i-reference-reads silva-138.2-ssu-nr99-seqs-515f-806r-uniq.qza \
  --i-reference-taxonomy silva-138.2-ssu-nr99-tax-515f-806r-derep-uniq.qza \
  --o-classifier silva-138.2-ssu-nr99-515f-806r-classifier.qza
