import glob
from matplotlib.pyplot import axis
import pandas as pd
import os
import time
import argparse

def parseArgs():
    parser = argparse.ArgumentParser(description='Dataset Building.')
    parser.add_argument('--incsv', dest='incsv', required=True, help='CSV File.')
    parser.add_argument('--inlabeled', dest='inlabeled', required=True, help='CSV.labeled File.')
    parser.add_argument('--outdir', dest='outdir', required=True, help='Path to the building queue.')

    return parser.parse_args()


def main():
    args = parseArgs()
    # diretório para arquivos de saída
    outdir = args.outdir
    # diretório para arquivos de entrada
    incsv = args.incsv
    inlabeled = args.inlabeled

    name = incsv.split('/')[-1]

    if os.path.isfile(inlabeled):
        labeled = pd.read_csv(inlabeled)

   # verificando se existe MotoDroid_dataset.csv no diretório outdir
    if not os.path.isfile(outdir + 'MotoDroid_dataset.csv'):
        # se não existir, cria o arquivo
        moto_df = pd.DataFrame(columns=['SHA256','NOME','PACOTE','API_MIN','API'])
        moto_df.to_csv(outdir + 'MotoDroid_dataset.csv', index=False)
    else:
        moto_df = pd.read_csv(outdir + 'MotoDroid_dataset.csv')


    start = time.time()

    # concatenando os arquivos de entrada
    dataset = pd.concat([moto_df, pd.read_csv(incsv)], ignore_index=True)
    dataset.loc[len(dataset)-1, 'CLASS'] = labeled['MALICIOUS'][0]
    dataset.fillna(0, inplace=True)
    start_test = time.time()
    # transformar colunas float em int
    for col in dataset:
        if dataset[col].dtype == "float64":
            dataset[col] = dataset[col].astype(int)

    end_test = time.time()
    print("Tempo para transformar colunas em INT: ", end_test - start_test, " segundos")
    #dataset.to_csv(outdir+"MotoDroid_dataset.csv", index=False, encoding='utf-8-sig')
    dataset.to_csv(outdir + "MotoDroid_dataset.csv", index=False, encoding='utf-8-sig')
    
    end = time.time()
    print("Tempo de concatenação do CSV " + name + ": ", end - start, "segundos")
    print("\n")
main()