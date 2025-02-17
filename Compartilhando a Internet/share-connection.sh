#!/bin/bash

# Verifica se o usuário é root
if [ "$EUID" -ne 0 ]; then
  echo "Por favor, execute como root"
  exit 1
fi

# Lista interfaces de rede disponíveis
echo "Detectando interfaces de rede disponíveis..."
ip -o link show | awk -F': ' '{print $2}' | grep -v "lo"

# Solicita ao usuário a interface interna
read -p "Digite o nome da interface interna (LAN): " INTERFACE_INTERNA
if ! ip link show "$INTERFACE_INTERNA" &>/dev/null; then
  echo "Erro: Interface '$INTERFACE_INTERNA' não encontrada!"
  exit 1
fi

# Solicita ao usuário a interface externa
read -p "Digite o nome da interface externa (WAN): " INTERFACE_EXTERNA
if ! ip link show "$INTERFACE_EXTERNA" &>/dev/null; then
  echo "Erro: Interface '$INTERFACE_EXTERNA' não encontrada!"
  exit 1
fi

# Configurações de rede
read -p "Digite o endereço IP para $INTERFACE_INTERNA: " IP_INTERNO
read -p "Digite a máscara de rede (ex: 255.255.255.0): " MASCARA
read -p "Digite a rede: " REDE
read -p "Digite o broadcast: " BROADCAST

echo "Configurando interface de rede $INTERFACE_INTERNA..."
cat <<EOF > /etc/network/interfaces
auto $INTERFACE_INTERNA
iface $INTERFACE_INTERNA inet static
    address $IP_INTERNO
    netmask $MASCARA
    network $REDE
    broadcast $BROADCAST
EOF

echo "Reiniciando interface de rede..."
systemctl restart networking

# Verifica se o iptables está instalado
echo "Verificando se o iptables está instalado..."
if ! command -v iptables &>/dev/null; then
  echo "iptables não encontrado! Instalando..."
  apt update && apt install -y iptables
else
  echo "iptables já está instalado."
fi

echo "Habilitando roteamento..."
sysctl -w net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p

echo "Configurando NAT com iptables..."
iptables -t nat -A POSTROUTING -o $INTERFACE_EXTERNA -j MASQUERADE
iptables -A FORWARD -i $INTERFACE_INTERNA -o $INTERFACE_EXTERNA -j ACCEPT
iptables -A FORWARD -i $INTERFACE_EXTERNA -o $INTERFACE_INTERNA -m state --state RELATED,ESTABLISHED -j ACCEPT

echo "Salvando regras do iptables..."
iptables-save > /etc/iptables.rules

echo "Adicionando regras ao /etc/network/interfaces para restaurar no boot..."
cat <<EOF >> /etc/network/interfaces

# Aplicar regras do iptables no boot
pre-up iptables-restore < /etc/iptables.rules
EOF

echo "Reiniciando o serviço de rede..."
systemctl restart networking

echo "Testando conexão com a Internet..."
ping -c 4 8.8.8.8

echo "Configuração concluída com sucesso!"

