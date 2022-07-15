import glob
from matplotlib.pyplot import axis
import pandas as pd
import os
import time

def main():
    start = time.time()

    print("Iniciando concatenação...")

    cwd = os.getcwd()
    os.chdir(cwd+"/Clean")
    extension = 'csv'
    varios_arquivos = [i for i in glob.glob('*.{}'.format(extension))]
    #combinar todos os arquivos da lista
    dataset= pd.concat([pd.read_csv(f) for f in varios_arquivos ], axis=0)
    #exportar para csv
    dataset.fillna(0, inplace=True)
    print("\n*** Transformando colunas em inteiros ***")
    start_test = time.time()
    # transformar colunas float em int
    for col in dataset:
        if dataset[col].dtype == "float64":
            dataset[col] = dataset[col].astype(int)

    end_test = time.time()
    print("\nTempo para transformar colunas em INT: ", end_test - start_test, " segundos\n")

    dataset.to_csv( "../Final/MotoDroid_dataset.csv", index=False, encoding='utf-8-sig')
    
    end = time.time()
    print("MotoDroid dataset gerado!!!")
    print("\nTempo de execução: ", end - start, "segundos")

main()