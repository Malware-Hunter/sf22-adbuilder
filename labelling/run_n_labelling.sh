#!/bin/bash

[ $1 ] && [ $2 ] && [ -d $2 ] || { echo "Uso: $0 <numero_de_instancias> <path_fila_extraction> <path_fila_building>"; exit; }

FILA_DE_EXTRACTION=$2
FILA_DE_BUILDING=$3
CONTADOR=1
LOG_DIR=logs/extraction
[ -d $LOG_DIR ] || { mkdir -p $LOG_DIR; }
N_EXTRACTORS=$1
TS=$(date +%Y%m%d%H%M%S)
for NEXT in $(seq 1 $N_EXTRACTORS)
do
    [ -d $LOG_DIR/stats-$TS-$CONTADOR ] || { mkdir -p $LOG_DIR/stats-$TS-$CONTADOR; }
    ./extraction/run_apk_extraction.sh $FILA_DE_EXTRACTION $FILA_DE_BUILDING $LOG_DIR/stats-$TS-$CONTADOR &> $LOG_DIR/extraction-$TS-$CONTADOR.log &
    CONTADOR=$((CONTADOR+1))
done

