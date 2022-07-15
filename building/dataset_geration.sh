mkdir Clean
mkdir Final
echo "Realizando o tratamento dos CSVs..."
python3 dataset_geration.py
echo "Finalizado!!! Concatenando os arquivos..."
python3 concat_dataset.py
echo "MotoDroid dataset gerado com sucesso!!!"