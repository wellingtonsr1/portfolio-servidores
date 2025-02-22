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

## 17. Criar Usuários e Administrar o Domínio:
## **17.1 Usuários**
- Criar usários:
  ```bash
  samba-tool user create usuario123 SenhaForte!
  ```
- Listar usuários:  
  ```bash
  samba-tool user list
  ```
- Resetar senha de um usuário:  
  ```bash
  samba-tool user setpassword usuario123 --newpassword=NovaSenha!
  ```
- Definir que o usuário deve alterar a senha no próximo login:  
  ```bash
  samba-tool user setpassword usuario123 --must-change-at-next-login
  ```
- Criar grupos:  
  ```bash
  samba-tool group add TI
  ```
- Adicionar um usuário a um grupo:  
  ```bash
  samba-tool group addmembers TI usuario123
  ```
- Remover um usuário de um grupo:  
  ```bash
  samba-tool group removemembers TI usuario123
  ```
## **17.2. Administração de Domínio**
- Criar um novo domínio Samba AD:  
  ```bash
  samba-tool domain provision --realm=EXEMPLO.COM --domain=EXEMPLO --adminpass=SenhaForte! --server-role=dc
  ```
- Adicionar um novo controlador de domínio ao Samba AD:  
  ```bash
  samba-tool domain join EXEMPLO.COM DC -U"Administrador"
  ```
- Rebaixar um controlador de domínio:  
  ```bash
  samba-tool domain demote
  ```
- Listar controladores de domínio ativos:  
  ```bash
  samba-tool domain list
  ```

---

## **3. Gerenciamento de Replicação do AD**
- Forçar replicação entre DCs:  
  ```bash
  samba-tool drs replicate DC1 DC2 dc=exemplo,dc=com
  ```
- Listar status da replicação:  
  ```bash
  samba-tool drs showrepl
  ```
- Verificar a integridade da replicação:  
  ```bash
  samba-tool dbcheck --cross-ncs
  ```

---

## **4. Gerenciamento de DNS**
- Criar um novo registro DNS:  
  ```bash
  samba-tool dns add DC1 exemplo.com servidor A 192.168.1.10 -U administrador
  ```
- Listar registros DNS:  
  ```bash
  samba-tool dns query DC1 exemplo.com @ ALL -U administrador
  ```
- Remover um registro DNS:  
  ```bash
  samba-tool dns delete DC1 exemplo.com servidor A 192.168.1.10 -U administrador
  ```

---

## **5. Gerenciamento de Políticas de Segurança**
- Definir política de senha (exemplo: mínimo de 12 caracteres):  
  ```bash
  samba-tool domain passwordsettings set --min-pwd-length=12
  ```
- Verificar configurações de política de senha:  
  ```bash
  samba-tool domain passwordsettings show
  ```
- Bloquear um usuário:  
  ```bash
  samba-tool user disable usuario123
  ```
- Desbloquear um usuário:  
  ```bash
  samba-tool user enable usuario123
  ```

---

## **6. Administração de Group Policy Objects (GPO)**
- Criar uma nova GPO:  
  ```bash
  samba-tool gpo create "Bloqueio de USB" --description="Restringe uso de USB"
  ```
- Listar GPOs disponíveis:  
  ```bash
  samba-tool gpo list
  ```
- Aplicar GPO a uma unidade organizacional (OU):  
  ```bash
  samba-tool gpo set "<GPO_ID>" --apply-on="OU=TI,DC=exemplo,DC=com"
  ```

---

## **7. Gerenciamento de Chaves Kerberos**
- Listar chaves Kerberos no domínio:  
  ```bash
  samba-tool kerberos list
  ```
- Resetar chave da conta de máquina:  
  ```bash
  samba-tool domain passwordsettings set --complexity=off
  ```
- Exibir detalhes do ticket Kerberos:  
  ```bash
  klist -e
  ```

---

## **8. Auditoria e Diagnóstico**
- Verificar integridade da base de dados do AD:  
  ```bash
  samba-tool dbcheck --fix
  ```
- Verificar contas de serviço duplicadas:  
  ```bash
  samba-tool domain tombstones expunge
  ```
- Exibir informações detalhadas de um usuário:  
  ```bash
  samba-tool user show usuario123
  ```

---

## **9. Exportação e Backup**
- Exportar lista de usuários para JSON:  
  ```bash
  samba-tool user list --json > usuarios.json
  ```
- Fazer backup da configuração do domínio:  
  ```bash
  samba-tool domain backup online --targetdir=/backup/samba
  ```
- Restaurar backup:  
  ```bash
  samba-tool domain backup restore --backup-dir=/backup/samba
  ```

---

## **10. Gerenciamento de Compartilhamento de Arquivos**
- Criar um novo compartilhamento:  
  ```bash
  mkdir /srv/compartilhado
  chmod 777 /srv/compartilhado
  ```
  Adicionar ao arquivo `smb.conf`:  
  ```
  [Compartilhado]
  path = /srv/compartilhado
  read only = no
  guest ok = yes
  ```
  Aplicar mudanças:  
  ```bash
  systemctl restart smbd
  ```

---

## Conclusão
Agora o seu Debian 12 está configurado como um Controlador de Domínio utilizando o Samba. Os dispositivos podem ingressar no domínio e a administração pode ser feita via ferramentas do Samba ou clientes Windows.

### Recursos adicionais
- [Documentação Oficial do Samba](https://wiki.samba.org)
- [Guia de Troubleshooting](https://wiki.samba.org/index.php/Troubleshooting)
