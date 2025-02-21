# Controlador de Domínio com Samba

Este documento descreve como configurar um **Controlador de Domínio (DC)** usando o **Samba** em um ambiente Linux. O Samba permite a implementação de um servidor **Active Directory (AD)** compatível com Windows, facilitando a autenticação centralizada e a gestão de usuários em redes corporativas.

## Requisitos
- Servidor Linux (Ubuntu/Debian, CentOS/RHEL, etc.)
- Pacotes necessários: Samba, Kerberos, Winbind, DNS
- Acesso root ou privilégios administrativos

## Instalação do Samba
```bash
sudo apt update && sudo apt install samba smbclient samba-dsdb-modules samba-vfs-modules winbind libnss-winbind libpam-winbind krb5-user
```

## Configuração do Kerberos
Edite o arquivo **/etc/krb5.conf**:
```ini
[libdefaults]
default_realm = EXEMPLO.LOCAL
dns_lookup_realm = false
dns_lookup_kdc = true
```

## Provisionamento do Domínio
```bash
sudo samba-tool domain provision --use-rfc2307 --interactive
```
Durante o processo, forneça:
- Nome do domínio (exemplo.local)
- Nome NetBIOS do domínio (EXEMPLO)
- Senha do administrador do domínio

## Configuração do DNS
Para usar o Samba como servidor DNS interno:
```bash
sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved
sudo rm /etc/resolv.conf
```
Crie um novo **/etc/resolv.conf**:
```ini
nameserver 127.0.0.1
search exemplo.local
```

## Iniciar os Serviços
```bash
sudo systemctl enable --now samba winbind
```
Verifique o status:
```bash
sudo systemctl status samba winbind
```

## Teste da Configuração
Autentique-se no domínio:
```bash
kinit administrator@EXEMPLO.LOCAL
```
Verifique a conectividade:
```bash
smbclient -L localhost -U administrator
```

## Adicionando um Cliente Windows ao Domínio
1. No Windows, acesse **Configurações > Sistema > Sobre**
2. Clique em **Alterar configurações** > **Mudar...**
3. Selecione **Domínio** e insira `EXEMPLO.LOCAL`
4. Insira as credenciais do administrador do domínio
5. Reinicie o computador

## Conclusão
Após seguir esses passos, seu Samba estará funcionando como um Controlador de Domínio, permitindo a autenticação centralizada de usuários e dispositivos em sua rede.


