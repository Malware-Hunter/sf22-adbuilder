#!/usr/bin/python3
import argparse
from dataclasses import asdict
import os
from pathlib import Path
import time
import pandas as pd
import sys

from colorama import init
init(strip=not sys.stdout.isatty()) # strip colors if stdout is redirected
from termcolor import cprint 
from pyfiglet import figlet_format

cprint(figlet_format('AD Builder!', font='starwars'), 'yellow', attrs=['bold', 'dark','blink'])

def create_directories(_dirs):
    for _dir in _dirs.keys():
        Path(_dirs[_dir]).mkdir(parents=True, exist_ok=True)

def create_logs(_logs):
    create_directories(_logs)

def create_queues(_queues):
    create_directories(_queues)

def main():

    parser = argparse.ArgumentParser()
    parser.add_argument('--download', type=str, default=False, help='TXT file with a list of APKs SHA256 to download.')
    parser.add_argument('--n_download_queues', '-npd', type=int, default=1, help='Number of parallel queues for download.')
    parser.add_argument('--feature_extraction', '-fe', help='APK feature extraction.', action="store_true")
    parser.add_argument('--n_feature_extraction_queues', '-npe', type=int, default=1, help='Number of parallel queues for feature extraction.')
    parser.add_argument('--labelling', type=str, default=False, help='Virus Total labelling. TXT file with a list of APKs SHA256 to download.')
    parser.add_argument('--apikeys', '-api', type=str, default=False, help='TXT file with a VirusTotal\'s list of API Keys to analysis.')
    parser.add_argument('--building', help='Building the dataset.', action="store_true")

    args = parser.parse_args()
    
    queues = { 'download': 'queues/download', 
              'extraction': 'queues/extraction', 
              'labelling': 'queues/labelling', 
              'building': 'queues/building' }
    create_queues(queues)

    logs = { 'download': 'logs/download', 
             'extraction': 'logs/extraction', 
             'labelling': 'logs/labelling', 
             'building': 'logs/building' }
    create_logs(logs)

    ##############################################
    global var_APKs

    # SOLUÇÃO TEMPORÁRIA
    if args.download:
        var_APKs = 0
        with open(args.download, 'r') as file:
            for line in file:
                if line.strip():
                    var_APKs += 1
    if args.labelling:
        var_APKs_2 = 0
        with open(args.labelling, 'r') as file:
            for line in file:
                if line.strip():
                    var_APKs_2 += 1
    ##############################################

    start = time.time()

    if args.download and args.n_download_queues:
        os.system('./download/run_n_downloads.sh {} {} {} {} {} &'.format(args.download, queues['download'], args.n_download_queues, queues['extraction'], logs['download']))
    
    if args.labelling and args.apikeys:
        os.system('./labelling/run_n_labellings.sh {} {} {} {} {}'.format(args.labelling, args.apikeys, queues['labelling'], queues['building'], logs['labelling']))
    
    if args.feature_extraction and args.n_feature_extraction_queues: 
        os.system('./extraction/run_n_extractions.sh {} {} {} {} {} &'.format(args.n_feature_extraction_queues, queues['download'], queues['extraction'], queues['building'], logs['extraction']))    
    
    if args.building and args.download:
        os.system('./building/run_building.sh {} {} {} &'.format(queues['labelling'], queues['building'], logs['building']))
    
    # remover arquivo de sinalização do building anterior
    dir_finished = "./queues/building"
    for path in os.listdir(dir_finished):
        if os.path.isfile(os.path.join(dir_finished, path)):
            if path.endswith("building.finished"):
                os.remove(os.path.join(dir_finished, path))

    counter_while = 1
    finished = 0

    while finished == 0:
        # informações do módulo de download
        download_count = 0
        dir_download = "./queues/download"
        for path in os.listdir(dir_download):
            if os.path.isfile(os.path.join(dir_download, path)):
                if path.endswith(".apk.downloaded"):
                    download_count += 1
        # informações do módulo de extração
        extraction_count = 0
        dir_extraction = "./queues/extraction"
        for path in os.listdir(dir_extraction):
            if os.path.isfile(os.path.join(dir_extraction, path)):
                if path.endswith(".apk.extracted"):
                    extraction_count += 1
        # informações do módulo de rotulação
        labelling_count = 0
        dir_labelling = "./queues/building"
        for path in os.listdir(dir_labelling):
            if os.path.isfile(os.path.join(dir_labelling, path)):
                if path.endswith(".csv.labeled"):
                    labelling_count += 1
        # informações do módulo de building
        building_count = 0
        dir_building = "./queues/building/Clean"
        try:
            for path in os.listdir(dir_building):
                if os.path.isfile(os.path.join(dir_building, path)):
                    if path.endswith(".csv.cleaned"):
                        building_count += 1
        except:
            ''

        building_count_OK = 0
        dir_building_OK = "./queues/building"
        try:
            for path in os.listdir(dir_building_OK):
                if os.path.isfile(os.path.join(dir_building_OK, path)):
                    if path.endswith(".csv.OK"):
                        building_count_OK += 1
        except:
            ''

        cprint("\n***** Status de Execução {} *****".format(counter_while), 'yellow', attrs=['bold'])
        cprint("Tempo decorrido: {} segundos".format(time.time() - start), 'yellow', attrs=['bold'])
        print("\n")
        if args.download and args.n_download_queues:
            if download_count != var_APKs:
                print("Download: {}/{}".format(download_count, var_APKs))
            else:
                cprint("Download: {}/{}".format(download_count, var_APKs), 'green', attrs=['bold'])
        if args.feature_extraction and args.n_feature_extraction_queues and args.download:
            if extraction_count != var_APKs:
                print("Extraction: {}/{}".format(extraction_count, var_APKs))
            else:
                cprint("Extraction: {}/{}".format(extraction_count, var_APKs), 'green', attrs=['bold'])
        elif args.feature_extraction and args.n_feature_extraction_queues and not args.download:
            # quantidade de arquivos apk.finished no diretório de download
            download_finished_count = 0
            dir_download = "./queues/download"
            for path in os.listdir(dir_download):
                if os.path.isfile(os.path.join(dir_download, path)):
                    if path.endswith(".apk.finished"):
                        download_finished_count += 1
            if extraction_count != download_finished_count:
                print("Extraction: {}/{}".format(extraction_count, download_finished_count))
            else:
                cprint("Extraction: {}/{}".format(extraction_count, download_finished_count), 'green', attrs=['bold'])
        if args.labelling and args.apikeys:
            if labelling_count != var_APKs_2:
                print("Labelling: {}/{}".format(labelling_count, var_APKs_2))
            else:
                cprint("Labelling: {}/{}".format(labelling_count, var_APKs_2), 'green', attrs=['bold'])
        if args.building and args.download:
            if building_count != var_APKs:
                print("Building: {}/{}".format(building_count, var_APKs))
            else:
                cprint("Building: {}/{}".format(building_count, var_APKs), 'green', attrs=['bold'])
        elif args.building and args.labelling:
            if building_count_OK != var_APKs_2:
                print("Building: {}/{}".format(building_count, var_APKs_2))
            else:
                cprint("Building: {}/{}".format(building_count, var_APKs_2), 'green', attrs=['bold'])
        elif args.building:
            if building_count != building_count_OK:
                print("Building: {}/{}".format(building_count, building_count_OK))
            else:
                cprint("Building: {}/{}".format(building_count, building_count_OK), 'green', attrs=['bold'])

        dir_dataset = "./queues/building/Final/ADBuilder_dataset.csv"
        try:
            if os.path.isfile(dir_dataset):
                if os.path.getsize(dir_dataset) > 0:
                    df = pd.read_csv(dir_dataset)
                    print("\n*** Dataset em construção ***\nNúmero de amostras: {}\nNúmero de características {}\nTamanho do dataset: {} bytes\n\n".format(len(df), len(df.columns), os.path.getsize(dir_dataset)))
        except:
            pass

        dir_building_finished = "./queues/building"
        try:
            for path in os.listdir(dir_building_finished):
                if os.path.isfile(os.path.join(dir_building_finished, path)):
                    if path.endswith("building.finished"):
                        finished = 1
        except:
            pass
        
        # verifica se apenas o download está em execução
        if args.download and not args.feature_extraction and not args.labelling and not args.building:
            if download_count == var_APKs:
                finished = 1
        # verifica se apenas a extração está em execução
        elif args.feature_extraction and not args.download and not args.labelling and not args.building:
            dir_building_finished = "./queues/building"
            try:
                for path in os.listdir(dir_building_finished):
                    if os.path.isfile(os.path.join(dir_building_finished, path)):
                        if path.endswith("extraction.finished"):
                            finished = 1
            except:
                pass
        # verifica se apenas a rotulação está em execução
        elif args.labelling and not args.download and not args.feature_extraction and not args.building:
            if labelling_count == var_APKs_2:
                finished = 1

        counter_while += 1
        time.sleep(10)

    end = time.time()
    cprint("\n***** ADBuilder *****\nExecutado em {} segundos.\n".format(end - start), 'green', attrs=['bold'])

    ##############################################

main()
