#!/bin/bash

[ -d $1 ] && [ -d $2 ] && [ -d $3 ] || { echo "Uso: $0 <path_fila_extraction> <path_fila_building> <path_dir_de_logs>"; exit; }

FILA_DE_EXTRACTION=$1
FILA_DE_BUILDING=$2
LOGS_DIR=$3

while [ 1 ]
do
    for ARQUIVO_APK in $(find $FILA_DE_EXTRACTION -type f -name \*.apk)
    do
	echo -n "Iniciando verificacao/processamento do APK $ARQUIVO_APK ... "

	# continua se o arquivo .OK existir. senao, pula para o proximo APK.
	[ -f $ARQUIVO_APK.OK ] || { continue; } 

	# pega o LOCK do APK. se o LOCK ja existir, pula para o proximo APK.
        if { set -C; 2>/dev/null >./$ARQUIVO_APK.lock; }; then
            trap "rm -f ./$ARQUIVO_APK.lock" EXIT
        else
	    continue # arquivo de LOCK ja existe. vai para proximo APK.
        fi

	# pega nome do APK sem PATH e sem extensao
	NOME=$(echo $ARQUIVO_APK | sed 's/^.*\///;s/\..*$//')

	# extrai as caracteristicas do APK e gera estatisticas
    	/usr/bin/time -f "$ARQUIVO_APK Tempo decorrido Extração = %e segundos, CPU = %P, Memoria = %M KiB" -a -o $LOGS_DIR/stats-$NOME.txt python3 extraction/get_caracteristicas.py -a $ARQUIVO_APK

	# move o CSV das caracteristicas para a FILA de building
    	mv $NOME.csv $FILE_DE_BUILDING/
	# sinaliza os processos de building que o CSV ja foi todo gravado
	touch $FILE_DE_BUILDING/$NOME.csv.OK

	echo "finalizado."
    done

    # se nao tem mais APKs no DIR, aguarda 10s e verifica novamente
    sleep 10
done
