# Guia do Usuário - Bloco de Notas

## Visão Geral

O Bloco de Notas é um aplicativo Flutter multiplataforma que permite criar, editar e gerenciar arquivos de texto (.txt) e Markdown (.md).

## Funcionalidades Principais

### 1. Menu Arquivo

#### Novo
- Cria um novo arquivo em branco
- Se houver alterações não salvas, solicita confirmação antes de descartar
- Atalho: Clique em "Arquivo" → "Novo"

#### Salvar
- Salva o arquivo atual
- Se for um arquivo novo (sem nome), abre o diálogo "Salvar Como"
- Atualiza a data de modificação do arquivo
- Atalho: Clique em "Arquivo" → "Salvar"

#### Salvar Como
- Permite salvar o arquivo com um novo nome
- Possibilita escolher o tipo de arquivo (.txt ou .md)
- Útil para criar cópias ou alterar o formato do arquivo
- Atalho: Clique em "Arquivo" → "Salvar Como"

#### Carregar
- Abre o gerenciador de arquivos
- Lista todos os arquivos salvos
- Permite selecionar um arquivo para edição
- Mostra data e hora da última modificação
- Atalho: Clique em "Arquivo" → "Carregar"

#### Download (Web)
- Disponível apenas na versão Web
- Baixa o arquivo atual para o computador
- Mantém a extensão correta (.txt ou .md)
- Atalho: Clique em "Arquivo" → "Download"

### 2. Menu Editar

#### Recortar
- Remove o texto selecionado e copia para a área de transferência
- Requer texto selecionado
- Atalho: Clique em "Editar" → "Recortar"

#### Copiar
- Copia o texto selecionado para a área de transferência
- Não remove o texto original
- Requer texto selecionado
- Atalho: Clique em "Editar" → "Copiar"

#### Selecionar Tudo
- Seleciona todo o conteúdo do arquivo
- Útil para copiar ou recortar todo o texto
- Atalho: Clique em "Editar" → "Selecionar Tudo"

### 3. Menu Exibir

#### Normal
- Modo de edição padrão
- Mostra o texto puro sem formatação
- Permite edição completa do conteúdo
- Ideal para arquivos .txt
- Atalho: Clique em "Exibir" → "Normal"

#### Formato Rich
- Renderiza arquivos Markdown com formatação
- Exibe títulos, listas, links, código, etc.
- Modo somente leitura (não permite edição)
- Ideal para visualizar arquivos .md
- Atalho: Clique em "Exibir" → "Formato Rich"

### 4. Gerenciador de Arquivos

O gerenciador de arquivos permite:
- Visualizar todos os arquivos salvos
- Ver a data e hora da última modificação
- Abrir arquivos para edição
- Excluir arquivos não desejados
- Distinguir arquivos .txt (ícone azul) e .md (ícone verde)

#### Abrir Arquivo
1. Clique em "Arquivo" → "Carregar"
2. Selecione o arquivo desejado na lista
3. Clique no arquivo ou no botão apropriado

#### Excluir Arquivo
1. Abra o gerenciador de arquivos
2. Clique no ícone de lixeira ao lado do arquivo
3. Confirme a exclusão no diálogo

### 5. Indicadores de Status

#### Alterações Não Salvas
- Um pequeno ponto laranja aparece no canto superior direito
- O nome do arquivo fica em negrito
- Indica que há modificações não salvas

#### Nome do Arquivo
- Mostra "Novo Arquivo" para arquivos ainda não salvos
- Mostra o nome completo do arquivo (com extensão) para arquivos salvos

## Sintaxe Markdown

Para arquivos .md, você pode usar:

### Títulos
```markdown
# Título 1
## Título 2
### Título 3
```

### Formatação de Texto
```markdown
**negrito**
*itálico*
`código inline`
```

### Listas
```markdown
- Item 1
- Item 2
  - Subitem

1. Item numerado
2. Outro item
```

### Links e Imagens
```markdown
[Texto do link](https://exemplo.com)
![Texto alternativo](url-da-imagem.jpg)
```

### Código
````markdown
```javascript
function exemplo() {
  console.log("Código");
}
```
````

### Citações
```markdown
> Esta é uma citação
```

## Dicas de Uso

1. **Salve frequentemente**: Use Ctrl+S ou o menu Salvar regularmente
2. **Use .md para documentação**: Arquivos Markdown são ideais para documentos formatados
3. **Use .txt para notas rápidas**: Arquivos de texto são mais simples e leves
4. **Alterne entre modos**: Use Normal para editar e Rich Format para visualizar o resultado
5. **Organize seus arquivos**: Use nomes descritivos para facilitar a localização

## Armazenamento

### Web
- Arquivos são salvos na memória do navegador durante a sessão
- Use a opção "Download" para salvar permanentemente no computador
- Os arquivos são perdidos ao fechar a aba/janela (sem download)

### Android
- Arquivos são salvos na memória da aplicação
- Persistem entre sessões da aplicação
- Acessíveis através do gerenciador de arquivos integrado

## Atalhos de Teclado

Atualmente, o aplicativo usa menus visuais. Futuros updates podem incluir:
- Ctrl+N: Novo arquivo
- Ctrl+S: Salvar
- Ctrl+O: Abrir
- Ctrl+C: Copiar
- Ctrl+X: Recortar
- Ctrl+A: Selecionar tudo

## Suporte

Para reportar problemas ou sugerir melhorias, acesse o repositório do projeto no GitHub.
