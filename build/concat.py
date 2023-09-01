import re
import os
import pandas as pd
import numpy as np
import argparse
from constants import *

def data_processing(df):
    split_permissions = re.sub(r'[\[\'\]\" ]', '', df['PERMISSIONS'][0]).split(',')
    split_permissions = [x for x in split_permissions if x != '' and x != ' ']
    split_intents = re.sub(r'[\[\'\]\"\{\} ]', '', df['INTENTS'][0]).split(',')
    split_intents = [x for x in split_intents if x != '' and x != ' ']
    split_apicalls = re.sub(r'[\[\'\]\"\<\> ]', '', df['APICALLS'][0]).split(',')
    split_apicalls = [x for x in split_apicalls if x != 'analysis.MethodAnalysis' and x != '' and x != ' ']

    permissions = list()
    for x in split_permissions:
        p = re.sub(r'.*\W+|[a-z]+|[1,3-9]+|^(?:[\t ]*(?:\r?\n|\r))}+', '', x)
        permissions.append(f'Permission :: {p}')

    intents = list()
    for x in split_intents:
        i = re.sub(r'.*\W+|[a-z]+|[1,3-9]+|^(?:[\t ]*(?:\r?\n|\r))+', '', x)
        if i in intent_list:
            intents.append(f'Intent :: {i}')

    split_apicalls = ["API Call :: " + x for x in split_apicalls]

    apicalls = list()
    for line in split_apicalls:
        for package in package_list:
            if str(package) in str(line):
                apicalls.append(line)

    pd_permissions = pd.DataFrame(columns = permissions)
    pd_permissions = pd_permissions.loc[:,~pd_permissions.columns.duplicated()]
    pd_intents = pd.DataFrame(columns = intents)
    pd_intents = pd_intents.loc[:,~pd_intents.columns.duplicated()]

    pd_apicalls = pd.DataFrame()
    if len(split_apicalls):
        pd_apicalls = pd.DataFrame(columns = apicalls)
        pd_apicalls = pd_apicalls.loc[:,~pd_apicalls.columns.duplicated()]

    pd_features = pd.concat([pd_permissions, pd_intents, pd_apicalls], axis = 1)
    pd_features.loc[0,:] = 1

    pd_metadata = pd.DataFrame()
    pd_metadata['SHA256'] = df['SHA256']
    pd_metadata['NAME'] = df['NAME']
    pd_metadata['PACKAGE'] = df['PACKAGE']
    pd_metadata['MIN_API'] = df['MIN_API']
    pd_metadata['TARGET_API'] = df['TARGET_API']

    pd_all = pd_metadata.join(pd_features)
    return pd_all

def parse_args():
    parser = argparse.ArgumentParser(description = 'Dataset Building.')
    parser.add_argument('--sha256', required = True, help = 'SHA256 From APK File')
    parser.add_argument('--extraction-dir', metavar = 'PATH', type = str, required = True, help = 'Path to Extraction Queue')
    parser.add_argument('--label-dir', metavar = 'PATH', type = str, required = True, help = 'Path to Label Queue')
    parser.add_argument('--build-dir', metavar = 'PATH', type = str, required = True, help = 'Path to Build Queue')
    args = parser.parse_args()
    return args

def wait_file(dir, sha256, type, timeout = 3600, interval = 1):
    import time
    start_time = time.time()
    file_found = None
    while not file_found:
        if os.path.exists(os.path.join(dir, f'{sha256}.{type}')):
            file_found = type
        elif os.path.exists(os.path.join(dir, f'{sha256}.error')):
            file_found = 'error'
        if time.time() - start_time > timeout:
            raise TimeoutError(f'File in {dir} Not Found After Timeout')
        time.sleep(interval)

    return file_found


if __name__ == '__main__':
    args = parse_args()

    extacted_file = os.path.join(args.extraction_dir, f'{args.sha256}.extracted')
    if not os.path.exists(extacted_file):
        try:
            file_found = wait_file(args.extraction_dir, args.sha256, 'extracted')
            if file_found == 'error':
                exit(1)
        except Exception as e:
            print(f'Exception When Wait For File {extacted_file}')

    labeled_file = os.path.join(args.label_dir, f'{args.sha256}.labeled')
    if not os.path.exists(labeled_file):
        try:
            file_found = wait_file(args.label_dir, args.sha256, 'labeled')
            if file_found == 'error':
                exit(1)
        except Exception as e:
            print(f'Exception When Wait For File {labeled_file}')

    extaction_file = os.path.join(args.extraction_dir, f'{args.sha256}.csv')
    features_df = pd.read_csv(extaction_file)
    features_df = data_processing(features_df)
    label_file = os.path.join(args.label_dir, f'{args.sha256}.csv')
    label_df = pd.read_csv(label_file)
    features_df.loc[0, 'LABEL'] = label_df['MALICIOUS'][0]
    dataset_file = os.path.join(args.build_dir, 'ADBuilder_Dataset.csv')
    if os.path.exists(dataset_file):
       dataset_df = pd.read_csv(dataset_file)
    else:
       dataset_df = pd.DataFrame()

    dataset_df = pd.concat([dataset_df, features_df], ignore_index = True)
    dataset_df.fillna(0, inplace = True)
    for col in dataset_df:
        if dataset_df[col].dtype == "float64":
            dataset_df[col] = dataset_df[col].astype(int)

    dataset_df.to_csv(dataset_file, index = False, encoding='utf-8-sig')
