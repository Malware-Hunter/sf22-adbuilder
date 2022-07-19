#!/bin/bash
[ $1 ] && [ $2 ] && [ -d $2 ] && [ $3 ] && [ -d $3 ] && [ $4 ] && [ -d $4 ] && [ $5 ] && [ -d $5 ] || { echo "Usage: <n_APKs> <path_labelling_queue> <path_queue_extraction> <path_building_queue> <path_logs_building>"; exit; }

N_APKS=$1
FILA_DE_LABELLING=$2
FILA_DE_EXTRACTION=$3
FILA_DE_BUILDING=$4
LOG_DIR=$5


[ -d $FILA_DE_BUILDING/Clean ] || { mkdir -p $FILA_DE_BUILDING/Clean; }
[ -d $FILA_DE_BUILDING/Final ] || { mkdir -p $FILA_DE_BUILDING/Final; }

while [ 1 ]
do
    COUNTER=0
    # verifica se existe algum arquivo .csv.OK no diretorio de entrada
    for FILE in $(find $FILA_DE_BUILDING -type f -name \*.csv.OK)
    do
        COUNTER=$((COUNTER+1))
    done

    # verificar se todos os CSVs já foram processados
    if [ $N_APKS -eq $COUNTER ]
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