#!/bin/bash

[ $1 ] && [ $2 ] && [ -d $2 ] && [ $3 ] && [ -d $3 ] && [ $4 ] && [ -d $4 ] || { echo "Usage: $0 <n_parallel_extractions> <path_extraction_queue> <path_building_queue> <path_logs>"; exit; }

EXTRACTION_QUEUE=$2
BUILDING_QUEUE=$3
CONTADOR=1
LOG_DIR=$4

[ -d $LOG_DIR ] || { mkdir -p $LOG_DIR; }
N_PARALLEL_EXTRACTORS=$1
TS=$(date +%Y%m%d%H%M%S)
for NEXT in $(seq 1 $N_PARALLEL_EXTRACTORS)
do
    [ -d $LOG_DIR/stats-$TS-$CONTADOR ] || { mkdir -p $LOG_DIR/stats-$TS-$CONTADOR; }
    bash -x ./extraction/run_apk_extraction.sh $EXTRACTION_QUEUE $BUILDING_QUEUE $LOG_DIR/stats-$TS-$CONTADOR &> $LOG_DIR/extraction-$TS-$CONTADOR.log &
    CONTADOR=$((CONTADOR+1))
done