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
wait
# etapa de rotulação de APKs com VirusTotal???

# etapa de geração do dataset
mkdir CSVs
for CSV in *.csv
do
    mv $CSV ./CSVs/
done
mkdir Clean
mkdir Final
echo "Realizando o tratamento dos CSVs..."
python3 dataset_geration.py && python3 concat_dataset.py

# mover pasta Clean, CSVs e Final para o diretorio /5_Temp/5_Geration
mv Clean ../5_Temp/5_Geration/
mv CSVs ../5_Temp/5_Geration/
mv Final ../5_Temp/5_Geration/
echo "MotoDroid dataset gerado com sucesso!!!"

# run processes and store pids in array
#for i in $n_procs; do
#    ./procs[${i}] &
#    pids[${i}]=$!
#done

# wait for all pids
#for pid in ${pids[*]}; do
#    wait $pid
#done