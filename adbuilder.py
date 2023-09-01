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
from termcolor import cprint, colored
from pyfiglet import figlet_format

cprint(figlet_format('AD Builder!', font='starwars'), 'yellow', attrs=['bold', 'dark','blink'])

def create_directories(_dirs):
    for _dir in _dirs.keys():
        Path(_dirs[_dir]).mkdir(parents=True, exist_ok=True)

def create_logs(_logs):
    create_directories(_logs)

def create_queues(_queues):
    create_directories(_queues)

def count_files(dir, ext):
    count = 0
    for file in os.listdir(dir):
        if file.endswith(ext) or file.endswith('.error'):
            count += 1
    return count

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--file', metavar = 'FILE', type = str, help = 'File With List of SHA256', required = True)
    parser.add_argument('--download', help='Download APKs', action = 'store_true')
    parser.add_argument('--androzoo-key', '-azk', metavar = 'KEY', type = str, help = 'Androzoo API Key')
    parser.add_argument('--num-parallel-download', '-npd', metavar = 'INT', type = int, default = 1, help = 'Number of Parallel Downloads')
    parser.add_argument('--extraction', help = 'APK Feature Extraction', action = "store_true")
    parser.add_argument('--num-parallel-extraction', '-npe', metavar = 'INT', type = int, default = 1, help='Number of Parallel Process for Feature Extraction')
    parser.add_argument('--label', help = 'Labeling APKs With VirusTotal', action = 'store_true')
    parser.add_argument('--vt-key', '-vtk', metavar = 'KEY', type = str, help = 'VirusTotal\'s API Key')
    parser.add_argument('--build', help='Building the dataset.', action="store_true")
    args = parser.parse_args()
    return args


if __name__ == '__main__':
    args = parse_args()

    queues = {'download': 'queues/download',
              'extraction': 'queues/extraction',
              'label': 'queues/label',
              'build': 'queues/build'}
    create_queues(queues)

    logs = {'download': 'logs/download',
            'extraction': 'logs/extraction',
            'label': 'logs/label',
            'build': 'logs/build'}
    create_logs(logs)

    with open(args.file, 'r') as f:
        lines = f.readlines()
        amount_sha256 = len(lines)
    start = time.time()
    running = dict()
    if args.download:
        script = os.path.join('download', 'run_download.sh')
        parameters = f"{args.file} {args.androzoo_key} {args.num_parallel_download} {queues['download']} {logs['download']}"
        cmd = f'{script} {parameters} &'
        exit_code = os.system(cmd)
        running['download'] = True
        if exit_code != 0:
            print(f'Error Running the Script {script}')
            running ['download'] = False

    if args.extraction:
        script = os.path.join('extraction', 'run_extraction.sh')
        parameters = f"{args.file} {args.num_parallel_extraction} {queues['download']} {queues['extraction']} {logs['extraction']}"
        cmd = f'{script} {parameters} &'
        exit_code = os.system(cmd)
        running['extraction'] = True
        if exit_code != 0:
            print(f'Error Running the Script {script}')
            running['extraction'] = False

    if args.label:
        script = os.path.join('label', 'virustotal', 'run_label.sh')
        parameters = f"{args.file} {args.vt_key} {queues['label']} {logs['label']}"
        cmd = f'{script} {parameters} &'
        exit_code = os.system(cmd)
        running['label'] = True
        if exit_code != 0:
            print(f'Error Running the Script {script}')
            running['label'] = False

    if args.build:
        script = os.path.join('build', 'run_build.sh')
        parameters = f"{args.file} {queues['extraction']} {queues['label']} {queues['build']} {logs['build']}"
        cmd = f'{script} {parameters} &'
        exit_code = os.system(cmd)
        running['build'] = True
        if exit_code != 0:
            print(f'Error Running the Script {script}')
            running['build'] = False

    iteration_counter = 1
    finished = False

    while not finished:
        cprint(f'\n\n***** Iteration {iteration_counter} Status *****', 'magenta', attrs = ['bold'])
        cprint(f'Elapsed Time: {time.time() - start:.2f} Seconds', 'magenta', attrs = ['bold'])

        if args.download:
            downloaded_count = count_files(os.path.join('queues', 'download'), '.downloaded')
            info = f'Download: {downloaded_count}/{amount_sha256}'
            if downloaded_count == amount_sha256:
                info = colored(info, 'green', attrs = ['bold'])
                running['download'] = False
            print(info)

        if args.extraction:
            extracted_count = count_files(os.path.join('queues', 'extraction'), '.extracted')
            info = f'Extraction: {extracted_count}/{amount_sha256}'
            if extracted_count == amount_sha256:
                info = colored(info, 'green', attrs = ['bold'])
                running['extraction'] = False
            print(info)

        if args.label:
            labeled_count = count_files(os.path.join('queues', 'label'), '.labeled')
            info = f'Label: {labeled_count}/{amount_sha256}'
            if labeled_count == amount_sha256:
                info = colored(info, 'green', attrs = ['bold'])
                running['label'] = False
            print(info)

        if args.build:
            builded_count = count_files(os.path.join('queues', 'build'), '.builded')
            info = f'Build: {builded_count}/{amount_sha256}'
            if builded_count == amount_sha256:
                info = colored(info, 'green', attrs = ['bold'])
                running['build'] = False
            print(info)

        dataset = os.path.join('queues', 'build', 'ADBuilder_Dataset.csv')
        try:
            if os.path.exists(dataset):
                dataset_df = pd.read_csv(dataset)
                print('\n*** Dataset Under Construction ***')
                print(f'Number of Samples: {len(dataset_df)}')
                print(f'Number of Features: {len(dataset_df.columns)}')
                print(f'Dataset Size: {os.path.getsize(dataset)} bytes\n')
        except:
            pass

        finished = all(not value for value in running.values())
        if not finished:
            time.sleep(5)
            iteration_counter += 1

    end = time.time()
    cprint(f'\n\n***** ADBuilder *****\nExecuted in {end - start:.2f} seconds.\n', 'green', attrs = ['bold'])
