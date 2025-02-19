# Servidor Proxy (Squid) no Debian 12
![Infra](imagens/squid.webp)

Este guia fornece instruções para instalar e configurar o servidor proxy Squid no Debian 12. O Squid é um proxy HTTP altamente configurável usado para otimização de rede, cache de conteúdo e controle de acesso.

## Requisitos
- Debian 12 instalado e atualizado.
- Permissões de superusuário (root ou sudo).

## Instalação do Squid
1. Atualize o sistema:
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

2. Instale o Squid:
   ```bash
   sudo apt install squid -y
   ```

3. Verifique a versão instalada:
   ```bash
   squid -v
   ```

## Configuração Básica
1. Edite o arquivo de configuração do Squid:
   ```bash
   sudo nano /etc/squid/squid.conf
   ```

2. Exemplo de configuração:
   ```
   # Porta Squid (Altere se necessário)
   # Define a porta em que o Squid escutará conexões HTTP.
   http_port 3128

   # Configuração para Autenticação  
   # Estas linhas configuram a autenticação básica no Squid usando um arquivo de senhas.   
   auth_param basic program /usr/lib/squid/basic_ncsa_auth /etc/squid/passwd  # Define o programa de autenticação  
   auth_param basic realm Squid                                               # Mensagem exibida no prompt de autenticação  
   auth_param basic credentialsttl 30 minutes                                 # Tempo de cache das credenciais (evita solicitar senha com muita frequência)  

   # Configuração de Cache
   cache_mem 1000 MB
   maximum_object_size 100 MB
   minimum_object_size 10 kB
   cache_dir ufs /var/spool/squid 2048 16 256
   cache_access_log /var/log/squid/access.log

   # Máquinas Liberadas
   #acl liberados src 10.200.0.1
   #cache_access allow liberados

   # Bloqueios 
   acl bloqueados dstdomain "/etc/squid/bloqueados" # Cria uma ACL chamada "bloqueados" com domínios listados no arquivo "/etc/squid/bloqueados"    
   http_access deny bloqueados                      # Bloqueia acesso aos domínios especificados na ACL "bloqueados"

   # Bloqueio de Downloads  
   # As linhas abaixo definem um bloqueio para downloads baseado em expressões regulares,  
   # verificando URLs listadas no arquivo "/etc/squid/bloqueio_downloads".  
   # Como estão comentadas, o bloqueio de downloads não está ativado.
   acl bloqueio_downloads url_regex -i "/etc/squid/bloqueio_downloads"
   http_access deny bloqueados_downloads

   acl home.lan src 10.200.0.0/8 # Define uma ACL chamada "home.lan" para a rede 10.200.0.0/8  
   http_access allow localhost   # Permite acesso irrestrito à máquina local (localhost) 
   
   # Autenticação com senha
   # Essas linhas configurariam a autenticação via proxy, exigindo credenciais.  
   acl password proxy_auth REQUIRED
   http_access allow password
   
   http_access allow home.lan # Permite acesso irrestrito à rede "home.lan" 
   http_access deny all       # Bloqueia qualquer outro acesso que não tenha sido explicitamente permitido acima  

   ```  

3. Crie uma arquivo `bloqueados`:
   ```
   sudo nano /etc/squid/bloqueados
   ```
   
4. Insira as seguintes linhas (Por exemplo):  
    ```bash
    .facebook.com
    .youtube.com
    ```   

5. Crie uma arquivo `bloqueio_downloads`:
   ```
   sudo nano /etc/squid/bloqueio_downloads
   ```
   
6. Insira as seguintes linhas (Por exemplo):
   ```
   \.mp4
   \.mp3
   \.exe
   ```

7. Reinicie o Squid para aplicar as alterações:
   ```
   sudo systemctl restart squid
   ```

## Gerenciamento do Squid
- Verifique o status do Squid:
  ```bash
  sudo systemctl status squid
  ```
- Habilite a inicialização automática:
  ```bash
  sudo systemctl enable squid
  ```
- Para recarregar a configuração sem reiniciar:
  ```bash
  sudo systemctl reload squid
  ```
- Para verificar logs:
  ```bash
  sudo tail -f /var/log/squid/access.log
  ```

## Testando o Proxy
1. Configure um navegador ou cliente para usar o proxy com o IP do servidor e a porta configurada (padrão: 3128).
2. Teste o acesso a um site e verifique os logs com:
   ```bash
   sudo tail -f /var/log/squid/access.log
   ```
   
## Conclusão
O Squid é uma ferramenta poderosa para gerenciamento de tráfego de rede, controle de acesso e cache. Com essas configurações básicas, é possível iniciar um proxy funcional e adaptá-lo conforme as necessidades da sua rede.


