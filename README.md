# sd22_motodroid

MotoDroidBuilder: implementação completa e totalmente integrada da ferramenta. Todas as etapas e "firulas" devem estar incorporadas na ferramenta.

### Ideias para a ferramenta

1) ser capaz de executar as etapas (todas ou individualmente) do processo de construção de um *dataset*:
    -   Download do APK;
    -   Extração de características (+ Tratamento e validação das mesmas);
    -   Rotulação dos APKs;
    -   Construção do *dataset* (+ Sanitização do *dataset*);

2) ser capaz de gerar arquivos de saída:
    -   logs (i.e., arquivos de texto) contendo informações sobre o processamento, como:
        -   tempo de download dos APKs;
        -   tempo de extração dos APKs;
        -   uso de CPU;
        -   consumo de memória RAM;
    -   um arquivo JSON para cada APK contendo os resultados da análise do VirusTotal;
    -   um arquivo de texto para cada APK contendo chamadas de API (extração crua);
    -   um arquivo CSV para cada APK contendo todas as características;
    -   um arquivo CSV para cada APK contendo os dados tratados e adequados para integrar ao *dataset* final;
    -   o *dataset* final (i.e., resultado final da ferramenta que contém a união de todos os CSVs de APKs);

3) ser capaz de oferecer opções de especificação para o usuário.

4) ser capaz de automatizar todo o processo de construção de um *dataset*.

5) possuir uma estrutura flexível para ser capaz de integrar mais funcionalidades, posteriormente.


### Dependências / Permissões
Antes de executar o projeto, você deve certificar-se de que as seguintes bibliotecas estão instaladas na sua máquina:

* curl 
* pandas = 1.3.5
* androguard = 3.3.5
* networkx = 2.2
* pandas = 1.3.5
* lxml = 4.5
* numpy 1.22.3
* (instalar json???)

Se não estiverem, execute os comandos abaixo:

- sudo snap install curl
- sudo apt-get install androguard=3.3.5
- sudo apt-get install networkx=2.2
- python3 -m pip install pandas=1.3.5

Se você tiver problemas de permissões, similar a esse:

sh: 1: ./labelling/run_n_labellings.sh: Permission denied.

Execute os seguintes comandos:

- chmod u+x permissions.sh
- ./permissions.sh


### Teste

Atualmente, todas as etapas estão integradas na ferramenta. Você poderá testar a ferramenta com o seguinte comando:

* *python3 mdbuilder.py --download sha256.txt -npd 2 -fe -npe 2 --labelling sha256.txt --building*

*Info: python3 mdbuilder.py --download (lista_de_sha256.txt) -npd (num de processos de download) --feature_extraction/-fe -npe (num de processos de extração) --labelling (lista_de_sha256.txt) -api (lista de API Keys do VirusTotal) --building*

Os parâmetros *--download* e *--labelling* recebem uma lista.txt contendo os sha256 dos APKs que se deseja baixar. Esta lista pode estar em qualquer lugar.

O parâmetro *-api* recebe uma lista.txt contendo as API Keys do VirusTotal. Esta lista pode estar em qualquer lugar.

O parâmetro *-npd* e -*npe* recebe um número inteiro informando a quantidade de processos (núcleos da máquina) que serão utilizados para realizar a etapa de download e extração, respectivamente. Se não for definido esse parâmetro, o valor será setado em 1 processo, por padrão.

*OBS: Também é possível rodar cada etapa separadamente. Apenas o building ainda precisa ser executado com o download ou labelling, porque precisa saber o número de sha256 da lista para a parada do processo.*