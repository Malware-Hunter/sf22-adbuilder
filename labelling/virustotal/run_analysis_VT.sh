[ $1 ] &&  [ -f $1 ] && [ $2 ] && [ $3 ] && [ -d $3 ] && [ $4 ] && [ -d $4 ] || { echo "Uso: $0 <sha256.txt> <API_Key> <path_logs_labelling> <path_queue_labelling>"; exit;}

SHA256_FILE=$1
API_KEY=$2
LOG_DIR=$3
FILA_DE_LABELLING=$4
TS=$(date +%Y%m%d%H%M%S)

[ -d $LOG_DIR ] || { mkdir -p $LOG_DIR; }
while read SHA256

do  
	echo -n "Realizando o download do json $SHA256 ... "
	echo -e "\nAPI Key utilizada: $API_KEY"
	/usr/bin/time -f "$SHA256 Tempo decorrido da Análise do VT = %e segundos, CPU = %P, Memoria = %M KiB" -a -o $LOG_DIR/stats-$TS curl  --request GET --url "https://www.virustotal.com/api/v3/files/"$SHA256 --header  'x-apikey:'$API_KEY > $FILA_DE_LABELLING/$SHA256".json"
	#curl  --request GET --url "https://www.virustotal.com/api/v3/files/"$SHA256 --header  'x-apikey:'$API_KEY > $SHA256".json" &

	sleep 30
	echo -e "Download finalizado!!!\n"

	# verificando se o tamanho doa arquivo é menor que 1KB
	if [ $(stat -c%s $FILA_DE_LABELLING/$SHA256".json") -lt 1024 ]
	then
		# verifica se o diretório existe, se não cria
		[ -d $FILA_DE_LABELLING/Errors ] || { mkdir -p $FILA_DE_LABELLING/Errors; }
		# move o arquivo para o diretório de erros
		mv $FILA_DE_LABELLING/$SHA256".json" $FILA_DE_LABELLING/Errors/
		echo -e "O arquivo $SHA256.json gerou erro!!!\n"
		continue
	else
		# cria arquivo temporário
		touch $FILA_DE_LABELLING/$SHA256.json.OK
	fi
	
done < $SHA256_FILE