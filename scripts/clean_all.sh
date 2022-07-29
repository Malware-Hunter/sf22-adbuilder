#!/bin/bash

for DIR in queues logs
do
    [ ! -d $DIR ] || { rm -rf $DIR; }
done
