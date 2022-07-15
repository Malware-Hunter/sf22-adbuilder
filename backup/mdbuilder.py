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
    parser = argparse.ArgumentParser()
    parser.add_argument('--download', type=str, default=False, help='TXT file with a list of APKs SHA256 to download.')
    parser.add_argument('--n_download_queues', type=int, default=1, help='Number of parallel queues for download.')
    parser.add_argument('--feature_extraction', help='APK feature extraction.', action="store_true")
    parser.add_argument('--n_feature_extraction_queues', type=int, default=1, help='Number of parallel queues for feature extraction.')
    parser.add_argument('--labelling', help='Virus Total labelling.', action="store_true")
    parser.add_argument('--n_labelling_queues', type=int, default=1, help='Number of parallel queues for labelling.')

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

    if args.download and args.n_download_queues:
        os.system('./download/run_n_downloads.sh {} {} {} {} {}'.format(args.download, queues['download'], args.n_download_queues, queues['extraction'], logs['download']))
    if args.labelling and args.n_labelling_queues:
        os.system('./labelling/run_n_labellings.sh {} {} {} {} {}'.format(args.labelling, queues['labelling'], args.n_labelling_queues, queues['building'], logs['extraction']))
    if args.feature_extraction and args.n_feature_extraction_queues: 
        os.system('./extraction/run_n_extractions.sh {} {} {} {}'.format(args.n_feature_extraction_queues, queues['extraction'], queues['building'], logs['extraction']))    

main()
