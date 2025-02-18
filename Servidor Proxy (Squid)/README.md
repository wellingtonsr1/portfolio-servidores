# Servidor Proxy (Squid) no Debian 12
![Infra](imagens/squid.png)

## Introdução
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

2. Exemplo de configuração para permitir acesso a uma rede específica (exemplo: 192.168.1.0/24):
   ```
   acl rede_local src 192.168.1.0/24
   http_access allow rede_local
   ```

3. Altere a porta padrão (se necessário):
   ```
   http_port 3128
   ```

4. Salve e saia do editor (Ctrl + X, depois Y e Enter).

5. Reinicie o Squid para aplicar as alterações:
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
     sudo nano /etc/squid/blocked_sites.txt
     ```
  2. Adicione domínios, um por linha, por exemplo:
     ```
     facebook.com
     youtube.com
     ```
  3. Edite o `squid.conf` e adicione:
     ```
     acl sites_proibidos dstdomain "/etc/squid/blocked_sites.txt"
     http_access deny sites_proibidos
     ```
  4. Reinicie o Squid:
     ```bash
     sudo systemctl restart squid
     ```

## Conclusão
O Squid é uma ferramenta poderosa para gerenciamento de tráfego de rede, controle de acesso e cache. Com essas configurações básicas, é possível iniciar um proxy funcional e adaptá-lo conforme as necessidades da sua rede.


