# líder da FT: Lucas

### Equipe

- Lucas
- Vagner
- Nicolas

### Estrutura de Atividades

- Desenvolver a ferramenta MotoDroidBuilder:

    - Integrar as etapas do processo do MotoDroid na ferramenta:
        - Download SHA256 do APK;
        - Extração de características CSV do APK;
        - Rotulação do VirusTotal SHA256 do APK;
        - Construção do *dataset*.

    - Verificar quais serão os parâmetros para a execução da ferramenta;
    - Adicionar parâmetros de execução;
    - Integrar os métodos de extração na ferramenta.

- Casos de teste:
    - Testar e validar as possíveis opções de execução da ferramenta;
    - Testar possíveis opções que gerem erros.

- Documentação do MotoDroidBuilder:
    - Documentar todo o processo de desenvolvimento da ferramenta;
    - Documentar todos os testes
    - Documentar dependências necessárias.

### Atividades Pendentes
 **PRIORIDADE**
    - Fazer Lista de API Keys ser recebida de qualquer lugar sem nenhum problema;
    - Gerar log usr/bin/time para concatenção. Falar sobre erro usr/bin/time; (Lucas)
    - Verificar os APKs corrompidos para matar processo, ao final; (Lucas e Vagner)
    - Resolver FIXMEs e fazer testes; (Lucas, Vagner e Nicolas)

**PRIORIDADE MENOR**
    - Fazer script.sh que liste todas as dependências atuais; (Lucas)
    - Configurar labelling para esperar por 24h???
    - Criar um *--building_only* sem a variável vars_APKs; (Lucas)
    - Sinal de DEBUG; (Após tarefas prioritárias)

**OPCIONAL**
- Fazer letras personalizadas de tela inicial do MotoDroidBuilder;


### Atividades Realizadas
- Estruturação de pastas neste repositório; (Lucas)
- Integrar etapa de download na ferramenta; (Lucas)
- Integrar etapa de extração de características na ferramenta; (Lucas)
- Integrar etapa de download/extração na ferramenta; (Lucas)
- Mover arquivos de saída de download e extração para uma sub-pasta; (Lucas)
- Organizar e padronizar diretório temporário para arquivos de saída; (Lucas)
- Verificar quais API Keys do VT estão disponíveis (Nicolas);
- Automatizae e executar análises do VirusTotal (Lucas);
- Integrar etapa da construção do *dataset* na ferramenta; (Lucas)
- Reestruturação do repositório e códigos; (Diego)
- Escrita textual do passo a passo do processo da ferramenta; (Lucas)
- Diagrama da arquitetura da ferramenta (Diego e Lucas)
- Integrar etapa da rotulação do VirusTotal na ferramenta: (Lucas)
- Sincronizar etapa de *labelling* com *building*; (Lucas)
- Fazer com que o run_analysis_VT.sh execute unicamente a partir do seu diretório raiz; (Lucas)
- Disponibilizar ferramenta para o pessoal testar; (Lucas)
- Andamento da escrita da implementação da ferramenta; (Lucas)
- Permitir a lista de API Keys ser recebida de qualquer lugar; (Lucas)
- Atualizar Readme.md; (Lucas e Vagner);
- Resolver erro do APK não conter nenhuma características de um tipo, e.g., intents; (Lucas);
- Teste de 100 APKs de 1MB >> 99% (1 APK corrompido);
- Teste de 100 APKs de 5MB >> 100%;