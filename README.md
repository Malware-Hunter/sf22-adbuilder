# sd22_motodroid

MotoDroidBuilder: implementação completa e totalmente integrada da ferramenta. Todas as etapas e "firulas" devem estar incorporadas na ferramenta.

Exemplos de parâmetros de execução:

- tool.py --extract-features-only arquivo.APK
- tool.py --download --extract-features SHA256_do_APK
- tool.py --download --extract-features --labelling-virustotal SHA256_do_APK
- tool.py --download --extract-features --labelling-all SHA256_do_APK
- tool.py --download --extract-features --labelling-all --build-dataset SHA256_do_APK
- tool.py --build-dataset-only arquivo_APK1.csv arquivo_APK2.csv ... arquivo_APKn.csv
- tool.py --all SHA256_do_APK

- tool.py --extract-all-features arquivo.APK

Parâmetros de extração de características:

- *-perm* >> extrair permissões do APK
- *-int* >> extrair intenções do APK
- *-api* >> extrair API Calls do APK
- *-act* >> extrair atividades do APK
- *-prov* >> extrair provedores do APK
- *-recep* >> extrair receptores do APK
- *-serv* >> extrair serviços do APK
- *-op* >> extrair opcodes do APK
- *-all* >> extrair todas as características do APK

*OBS:* *Se mais de um parâmetro for adicionado, e.g., -perm -int -api, serão extraídas as respectivas características (e.g., permissões, intenções e chamadas de API).*
*Se o parâmetro -all for adicionado, então todas as características serão extraídas do APK em questão.*