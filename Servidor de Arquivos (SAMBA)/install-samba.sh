#!/bin/bash

set -e

# Definição de variáveis
SHARE_NAME="compartilhado"
SHARE_PATH="/srv/$SHARE_NAME"
SAMBA_USER="usuario"
CONFIG_FILE="/etc/samba/smb.conf"
BACKUP_FILE="/etc/samba/smb.conf.bak"

# Função para exibir mensagens formatadas
log() {
    echo -e "\e[1;32m[INFO] $1\e[0m"
}

log "Atualizando o sistema..."
sudo apt update && sudo apt upgrade -y

log "Instalando o Samba..."
# Os pacotes 'smbclient cifs-utils' são opcionais
sudo apt install samba smbclient cifs-utils -y

log "Fazendo backup do arquivo de configuração original..."
sudo cp "$CONFIG_FILE" "$BACKUP_FILE"

log "Configurando o compartilhamento Samba..."
echo "
[global]
workgroup = Linux
log file = /var/log/samba/log.%m
syslog = 0
server role = standalone server
map to guest = bad user

[$SHARE_NAME]
    path = $SHARE_PATH
    browseable = yes
    writable = yes
    valid users = $SAMBA_USER
" | sudo tee -a "$CONFIG_FILE" > /dev/null

log "Criando diretório compartilhado e ajustando permissões..."
sudo mkdir -p "$SHARE_PATH"
sudo chmod 2775 "$SHARE_PATH"
#sudo chown nobody:nogroup "$SHARE_PATH"

log "Criando usuário Samba..."
if ! id "$SAMBA_USER" &>/dev/null; then
    sudo adduser --disabled-password --gecos "" "$SAMBA_USER"
fi
sudo smbpasswd -a "$SAMBA_USER"

log "Reiniciando o serviço Samba..."
sudo systemctl restart smbd
sudo systemctl enable smbd

log "Configurando o firewall para permitir Samba..."
sudo ufw allow samba

log "Configuração do servidor Samba concluída com sucesso!"

