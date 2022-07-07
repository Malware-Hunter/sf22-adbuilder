import argparse
from xmlrpc.client import Boolean

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--download', type=Boolean, default=False, help='Etapa que realiza o download dos APKs desejados.')
    #parser.add_argument('--list', '-ls', type=str, help='Lista que contém o(s) sha256 do(s) APK(s).')
    #parser.add_argument('--n_processes', '-np', type=int, default=1, help='Número de processos que serão executados. Por padrão o valor é setado em 1.')
    args = parser.parse_args()
    
    if args.download:
        # Realiza o download dos APKs desejados.
        # Acessar a pasta 1_Download.
        # Executar o script ./run_download.sh passando os dois parâmetros.
        print("Etapa de download dos APKs.")

main()