# líder da FT: Lucas

### Equipe

- Lucas
- Joner
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
    - Permitir a lista de API Keys ser recebida de qualquer lugar; (Lucas)
    - Gerar log usr/bin/time para concatenção; (Lucas)
    - Criar um *--building_only* sem a variável vars_APKs; (Lucas)
    - Resolver FIXMEs e fazer testes; (Lucas, Vagner e Nicolas)
    - Disponibilizar ferramenta para o pessoal testar. (Lucas)

**PRIORIDADE MENOR**
- Resolver *quote exceed* das análises do Virus Total? (Nicolas)

**OPCIONAL**
- Fazer letras bonitas de tela inicial do MotoDroidBuilder;
3° gerar log usr/bin/time para a concatenação;
4° fazer um --building_only sem a vars_APKs;

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