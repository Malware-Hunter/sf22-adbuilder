#!/bin/bash
atual="$PWD"
input="$1"
file_name="$(basename $input)"
path_file="$(dirname $input)"
cd $path_file
cp $file_name $atual
cd $atual

[ "$file_name" ] &&  [ -f "$file_name" ] && [ "$2" ] || { echo "Uso: $0 <sha256.txt>"; exit;}
LINHAS=$(wc -l $file_name | cut -d' ' -f1)
TAMANHO=$(($LINHAS/$2))
split -l $TAMANHO "$file_name" moto_
for arquivo in moto_*
do
    ./download.sh "$arquivo" 
done

rm $file_name
