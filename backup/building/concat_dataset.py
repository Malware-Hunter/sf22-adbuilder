import glob
from matplotlib.pyplot import axis
import pandas as pd
import os
import time
import argparse

def parseArgs():
    parser = argparse.ArgumentParser(description='Dataset Building.')
    parser.add_argument('--outdir', dest='outdir', required=True, help='Path to the building queue.')
    parser.add_argument('--indir', dest='indir', required=True, help='Path to the input files.')

    return parser.parse_args()


def main():
    args = parseArgs()
    # diretório para arquivos de saída
    outdir = args.outdir
    # diretório para arquivos de entrada
    indir = args.indir

    start = time.time()

    print("Iniciando concatenação...")

    #cwd = os.getcwd()
    os.chdir(indir)
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
    #dataset.to_csv(outdir+"MotoDroid_dataset.csv", index=False, encoding='utf-8-sig')
    dataset.to_csv( "../Final/MotoDroid_dataset.csv", index=False, encoding='utf-8-sig')
    
    end = time.time()
    print("MotoDroid dataset gerado!!!")
    print("\nTempo de execução: ", end - start, "segundos")

main()