#!/bin/bash

[[ $1 ]] || { echo "Usage: $0 <docker_IMAGE_ID>" ; 
echo "useful commands:"
echo "        sudo docker images"
echo "exec examples:" 
echo "        $0 38d9c0886f5f"
exit 1; }

SHARED_DIR=$(pwd)
DOCKER_WORKDIR=/sf22
DOCKER_IMAGE=$1
sudo docker run -t -i -v $SHARED_DIR:$DOCKER_WORKDIR $DOCKER_IMAGE
