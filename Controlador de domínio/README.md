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

## 2. Configurar interface de rede...
```bash
sudo nano /etc/network/interface
```
![conf de interfaces](imagens/interfaces.png)  

## 3. Reiniciar o serviço de rede
```bash
sudo systemctl restart networking
```
![restart interfaces](imagens/restart-net.png) 

## 4. Checando os IPs
```bash
ip -4 a
```

## 5. Atualizar o Sistema
```bash
sudo apt update && sudo apt upgrade -y
```

## 6. Instalar o samba e suas dependências
```sh
sudo apt install samba smbclient winbind libnss-winbind libpam-winbind krb5-user krb5-config acl attr -y
```
Durante a instalação, configure o Kerberos:
- Domínio REALM: `MEUDOMINIO.COM.BR`  
![default-kerberos](imagens/default-kerberos.png)
  
- Servidor KDC: `meudc.meudominio.com.br`  
![kerberos-servers](imagens/kerberos-servers.png)

- Servidor de Admin: `meudc.meudominio.com.br`  
![administrative-server](imagens/administrative-server.png)  

## 7. Configurar o Samba
Pare os serviços do Samba antes da configuração:
```sh
sudo systemctl stop smbd nmbd winbind
```
Renomeie o arquivo de configuração padrão:
```sh
sudo mv /etc/samba/smb.conf /etc/samba/smb.conf.old
```  
![backup-smbd](imagens/backup-smbd.png)

Inicie a configuração do DC:
```sh
sudo samba-tool domain provision --use-rfc2307 --interactive
```
Parâmetros importantes:
- Realm: "domínio"
- Domain ["domínio"]:
- Server role...[DC]: `<ENTER>`
- DNS backend...[SAMBA_INTERNAL]: `<ENTER>`
- DNS forwarder...[8.8.8.8]: 10.200.0.2
- Administrator password: `<SENHA-FORTE>`
- Retype password: `<SENHA-FORTE>`

## 8. Checando o conteúdo do smb.conf
```bash
cat /etc/samba/smb.conf
```

## 9. Configurar o DNS
Edite `/etc/resolv.conf`:
```
nameserver 127.0.0.1
search meudominio.local
```

## 10. Copiar o arquivo krb5.conf
```bash
sudo cp /var/lib/samba/private/krb5.conf /etc
```

## 11. Mudando o nome do serviço do samba para samba-ad-dc
```bash
sudo systemctl stop smbd nmbd winbind
sudo systemctl disable smbd nmbd winbind
sudo systemctl unmask samba-ad-dc
sudo systemctl start samba-ad-dc
sudo systemctl enable samba-ad-dc
```

## 12. Consultando o status do serviço
```bash
sudo smbclient -L localhost -U%
```

## 13. Exibir o domínio
```bash
sudo samba-tool domain level show
```

## 14. Exibir informações do nosso servidor
```bash
sudo samba-tool domain info 10.200.0.2
```

## 15. Teste a resolução de nomes:
```sh
dig meudominio.local
```

## 16. Habilitar e Iniciar os Serviços
```sh
sudo systemctl enable samba-ad-dc
sudo systemctl start samba-ad-dc
```
Verifique o status:
```sh
sudo systemctl status samba-ad-dc
```

## 17. Criar Usuários e Administrar o Domínio
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
