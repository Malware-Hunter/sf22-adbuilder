#!/bin/bash
[ $1 ] && [ $2 ] && [ -d $2 ] && [ $3 ] && [ -d $3 ] && [ $4 ] && [ -d $4 ] || { echo "Usage: <n_APKs> <path_labelling_queue> <path_building_queue> <path_logs_building>"; exit; }

N_APKS=$1
FILA_DE_LABELLING=$2
FILA_DE_BUILDING=$3
LOG_DIR=$4


[ -d $FILA_DE_BUILDING/Clean ] || { mkdir -p $FILA_DE_BUILDING/Clean; }
[ -d $FILA_DE_BUILDING/Final ] || { mkdir -p $FILA_DE_BUILDING/Final; }
[ -d $LOG_DIR ] || { mkdir -p $LOG_DIR; }

TS=$(date +%Y%m%d%H%M%S)
[ -d $LOG_DIR/stats-$TS ] || { mkdir -p $LOG_DIR/stats-$TS; }

# verifica se existe arquivos antigos que já foram limpados
for CLEANED in $(find $FILA_DE_BUILDING/Clean/ -type f -name \*.csv.cleaned)
do
    # splitar nome do arquivo
    DIR_CLEANED=$(echo $CLEANED | cut -d'.' -f1)
    NAME_CLEANED=$(echo $DIR_CLEANED | cut -d'/' -f4)
    
    # exclui arquivos antigos
    if [ -f $FILA_DE_BUILDING/$NAME_CLEANED.csv.OK ]; then
        rm -f $FILA_DE_BUILDING/$NAME_CLEANED.csv.OK
        continue
    fi
done
# excluir outros possíveis arquivos antigos
#rm -f $FILA_DE_BUILDING/*.csv.OK


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
            #/usr/bin/time -f "$NOME_ARQUIVO Tempo decorrido do Tratamento e Geração do CSV = %e segundos, CPU = %P, Memoria = %M KiB" -a -o $LOG_DIR/stats-$TS/stats-Geration.txt python3 ./building/dataset_geration.py --indir $DIR_ARQUIVO.csv --outdir $FILA_DE_BUILDING/Clean/ &
            /usr/bin/time -f "$NOME_ARQUIVO Tempo decorrido do Tratamento e Geração do CSV (%%e) = %e segundos, Tempo (%%E) = %E segundos, CPU ((%%U + %%S) / %%E) = %P, CPU nível usuário (%%U) = %U segundos, CPU nível kernel (%%S) = %S segundos" -a -o $LOG_DIR/stats-$TS/stats-Geration.txt python3 ./building/dataset_geration.py --indir $DIR_ARQUIVO.csv --outdir $FILA_DE_BUILDING/Clean/ &
        else
            if [ -f $FILA_DE_BUILDING/$NOME_ARQUIVO.csv.labeled ] && [ ! -f $FILA_DE_BUILDING/Clean/$NOME_ARQUIVO.csv.cleaned ]
            then
                #python3 ./building/concat_dataset.py --incsv $FILA_DE_BUILDING/Clean/$NOME_ARQUIVO.csv --inlabeled $FILA_DE_BUILDING/$NOME_ARQUIVO.csv.labeled --outdir $FILA_DE_BUILDING/Final/  &>> $LOG_DIR/stats-$TS/Concat-$TS.log
                #/usr/bin/time -f "$NOME_ARQUIVO Tempo decorrido da Concatenação do CSV = %e segundos, CPU = %P, Memoria = %M KiB" -a -o $LOG_DIR/stats-$TS/stats-Concat.txt python3 ./building/concat_dataset.py --incsv $FILA_DE_BUILDING/Clean/$NOME_ARQUIVO.csv --inlabeled $FILA_DE_BUILDING/$NOME_ARQUIVO.csv.labeled --outdir $FILA_DE_BUILDING/Final/ &
                /usr/bin/time -f "$NOME_ARQUIVO Tempo decorrido da Concatenação do CSV (%%e) = %e segundos, Tempo (%%E) = %E segundos, CPU ((%%U + %%S) / %%E) = %P, CPU nível usuário (%%U) = %U segundos, CPU nível kernel (%%S) = %S segundos" -a -o $LOG_DIR/stats-$TS/stats-Concat.txt python3 ./building/concat_dataset.py --incsv $FILA_DE_BUILDING/Clean/$NOME_ARQUIVO.csv --inlabeled $FILA_DE_BUILDING/$NOME_ARQUIVO.csv.labeled --outdir $FILA_DE_BUILDING/Final/ &
                # PID do processo de concatenacao, para o building esperar esse PID para matar os processos
                PID_CONCAT=$$
                wait
                touch $FILA_DE_BUILDING/Clean/$NOME_ARQUIVO.csv.cleaned
                COUNTER=$((COUNTER+1))               
            fi
        fi

    done

    # contagem de APKs processados
    #echo -e "\nNúmero de APKs já processados: $COUNTER / $N_APKS\n"

    # verificar se todos os CSVs já foram processados
    if [ $N_APKS -eq $COUNTER ]
    then
        echo -e "Esperando PID $PID_CONCAT para encerrar o programa..."
        #esperar o PID do processo atual
        wait $PID_CONCAT
        echo -e "\nTodos os CSVs já foram processados!\nDataset gerado!\n\nMatando todos os processos..."  
        ./scripts/kill_all.sh
        break
    fi
    sleep 10
done