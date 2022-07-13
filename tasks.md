# líder da FT: Lucas
- realizar o acompanhamento diários das atividades do time;

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

- Fazer a lista ser recebida por parâmetro a partir de qualquer lugar; (Nicolas)
- Integrar etapa da rotulação do VirusTotal na ferramenta; (Lucas e Joner)
- Integrar etapa completa da construção do *dataset* (--all); (em andamento... Lucas)

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