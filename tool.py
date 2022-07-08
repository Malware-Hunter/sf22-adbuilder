import argparse
import os

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--download', type=str, default=False, help='Recebe a lista contendo os sha256 dos APKs para download. A lista.txt precisa estar no diretório 1_Download.')
    parser.add_argument('--n_processes', '-np', type=int, default=1, help='Número de processos que serão executados. Por padrão o valor é setado em 1.')
    args = parser.parse_args()
    
    # se o download for True, então o programa vai fazer o download dos APKs
    if args.download:
        os.system('cd 1_Download && ./run_download.sh {} {}'.format(args.download, args.n_processes))

main()