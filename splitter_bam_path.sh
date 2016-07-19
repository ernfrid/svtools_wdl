#!/bin/bash -uex

SAMPLE=$1
BAM=$2

#echo -e "Sample\tBAM\tSPLITTER"
SPL=${BAM%.*}.splitters.bam
echo $SPL
