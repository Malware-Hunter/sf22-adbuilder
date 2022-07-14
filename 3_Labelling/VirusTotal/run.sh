#!/bin/bash
[ "$1" ] && [ -f "$1" ] && [ "$2" ] && [ -f "$2" ] || { echo "Usage: $0 <sha256.txt> <API_Keys.txt>"; exit 1; }

# Contador de API Keys
MAX_API_KEYS=$(wc -l $2 | cut -d' ' -f1)
COUNTER=1

# executar os arquivos de arquivos de entrada
for arquivo in Folder_*
do
    # se o counter for menor ou igual ao numero de API Keys, pegar a API Key
    if [ $COUNTER -le $MAX_API_KEYS ]
    then
        # pegar linha da API Key
        API_KEY=$(sed -n "${COUNTER}p" $2)
        cd $arquivo
        # splitar Folder_ do nome do arquivo
        NOME=$(echo $arquivo | cut -d'_' -f4)
        # executar o arquivo run_analysis.sh
        ./run_analysis.sh 500_VT_"$NOME".txt "$API_KEY"
        cd ..
        # incrementar contador de API Keys
        COUNTER=$(($COUNTER+1))
        # renomear diretório
        mv $arquivo X_"$arquivo"
    fi
done