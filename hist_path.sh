#!/bin/bash -uex

SAMPLE=$1
LUMPY_DIR=$2
BAM=$3

HIST=$LUMPY_DIR/$SAMPLE/temp/cnvnator-temp/${BAM##*/}.hist.root
echo $HIST
