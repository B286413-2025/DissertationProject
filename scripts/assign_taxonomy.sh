#!/bin/bash -l
#$ -N qiime2_assign_taxonomy
#$ -cwd
#$ -l h_rt=12:00:00
#$ -pe sharedmem 8
#$ -o ../logs/$JOB_NAME.out
#$ -e ../logs/$JOB_NAME.err

set -euo pipefail
mkdir -p ../logs
mkdir -p ../taxonomy

# Activate conda environment
. /etc/profile.d/modules.sh
module load anaconda
conda activate rachis-qiime2-2026.4

threads="${NSLOTS:-1}"

classifier="../classifier/silva-138.2-ssu-nr99-515f-806r-classifier.qza"

# Inputs
repseqs="../denoise/merged_asv.qza"

# Outputs
taxonomy_qza="../taxonomy/merged_taxonomy.qza"
taxonomy_qzv="../taxonomy/merged_taxonomy.qzv"

qiime feature-classifier classify-sklearn \
  --i-classifier "${classifier}" \
  --i-reads "${repseqs}" \
  --p-n-jobs "${threads}" \
  --o-classification "${taxonomy_qza}"

qiime metadata tabulate \
  --m-input-file "${taxonomy_qza}" \
  --o-visualization "${taxonomy_qzv}"
