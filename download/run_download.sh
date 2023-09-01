#!/bin/bash
[ $1 ] &&  [ -f $1 ] && [ $2 ] && [ $3 ] && [ $4 ] && [ -d $4 ] && [ $5 ] && [ -d $5 ] || { echo "Usage: $0 <SHA256_LIST_FILE> <API_KEY> <CONCURRENT_DOWNLOADS> <DOWNLOAD_DIR_PATH> <LOG_DIR_PATH>"; exit; }

SHA256_LIST=$1
API_KEY=$2
CONCURRENT_DOWNLOADS=$3
DOWNLOAD_DIR=$4
LOG_DIR=$5

TIME_STAMP=$(date +%Y%m%d%H%M%S)
LOG_FILE=$(basename $1 | cut -d. -f1)
LOG_FILE_PATH="$LOG_DIR/${TIME_STAMP}_${LOG_FILE}.log"
BASE_URL="https://androzoo.uni.lu/api/download"
JOB_COUNTER=0
APK_COUNTER=1

rm -rf $DOWNLOAD_DIR/*.downloaded
rm -rf $DOWNLOAD_DIR/*.error
[ -f $DOWNLOAD_DIR/download.finished ] && { rm $DOWNLOAD_DIR/download.finished; }

# function to download an APK file based on SHA256
download_apk() {
    SHA256=$1
    # mounting APK download URL
    APK_URL="$BASE_URL?apikey=$API_KEY&sha256=$SHA256"
    # downloaded file path
    APK_FILE="$DOWNLOAD_DIR/$SHA256.apk"
    # checking if file already exists
    if [ -f $APK_FILE ]; then
      touch "$DOWNLOAD_DIR/$SHA256.downloaded"
      #echo "$SHA256 Already Exists. Skipping Download ..."
      return
    fi
    # downloading file
    #echo "[$APK_COUNTER] Downloading $SHA256 ..."
    /usr/bin/time -a -o $LOG_FILE_PATH -f "$SHA256\nDownload Total Time: %e s\nCPU Time: %U s\nMemory Consumption: %M KiB" curl -L -o $APK_FILE $APK_URL > /dev/null 2>&1

    # checks if the download was successful
    if [ $? -eq 0 ]; then
      touch "$DOWNLOAD_DIR/$SHA256.downloaded"
      #echo "$SHA256 Successfully Downloaded"
    else
      touch "$DOWNLOAD_DIR/$SHA256.error"
      #echo "Error Downloading $SHA256"
    fi
}

while read SHA256; do
  download_apk $SHA256 &
  sleep 1
  ((APK_COUNTER++))
  ((JOB_COUNTER++))
  while [ $JOB_COUNTER -ge $CONCURRENT_DOWNLOADS ]; do
    wait -n
    ((JOB_COUNTER--))
  done
done < $SHA256_LIST

while [ $JOB_COUNTER -gt 0 ]; do
  wait -n
  ((JOB_COUNTER--))
done

touch $DOWNLOAD_DIR/download.finished
#echo "Download Completed"
