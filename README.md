# sd22_motodroid

MotoDroidBuilder: implementação completa e totalmente integrada da ferramenta. Todas as etapas e "firulas" devem estar incorporadas na ferramenta.

### Exemplos de parâmetros de execução:

- tool.py --extract-features-only arquivo.APK  ||  tool.py --extract-all-features arquivo.APK
- tool.py --download --extract-features SHA256_do_APK
- tool.py --download --extract-features --labelling-virustotal SHA256_do_APK
- tool.py --download --extract-features --labelling-all SHA256_do_APK
- tool.py --download --extract-features --labelling-all --build-dataset SHA256_do_APK
- tool.py --build-dataset-only arquivo_APK1.csv arquivo_APK2.csv ... arquivo_APKn.csv
- tool.py --all SHA256_do_APK


### Exemplos de parâmetros de extração de características:

- *-sha256* >> extrair SHA256 do APK
- *-nome* >> extrair nome do APK
- *-pkg* >> extrair permissões do APK
- *-api* >> extrair a versão de API do APK
- *-api-min* >> extrair a versão mínima de API suportada pelo APK
- *-perm* >> extrair permissões do APK
- *-int* >> extrair intenções do APK
- *-apicall* >> extrair API Calls do APK
- *-act* >> extrair atividades do APK
- *-prov* >> extrair provedores do APK
- *-recep* >> extrair receptores do APK
- *-serv* >> extrair serviços do APK
- *-op* >> extrair opcodes do APK
- *-all* >> extrair todas as características do APK

*OBS_1:* *Se mais de um parâmetro for adicionado, e.g., -perm -int -api, serão extraídas as respectivas características (e.g., permissões, intenções e chamadas de API).*

*OBS_2:* *Se o parâmetro -all for adicionado, então todas as características serão extraídas do APK em questão.*

#### Dúvidas

* Permitir a opção para excluir ou não o APK?
* Opção para incluir as chamadas de API cruas?