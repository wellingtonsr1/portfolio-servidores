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
   http_port 3128

   # Configuração para Autenticação
   #auth_param basic program /usr/lib/squid3/basic_ncsa_auth /etc/squid/passwd
   #auth_param basic realm Squid
   #auth_param basic credentialsttl 30 minutes

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
   acl bloqueados url_regex -i "/etc/squid/bloqueados"
   http_access deny bloqueados

   # Bloqueio de Downloads
   #acl bloqueio_downloads url_regex -i "/etc/squid/bloqueio_downloads"
   #http_access deny bloqueados_downloads

   acl home.lan src 10.200.0.0/8
   http_access allow localhost
   #acl password proxy_auth REQUIRED
   #http_access allow password
   http_access allow home.lan
   http_access deny all

   ```



3. Salve e saia do editor (Ctrl + X, depois Y e Enter).

4. Reinicie o Squid para aplicar as alterações:
   ```bash
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

## Segurança e Controle de Acesso
- Para bloquear sites específicos:
  1. Crie um arquivo de sites bloqueados:
     ```bash
     sudo nano /etc/squid/bloqueados
     ```
  2. Adicione domínios, um por linha, por exemplo:
     ```
     facebook.com
     youtube.com
     ```
  3. Edite o `squid.conf` e adicione:
     ```
     acl sites_proibidos dstdomain "/etc/squid/bloqueados"
     http_access deny sites_proibidos
     ```
  4. Reinicie o Squid:
     ```bash
     sudo systemctl restart squid
     ```

## Conclusão
O Squid é uma ferramenta poderosa para gerenciamento de tráfego de rede, controle de acesso e cache. Com essas configurações básicas, é possível iniciar um proxy funcional e adaptá-lo conforme as necessidades da sua rede.


