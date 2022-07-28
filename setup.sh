#!/bin/bash

# permissoes
chmod u+x ./building/run_building.sh
chmod u+x ./labelling/run_n_labellings.sh
chmod u+x ./labelling/virustotal/run.sh
chmod u+x ./labelling/virustotal/run_analysis_VT.sh
chmod u+x ./download/run_apk_download.sh
chmod u+x ./download/run_n_downloads.sh
chmod u+x ./extraction/run_apk_extraction.sh
chmod u+x ./extraction/run_n_extractions.sh
chmod u+x kill_all.sh

# dependências
sudo snap install curl
sudo apt install time
sudo apt install python3-pip
sudo python3 -m pip install androguard==3.3.5
sudo python3 -m pip install networkx==2.2
sudo python3 -m pip install pandas==1.3.5
