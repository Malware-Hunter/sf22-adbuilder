#!/bin/bash

for i in run_apk_extraction.sh run_apk_download.sh run.sh
do
    kill `ps guaxwww | grep $i | awk '{print $2}'`
done

