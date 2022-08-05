[ $1 ] && [ -f $1 ] && [ $2 ] && [ -d $2 ] && [ $3 ] && [ -d $3 ] && [ $4 ] && [ -d $4 ] || { echo "Usage: $0 <APK_SHA256_list.txt> <path_download_queue> <path_extraction_queue> <path_logs>"; exit; }

SHA256_LIST=$1
DOWNLOAD_QUEUE=$2
EXTRACTION_QUEUE=$3
LOG_DIR=$4
APK_LIST_FILE=$(echo $1 | sed 's/^.*\///;s/\..*$//')

# pegar última linha (sha256) do arquivo
LAST_LINE=$(tail -n 1 $SHA256_LIST)

while read SHA256
do  
	echo -n "Realizando o download do APK $SHA256 ... "
	/usr/bin/time -f "$SHA256 Tempo decorrido Download = %e segundos, CPU = %P, Memoria = %M KiB" -a -o $LOG_DIR/stats-"$APK_LIST_FILE".txt curl -s -S -o $EXTRACTION_QUEUE/$SHA256.apk --remote-header-name -G -d apikey=44e1937815802c68ee461e4f186f388107ad2ac5f10d0a38f93de5d56a7420ec -d sha256=$SHA256 https://androzoo.uni.lu/api/download
	#/usr/bin/time -f "$SHA256 Tempo decorrido Download (%%e) = %e segundos, Tempo (%%E) = %E segundos, CPU ((%%U + %%S) / %%E) = %P, CPU nível usuário (%%U) = %U segundos, CPU nível kernel (%%S) = %S segundos" -a -o $LOG_DIR/stats-"$APK_LIST_FILE".txt curl -s -S -o $EXTRACTION_QUEUE/$SHA256.apk --remote-header-name -G -d apikey=44e1937815802c68ee461e4f186f388107ad2ac5f10d0a38f93de5d56a7420ec -d sha256=$SHA256 https://androzoo.uni.lu/api/download
	CURL_EXEC=$(echo $?)
	if [ -f $EXTRACTION_QUEUE/$SHA256.apk ] && [ $CURL_EXEC -eq 0 ] 
	then
		touch $DOWNLOAD_QUEUE/$SHA256.apk.downloaded
	    touch $EXTRACTION_QUEUE/$SHA256.apk.OK
	    echo "DONE"
	else
	    echo "ERROR"
	fi

	# verificar se o último APK do arquivo já foi baixado
	if [ -f $DOWNLOAD_QUEUE/$LAST_LINE.apk.downloaded ]
	then
		touch $DOWNLOAD_QUEUE/$LAST_LINE.apk.finished
	fi
done < $SHA256_LIST
