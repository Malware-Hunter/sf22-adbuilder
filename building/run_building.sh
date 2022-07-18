#!/bin/bash
[ $1 ] && [ -d $1 ] && [ $2 ] && [ -d $2 ] && [ $3 ] && [ -d $3 ] && [ $4 ] && [ -d $4 ] || { echo "Usage: <path_labelling_queue> <path_queue_extraction> <path_building_queue> <path_logs_building>"; exit; }

FILA_DE_LABELLING=$1
FILA_DE_EXTRACTION=$2
FILA_DE_BUILDING=$3
LOG_DIR=$4


[ -d $FILA_DE_BUILDING/Clean ] || { mkdir -p $FILA_DE_BUILDING/Clean; }
[ -d $FILA_DE_BUILDING/Final ] || { mkdir -p $FILA_DE_BUILDING/Final; }

while [ 1 ]
do
    # verificar se existe um arquivo de sinalizacao
    if [ -f $FILA_DE_BUILDING/all_files_processed.OK ]
    then
        echo -e "\nRealizando o tratamento dos CSVs..."
        # executar o script de tratamento dos CSVs
        python3 ./building/dataset_geration.py --indir $FILA_DE_BUILDING --outdir $FILA_DE_BUILDING/Clean/
        echo -e "\nFinalizado!!! Concatenando os arquivos..."
        python3 ./building/concat_dataset.py --indir $FILA_DE_BUILDING/Clean/ --outdir $FILA_DE_BUILDING/Final/
        echo -e "\nMotoDroid dataset gerado com sucesso!!!"  
        break
    fi
    sleep 10
done