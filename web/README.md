# Configurando um Servidor Web no Debian 12

Este guia descreve como instalar e configurar um servidor web no Debian 12 usando o Apache.

## Requisitos
Antes de começar, certifique-se de:
- Ter acesso root ou um usuário com privilégios de sudo.
- Ter uma conexão ativa com a internet.

## Instalação do Servidor Web
1. Atualize o sistema:
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

2. Instale o Apache:
   ```bash
   sudo apt install apache2 -y
   ```

## Configuração do Servidor Web
### 1 Verificar o Status do Serviço
Após a instalação, verifique se o serviço está rodando:
   ```bash
   sudo systemctl status apache2
   ```
   Para garantir que o serviço seja iniciado automaticamente com o sistema:
   ```bash
   sudo systemctl enable apache2
   ```

### 2 Configurar Firewall
Se estiver usando o UFW, permita o tráfego HTTP e HTTPS:
   ```bash
   sudo ufw allow 'Apache Full'
   sudo ufw enable
   ```

### 3 Testar a Instalação
Abra um navegador e digite o endereço do servidor:
   ```
   http://seu_ip_servidor
   ```
   Você deve ver a página padrão do Apache.

## Configuração Avançada
Se desejar hospedar um site personalizado, edite o arquivo de configuração do Virtual Host:
   ```bash
   sudo nano /etc/apache2/sites-available/000-default.conf
   ```
   Modifique a diretiva `DocumentRoot` para apontar para seu diretório web personalizado:
   ```bash
   DocumentRoot /var/www/meusite
   ```
   Salve e reinicie o Apache:
   ```bash
   sudo systemctl restart apache2
   ```

## Solução de Problemas
- Se o serviço não iniciar, verifique os logs:
  ```bash
  sudo journalctl -xe | grep apache2
  ```
- Certifique-se de que nenhuma outra aplicação está ocupando a porta 80.
- Verifique permissões e propriedade dos arquivos em `/var/www/html/`.

## Referências
- [Documentação oficial do Apache](https://httpd.apache.org/docs/2.4/)


