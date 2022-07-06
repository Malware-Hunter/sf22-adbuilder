# sd22_motodroid

MotoDroidBuilder: implementação completa e totalmente integrada da ferramenta. Todas as etapas e "firulas" devem estar incorporadas na ferramenta.

### Ideias para a ferramenta

1) ser capaz de executar as etapas (todas ou individualmente) do processo de construção de um *dataset*:
    -   Download do APK;
    -   Extração de características;
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


### Exemplos de parâmetros de execução:

- tool.py --extract-features-only arquivo.APK  ||  tool.py --extract-all-features arquivo.APK
- tool.py --download --extract-features SHA256_do_APK
- tool.py --download --extract-features --labelling-virustotal SHA256_do_APK
- tool.py --download --extract-features --labelling-all SHA256_do_APK
- tool.py --download --extract-features --labelling-all --build-dataset SHA256_do_APK
- tool.py --build-dataset-only arquivo_APK1.csv arquivo_APK2.csv ... arquivo_APKn.csv
- tool.py --all SHA256_do_APK
