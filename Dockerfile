FROM ubuntu:22.04 as base
RUN apt-get update
RUN apt-get upgrade -y
RUN DEBIAN_FRONTEND=noninteractive apt install python3 python3-pip vim curl time wget -y
RUN DEBIAN_FRONTEND=noninteractive python3 -m pip install androguard==3.3.5
RUN DEBIAN_FRONTEND=noninteractive python3 -m pip install networkx==2.2
RUN DEBIAN_FRONTEND=noninteractive python3 -m pip install pandas==1.3.5
WORKDIR /sf22
#COPY . ./sf22/
