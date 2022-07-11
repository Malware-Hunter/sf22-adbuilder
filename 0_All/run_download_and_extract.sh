#!/bin/bash
# etapa de download e extração
[ "$1" ] &&  [ -f "$1" ] && [ "$2" ] || { echo "Uso: $0 <sha256.txt>"; exit;}
LINHAS=$(wc -l $1 | cut -d' ' -f1)
TAMANHO=$(($LINHAS/$2))
split -l $TAMANHO "$1" moto_
for arquivo in moto_*
do
    ./download_and_extract.sh "$arquivo" &
done