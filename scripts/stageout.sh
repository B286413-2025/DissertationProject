#!/bin/bash

#$ -N stageout
#$ -cwd
#$ -q staging

# Runtime limit
#$ -l h_rt=00:10:00

#$ -r yes
#$ -notify
trap 'exit 99' sigusr1 sigusr2 sigterm

# Destination
DESTINATION=/exports/cmvm/datastore/eb/groups/glendinning_grp/analyses/dog_microbiome_daniela/

# Source
SOURCE=/exports/cmvm/eddie/eb/groups/glendinning_grp/daniela_dog_microbiome/*

rsync -rtl ${SOURCE} ${DESTINATION}

# To submit: qsub stageout.sh
