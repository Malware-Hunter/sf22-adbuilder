#!/bin/bash
[ "$1" ] && [ -f "$1" ] && [ "$2" ] && [ -f "$2" ] || { echo "Usage: $0 <sha256.txt> <API_Keys.txt>"; exit 1; }

# PASSAR OS DIRETÓRIOS LOGS E QUEUES CERTOS PARA O SCRIPT

# splitar arquivos em partes de ~500 linhas
LINHAS=$(wc -l $1 | cut -d' ' -f1)
TAMANHO=$(($LINHAS/235))
if [ $TAMANHO -eq 0 ]; then
    mkdir -p 500_VT_aa
else
    split -l $TAMANHO "$1" 500_VT_
fi

# criar pasta para armazenar os arquivos de arquivos de entrada
for arquivo in 500_VT_*
do
    # converter o arquivo para txt
    cat $arquivo | cut -d' ' -f1 > $arquivo.txt
    # criar diretório
    mkdir Folder_"$arquivo"
    # remover arquivo original
    rm $arquivo
    # mover arquivo para a pasta
    mv $arquivo.txt Folder_"$arquivo"/
    # copiar arquivo run.sh para a pasta
    cp run_analysis.sh Folder_"$arquivo"/
done