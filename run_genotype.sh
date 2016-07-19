#!/bin/bash -uex
set -o pipefail

COHORT_VCF=$1
SAMPLE=$2
ALIGNMENT_BAM=$3
SPLITTER_BAM=$4

cat $COHORT_VCF | /gscmnt/gc2719/halllab/bin/vawk --header '{  $6="."; print }' | svtools genotype -B $ALIGNMENT_BAM -S $SPLITTER_BAM | sed 's/PR...=[0-9\.e,-]*\(;\)\{0,1\}\(\t\)\{0,1\}/\2/g' - 
