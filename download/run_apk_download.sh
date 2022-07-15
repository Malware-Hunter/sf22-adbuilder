[ $1 ] && [ -f $1 ] && [ $2 ] && [ -d $2 ] && [ $3 ] && [ -d $3 ] || { echo "Usage: $0 <APK_SHA256_list.txt> <path_extraction_queue> <path_logs>"; exit; }

EXTRACTION_QUEUE=$2
LOG_DIR=$3
APK_LIST_FILE=$(echo $1 | sed 's/^.*\///;s/\..*$//')
while read SHA256
do  
	echo -n "Realizando o download do APK $SHA256 ... "
	/usr/bin/time -f "$SHA256 Tempo decorrido Download = %e segundos, CPU = %P, Memoria = %M KiB" -a -o $LOG_DIR/stats-"$APK_LIST_FILE".txt curl -s -S -o $EXTRACTION_QUEUE/$SHA256.apk --remote-header-name -G -d apikey=44e1937815802c68ee461e4f186f388107ad2ac5f10d0a38f93de5d56a7420ec -d sha256=$SHA256 https://androzoo.uni.lu/api/download
	CURL_EXEC=$(echo $?)
	if [ -f $EXTRACTION_QUEUE/$SHA256.apk ] && [ $CURL_EXEC -eq 0 ] 
	then
	    touch $EXTRACTION_QUEUE/$SHA256.apk.OK
	    echo "DONE"
	else
	    echo "ERROR"
	fi
done < $1
