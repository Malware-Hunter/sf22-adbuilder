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
