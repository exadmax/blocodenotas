#!/bin/bash

# Script de configuração do ambiente Flutter para Codespace
# Este script instala o Flutter e configura o ambiente de desenvolvimento

set -e

echo "🚀 Iniciando configuração do ambiente Flutter..."

# Verifica se o Flutter já está instalado
if ! command -v flutter &> /dev/null; then
    echo "📦 Instalando Flutter..."
    
    # Baixa o Flutter SDK
    cd ~
    git clone https://github.com/flutter/flutter.git -b stable --depth 1
    
    # Adiciona o Flutter ao PATH
    export PATH="$HOME/flutter/bin:$PATH"
    echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.bashrc
    
    echo "✅ Flutter instalado com sucesso!"
else
    echo "✅ Flutter já está instalado"
    export PATH="$HOME/flutter/bin:$PATH"
fi

# Verifica e instala o Chromium para desenvolvimento web
if ! command -v chromium-browser &> /dev/null; then
    echo "📦 Instalando Chromium para desenvolvimento web..."
    sudo apt-get update
    sudo apt-get install -y chromium-browser
    echo "✅ Chromium instalado com sucesso!"
else
    echo "✅ Chromium já está instalado"
fi

# Configura o Chrome para o Flutter
export CHROME_EXECUTABLE=$(which chromium-browser)
echo 'export CHROME_EXECUTABLE=$(which chromium-browser)' >> ~/.bashrc

# Habilita suporte para web no Flutter
echo "⚙️  Habilitando suporte para web..."
flutter config --enable-web

# Volta para o diretório do projeto
cd /workspaces/blocodenotas

# Instala as dependências do projeto
echo "📦 Instalando dependências do projeto..."
flutter pub get

# Executa o flutter doctor para verificar a instalação
echo "🔍 Verificando instalação do Flutter..."
flutter doctor

echo ""
echo "✨ Configuração concluída com sucesso!"
echo ""
echo "📝 Comandos úteis:"
echo "  flutter run -d chrome        # Executar no Chrome"
echo "  flutter build web            # Build para produção (web)"
echo "  flutter test                 # Executar testes"
echo "  flutter doctor               # Verificar status do ambiente"
echo ""
echo "🌐 Para executar o projeto web:"
echo "  flutter run -d chrome --web-port=8080"
echo ""
