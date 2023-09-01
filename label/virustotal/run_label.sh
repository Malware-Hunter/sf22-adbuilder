#!/bin/bash
[ $1 ] &&  [ -f $1 ] && [ $2 ] && [ $3 ] && [ -d $3 ] && [ $4 ] && [ -d $4 ] || { echo "Usage: $0 <SHA256_LIST_FILE> <API_KEY> <LABEL_DIR_PATH> <LOG_DIR_PATH>"; exit; }

SHA256_LIST=$1
API_KEY=$2
LABEL_DIR=$3
LOG_DIR=$4

TIME_STAMP=$(date +%Y%m%d%H%M%S)
LOG_FILE=$(basename $1 | cut -d. -f1)
LOG_FILE_PATH="$LOG_DIR/${TIME_STAMP}_${LOG_FILE}.log"
APK_COUNTER=1

rm -rf $LABEL_DIR/*.labeled
rm -rf $LABEL_DIR/*.error
[ -f $LABEL_DIR/label.finished ] && { rm $LABEL_DIR/label.finished; }
# function to label using VirusTotal
vt_label() {
    SHA256=$1
    CSV_FILE="$LABEL_DIR/$SHA256.csv"
    if [ -f $CSV_FILE ]; then
      touch "$LABEL_DIR/$SHA256.labeled"
      #echo "$SHA256 Already Labeled. Skipping Download ..."
      return
    fi
    # labeling APK
    #echo "[$APK_COUNTER] Labeling $SHA256 ..."
    /usr/bin/time -a -o $LOG_FILE_PATH -f "$SHA256\nLabel Total Time: %e s\nCPU Time: %U s\nMemory Consumption: %M KiB" python3 label/virustotal/vt_label.py --sha256 $SHA256 --key $API_KEY --label-dir $LABEL_DIR > /dev/null 2>&1
    # checks if the label was successful
    if [ $? -eq 0 ]; then
      touch "$LABEL_DIR/$SHA256.labeled"
      #echo "$SHA256 Successfully Labeled"
    else
      touch "$LABEL_DIR/$SHA256.error"
      #echo "Error Labeling $SHA256"
    fi
    sleep 15
}

while read SHA256; do
  vt_label $SHA256
  ((APK_COUNTER++))
  sleep 1
done < $SHA256_LIST

touch $LABEL_DIR/label.finished
#echo "Label Completed"
