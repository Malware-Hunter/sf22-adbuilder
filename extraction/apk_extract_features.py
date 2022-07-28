import os, sys, stat
import pandas as pd
import os, sys, stat ,hashlib
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

def parseArgs():
    parser = argparse.ArgumentParser(description='A program modifying an APK to load Ronin shared library.')
    parser.add_argument('--apk', dest='apk', required=True, help='Path to the APK file to be analysed')
    parser.add_argument('--logdir', dest='logdir', required=True, help='Path to the log dir')
    parser.add_argument('--outdir', dest='outdir', required=True, help='Path to the building queue')
    return parser.parse_args()

def apk_extract_features(args):

    f = open(args.apk, 'rb')
    contents = f.read()

    sha256 = hashlib.sha256(contents).hexdigest()
    
    app,d,dx   = AnalyzeAPK(args.apk)

    apicalls = []
    treatments = []
    op_codes = []
    intents  = []

    cg = dx.get_call_graph()

    comuns_methods = [".equals()", ".hashCode()", ".toString()", ".clone()", ".finalize()", ".wait()",
                 ".print()", ".println()"]
    
    try:
        nome = app.get_app_name()
    except:
        nome = "Nao encontrado"
    pacote        = app.get_package()
    API           = app.get_effective_target_sdk_version()
    minSdkVersion = app.get_min_sdk_version()
    try:
        permissoes    = app.get_permissions()
    except:
        permissoes = []
        print("\nNão foi possível extrair as permissões\n")

    try:    
        activity      = app.get_activities()
    except:
        activity = []
        print("\nNão foi possível extrair as activities\n")
    
    try:
        service       = app.get_services()
    except:
        service = []
        print("\nNão foi possível extrair os serviços\n")
    
    try:
        receiver      = app.get_receivers()
    except:
        receiver = []
        print("\nNão foi possível extrair os receivers\n")
    
    try:
        provider      = app.get_providers()
    except:
        provider = []
        print("\nNão foi possível extrair os providers\n")
    """
    implementação baseada na documentação
    https://github.com/androguard/androguard/issues/685
    """
    def get_op_codes(dx):
        for method in dx.get_methods():
            m = method.get_method()
            if method.is_external():
                continue
            idx = 0
            for ins in m.get_instructions():
                lista_opcode =['{}'.format(ins.get_name())]
                for i in lista_opcode:
                    if i not in op_codes:
                        op_codes.append(i)
			 
        return op_codes
					
    def get_api_calls_3(dx):
        for method in dx.get_methods():
            # Métodos XREF_FROM
            for _,call, _ in method.get_xref_from():
                package = call.class_name.replace(';','')
                if not call.name.endswith(">"):
                        #cria lista formatada ex.: Landroid/support/design/internal/BaselineLayout.onLayout()
                        lista_api_calls =["{}.{}()".format(package, call.name)]
                        for i in lista_api_calls:
                            # remove as API Calls que contenham $[0-9]
                            cifra_aux = str(i)
                            call_treatment = re.findall(r'\$[0-9]+', cifra_aux)
                            if len(call_treatment) == 0:
                                # adiciona todos o métodos contendo Ljava/lang/Class
                                if "Ljava/lang/Class" in i:
                                    if i not in apicalls:
                                        apicalls.append(i)
								  
                                # remover todos os Ljava/lang (métodos comuns da linguagem Java)
                                if "Ljava/lang" not in i:
                                    comum_control = 0
                                    # remove métodos comuns aos Objetos Java
                                    for comum in comuns_methods:
                                        if i.endswith(comum):
                                            comum_control += 1                                
                                            # verificação de duplicatas
                                    if i not in apicalls:
                                        if comum_control == 0:
                                            apicalls.append(i)
									  
									
            for _,call, _ in method.get_xref_to():      # Métodos XREF_TO
                package = call.class_name.replace(';','')
                if not call.name.endswith(">"):
                    #cria lista formatada ex.: Landroid/support/design/internal/BaselineLayout.onLayout()
                    lista_api_calls =["{}.{}()".format(package, call.name)]
                    for i in lista_api_calls:
                        # remove as API Calls que contenham $[0-9]
                        cifra_aux = str(i)
                        call_treatment = re.findall(r'\$[0-9]+', cifra_aux)
                        if len(call_treatment) == 0:
                            # adiciona todos o métodos contendo Ljava/lang/Class
                            if "Ljava/lang/Class" in i:
                                if i not in apicalls:
                                    apicalls.append(i)
								  
                            # remover todos os Ljava/lang (métodos comuns da linguagem Java)
                            if "Ljava/lang" not in i:
                                comum_control = 0
                                # remove métodos comuns aos Objetos Java
                                for comum in comuns_methods:
                                    if i.endswith(comum):
                                        comum_control += 1                                
                                # verificação de duplicatas
                                if i not in apicalls:
                                    if comum_control == 0:
                                        apicalls.append(i)
									  
        return apicalls              
	  
	#Utilizamos a funcao abaixo para obter os metodos que sao chamados pelo app
    def get_api_calls(cg):
        # criar arquivo txt para armazenar os metodos sem o tratamento (metodos crus)
        with open(args.outdir + '/' + sha256+"_API_Calls_original.txt", "w") as file:
            # percorerr vetor contendo as API Calls
            for node in cg.nodes:
                # armazena no txt os metodos crus
                file.write(str(node).strip("\n") + "\n")
                split = str(node).split(" ")
                split_v = str(split).split("(")
                split_v[0] = split_v[0] + "()"
                if split_v[0] not in apicalls:
                    apicalls.append(split_v[0])
                    # remove as API Calls que contenham $[0-9]
                    cifra_aux = split_v[0]
                    call_treatment = re.findall(r'\$[0-9]+', cifra_aux)
                    if len(call_treatment) == 0:
                        aux = str(split_v[0]).replace("\n", "").replace(";->", ".")
                        split = aux.split("(")
                        split[0] = split[0] + "()"
                        if ".access$" not in split[0]:
                            if "java/lang/Object.getClass()" in split[0]:
                                if split[0] not in treatments:
                                    treatments.append(split[0])
                            if "java/lang/Object" not in split[0]:
                                comum_control = 0
                                # remove métodos comuns aos Objetos Java
                                for comum in comuns_methods:
                                    if split[0].endswith(comum):
                                        comum_control += 1 
                                if comum_control == 0:
                                    if split[0] not in treatments:
                                        treatments.append(split[0])
        # criar arquivo zip
        zipfile = zp.ZipFile(args.outdir + '/' + sha256+"_API_Calls_original.zip", "w", zp.ZIP_LZMA)
        zipfile.write(args.outdir + '/' + sha256+"_API_Calls_original.txt")
        zipfile.close()
        # remover txt
        os.remove(args.outdir + '/' + sha256+"_API_Calls_original.txt")

        return treatments  
	  
    def get_intents(app):
        intents  = []
        services = app.get_services()
        serviceString = 'service'
        for service in services:
            for action,intent_name in app.get_intent_filters(serviceString, service).items():
                for intent in intent_name: 
                    intents.append(intent)
				  
        receivers = app.get_receivers()
        receiverString = 'receiver'
        for receiver in receivers:
            for action,intent_name in app.get_intent_filters(receiverString, receiver).items():
                for intent in intent_name:  
                    intents.append(intent)   
				  
        activitys = app.get_activities()
        activityString = 'activity'
        for activity in activitys:
            for action,intent_name in app.get_intent_filters(activityString, activity).items():
                for intent in intent_name:  
                    intents.append(intent)
					   
        return intents
      
    def remove_APK(apk):
        os.remove(apk)
        print(apk,"removido com sucesso!!!")
        return

    try:  
        intents_full  = get_intents(app)
    except:
        intents_full = []
        print("\nNão foi possível obter os intents do app\n")

    try:
        opcodes_full  = get_op_codes(dx)
    except:
        opcodes_full = []
        print("\nNão foi possível obter os opcodes do app\n")

    try:
        apicalls_full = get_api_calls(cg)
    except:
        apicalls_full = []
        print("\nNão foi possível obter os métodos chamados pelo app\n")
    
    #apicalls_full = get_api_calls_3(dx)
    data=[sha256,nome,pacote,API, minSdkVersion,permissoes,intents_full,activity,service,receiver,provider,opcodes_full,apicalls_full]
    # cria um dataframe
    df = pd.DataFrame([data], columns=['SHA256','NOME','PACOTE','API','API_MIN','PERMISSOES','INTENTS','ACTIVITYS','SERVICES','RECEIVER','PROVIDER','OPCODES','APICALLS'])
    df.to_csv(args.outdir + '/' + str(sha256)+'.csv', index = False, encoding="utf-8-sig")

    # remover APK utilizado
    remove_APK(args.apk)

if __name__ == '__main__':
    args = parseArgs()
    apk_extract_features(args)
