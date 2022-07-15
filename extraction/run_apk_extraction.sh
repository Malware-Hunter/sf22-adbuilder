#!/bin/bash

[ -d $1 ] && [ -d $2 ] && [ -d $3 ] || { echo "Uso: $0 <path_extraction_queue> <path_building_queue> <path_logs>"; exit; }

EXTRACTION_QUEUE=$1
BUILDING_QUEUE=$2
LOGS_DIR=$3

while [ 1 ]
do
    for APK_FILE in $(find $EXTRACTION_QUEUE -type f -name \*.apk)
    do
        echo -n "stating processing APK file $APK_FILE ... "
 
        # continua se o arquivo .OK existir. senao, pula para o proximo APK.
        [ -f $APK_FILE.OK ] || { continue; } 
 
        # pega o LOCK do APK. se o LOCK ja existir, pula para o proximo APK.
        if { set -C; 2>/dev/null >./$APK_FILE.lock; }; then
            trap "rm -f ./$APK_FILE.lock" EXIT
        else
            continue # arquivo de LOCK ja existe. vai para proximo APK.
        fi
 
        # pega nome do APK sem PATH e sem extensao
        APK_FILE_NAME=$(echo $APK_FILE | sed 's/^.*\///;s/\..*$//')
 
        # extrai as caracteristicas do APK e gera estatisticas
        /usr/bin/time -f "$APK_FILE Tempo decorrido Extracao = %e segundos, CPU = %P, Memoria = %M KiB" -a -o $LOGS_DIR/stats-$APK_FILE_NAME.txt python3 extraction/apk_extract_features.py --apk $APK_FILE --outdir $BUILDING_QUEUE --logdir $LOGS_DIR
 
        if [ -f $BUILDING_QUEUE/$APK_FILE_NAME.csv ]
        then
            # sinaliza os processos de building que o CSV ja foi todo gravado
            touch $BUILDING_QUEUE/$APK_FILE_NAME.csv.OK
        fi
 
        echo "done."
        rm -f $APK_FILE.{OK,lock}
        touch $APK_FILE.extracted
    done

    # se nao tem mais APKs no DIR, aguarda 10s e verifica novamente
    sleep 10
done
