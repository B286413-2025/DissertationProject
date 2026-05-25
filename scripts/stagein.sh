#!/bin/bash

#$ -N stagein
#$ -cwd
#$ -q staging

# Runtime limit
#$ -l h_rt=05:00:00

#$ -r yes
#$ -notify
trap 'exit 99' sigusr1 sigusr2 sigterm

# Source
SOURCE=/exports/cmvm/datastore/eb/groups/glendinning_grp/raw_seq_data_read_only/dog_microbiome_daniela/raw_data

# Destination
DESTINATION=/exports/cmvm/eddie/eb/groups/glendinning_grp/

rsync -rtl ${SOURCE} ${DESTINATION}

# To submit: qsub stagein.sh

