#!/bin/bash
# ---------------------------------------------------
# Script para Instalação do Samba AD no Debian 12
# Autor: Wellington
# Descrição: Instala e configura um Controlador de Domínio Samba no Debian 12
# Versão: 2.0
# ---------------------------------------------------

# Definição de Variáveis
DOMINIO="exemplo.com.br"       # Defina o nome do seu domínio
NETBIOS="EXEMPLO"              # Nome NetBIOS do domínio
SENHA_ADMIN="SenhaForte123!"   # Defina uma senha segura para o Administrador do Samba
LOG="/var/log/samba_install.log"
DEBIAN_FRONTEND=noninteractive

# Função para registrar logs
log_info() {
    echo -e "[INFO] $1" | tee -a $LOG
}

log_error() {
    echo -e "[ERRO] $1" | tee -a $LOG
    exit 1
}

# Verifica se o script está sendo executado como root
if [[ $EUID -ne 0 ]]; then
    log_error "Este script deve ser executado como root!"
fi

log_info "Iniciando a instalação do Samba AD no Debian 12..."

# Atualização do sistema
log_info "Atualizando pacotes do sistema..."
apt update && apt upgrade -y || log_error "Falha ao atualizar pacotes."

# Instalação dos pacotes necessários para o Samba AD
log_info "Instalando pacotes essenciais para o Samba AD..."
apt install -y samba krb5-user winbind libnss-winbind libpam-winbind acl attr resolvconf dnsutils || log_error "Falha ao instalar pacotes."

# Parando serviços antes da configuração
log_info "Parando serviços do Samba antes da configuração..."
systemctl stop smbd nmbd winbind || log_error "Falha ao parar os serviços."

# Backup de arquivos de configuração existentes
log_info "Realizando backup das configurações antigas..."
[ -f /etc/samba/smb.conf ] && mv /etc/samba/smb.conf /etc/samba/smb.conf.old
[ -f /etc/krb5.conf ] && mv /etc/krb5.conf /etc/krb5.conf.old

# Configuração do Samba como Controlador de Domínio
log_info "Configurando o Samba como Controlador de Domínio..."
samba-tool domain provision \
  --use-rfc2307 \
  --realm=$DOMINIO \
  --domain=$NETBIOS \
  --adminpass=$SENHA_ADMIN \
  --server-role=dc || log_error "Falha na configuração do Samba AD."

# Configuração do Kerberos
log_info "Ajustando configurações do Kerberos..."
ln -sf /var/lib/samba/private/krb5.conf /etc/krb5.conf || log_error "Falha ao configurar o Kerberos."

# Ativando e iniciando os serviços do Samba
log_info "Habilitando e iniciando serviços do Samba AD..."
systemctl unmask samba-ad-dc
systemctl enable samba-ad-dc
systemctl start samba-ad-dc || log_error "Falha ao iniciar o serviço Samba AD DC."

# Configuração do DNS no resolv.conf
log_info "Ajustando configurações de DNS..."
echo -e "nameserver 127.0.0.1\nsearch $DOMINIO" > /etc/resolv.conf

# Verificação da configuração do domínio
log_info "Validando a instalação..."
samba-tool domain info 127.0.0.1 || log_error "Falha ao validar o domínio Samba."

log_info "Instalação concluída com sucesso! O Samba AD está operacional."

log_info "Para adicionar usuários ao domínio, utilize o seguinte comando:"
log_info "samba-tool user create <usuario> --random-password --must-change-at-next-login"

exit 0

