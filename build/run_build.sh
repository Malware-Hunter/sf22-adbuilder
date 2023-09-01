#!/bin/bash
[ $1 ] &&  [ -f $1 ] && [ $2 ] && [ -d $2 ] && [ $3 ] && [ -d $3 ] && [ $4 ] && [ -d $4 ] && [ $5 ] && [ -d $5 ] || { echo "Usage: $0 <SHA256_LIST_FILE> <EXTRACTION_DIR_PATH> <LABEL_DIR_PATH> <BUILD_DIR_PATH> <LOG_DIR_PATH>"; exit; }

SHA256_LIST=$1
EXTRACTION_DIR=$2
LABEL_DIR=$3
BUILD_DIR=$4
LOG_DIR=$5

TIME_STAMP=$(date +%Y%m%d%H%M%S)
LOG_FILE=$(basename $1 | cut -d. -f1)
LOG_FILE_PATH="$LOG_DIR/${TIME_STAMP}_${LOG_FILE}.log"
APK_COUNTER=1

rm -rf $BUILD_DIR/*.builded
rm -rf $BUILD_DIR/*.error
[ -f $BUILD_DIR/build.finished ] && { rm $BUILD_DIR/build.finished; }
# function to label using VirusTotal
dataset_concat() {
    SHA256=$1
    #echo "[$APK_COUNTER] Concatenating $SHA256 ..."
    /usr/bin/time -a -o $LOG_FILE_PATH -f "$SHA256\nConcat Total Time: %e s\nCPU Time: %U s\nMemory Consumption: %M KiB" python3 build/concat.py --sha256 $SHA256 --extraction-dir $EXTRACTION_DIR --label-dir $LABEL_DIR --build-dir $BUILD_DIR > /dev/null 2>&1
    # checks if the label was successful
    if [ $? -eq 0 ]; then
      touch "$BUILD_DIR/$SHA256.builded"
      #echo "$SHA256 Successfully Labeled"
    else
      touch "$BUILD_DIR/$SHA256.error"
      #echo "Error Concatenating $SHA256"
    fi
}

while read SHA256; do
  dataset_concat $SHA256
  ((APK_COUNTER++))
  sleep 1
done < $SHA256_LIST

touch $BUILD_DIR/build.finished
#echo "Build Completed"
