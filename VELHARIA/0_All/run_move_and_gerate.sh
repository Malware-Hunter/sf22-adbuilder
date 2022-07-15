#!/bin/bash
# etapa de rotulação de APKs com VirusTotal???

# etapa de geração do dataset
mkdir CSVs
for CSV in *.csv
do
    mv $CSV ./CSVs/
done
mkdir Clean
mkdir Final
echo "Realizando o tratamento dos CSVs..."
python3 dataset_geration.py && python3 concat_dataset.py

# mover pasta Clean, CSVs e Final para o diretorio /5_Temp/5_Geration
mv Clean ./5_Temp/5_Geration/
mv CSVs ./5_Temp/5_Geration/
mv Final ./5_Temp/5_Geration/
echo "MotoDroid dataset gerado com sucesso!!!"