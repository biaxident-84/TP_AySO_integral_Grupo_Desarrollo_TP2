#!/bin/bash
set -eux
# --- Configuración ---
TARGET_USER="vagrant"

check_command() {
    if [ $? -ne 0 ]; then
        echo "ERROR: $1 falló. Saliendo del script."
        exit 1
    fi
}

echo "Iniciando la configuración de Fedora..."

# 1. Actualizar el sistema
echo "---"
echo "Actualizando el sistema Fedora. Esto puede tardar unos minutos..."
sudo dnf install -y git
check_command "Actualización del sistema Fedora"

# 2. Instalar paquetes básicos
echo "---"
echo "Instalando paquetes básicos (tree, ansible, ca-certificates, curl)..."
sudo dnf install -y tree ansible ca-certificates curl
sudo dnf install git -y
check_command "Instalación de paquetes básicos"

echo "Todos los paquetes básicos instalados correctamente."

# 3. Instalación de Docker
echo "---"
echo "Eliminando posibles instalaciones anteriores de Docker..."
sudo dnf remove -y docker \
    docker-client \
    docker-client-latest \
    docker-common \
    docker-latest \
    docker-latest-logrotate \
    docker-logrotate \
    docker-engine \
    docker-selinux \
    docker-engine-selinux > /dev/null 2>&1 || true

echo "Instalando Docker con el script oficial..."
curl -fsSL https://get.docker.com -o get-docker.sh
check_command "Descarga del script oficial de Docker"

sudo sh get-docker.sh
check_command "Ejecución del script de instalación de Docker"

# Limpio el script descargado
rm -f get-docker.sh

echo "Habilitando e iniciando Docker..."
sudo systemctl enable --now docker
check_command "Habilitar e iniciar Docker"

# 4. Agregar usuario al grupo docker
echo "---"
echo "Agregando el usuario '$TARGET_USER' al grupo 'docker'..."
sudo usermod -aG docker $TARGET_USER
check_command "Agregar usuario al grupo docker"

# 5. Verificaciones finales
echo "---"
echo "Verificando versiones instaladas:"
ansible --version || echo "Ansible no encontrado."
tree --version || echo "Tree no encontrado."
docker --version || echo "Docker no encontrado."

echo "---"
echo "Script de instalación completado correctamente."
echo "Nota: el usuario '$TARGET_USER' debe cerrar y volver a abrir sesión para usar Docker sin sudo."

#Reseteamos Docker
sudo systemctml restart docker
sudo systemctml status docker
