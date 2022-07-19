import glob
from matplotlib.pyplot import axis
import pandas as pd
import os
import time
import argparse

def parseArgs():
    parser = argparse.ArgumentParser(description='Dataset Building.')
    parser.add_argument('--indir', dest='indir', required=True, help='CSV File.')
    parser.add_argument('--outdir', dest='outdir', required=True, help='Path to the building queue.')

    return parser.parse_args()


def main():
    args = parseArgs()
    # diretório para arquivos de saída
    outdir = args.outdir
    # diretório para arquivos de entrada
    indir = args.indir

   # verificando se existe MotoDroid_dataset.csv no diretório outdir
    if not os.path.isfile(outdir + 'MotoDroid_dataset.csv'):
        # se não existir, cria o arquivo
        moto_df = pd.DataFrame()
        moto_df.to_csv(outdir + 'MotoDroid_dataset.csv', index=False)
    else:
        moto_df = pd.read_csv(outdir + 'MotoDroid_dataset.csv')


    start = time.time()

    print("Concatenando " + indir + "...")
    # concatenando os arquivos de entrada
    dataset = pd.concat([moto_df, pd.read_csv(indir)], ignore_index=True)
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
    dataset.to_csv(outdir + "MotoDroid_dataset.csv", index=False, encoding='utf-8-sig')
    
    end = time.time()
    print("MotoDroid dataset gerado!!!")
    print("\nTempo de execução: ", end - start, "segundos")

main()