#!/bin/bash

# Atualizar sistema
echo "Atualizando sistema..."
sudo apt update && sudo apt upgrade -y

# Instalar Squid
echo "Instalando Squid..."
sudo apt install squid -y

# Configurar Squid
echo "Configurando Squid..."
CONFIG_FILE="/etc/squid/squid.conf"
BLOCKED_SITES_FILE="/etc/squid/blocked_sites.txt"

# Criar backup da configuração original
sudo cp $CONFIG_FILE ${CONFIG_FILE}.bak

# Definir configurações básicas
echo "Configurando rede local e porta..."
echo "acl rede_local src 192.168.1.0/24" | sudo tee -a $CONFIG_FILE
echo "http_access allow rede_local" | sudo tee -a $CONFIG_FILE

echo "Definindo porta padrão..."
echo "http_port 3128" | sudo tee -a $CONFIG_FILE

# Criar lista de sites bloqueados
echo "Criando lista de sites bloqueados..."
echo -e "facebook.com\nyoutube.com" | sudo tee $BLOCKED_SITES_FILE

echo "Configurando bloqueio de sites..."
echo "acl sites_proibidos dstdomain \"$BLOCKED_SITES_FILE\"" | sudo tee -a $CONFIG_FILE
echo "http_access deny sites_proibidos" | sudo tee -a $CONFIG_FILE

# Reiniciar o Squid para aplicar configurações
echo "Reiniciando Squid..."
sudo systemctl restart squid

# Habilitar inicialização automática
echo "Habilitando inicialização automática..."
sudo systemctl enable squid

echo "Squid instalado e configurado com sucesso!"

