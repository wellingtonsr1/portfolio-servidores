#!/bin/bash

# Script para instalação e configuração do servidor DHCP no Debian 12
# Autor: wellington
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

log "Instalando o servidor DHCP..."
apt install -y isc-dhcp-server

log "Configurando a interface de rede..."
INTERFACE="eth0"
echo "INTERFACESv4=\"$INTERFACE\"" > /etc/default/isc-dhcp-server

log "Realizando backup do arquivo de configuração DHCP..."
if [ -f /etc/dhcp/dhcpd.conf ]; then
    cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.old
    log "Backup criado em /etc/dhcp/dhcpd.conf.old"
else
    log "Arquivo dhcpd.conf não encontrado, criando novo."
fi

log "Criando configuração padrão do DHCP..."
cat <<EOF > /etc/dhcp/dhcpd.conf
subnet 192.168.1.0 netmask 255.255.255.0 {
    range 192.168.1.100 192.168.1.200;
    option routers 192.168.1.1;
    option domain-name-servers 8.8.8.8, 8.8.4.4;
    default-lease-time 600;
    max-lease-time 7200;
}
EOF

log "Habilitando e iniciando o serviço DHCP..."
systemctl enable isc-dhcp-server
systemctl restart isc-dhcp-server

log "Verificando status do servidor DHCP..."
systemctl status isc-dhcp-server --no-pager

log "Servidor DHCP instalado e configurado com sucesso!"
exit 0

