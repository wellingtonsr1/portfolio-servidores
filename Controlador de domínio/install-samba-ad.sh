#!/bin/bash
# ---------------------------------------------------
# Script Profissional para Instalação do Samba AD
# Autor: [Seu Nome]
# Descrição: Instala e configura um Controlador de Domínio Samba no Debian 10
# Versão: 1.0
# ---------------------------------------------------

# Definição de Variáveis
DOMINIO="exemplo.com"
NETBIOS="EXEMPLO"
SENHA_ADMIN="SenhaForte!" # Substitua por uma senha segura
LOG="/var/log/samba_install.log"
DEBIAN_FRONTEND=noninteractive

# Função para verificar erros e registrar logs
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

log_info "Iniciando a instalação do Samba AD no Debian 10..."

# Atualização do sistema
log_info "Atualizando pacotes do sistema..."
apt update && apt upgrade -y || log_error "Falha ao atualizar pacotes."

# Instalação dos pacotes necessários
log_info "Instalando pacotes necessários..."
apt install -y samba smbclient krb5-user winbind libnss-winbind libpam-winbind dnsutils acl attr || log_error "Falha ao instalar pacotes."

# Parando serviços antes da configuração
log_info "Desativando serviços do Samba para configuração..."
systemctl stop smbd nmbd winbind || log_error "Falha ao parar os serviços."

# Backup de arquivos de configuração existentes
log_info "Realizando backup dos arquivos de configuração antigos..."
[ -f /etc/samba/smb.conf ] && mv /etc/samba/smb.conf /etc/samba/smb.conf.bkp
[ -f /etc/krb5.conf ] && mv /etc/krb5.conf /etc/krb5.conf.bkp

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
systemctl enable samba-ad-dc
systemctl start samba-ad-dc || log_error "Falha ao iniciar o serviço Samba AD DC."

# Verificação da configuração do domínio
log_info "Validando a instalação..."
samba-tool domain info 127.0.0.1 || log_error "Falha ao validar o domínio Samba."

log_info "Instalação concluída com sucesso! O Samba AD está operacional."

log_info "Para adicionar usuários, utilize o seguinte comando:"
log_info "samba-tool user create <usuario> <senha> --must-change-at-next-login"

exit 0

