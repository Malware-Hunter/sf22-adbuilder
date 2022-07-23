import argparse
import pandas as pd
import json 
import os
from json.decoder import JSONDecodeError
import shutil


def parseArgs():
    parser = argparse.ArgumentParser(description='Dataset Labelling.')
    parser.add_argument('--injson', dest='injson', required=True, help='JSON File.')
    parser.add_argument('--outdir', dest='outdir', required=True, help='Path to the labelling queue.')

    return parser.parse_args()


def main():
    args = parseArgs()
    # arquivo JSON de entrada
    injson = args.injson
    # diretório para arquivos de saída
    outdir = args.outdir

    name_split =str(injson.split('/')[-1])
    name = name_split.split('.')[0]

    if not os.path.isfile(outdir + name + '.csv.labeled'):
        # se não existir, cria o arquivo
        moto_df = pd.DataFrame(columns=['SHA256','MALICIOUS'])
        moto_df.to_csv(outdir + name + '.csv.labeled', index=False)
    else:
        moto_df = pd.read_csv(outdir + name + '.csv.labeled')

    dados=[]
    with open(injson) as file:
        try:
            data1= json.loads("[" + file.read().replace("}\n{", "},{") + "]")
            app = pd.json_normalize(data1[0]['data']['attributes'])
            last_stats = data1[0]['data']['attributes']['last_analysis_stats']
            d = {'sha256': app['sha256'].values[0], 'malicious': last_stats['malicious'],'undetected': last_stats['undetected'], 'harmless': last_stats['harmless'] ,'suspicious': last_stats['suspicious'] ,'failure': last_stats['failure'],'unsupported': last_stats['type-unsupported'],'timeout': last_stats['timeout'],'confirmed_timeout': last_stats['confirmed-timeout']}
            dados.append(d)
            file.close()

        except JSONDecodeError as e:
            shutil.move(file,"Erros")
        except TypeError as e:
            shutil.move(file,"Erros")

    df_VT = pd.DataFrame(dados)
    df_OUT = pd.DataFrame()
    df_OUT['SHA256'] = df_VT['sha256']
    df_OUT['MALICIOUS'] = df_VT['malicious']
    #df_concat = pd.concat([moto_df, df_OUT], ignore_index=True)
    #df_concat.fillna(-1, inplace=True)
    df_OUT.to_csv(outdir + name + '.csv.labeled', index=False)   # salva o arquivo
    #print("Arquivos JSONs processados: ",len(df_concat))

main()