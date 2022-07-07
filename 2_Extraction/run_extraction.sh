#!/bin/bash
[ "$1" ] &&  [ -f "$1" ] && [ "$2" ] || { echo "Uso: $0 <sha256.csv>"; exit;}
for arquivo in *.csv
do
    ./extraction.sh "$arquivo" &
done