import argparse
import pandas as pd
import json
import os
from json.decoder import JSONDecodeError
import requests

def parse_args():
    parser = argparse.ArgumentParser(description = 'VirusTotal Label')
    parser.add_argument('--sha256', metavar = 'SHA256', type = str, required = True, help = 'SHA256 From APK File')
    parser.add_argument('--key', metavar = 'KEY', type = str, required = True, help = 'VirusTotal\'s API Key')
    parser.add_argument('--label-dir', metavar = 'PATH', type = str, required = True, help = 'Path to Label Queue')
    args = parser.parse_args()
    return args

def vt_report(sha256, vt_key):
    url = f'https://www.virustotal.com/api/v3/files/{sha256}'
    headers = {
        'accept': 'application/json',
        'x-apikey': vt_key
        }
    try:
        response = requests.get(url, headers = headers)
        response.raise_for_status()
        if response.text:
            return response.json()
    except requests.exceptions.HTTPError as errh:
        if errh.response.text and 'error' in errh.response.text:
            json_data = (errh.response.text).json()
            code = json_data['error']['code']
            if code == 'QuotaExceededError':
                print(f'[{code}] Quota Exceeded')
                exit(2)
            elif code == 'UserNotActiveError':
                print(f'[{code}] Finishing Execution')
                exit(3)
    except Exception as e:
        return None
    return None

def save_json(sha256, json_data, dir):
    try:
        json_object = json.dumps(json_data, indent = 3)
        json_location = os.path.join(dir, f'{sha256}.json')
        json_file = open(json_location, 'w')
        json_file.write(json_object)
        json_file.close()
    except Exception as e:
        exit(1)

if __name__=="__main__":
    args = parse_args()
    exists_csv_file = os.path.exists(os.path.join(args.label_dir, f'{args.sha256}.csv'))
    if exists_csv_file:
        print(f'{args.sha256} Already Labeled')
    else:
        json_data = vt_report(args.sha256, args.key)
        if json_data:
            try:
                attributes = json_data['data']['attributes']
                last_stats = attributes['last_analysis_stats']
                labelling_data = pd.DataFrame([[args.sha256, last_stats['malicious']]], columns = ['SHA256', 'MALICIOUS'])
                sha256_csv = os.path.join(args.label_dir, f'{args.sha256}.csv')
                labelling_data.to_csv(sha256_csv, index = False)
                save_json(args.sha256, json_data, args.label_dir)
            except Exception as e:
                print(e)
                print('Exception Processing Report')
                exit(1)
        else:
            exit(1)
