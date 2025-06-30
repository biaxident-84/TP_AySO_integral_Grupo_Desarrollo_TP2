#!/bin/bash

# 1. Generar claves SSH si no existen
if [ ! -f ~/.ssh/id_rsa ]; then
    echo "Generando claves SSH..."
    ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
    echo "Claves SSH generadas."
else
    echo "Las claves SSH ya existen."
fi

# 2. Copiar la clave pública al host destino
#    Asegúrate de que las IPs en el Vagrantfile sean correctas (192.168.56.10 para testing, 192.168.56.20 para produccion)

# Detectar el nombre de la máquina actual
HOSTNAME=$(hostname)

if [ "$HOSTNAME" == "vmTesting" ]; then
    DESTINO_IP="192.168.56.20" # IP de la VM produccion
    DESTINO_NOMBRE="produccion"
    echo "Copiando clave pública de vmTesting a vmProduccion..."
elif [ "$HOSTNAME" == "produccion" ]; then
	#Establesco la ip estatica en fedora
    sudo nmcli connection modify enp0s8 ipv4.addresses 192.168.56.20/24
    sudo nmcli connection modify enp0s8 ipv4.gateway 192.168.56.1
    sudo nmcli connection modify enp0s8 ipv4.method manual
    sudo nmcli connection down enp0s8 && sudo nmcli connection up enp0s8

    DESTINO_IP="192.168.56.10" # IP de la VM testing
    DESTINO_NOMBRE="testing"
    echo "Copiando clave pública de vmProduccion a vmTesting..."
else
    echo "Error: Hostname desconocido. No se puede determinar el destino SSH."
    exit 1
fi


# Añadir un breve retraso para asegurar que la otra VM esté completamente lista para recibir conexiones SSH
sleep 10

sudo ssh-copy-id -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null vagrant@$DESTINO_IP
