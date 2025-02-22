# Configurando um Controlador de Domínio com Samba no Debian 12
![Controlador de domínio com SAMBA](imagens/domain-controller.webp)

Este guia detalha o processo de configuração de um Controlador de Domínio (DC) utilizando o Samba no Debian 12. O Samba permite a implementação de um Active Directory (AD) compatível com o Windows, fornecendo autenticação centralizada para usuários e dispositivos.

## Requisitos
- Servidor com Debian 12 instalado
- Acesso root ou privilégios de sudo
- Conectividade de rede estável
- Nome de domínio definido (exemplo: `meudominio.local`)
- IP fixo configurado

## 1. Alterar o nome do host
```bash
sudo nano /etc/hostname
```

## 2. Atualizar o Sistema
```sh
sudo apt update && sudo apt upgrade -y
```

## 3. Instalar Dependências
```sh
sudo apt install samba smbclient winbind libnss-winbind libpam-winbind krb5-user krb5-config acl attr -y
```
Durante a instalação, configure o Kerberos:
- Domínio REALM: `MEUDOMINIO.LOCAL`  
![default-kerberos](imagens/default-kerberos.png)
  
- Servidor KDC: `meudc.meudominio.local`
- Servidor de Admin: `meudc.meudominio.local`

## 4. Configurar o Samba
Pare os serviços do Samba antes da configuração:
```sh
sudo systemctl stop smbd nmbd winbind
```
Renomeie o arquivo de configuração padrão:
```sh
mv /etc/samba/smb.conf /etc/samba/smb.conf.bkp
```
Inicie a configuração do DC:
```sh
sudo samba-tool domain provision --use-rfc2307 --interactive
```
Parâmetros importantes:
- Nome do Domínio: `MEUDOMINIO`
- Nome NETBIOS: `MEUDOMINIO`
- Caminho do banco de dados: `/var/lib/samba`
- Configuração de DNS: `BIND9_DLZ`

## 5. Configurar o DNS
Edite `/etc/resolv.conf`:
```
nameserver 127.0.0.1
search meudominio.local
```
Teste a resolução de nomes:
```sh
dig meudominio.local
```

## 6. Habilitar e Iniciar os Serviços
```sh
sudo systemctl enable samba-ad-dc
sudo systemctl start samba-ad-dc
```
Verifique o status:
```sh
sudo systemctl status samba-ad-dc
```

## Passo 6: Criar Usuários e Administrar o Domínio
Criar um usuário:
```sh
samba-tool user create usuario --random-password
```
Promover um usuário a administrador:
```sh
samba-tool group addmembers "Domain Admins" usuario
```

## Conclusão
Agora o seu Debian 12 está configurado como um Controlador de Domínio utilizando o Samba. Os dispositivos podem ingressar no domínio e a administração pode ser feita via ferramentas do Samba ou clientes Windows.

### Recursos adicionais
- [Documentação Oficial do Samba](https://wiki.samba.org)
- [Guia de Troubleshooting](https://wiki.samba.org/index.php/Troubleshooting)
