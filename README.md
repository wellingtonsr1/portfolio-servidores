# Infraestrutura de Redes e Serviços  

Este repositório contém configurações e scripts para a implementação de diversos serviços essenciais em um ambiente de rede, utilizando servidores Linux.  

Estrutura do Repositório  
------------------------

- `Compartilhando a Internet`: Configuração de NAT e compartilhamento de conexão com a Internet para a rede interna.  
- `Controlador de domínio`: Implementação de um servidor de domínio (Active Directory ou Samba AD) para gerenciamento centralizado de usuários e permissões.  
- `Servidor DHCP`: Configuração de um servidor DHCP para atribuição automática de endereços IP na rede.  
- `Servidor DNS`: Configuração de um servidor DNS para resolução de nomes dentro da rede local e/ou internet.  
- `Firewall`: Regras de firewall (usando `iptables` ou `ufw`) para proteção e controle de tráfego na rede.  
- `Servidor de banco de dados (MariaDB)`: Configuração de um servidor de banco de dados MariaDB para armazenamento e gerenciamento de dados.  
- `Servidor de Arquivos (SAMBA)`: Configuração de um servidor Samba para compartilhamento de arquivos entre usuários na rede.  
- `Servidor Proxy (Squid)`: Configuração de um servidor proxy Squid para controle de acesso e cache de navegação na web.  
- `Servidor WEB (Apache)`: Configuração de um servidor web (Apache, Nginx, etc.) para hospedagem de sites e aplicações.  

Como Utilizar:  
--------------
Cada diretório contém scripts e arquivos de configuração para facilitar a implementação dos serviços. 
Consulte o `README.md` dentro de cada pasta para mais detalhes sobre instalação e configuração específicas.  

Referências:  
------------

- [Documentação Oficial do Debian](https://www.debian.org/doc/)  
- [Guia de Administração de Redes Linux](https://wiki.archlinux.org/)  


