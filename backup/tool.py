import argparse
import os
from pathlib import Path

def cria_filas_se_nao_existem(_filas):
    for _fila in _filas:
        Path(_fila).mkdir(parents=True, exist_ok=True)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--download', type=str, default=False, help='Recebe um arquivo TXT contendo a lista dos SHA256 dos APKs para download.')
    parser.add_argument('--num_processes', '-np', type=int, default=1, help='Número de processos que serão executados. Por padrão o valor é setado em 1.')
    parser.add_argument('--extract_features', '-ef', type=str, default=False, help='Por enquanto na versão beta da ferramenta, recebe qualquer char apenas para invocar a extração de características.')
    parser.add_argument('--extract_features_only', '-efo', type=str, default=False, help='Recebe uma pasta contendo os APKs que terão suas características extraídas.')
    parser.add_argument('--all', type=str, default=False, help='Recebe uma lista contendo os sha256 dos APKs para realizar o processo completo da construção de um dataset.')
    args = parser.parse_args()
    
    filas = ["filas/download", "filas/extracao", "filas/labelling", "filas/building"]
    cria_filas_se_nao_existem(filas)

    # se o download e extract_features for True, então o programa vai fazer o download dos APKs e extrair suas características
    if args.download and args.extract_features:
        print("Realizando download e extração de características do(s) APK(s)...\n")
        os.system('cd 2_Extraction && ./run_download_and_extract.sh {} {}'.format(args.download, args.num_processes))
    # se o download for True, então o programa vai fazer o download dos APKs
    elif args.download:
        print("Realizando download do(s) APK(s)...\n")
        os.system('cd 1_Download && ./run_download.sh {} {}'.format(args.download, args.num_processes))
    # **se o extract_features_only for True, então a ferramenta irá extrair características dos APKs da lista
    elif args.extract_features_only: # Não está extraindo as características dos APKs da pasta indicada
        print("Realizando extração de características do(s) APK(s)...\n")
        os.system('cd 2_Extraction && ./run_extraction.sh {}'.format(args.extract_features_only))    
    # se o all for True, então o programa vai realizar o processo completo para a construção de um dataset
    elif args.all:
        print("Realizando o processo completo para construir o dataset...\n")
        os.system("cd 0_All && ./run_all.sh {} {}".format(args.all, args.num_processes))

main()
