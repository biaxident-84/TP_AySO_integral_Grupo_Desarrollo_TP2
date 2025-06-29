#!/bin/bash

# cruzar_claves_ssh.sh

# Generar clave SSH ed25519 si no existe
if [ ! -f ~/.ssh/id_ed25519 ]; then
    echo "[INFO] Generando clave SSH ed25519..."
    ssh-keygen -t ed25519 -N "" -f ~/.ssh/id_ed25519
    echo "[INFO] Clave generada en ~/.ssh/id_ed25519"
else
    echo "[INFO] La clave SSH ya existe en ~/.ssh/id_ed25519"
fi

# Definir destino según el hostname
HOSTNAME=$(hostname)

if [ "$HOSTNAME" == "vmTesting" ]; then
    DESTINO_IP="192.168.56.20"
    DESTINO_NOMBRE="produccion"
elif [ "$HOSTNAME" == "produccion" ]; then

    sudo nmcli connection modify "Wired connection 1" ipv4.addresses 192.168.56.20/24
    sudo nmcli connection modify "Wired connection 1" ipv4.gateway 192.168.56.1
    sudo nmcli connection modify "Wired connection 1" ipv4.method manual
    sudo nmcli connection down "Wired connection 1" && sudo nmcli connection up "Wired connection 1"

    DESTINO_IP="192.168.56.10"
    DESTINO_NOMBRE="testing"
else
    echo "[ERROR] Hostname desconocido. No se puede determinar el destino SSH."
    exit 1
fi

echo "[INFO] Intentando cruzar claves hacia $DESTINO_NOMBRE ($DESTINO_IP)"

# Comprobar conectividad
echo "[INFO] Verificando conectividad con $DESTINO_NOMBRE..."
ping -c 2 $DESTINO_IP > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "[ERROR] No hay respuesta desde $DESTINO_IP. ¿La otra VM está encendida?"
    exit 1
fi

# Esperar un poco más por si el servicio SSH demora
sleep 5

# Copiar clave pública con ssh-copy-id
echo "[INFO] Copiando clave pública a $DESTINO_NOMBRE ($DESTINO_IP)..."
ssh-copy-id -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null vagrant@$DESTINO_IP

if [ $? -eq 0 ]; then
    echo "[OK] Clave pública copiada correctamente a $DESTINO_NOMBRE."
else
    echo "[ERROR] Falló la copia de la clave pública."
    exit 1
fi