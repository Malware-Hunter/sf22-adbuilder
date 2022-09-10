<h1 align="center"> ADBuilder </h1>
<h5 align="left"> Ferramenta automatizada para gerar um dataset de malwares em Android. A ferramenta passa por todas as etapas, incluindo: </h5>


- [x] Download de Aplicativos;
- [x] Extração de Features;
- [x] Rotulação dos Aplicativos;
- [x] Geração do Dataset.

[//]: # (ADBuilder: implementação completa e totalmente integrada da ferramenta. Todas as etapas e "firulas" devem estar incorporadas na ferramenta.)

[//]: # ()
[//]: # (### Ideias para a ferramenta)

[//]: # ()
[//]: # (1&#41; ser capaz de executar as etapas &#40;todas ou individualmente&#41; do processo de construção de um *dataset*:)

[//]: # (    -   Download do APK;)

[//]: # (    -   Extração de características &#40;+ Tratamento e validação das mesmas&#41;;)

[//]: # (    -   Rotulação dos APKs;)

[//]: # (    -   Construção do *dataset* &#40;+ Sanitização do *dataset*&#41;;)

[//]: # ()
[//]: # (2&#41; ser capaz de gerar arquivos de saída:)

[//]: # (    -   logs &#40;i.e., arquivos de texto&#41; contendo informações sobre o processamento, como:)

[//]: # (        -   tempo de download dos APKs;)

[//]: # (        -   tempo de extração dos APKs;)

[//]: # (        -   uso de CPU;)

[//]: # (        -   consumo de memória RAM;)

[//]: # (    -   um arquivo JSON para cada APK contendo os resultados da análise do VirusTotal;)

[//]: # (    -   um arquivo de texto para cada APK contendo chamadas de API &#40;extração crua&#41;;)

[//]: # (    -   um arquivo CSV para cada APK contendo todas as características;)

[//]: # (    -   um arquivo CSV para cada APK contendo os dados tratados e adequados para integrar ao *dataset* final;)

[//]: # (    -   o *dataset* final &#40;i.e., resultado final da ferramenta que contém a união de todos os CSVs de APKs&#41;;)

[//]: # ()
[//]: # (3&#41; ser capaz de oferecer opções de especificação para o usuário.)

[//]: # ()
[//]: # (4&#41; ser capaz de automatizar todo o processo de construção de um *dataset*.)

[//]: # ()
[//]: # (5&#41; possuir uma estrutura flexível para ser capaz de integrar mais funcionalidades, posteriormente.)
### Índice

* [Ambiente de Teste](#ambiente-de-teste)
* [Preparando o Ambiente (Linux)](#preparando-o-ambiente)
* [Parâmetros Disponíveis](#parametros-disponiveis)
* [Exemplo de Uso](#exemplo-de-uso)

<div id="ambiente-de-teste"/>

### 🖱️ Ambiente de Teste 

A ferramenta foi testada e utilizada na prática nos seguintes ambientes:

Ubuntu 22.04 LTS
* Kernel = ``` 5.15.0-41 generic ```
* Python = ``` 3.10.4 ```
* Ferramentas: ``` curl, time, pandas (versão 1.3.5), androguard (versão 3.3.5), networkx (versão 2.2), lxml (versão 4.5), numpy (versão 1.22.3). ```

Ubuntu 20.04 LTS
* Kernel = ``` 5.10.16.3-microsoft-standard-WSL2 ```
* Python = ``` 3.8.10 ```
* Ferramentas: ``` curl, time, pandas (versão 1.3.5), androguard (versão 3.3.5), networkx (versão 2.2), lxml (versão 4.5), numpy (versão 1.22.3). ```

<div id="preparando-o-ambiente"/>

### ⚙️Preparando o ambiente (Linux)
Instalação do Git
```
sudo apt-get install git -y
```
Clone o Repositório
```
git clone https://github.com/Malware-Hunter/sf22-adbuilder.git
```
Nós disponibilizamos um arquivo shell de setup que contém configurações de permissões e dependências necessárias. Portanto, para preparar o ambiente, basta executar o seguinte comando:
```
cd sf22_adbuilder
./scripts/setup.sh
```
Caso prefira, você pode instalar as dependências individualmente utilizando os seguintes comandos:
```
- sudo snap install curl
- sudo apt install time
- sudo apt install python3.8
- python3 -m pip install androguard==3.3.5
- python3 -m pip install networkx==2.2
- python3 -m pip install pandas==1.3.5
- python3 -m pip install termcolor
- python3 -m pip install pyfiglet
```

<div id="parametros-disponiveis"/>

### 📌 Parâmetros disponíveis:


```
--download (lista_de_sha256.txt) = realiza download de aplicativos obtidos pelo arquivo .txt fornecido.
-npd (processos) = insira um número inteiro (e.g., 5) de processos para download (por padrão é 1).
--feature_extraction, -fe = extrai características dos aplicativos.
-npe (processos) = insira um número inteiro (e.g., 5) de processos de extração (por padrão é 1). 
--labelling (lista_de_sha256.txt) = realiza a rotulação dos aplicativos obtidos pelo arquivo .txt fornecido.
-api (lista_de_keys_virustotal.txt) = insira um arquivo com API keys do VirusTotal.
--building = gera o dataset final.
```

[//]: # (Os parâmetros *--download* e *--labelling* recebem uma lista.txt contendo os sha256 dos APKs que se deseja baixar e rotular, respectivamente. Estas listas podem estar em qualquer lugar.)

[//]: # ()
[//]: # (O parâmetro *-api* recebe uma lista.txt contendo as API Keys do VirusTotal. Esta lista pode estar em qualquer lugar.)

[//]: # ()
[//]: # (O parâmetro *-npd* e -*npe* recebe um número inteiro informando a quantidade de processos &#40;núcleos da máquina&#41; que serão utilizados para realizar a etapa de download e extração, respectivamente. Se não for definido esse parâmetro, o valor será setado em 1 processo, por padrão.)

***É possível rodar cada etapa separadamente ou em conjunto.***

<div id="exemplo-de-uso"/>

### 👨‍💻 Exemplo de uso
Entre no diretório principal:
```
cd sf22_adbuilder
```
O seguinte comando executa todos módulos integrados. Basta passar os parâmetros que preferir:
```
python3 adbuilder.py --download inputs/androzoo/sha256_6_APKs_rand.txt -npd 2 -fe -npe 2 --labelling inputs/androzoo/sha256_6_APKs_rand.txt -api ./inputs/virustotal_api_keys.txt --building
```
É possível executar cada módulo individualmente, conforme exemplos de uso:
```
python3 adbuilder.py --download inputs/androzoo/sha256_6_APKs_rand.txt
python3 adbuilder.py -fe
python3 adbuilder.py --labelling inputs/androzoo/sha256_6_APKs_rand.txt -api ./inputs/virustotal_api_keys.txt
python3 adbuilder.py --building
```
Também é possível executar os módulos de download e extração com mais de um processo, por exemplo:
```
python3 adbuilder.py --download inputs/androzoo/sha256_6_APKs_rand.txt -npd 3 (download com três processos)
python3 adbuilder.py -fe -npe 3 (extração com três processos)
python3 adbuilder.py --download inputs/androzoo/sha256_6_APKs_rand.txt -npd 3 -fe -npe 2 (download com três processos e extração com dois processos)

```
Por fim, é possível executar módulos em conjunto, conforme exemplos:
```
python3 adbuilder.py --download inputs/androzoo/sha256_6_APKs_rand.txt -npd 3 -fe -npe 3 --building
python3 adbuilder.py --download inputs/androzoo/sha256_6_APKs_rand.txt -fe
python3 adbuilder.py -fe --labelling inputs/androzoo/sha256_6_APKs_rand.txt -api ./inputs/virustotal_api_keys.txt
python3 adbuilder.py --download inputs/androzoo/sha256_6_APKs_rand.txt -fe --labelling inputs/androzoo/sha256_6_APKs_rand.txt -api ./inputs/virustotal_api_keys.txt
python3 adbuilder.py  -fe --labelling inputs/androzoo/sha256_6_APKs_rand.txt -api ./inputs/virustotal_api_keys.txt --building
```

***OBS: O dataset final é gerado na fila do módulo de geração, na pasta: queues/building/final.***