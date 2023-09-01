import pandas as pd
import os
import sys
import stat
import hashlib
import pandas as pd
import re
import networkx as nx
from androguard.core.bytecodes.apk import APK
from androguard.core.analysis.analysis import ExternalMethod
from androguard.misc import AnalyzeAPK
from androguard import *
from androguard.core.analysis import *
import argparse
import zipfile as zp
import time

def parse_args(argv):
    parser = argparse.ArgumentParser()
    parser.add_argument('--sha256', metavar = 'SHA256', required = True, help = 'SHA256 From APK File')
    parser.add_argument('--extraction-dir', metavar = 'PATH', required = True, help = 'Path to Extraction Queue')
    parser.add_argument('--download-dir', metavar = 'PATH', required = True, help = 'Path to Download Queue')
    args = parser.parse_args(argv)
    return args

'''
documentation based implementation
https://github.com/androguard/androguard/issues/685
'''
def get_opcodes(dx):
    opcodes = list()
    for method in dx.get_methods():
        if method.is_external():
            continue
        m = method.get_method()
        for ins in m.get_instructions():
            opcode_list =['{}'.format(ins.get_name())]
            for i in opcode_list:
                if i not in opcodes:
                    opcodes.append(i)
    return opcodes

def get_apicalls(cg, sha256):
    global args
    apicalls = list()
    treatments = list()
    common_methods = ['.equals()', '.hashCode()', '.toString()', '.clone()', '.finalize()', '.wait()', '.print()', '.println()']
    # txt file to store the raw methods
    all_apicalls_file = os.path.join(args.extraction_dir, f'{sha256}_API_Calls_original.txt')
    with open(all_apicalls_file, 'w') as file:
        # iterate over CG containing the API Calls
        for node in cg.nodes:
            file.write(f'{str(node)}\n')
            split = str(node).split(' ')
            split_v = str(split).split('(')
            split_v[0] = split_v[0] + '()'
            if split_v[0] not in apicalls:
                apicalls.append(split_v[0])
                # removes API Calls that contain $[0-9]
                cipher_aux = split_v[0]
                call_treatment = re.findall(r'\$[0-9]+', cipher_aux)
                if len(call_treatment) == 0:
                    aux = str(split_v[0]).replace('\n', '').replace(';->', '.')
                    split = aux.split('(')
                    split[0] = split[0] + '()'
                    if '.access$' not in split[0]:
                        if 'java/lang/Object.getClass()' in split[0]:
                            if split[0] not in treatments:
                                treatments.append(split[0])
                        if 'java/lang/Object' not in split[0]:
                            common_control = 0
                            # remove methods common to Java Objects
                            for common in common_methods:
                                if split[0].endswith(common):
                                    common_control += 1
                            if common_control == 0:
                                if split[0] not in treatments:
                                    treatments.append(split[0])
    # create zip file
    zipfile = zp.ZipFile(os.path.join(args.extraction_dir, f'{sha256}_APICalls_Original.zip'), 'w', zp.ZIP_LZMA)
    zipfile.write(all_apicalls_file)
    zipfile.close()
    # remove txt file
    os.remove(all_apicalls_file)
    return treatments

def get_intents(app):
    intents = list()
    activities = app.get_activities()
    receivers = app.get_receivers()
    services = app.get_services()

    intent_filters = ['activity', 'receiver', 'service']
    intent_types = [activities, receivers, services]

    for i in range(len(intent_filters)):
        i_filter = intent_filters[i]
        i_type = intent_types[i]
        for item in i_type:
            for action, intent_name in app.get_intent_filters(i_filter, item).items():
                for intent in intent_name:
                    intents.append(intent)

    return intents

def wait_file(dir, sha256, timeout = 3600, interval = 1):
    start_time = time.time()
    file_found = None
    while not file_found:
        print('Found', file_found, sha256)
        if os.path.exists(os.path.join(dir, f'{sha256}.downloaded')):
            file_found = 'downloaded'
        elif os.path.exists(os.path.join(dir, f'{sha256}.error')):
            file_found = 'error'
        if time.time() - start_time > timeout:
            raise TimeoutError(f'File in {dir} Not Found After Timeout')
        time.sleep(interval)
    print('Found', file_found, sha256)
    return file_found

def extract_features(args):
    exists_csv_file = os.path.exists(os.path.join(args.extraction_dir, f'{args.sha256}.csv'))
    if exists_csv_file:
        print(f'{args.sha256} Already Processed')
        return

    downloaded_file = os.path.join(args.download_dir, f'{args.sha256}.downloaded')
    if not os.path.exists(downloaded_file):
        try:
            file_found = wait_file(args.download_dir, args.sha256)
            if file_found == 'error':
                exit(1)
        except Exception as e:
            print(f'Exception When Wait For File {downloaded_file}')
            exit(1)

    apk = os.path.join(args.download_dir, f'{args.sha256}.apk')
    if not os.path.exists(apk):
        print(f'{args.sha256} Not Downloaded')
        exit(1)
    try:
        f = open(apk, 'rb')
        contents = f.read()
    except Exception as e:
        print(f'Error Reading APK {apk}')
        exit(1)

    sha256 = hashlib.sha256(contents).hexdigest()
    sha256 = sha256.upper()
    try:
        app, d, dx = AnalyzeAPK(apk)
    except Exception as e:
        print(f'Error in AnalyzeAPK {apk}')
        exit(1)

    try:
        app_name = app.get_app_name()
    except:
        app_name = ''

    package = app.get_package()
    target_sdk = app.get_effective_target_sdk_version()
    min_sdk = app.get_min_sdk_version()

    try:
        permissions = app.get_permissions()
    except:
        permissions = list()
        print('Unable to Extract Permissions')

    try:
        activities = app.get_activities()
    except:
        activities = list()
        print('Unable to Extract Activities')

    try:
        services = app.get_services()
    except:
        services = list()
        print('Unable to Extract Services')

    try:
        receivers = app.get_receivers()
    except:
        receivers = list()
        print('Unable to Extract Receivers')

    try:
        providers = app.get_providers()
    except:
        provider = list()
        print('Unable to Extract Providers')

    try:
        intents = get_intents(app)
    except:
        intents = list()
        print('Unable to Get APP Intents')

    try:
        opcodes = get_opcodes(dx)
    except:
        opcodes = list()
        print('Unable to Get APP OpCodes')

    try:
        cg = dx.get_call_graph()
        apicalls = get_apicalls(cg, sha256)
    except:
        apicalls = list()
        print('Could Not Get Methods Called by APP')

    data = [sha256, app_name, package, target_sdk, min_sdk, permissions, intents, activities, services, receivers, providers, opcodes, apicalls]
    # create dataframe
    df = pd.DataFrame([data], columns = ['SHA256', 'NAME', 'PACKAGE', 'TARGET_API', 'MIN_API', 'PERMISSIONS', 'INTENTS', 'ACTIVITIES', 'SERVICES', 'RECEIVERS', 'PROVIDERS', 'OPCODES', 'APICALLS'])
    df.to_csv(os.path.join(args.extraction_dir, f'{sha256}.csv'), index = False, encoding='utf-8-sig')

if __name__ == '__main__':
    global args
    args = parse_args(sys.argv[1:])
    extract_features(args)
