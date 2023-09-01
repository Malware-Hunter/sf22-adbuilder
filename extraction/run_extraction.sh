#!/bin/bash
[ $1 ] &&  [ -f $1 ] && [ $2 ] && [ $3 ] && [ -d $3 ] && [ $4 ] && [ -d $4 ] && [ $5 ] && [ -d $5 ] || { echo "Usage: $0 <SHA256_LIST_FILE> <CONCURRENT_PROCESS> <DOWNLOAD_DIR_PATH> <EXTRACTION_DIR_PATH> <LOG_DIR_PATH>"; exit; }

SHA256_LIST=$1
CONCURRENT_PROCESS=$2
DOWNLOAD_DIR=$3
EXTRACTION_DIR=$4
LOG_DIR=$5

TIME_STAMP=$(date +%Y%m%d%H%M%S)
LOG_FILE=$(basename $1 | cut -d. -f1)
LOG_FILE_PATH="$LOG_DIR/${TIME_STAMP}_${LOG_FILE}.log"
JOB_COUNTER=0
APK_COUNTER=1

rm -rf $EXTRACTION_DIR/*.extracted
rm -rf $EXTRACTION_DIR/*.error
[ -f $EXTRACTION_DIR/extraction.finished ] && { rm $EXTRACTION_DIR/extraction.finished; }
# function to extract fetatures of APK
extract_features() {
    SHA256=$1
    # extracting APK features
    #echo "[$APK_COUNTER] Extracting $SHA256 ..."
    /usr/bin/time -a -o $LOG_FILE_PATH -f "$SHA256\nExtraction Total Time: %e s\nCPU Time: %U s\nMemory Consumption: %M KiB" python3 extraction/extract_features.py --sha256 $SHA256 --extraction-dir $EXTRACTION_DIR --download-dir $DOWNLOAD_DIR > /dev/null 2>&1
    # checks if the extraction was successful
    if [ $? -eq 0 ]; then
      touch "$EXTRACTION_DIR/$SHA256.extracted"
      #echo "$SHA256 Successfully Extracted"
    else
      touch "$EXTRACTION_DIR/$SHA256.error"
      #echo "Error Extracting $SHA256"
    fi
}

while read SHA256; do
  extract_features $SHA256 &
  sleep 1
  ((APK_COUNTER++))
  ((JOB_COUNTER++))
  while [ $JOB_COUNTER -ge $CONCURRENT_PROCESS ]; do
    wait -n
    ((JOB_COUNTER--))
  done
done < $SHA256_LIST

while [ $JOB_COUNTER -gt 0 ]; do
  wait -n
  ((JOB_COUNTER--))
done

touch $EXTRACTION_DIR/extraction.finished
#echo "Extraction Completed"
