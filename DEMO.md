# Demo e Screenshots

## Estrutura da Interface

A aplicação possui uma interface simples e intuitiva:

```
┌─────────────────────────────────────────────────────────┐
│  Bloco de Notas - [Nome do Arquivo] [●]                 │
├─────────────────────────────────────────────────────────┤
│  Arquivo │ Editar │ Exibir                              │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  [Área de Edição/Visualização]                          │
│                                                          │
│  - Modo Normal: Editor de texto                         │
│  - Modo Rich: Visualização Markdown formatada           │
│                                                          │
│                                                          │
│                                                          │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

## Elementos da Interface

### 1. Barra de Título
- Mostra o nome do arquivo atual ou "Novo Arquivo"
- Indicador de alterações não salvas (●)

### 2. Barra de Menu
Três menus principais:

**Arquivo:**
```
┌──────────────────┐
│ ● Novo           │
│ ● Salvar         │
│ ● Salvar Como    │
│ ● Carregar       │
│ ● Download       │
└──────────────────┘
```

**Editar:**
```
┌──────────────────┐
│ ✂ Recortar       │
│ ⎘ Copiar         │
│ ⬚ Selecionar Tudo│
└──────────────────┘
```

**Exibir:**
```
┌──────────────────┐
│ ⊞ Normal       ✓ │
│ ⊟ Formato Rich   │
└──────────────────┘
```

### 3. Área de Edição
- **Modo Normal**: Campo de texto editável com múltiplas linhas
- **Modo Rich Format**: Visualização renderizada do Markdown

### 4. Gerenciador de Arquivos
```
┌────────────────────────────────────────┐
│  Gerenciador de Arquivos               │
├────────────────────────────────────────┤
│                                        │
│  📄 meu_arquivo.txt                   🗑│
│     Modificado: 13/02/2026 15:30      │
│                                        │
│  📝 documento.md                      🗑│
│     Modificado: 13/02/2026 14:15      │
│                                        │
│  📄 notas.txt                         🗑│
│     Modificado: 12/02/2026 10:45      │
│                                        │
├────────────────────────────────────────┤
│                            [Fechar]    │
└────────────────────────────────────────┘
```

## Fluxo de Trabalho Típico

### Criar um Novo Arquivo
1. Abrir a aplicação
2. Clicar em "Arquivo" → "Novo"
3. Digitar o conteúdo
4. Clicar em "Arquivo" → "Salvar Como"
5. Escolher nome e tipo (.txt ou .md)
6. Clicar em "Salvar"

### Editar um Arquivo Existente
1. Clicar em "Arquivo" → "Carregar"
2. Selecionar o arquivo desejado
3. Editar o conteúdo
4. Clicar em "Arquivo" → "Salvar"

### Visualizar Markdown Formatado
1. Criar ou carregar um arquivo .md
2. Escrever conteúdo Markdown
3. Clicar em "Exibir" → "Formato Rich"
4. Ver a renderização formatada

### Fazer Download (Web)
1. Ter um arquivo salvo
2. Clicar em "Arquivo" → "Download"
3. O arquivo será baixado para o computador

## Diálogos

### Diálogo "Salvar Como"
```
┌──────────────────────────────────┐
│  Salvar Como                     │
├──────────────────────────────────┤
│                                  │
│  Nome do arquivo:                │
│  [___________________________]   │
│                                  │
│  Tipo: [.txt ▼]                  │
│                                  │
├──────────────────────────────────┤
│           [Cancelar]  [Salvar]   │
└──────────────────────────────────┘
```

### Diálogo "Alterações Não Salvas"
```
┌──────────────────────────────────┐
│  Alterações não salvas           │
├──────────────────────────────────┤
│                                  │
│  Deseja salvar as alterações     │
│  antes de continuar?             │
│                                  │
├──────────────────────────────────┤
│  [Descartar] [Cancelar] [Salvar] │
└──────────────────────────────────┘
```

## Recursos Visuais

### Ícones
- 📄 Arquivo .txt (azul)
- 📝 Arquivo .md (verde)
- 🗑 Excluir arquivo
- ● Alterações não salvas (laranja)
- ✓ Opção selecionada (no menu)

### Cores do Tema
- Cor primária: Azul Material Design
- Cor de destaque: Laranja (para indicador)
- Fundo: Branco
- Menu: Cinza claro

## Compatibilidade

### Plataformas Suportadas
- ✅ Web (Chrome, Firefox, Safari, Edge)
- ✅ Android (versão 5.0 ou superior)
- 🔜 iOS (suporte futuro)
- 🔜 Desktop (Windows, macOS, Linux - suporte futuro)

### Requisitos do Navegador (Web)
- Suporte a HTML5
- JavaScript habilitado
- API de Blob para download de arquivos

### Requisitos do Android
- Android 5.0 (API 21) ou superior
- Mínimo 50 MB de espaço livre
- Permissões de armazenamento (para versões futuras)
