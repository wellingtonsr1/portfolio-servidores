#!/bin/bash

# Script para instalação e configuração do servidor web Apache no Debian 12
# Autor: [Seu Nome]
# Data: $(date +%Y-%m-%d)
# Versão: 1.0

set -e  # Terminar o script em caso de erro

# Cores para saída
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # Sem cor

# Função para exibir mensagens
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

erro() {
    echo -e "${RED}[ERRO]${NC} $1" >&2
    exit 1
}

# Verifica se o script está sendo executado como root
if [ "$EUID" -ne 0 ]; then
    erro "Este script precisa ser executado como root. Use sudo."
fi

log "Atualizando lista de pacotes..."
apt update -y && apt upgrade -y

log "Instalando Apache2..."
apt install -y apache2

log "Habilitando e iniciando o serviço Apache..."
systemctl enable apache2
systemctl start apache2

log "Configurando firewall para permitir tráfego HTTP e HTTPS..."
ufw allow 'Apache Full' || log "UFW não está instalado ou configurado. Ignorando..."

log "Testando o serviço Apache..."
systemctl status apache2 --no-pager

log "Servidor web instalado com sucesso! Acesse http://$(hostname -I | awk '{print $1}') para testar."
exit 0
cd ..

