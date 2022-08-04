#!/bin/bash

[ $1 ] && [ $2 ] && [ -d $2 ] && [ $3 ] && [ -d $3 ] && [ $4 ] && [ -d $4 ] || { echo "Usage: $0 <n_parallel_extractions> <path_download_queue> <path_extraction_queue> <path_building_queue> <path_logs>"; exit; }

DOWNLOAD_QUEUE=$2
EXTRACTION_QUEUE=$3
BUILDING_QUEUE=$4
CONTADOR=1
LOG_DIR=$5

[ -d $LOG_DIR ] || { mkdir -p $LOG_DIR; }
N_PARALLEL_EXTRACTORS=$1
TS=$(date +%Y%m%d%H%M%S)

for NEXT in $(seq 1 $N_PARALLEL_EXTRACTORS)
do
    [ -d $LOG_DIR/stats-$TS-$CONTADOR ] || { mkdir -p $LOG_DIR/stats-$TS-$CONTADOR; }
    bash -x ./extraction/run_apk_extraction.sh $EXTRACTION_QUEUE $BUILDING_QUEUE $LOG_DIR/stats-$TS-$CONTADOR $CONTADOR &> $LOG_DIR/extraction-$TS-$CONTADOR.log &
    CONTADOR=$((CONTADOR+1))
done

while [ 1 ]
do
    # contabilizar arquivos .downloaded e .extracted
    EXT_DOWNLOAD=$(find $FILA_DE_DOWNLOAD -type f -name \*.apk.downloaded | wc -l)
    EXT_COUNT=$(find $FILA_DE_EXTRACTION -type f -name \*.apk.extracted | wc -l)

    # verifica se o download foi finalizado
    if [ -f $EXTRACTION_QUEUE/download.finished ] && [ $EXT_DOWNLOAD -eq $EXT_COUNT ]
    then
        touch $BUILDING_QUEUE/extraction.finished
        break
    fi

    sleep 10
done