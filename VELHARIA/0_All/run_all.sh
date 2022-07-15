#!/bin/bash
[ "$1" ] &&  [ -f "$1" ] && [ "$2" ] || { echo "Uso: $0 <sha256.txt>"; exit;}
./all.sh "$1" "$2"
# ./run_download_and_extract.sh "$1" "$2"
#wait $!
#./run_move_and_gerate.sh 
