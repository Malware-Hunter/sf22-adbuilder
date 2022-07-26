#!/bin/bash
[ $1 ] && [ -f $1 ] && [ $2 ] && [ -f $2 ] && [ $3 ] && [ -d $3 ] && [ $4 ] && [ -d $4 ] && [ $5 ] && [ -d $5 ] || { echo "Uso: $0 <sha256.txt> <API_Keys.txt> <path_labelling_queue> <path_queue_building> <path_logs_labelling>"; exit; }

SHA256=$1
API_KEYS=$2
FILA_DE_LABELLING=$3
FILA_DE_BUILDING=$4
LOG_DIR=$5

TS=$(date +%Y%m%d%H%M%S)
[ -d $LOG_DIR/stats-$TS ] || { mkdir -p $LOG_DIR/stats-$TS; }

########### SPLIT_500 ##########
# splitar arquivos em partes de ~500 linhas
LINHAS=$(wc -l $SHA256 | cut -d' ' -f1)
TAMANHO=$(($LINHAS/235))
if [ $TAMANHO -eq 0 ]; then
    [ -d $FILA_DE_LABELLING/500_VT_aa_Analysis ] || { mkdir -p $FILA_DE_LABELLING/500_VT_aa_Analysis; }
    cp $SHA256 $FILA_DE_LABELLING/500_VT_aa_Analysis/
    mv $FILA_DE_LABELLING/500_VT_aa_Analysis/$SHA256 $FILA_DE_LABELLING/500_VT_aa_Analysis/500_VT_aa
else
    split -l $TAMANHO $SHA256 $FILA_DE_LABELLING/500_VT_
    for ARQUIVO in $FILA_DE_LABELLING/500_VT_*
    do
        [ -d $ARQUIVO\_Analysis ] || { mkdir -p $ARQUIVO\_Analysis; }
        mv $ARQUIVO $ARQUIVO\_Analysis/
    done
fi

bash -x ./labelling/virustotal/run.sh $SHA256 $API_KEYS $FILA_DE_LABELLING $FILA_DE_BUILDING $LOG_DIR &> $LOG_DIR/stats-$TS-bash.log &

#N_LABELLINGS=$2
#TS=$(date +%Y%m%d%H%M%S)
#for NEXT in $(seq 1 $N_LABELLINGS)
#do
#    [ -d $LOG_DIR/stats-$TS-$CONTADOR ] || { mkdir -p $LOG_DIR/stats-$TS-$CONTADOR; }
#    ./virustotal/run.sh $0 ./virustotal/API_Keys.txt $FILA_DE_LABELLING $FILA_DE_BUILDING $LOG_DIR/stats-$TS-$CONTADOR &> $LOG_DIR/labelling-$TS-$CONTADOR/log &
    #./extraction/run_apk_extraction.sh $FILA_DE_EXTRACTION $FILA_DE_BUILDING $LOG_DIR/stats-$TS-$CONTADOR &> $LOG_DIR/extraction-$TS-$CONTADOR.log &
#    CONTADOR=$((CONTADOR+1))
#done

