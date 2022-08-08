#!/bin/bash
[ $1 ] && [ -d $1 ] && [ $2 ] && [ -d $2 ] && [ $3 ] && [ -d $3 ] || { echo "Usage: <path_labelling_queue> <path_building_queue> <path_logs_building>"; exit; }

FILA_DE_LABELLING=$1
FILA_DE_BUILDING=$2
LOG_DIR=$3


[ -d $FILA_DE_BUILDING/Clean ] || { mkdir -p $FILA_DE_BUILDING/Clean; }
[ -d $FILA_DE_BUILDING/Final ] || { mkdir -p $FILA_DE_BUILDING/Final; }
[ -d $LOG_DIR ] || { mkdir -p $LOG_DIR; }

TS=$(date +%Y%m%d%H%M%S)
[ -d $LOG_DIR/stats-$TS ] || { mkdir -p $LOG_DIR/stats-$TS; }


# remover arquivos antigos .cleaned
for FILE in $FILA_DE_BUILDING/Clean/*.cleaned
do
    rm $FILE > /dev/null 2>&1
done

COUNTER=0
while [ 1 ]
do
    # verifica se existe algum arquivo .csv.OK no diretorio de entrada
    for FILE in $(find $FILA_DE_BUILDING -type f -name \*.csv.OK)
    do
        # splitar nome do arquivo
        DIR_ARQUIVO=$(echo $FILE | cut -d'.' -f1)
        NOME_ARQUIVO=$(echo $DIR_ARQUIVO | cut -d'/' -f3)
        
        if [ ! -f $FILA_DE_BUILDING/Clean/$NOME_ARQUIVO.csv ]
        then
            #python3 ./building/dataset_geration.py --indir $DIR_ARQUIVO.csv --outdir $FILA_DE_BUILDING/Clean/ &>> $LOG_DIR/stats-$TS/Geration-$TS.log
            /usr/bin/time -f "$NOME_ARQUIVO Tempo decorrido do Tratamento e Geração do CSV = %e segundos, CPU = %P, Memoria = %M KiB" -a -o $LOG_DIR/stats-$TS/stats-Geration.txt python3 ./building/dataset_geration.py --indir $DIR_ARQUIVO.csv --outdir $FILA_DE_BUILDING/Clean/ &
        else
            if [ -f $FILA_DE_BUILDING/$NOME_ARQUIVO.csv.labeled ] && [ ! -f $FILA_DE_BUILDING/Clean/$NOME_ARQUIVO.csv.cleaned ]
            then
                #python3 ./building/concat_dataset.py --incsv $FILA_DE_BUILDING/Clean/$NOME_ARQUIVO.csv --inlabeled $FILA_DE_BUILDING/$NOME_ARQUIVO.csv.labeled --outdir $FILA_DE_BUILDING/Final/  &>> $LOG_DIR/stats-$TS/Concat-$TS.log
                /usr/bin/time -f "$NOME_ARQUIVO Tempo decorrido da Concatenação do CSV = %e segundos, CPU = %P, Memoria = %M KiB" -a -o $LOG_DIR/stats-$TS/stats-Concat.txt python3 ./building/concat_dataset.py --incsv $FILA_DE_BUILDING/Clean/$NOME_ARQUIVO.csv --inlabeled $FILA_DE_BUILDING/$NOME_ARQUIVO.csv.labeled --outdir $FILA_DE_BUILDING/Final/ &
                # PID do processo de concatenacao, para o building esperar esse PID para matar os processos
                PID_CONCAT=$$
                wait
                touch $FILA_DE_BUILDING/Clean/$NOME_ARQUIVO.csv.cleaned
                # renomear arquivo de csv.OK para csv.OK.finished
                mv $FILA_DE_BUILDING/$NOME_ARQUIVO.csv.OK $FILA_DE_BUILDING/$NOME_ARQUIVO.csv.OK.finished
                COUNTER=$((COUNTER+1))               
            fi
        fi
    done

    # contar quantos arquivos .extracted existem na fila de extração
    EXT_COUNT=$(find $FILA_DE_EXTRACTION -type f -name \*.apk.extracted | wc -l)

    # verificar se todos os CSVs já foram processados
    if [ -f $FILA_DE_BUILDING/extraction.finished ] && [ $EXT_COUNT -eq $COUNTER ]
    then
        #echo -e "Esperando PID $PID_CONCAT para encerrar o programa..."
        #esperar o PID do processo atual
        wait $PID_CONCAT > /dev/null 2>&1
        echo -e "\nTodos os CSVs já foram processados!\nDataset gerado!\n"  
        touch $FILA_DE_BUILDING/building.finished
        #./scripts/kill_all.sh
        break
    fi
    sleep 10
done