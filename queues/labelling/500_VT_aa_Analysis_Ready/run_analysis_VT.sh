[ $1 ] &&  [ -f $1 ] && [ $2 ] && [ $3 ] && [ -d $3 ] || { echo "Uso: $0 <sha256.txt> <API_Key> <path_logs_labelling>"; exit;}

SHA256_FILE=$1
API_KEY=$2
LOG_DIR=$3
TS=$(date +%Y%m%d%H%M%S)

[ -d $LOG_DIR ] || { mkdir -p $LOG_DIR; }
while read SHA256

do  
	echo -n "Realizando o download do json $SHA256 ... "
	#/usr/bin/time -f "$SHA256 Tempo decorrido da Análise do VT = %e segundos, CPU = %P, Memoria = %M KiB" -a -o $LOG_DIR/stats-$TS curl  --request GET --url "https://www.virustotal.com/api/v3/files/"$SHA256 --header  'x-apikey:'$API_KEY > $SHA256".json" &
	curl  --request GET --url "https://www.virustotal.com/api/v3/files/"$SHA256 --header  'x-apikey:'$API_KEY > $SHA256".json" &

	sleep 30
	echo "Download finalizado!!!"
done < $SHA256_FILE