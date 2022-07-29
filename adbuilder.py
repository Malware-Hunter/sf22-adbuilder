#!/usr/bin/python3
import argparse
import os
from pathlib import Path

def create_directories(_dirs):
    for _dir in _dirs.keys():
        Path(_dirs[_dir]).mkdir(parents=True, exist_ok=True)

def create_logs(_logs):
    create_directories(_logs)

def create_queues(_queues):
    create_directories(_queues)

def main():
    
    print("\n***** MotoDroid Builder *****\n\nExecutando...")

    parser = argparse.ArgumentParser()
    parser.add_argument('--download', type=str, default=False, help='TXT file with a list of APKs SHA256 to download.')
    parser.add_argument('--n_download_queues', '-npd', type=int, default=1, help='Number of parallel queues for download.')
    parser.add_argument('--feature_extraction', '-fe', help='APK feature extraction.', action="store_true")
    parser.add_argument('--n_feature_extraction_queues', '-npe', type=int, default=1, help='Number of parallel queues for feature extraction.')
    parser.add_argument('--labelling', type=str, default=False, help='Virus Total labelling. TXT file with a list of APKs SHA256 to download.')
    parser.add_argument('--apikeys', '-api', type=str, default=False, help='TXT file with a VirusTotal\'s list of API Keys to analysis.')
    parser.add_argument('--building', help='Building the dataset.', action="store_true")
    parser.add_argument('--building_only', help='Only Building the dataset.', action="store_true")


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
    elif args.labelling:
        var_APKs = 0
        with open(args.labelling, 'r') as file:
            for line in file:
                if line.strip():
                    var_APKs += 1
    ##############################################

    if args.download and args.n_download_queues:
        os.system('./download/run_n_downloads.sh {} {} {} {} {}'.format(args.download, queues['download'], args.n_download_queues, queues['extraction'], logs['download']))
    
    if args.labelling and args.apikeys:
        os.system('./labelling/run_n_labellings.sh {} {} {} {} {}'.format(args.labelling, args.apikeys, queues['labelling'], queues['building'], logs['labelling']))
    
    if args.feature_extraction and args.n_feature_extraction_queues: 
        os.system('./extraction/run_n_extractions.sh {} {} {} {}'.format(args.n_feature_extraction_queues, queues['extraction'], queues['building'], logs['extraction']))    
    
    if args.building:
        os.system('./building/run_building.sh {} {} {} {}'.format(var_APKs, queues['labelling'], queues['building'], logs['building']))

    if args.building_only:
        os.system('./building/run_building.sh {} {} {} {}'.format(-1, queues['labelling'], queues['building'], logs['building']))


    #if args.building and args.download:
    #    os.system('./building/run_building.sh {} {} {} {}'.format(queues['labelling'], queues['extraction'], queues['building'], logs['building']))
    #    os.system('./extraction/run_verify.sh {} {}'.format(args.download, queues['building']))
    ##############################################

main()
