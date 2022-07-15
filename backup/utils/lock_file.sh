#!/bin/bash

[ $1 ] && [ -f $1 ] && [ $2 ] || { echo "Use: $0 <path_of_file_to_lock> <lock_time_in_seconds>"; exit; }

if { set -C; 2>/dev/null >./$1.lock; }; then
        trap "rm -f ./$1.lock" EXIT
else
        echo "Lock file exists… exiting"
        exit
fi

echo "FILE $1 is LOCKED do $2s!"

sleep $2

