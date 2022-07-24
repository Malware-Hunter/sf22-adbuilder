#!/bin/bash
[ $1 ] && [ $2 ] && [ -d $2 ] && [ $3 ] && [ -d $3 ] && [ $4 ] && [ -d $4 ] && [ $5 ] && [ -d $5 ] || { echo "Usage: <n_APKs> <path_labelling_queue> <path_queue_extraction> <path_building_queue> <path_logs_building>"; exit; }

N_APKS=$1
FILA_DE_LABELLING=$2
FILA_DE_EXTRACTION=$3
FILA_DE_BUILDING=$4
LOG_DIR=$5


[ -d $FILA_DE_BUILDING/Clean ] || { mkdir -p $FILA_DE_BUILDING/Clean; }
[ -d $FILA_DE_BUILDING/Final ] || { mkdir -p $FILA_DE_BUILDING/Final; }
[ -d $LOG_DIR ] || { mkdir -p $LOG_DIR; }

TS=$(date +%Y%m%d%H%M%S)
[ -d $LOG_DIR/stats-$TS ] || { mkdir -p $LOG_DIR/stats-$TS; }
#bash -x ./extraction/run_apk_extraction.sh $EXTRACTION_QUEUE $BUILDING_QUEUE $LOG_DIR/stats-$TS-$CONTADOR &> $LOG_DIR/extraction-$TS-$CONTADOR.log &

for CLEANED in $(find $FILA_DE_BUILDING/Clean/ -type f -name \*.csv.cleaned)
do
    # splitar nome do arquivo
    DIR_CLEANED=$(echo $CLEANED | cut -d'.' -f1)
    NOME_CLEANED=$(echo $DIR_CLEANED | cut -d'/' -f4)
    
    if [ -f $FILA_DE_BUILDING/$NOME_CLEANED.csv.OK ]; then
        rm -f $FILA_DE_BUILDING/$NOME_CLEANED.csv.OK
        continue
    fi
done
# excluir outros possíveis arquivos antigos
#rm -f $FILA_DE_BUILDING/*.csv.OK

while [ 1 ]
do
    COUNTER=0
    # verifica se existe algum arquivo .csv.OK no diretorio de entrada
    for FILE in $(find $FILA_DE_BUILDING -type f -name \*.csv.OK)
    do
        # splitar nome do arquivo
        DIR_ARQUIVO=$(echo $FILE | cut -d'.' -f1)
        NOME_ARQUIVO=$(echo $DIR_ARQUIVO | cut -d'/' -f3)

        # tamanho do arquivo em bytes
        TAMANHO_ARQUIVO=$(stat -c%s $FILE)
        
        if [ ! -f $FILA_DE_BUILDING/Clean/$NOME_ARQUIVO.csv ]
        then
            python3 ./building/dataset_geration.py --indir $DIR_ARQUIVO.csv --outdir $FILA_DE_BUILDING/Clean/ &>> $LOG_DIR/stats-$TS/Geration-$TS.log
        else
            if [ -f $FILA_DE_BUILDING/$NOME_ARQUIVO.csv.labeled ] && [ ! -f $FILA_DE_BUILDING/Clean/$NOME_ARQUIVO.csv.cleaned ]
            then
                python3 ./building/concat_dataset.py --incsv $FILA_DE_BUILDING/Clean/$NOME_ARQUIVO.csv --inlabeled $FILA_DE_BUILDING/$NOME_ARQUIVO.csv.labeled --outdir $FILA_DE_BUILDING/Final/  &>> $LOG_DIR/stats-$TS/Concat-$TS.log
                touch $FILA_DE_BUILDING/Clean/$NOME_ARQUIVO.csv.cleaned
                COUNTER=$((COUNTER+1))
                # PID do processo atual
                PID=$!                
            fi
        fi

        #/usr/bin/time -f "$NOME_ARQUIVO Tempo decorrido do Tratamento e Geração do CSV = %e segundos, CPU = %P, Memoria = %M KiB, Tamanho = $TAMANHO_ARQUIVO bytes" -a -o $LOGS_DIR/stats-$TS-Geration python3 ./building/dataset_geration.py --indir $DIR_ARQUIVO.csv --outdir $FILA_DE_BUILDING/Clean/ &> $LOG_DIR/building-$TS-Geration.log &
        #/usr/bin/time -f "$NOME_ARQUIVO Tempo decorrido da Concatenação do CSV = %e segundos, CPU = %P, Memoria = %M KiB Tamanho = $TAMANHO_ARQUIVO bytes" -a -o $LOGS_DIR/stats-$TS-Concat python3 ./building/concat_dataset.py --indir $FILA_DE_BUILDING/Clean/$NOME_ARQUIVO.csv --outdir $FILA_DE_BUILDING/Final/  &> $LOG_DIR/building-$TS-Concat.log &
    done

    # fazer esperar a rotulação

    # verificar se todos os CSVs já foram processados
    if [ $N_APKS -eq $COUNTER ]
    then
        #esperar o PID do processo atual
        wait $PID
        echo -e "Todos os CSVs já foram processados!\nDataset gerado!\n\nMatando todos os processos..."  
        ./kill_all.sh
        break
    fi
    sleep 10
done