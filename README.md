# Bloco de Notas

Projeto Flutter para Android e Web que trabalha com bloco de notas de arquivos .txt e arquivos .md

## Funcionalidades

### Gerenciamento de Arquivos
- ✅ Criar novos arquivos
- ✅ Salvar arquivos (.txt ou .md)
- ✅ Salvar Como - escolher nome e tipo de arquivo
- ✅ Carregar arquivos salvos
- ✅ Download de arquivos (Web)
- ✅ Gerenciador de arquivos integrado (Android e Web)
- ✅ Exclusão de arquivos do gerenciador

### Edição de Texto
- ✅ Editor de texto completo
- ✅ Recortar texto selecionado
- ✅ Copiar texto selecionado
- ✅ Selecionar todo o texto

### Visualização
- ✅ Modo Normal - edição de texto simples
- ✅ Modo Formato Rich - visualização de arquivos .md com formatação Markdown

### Interface
- ✅ Barra de menu com opções:
  - **Arquivo**: Novo, Salvar, Salvar Como, Carregar, Download
  - **Editar**: Recortar, Copiar, Selecionar Tudo
  - **Exibir**: Normal, Formato Rich
- ✅ Indicador de alterações não salvas
- ✅ Diálogo de confirmação para alterações não salvas

## Estrutura do Projeto

```
lib/
├── main.dart                          # Ponto de entrada da aplicação
├── models/
│   └── note_file.dart                 # Modelo de dados para arquivos
├── services/
│   └── file_storage_service.dart      # Serviço de armazenamento de arquivos
├── screens/
│   └── notepad_screen.dart            # Tela principal do editor
└── widgets/
    └── file_manager_dialog.dart       # Diálogo do gerenciador de arquivos
```

## Como Executar

### Requisitos
- Flutter SDK 3.0.0 ou superior
- Para Web: Navegador moderno com suporte a HTML5
- Para Android: Android SDK e dispositivo/emulador Android

### Comandos

```bash
# Instalar dependências
flutter pub get

# Executar na Web
flutter run -d chrome

# Executar no Android
flutter run -d android

# Build para Web
flutter build web

# Build para Web no GitHub Pages (repo project page)
flutter build web --release --base-href /blocodenotas/

# Build para Android
flutter build apk
```

## Publicação no GitHub Pages

O projeto já possui workflow em `.github/workflows/deploy-github-pages.yml` para publicar automaticamente a versão Web.

### Passos
1. Faça push para a branch `main`.
2. No GitHub, vá em **Settings > Pages**.
3. Em **Build and deployment**, selecione **Source: GitHub Actions**.
4. Aguarde o workflow **Deploy Web no GitHub Pages** concluir.

### URL esperada
- `https://exadmax.github.io/blocodenotas/`

## Dependências

- `flutter_markdown`: ^0.6.18 - Renderização de Markdown
- `markdown`: ^7.1.1 - Parser de Markdown
- `file_picker`: ^6.0.0 - Seleção de arquivos (futuro uso)
- `path_provider`: ^2.1.0 - Acesso a diretórios do sistema (futuro uso)
- `universal_html`: ^2.2.4 - Suporte a HTML para download de arquivos na Web

## Recursos Implementados

### Arquivos .txt
- Criação e edição de arquivos de texto simples
- Salvamento local (em memória para a versão atual)
- Visualização em modo normal

### Arquivos .md
- Criação e edição de arquivos Markdown
- Salvamento local (em memória para a versão atual)
- Visualização em modo Rich Format com formatação Markdown aplicada
- Suporte a sintaxe Markdown completa (títulos, listas, links, imagens, código, etc.)

### Plataforma Web
- Download de arquivos para o dispositivo local
- Armazenamento temporário de arquivos na sessão

### Plataforma Android
- Gerenciador de arquivos integrado
- Salvamento de arquivos na memória da aplicação
- Interface otimizada para dispositivos móveis

## Notas Técnicas

- Os arquivos são armazenados em memória durante a sessão da aplicação
- Para persistência permanente, pode-se integrar com `shared_preferences` ou banco de dados local
- A versão Web usa Blob API para download de arquivos
- O projeto suporta tanto Android quanto Web com código compartilhado
