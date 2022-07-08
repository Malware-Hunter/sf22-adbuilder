import argparse
import os

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--download', type=str, default=False, help='Recebe a lista contendo os sha256 dos APKs para download. A lista.txt precisa estar no diretório 1_Download.')
    parser.add_argument('--num_processes', '-np', type=int, default=1, help='Número de processos que serão executados. Por padrão o valor é setado em 1.')
    parser.add_argument('--extract_features', '-ef', type=str, default=False, help='Recebe uma pasta contendo os APKs para extrair suas características.')
    args = parser.parse_args()
    
    # se o download for True, então o programa vai fazer o download dos APKs
    if args.download:
        os.system('cd 1_Download && ./run_download.sh {} {}'.format(args.download, args.n_processes))
        # se o extract-features for True, então o programa vai extrair as características dos APKs
        if args.extract_features:
            os.system('cd 2_Extract_Features && ./run_extract_features.sh {} {}'.format(args.extract_features, args.n_processes))
main()