#!/bin/bash

[ $1 ] &&  [ -f $1 ] && [ $2 ] && [ -d $2 ] && [ $3 ] && [ $4 ] && [ -d $4 ] && [ $5 ] && [ -d $5 ] || { echo "Usage: $0 <list_of_APK_SHA256.txt> <path_download_queue> <n_parallel_downloads> <path_extraction_queue> <path_logs_download>"; exit; }

DOWNLOAD_QUEUE=$2
N_PARALLEL_DOWNLOADS=$3

# excluir arquivos moto_ que já foram baixados
for MOTO in $DOWNLOAD_QUEUE/moto_*
do
	[ -f $MOTO ] && {
		SHA256=$(cat $MOTO | awk '{print $1}')
		echo "Excluindo $MOTO"
		rm $MOTO
	}
done

if [ $3 -gt 1 ]
then	
	SIZE=$(wc -l "$1" | awk '{ print $1 }')
	SIZE=$((SIZE/N_PARALLEL_DOWNLOADS+1))
	split -l $SIZE $1 $DOWNLOAD_QUEUE/moto_
else
	FILE=$(echo $1 | sed 's/^.*\///')
	cp -f $1 $DOWNLOAD_QUEUE/moto_$FILE
fi
TS=$(date +%Y%m%d%H%M%S)
COUNTER=1
LOG_DIR=$5
[ -d $LOG_DIR ] || { mkdir -p $LOG_DIR; }
for APK_LIST_FILE in $DOWNLOAD_QUEUE/moto_*
do
    [ -d $LOG_DIR/stats-$TS-$COUNTER ] || { mkdir -p $LOG_DIR/stats-$TS-$COUNTER; }
    ./download/run_apk_download.sh $APK_LIST_FILE $4 $LOG_DIR/stats-$TS-$COUNTER &> $LOG_DIR/download-$TS-$COUNTER.log &
    COUNTER=$((COUNTER+1))
done

