#!/bin/bash
[ $1 ] && [ -f $1 ] && [ $2 ] && [ -f $2 ] && [ $3 ] && [ -d $3 ] && [ $4 ] && [ -d $4 ] && [ $5 ] && [ -d $5 ] || { echo "Usage: $0 <sha256.txt> <API_Keys.txt> <path_queue_labelling> <path_queue_building> <path_logs_labelling> "; exit 1; }

SHA256=$1
API_KEYS=$2
FILA_DE_LABELLING=$3
FILA_DE_BUILDING=$4
LOG_DIR=$5
CONTADOR=1
COUNTER=0

# Contador de SHA256
MAX_SHA256=$(wc -l $SHA256 | cut -d' ' -f1)

# Contador de API Keys
MAX_API_KEYS=$(wc -l $API_KEYS | cut -d' ' -f1)


[ -d $LOG_DIR ] || { mkdir -p $LOG_DIR; }
TS=$(date +%Y%m%d%H%M%S)
# executar os arquivos de arquivos de entrada
for ARQUIVO in $FILA_DE_LABELLING/*_Analysis
do
    # se o contador for menor ou igual ao numero de API Keys, pega a API Key
    if [ $CONTADOR -le $MAX_API_KEYS ]
    then
        [ -d $LOG_DIR/stats-$TS-$CONTADOR ] || { mkdir -p $LOG_DIR/stats-$TS-$CONTADOR; }
        # pega linha da API Key
        API_KEY=$(sed -n "${CONTADOR}p" $2)
        # splita Folder_ do nome do arquivo
        NOME=$(echo $ARQUIVO | cut -d'_' -f3)
        # executa o arquivo run_analysis.sh
        ./labelling/virustotal/run_analysis_VT.sh $ARQUIVO/500_VT_"$NOME" $API_KEY $LOG_DIR/stats-$TS-$CONTADOR $ARQUIVO &> $LOG_DIR/stats-$TS-$CONTADOR/log.log & 
        # incrementa contador de API Keys
        CONTADOR=$((CONTADOR+1))
        # renomear diretório
        #wait $!
        #mv $ARQUIVO $ARQUIVO\_Ready
    fi
done

while [ 1 ]
do
    # verifica se existe algum arquivo .json.OK no diretorio de entrada
    for FILE in $(find $FILA_DE_LABELLING -type f -name \*.json.OK)
    do
        # splitar nome do arquivo
        DIR_ARQUIVO=$(echo $FILE | cut -d'.' -f1)
        NOME_ARQUIVO=$(echo $DIR_ARQUIVO | cut -d'/' -f4)

        python3 ./labelling/virustotal/label.py --injson $DIR_ARQUIVO.json --outdir $FILA_DE_BUILDING/
        # renomear arquivo
        mv $DIR_ARQUIVO.json.OK $DIR_ARQUIVO.json.labeled

        COUNTER=$((COUNTER+1))
    done

    # verificar se COUNTER é igual ao MAX_SHA256
    if [ $COUNTER -eq $MAX_SHA256 ]
    then
        # encerra o script
        break
    fi

    sleep 10
done