#!/bin/bash
DEBIAN_FRONTEND=noninteractive apt-get update
DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
DEBIAN_FRONTEND=noninteractive apt install python3 python3-pip vim curl time -y
DEBIAN_FRONTEND=noninteractive python3 -m pip install androguard==3.3.5
DEBIAN_FRONTEND=noninteractive python3 -m pip install networkx==2.2
DEBIAN_FRONTEND=noninteractive python3 -m pip install pandas==1.3.5
