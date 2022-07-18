#!/bin/bash
[ $1 ] && [ -f $1 ] && [ $2 ] && [ -d $2 ] || { echo "Usage: $0 <sha256.txt> <path_queue_building>"; exit; }

COUNTER1=0
COUNTER2=0

# contando o numero de linhas do arquivo sha256.txt
for LINE in $(cat $1)
do
    COUNTER1=$((COUNTER1+1))
done

# enquanto COUNTER1 não for igual a COUNTER2, continua
while [ 1 ]
do
    COUNTER2=0
    # contando o numero de arquivos .csv.OK no diretorio de saida
    for FILE in $(find $2 -type f -name \*.csv.OK)
    do
        COUNTER2=$((COUNTER2+1))
    done

    # se COUNTER1 for igual a COUNTER2, sai do loop
    if [ $COUNTER1 -eq $COUNTER2 ]
    then
        echo "Todos os arquivos foram processados!!!"
        # criar arquivo de sinalizacao
        touch $2/all_files_processed.OK
        break
    fi

    sleep 10
done