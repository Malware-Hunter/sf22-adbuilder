#!/bin/bash
[ $1 ] && [ -f $1 ] && [ $3 ] && [ -d $3 ] && [ $4 ] && [ -d $4 ] && [ $5 ] && [ -d $5 ] || { echo "Uso: $0 <sha256.txt> <path_labelling_queue> <path_queue_building> <path_logs_labelling>"; exit; }

SHA256=$1
API_KEYS=./API_Keys.txt
FILA_DE_LABELLING=$3
FILA_DE_BUILDING=$4
LOG_DIR=$5

########### SPLIT_500 ##########

# splitar arquivos em partes de ~500 linhas
LINHAS=$(wc -l $SHA256 | cut -d' ' -f1)
TAMANHO=$(($LINHAS/235))
if [ $TAMANHO -eq 0 ]; then
    [ -d $FILA_DE_LABELLING/500_VT_aa ] || { mkdir -p $FILA_DE_LABELLING/500_VT_aa; }
else
    split -l $TAMANHO $SHA256 $FILA_DE_LABELLING/500_VT_
fi

# criar pasta para armazenar os arquivos de arquivos de entrada
for ARQUIVO in $FILA_DE_LABELLING/500_VT_*
do
    # criar diretório, se não existir
    [ -d "$ARQUIVO"_Analysis ] || { mkdir -p "$ARQUIVO"_Analysis; }
    # mover arquivo para a pasta
    mv $ARQUIVO "$ARQUIVO"_Analysis/
    # copiar arquivo run.sh para a pasta
    cp ./virustotal/run_analysis.sh "$ARQUIVO"_Analysis/
done

./virustotal/run.sh $SHA256 $API_KEYS $FILA_DE_LABELLING $FILA_DE_BUILDING $LOG_DIR

#N_LABELLINGS=$2
#TS=$(date +%Y%m%d%H%M%S)
#for NEXT in $(seq 1 $N_LABELLINGS)
#do
#    [ -d $LOG_DIR/stats-$TS-$CONTADOR ] || { mkdir -p $LOG_DIR/stats-$TS-$CONTADOR; }
#    ./virustotal/run.sh $0 ./virustotal/API_Keys.txt $FILA_DE_LABELLING $FILA_DE_BUILDING $LOG_DIR/stats-$TS-$CONTADOR &> $LOG_DIR/labelling-$TS-$CONTADOR/log &
    #./extraction/run_apk_extraction.sh $FILA_DE_EXTRACTION $FILA_DE_BUILDING $LOG_DIR/stats-$TS-$CONTADOR &> $LOG_DIR/extraction-$TS-$CONTADOR.log &
#    CONTADOR=$((CONTADOR+1))
#done

