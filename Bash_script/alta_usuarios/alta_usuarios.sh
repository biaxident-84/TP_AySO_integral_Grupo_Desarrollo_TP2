#!/bin/bash
clear

##############################################
# Script para generar usuarios de forma masiva
#
# Parámetros esperados:
#   $1: Ruta al archivo de lista de usuarios
#       (formato: usuario:grupo en cada línea)
#   $2: Nombre del usuario base desde el cual se tomará la contraseña
#
# Lo que hace:
#   - Lee la lista ignorando comentarios (líneas que empiezan con #)
#   - Extrae usuario y grupo por cada línea
#   - Genera comandos para crear esos usuarios, 
#     asignando el mismo password del usuario base
##############################################

LISTA=$1
USUARIO_BASE=$2

# Se obtiene la clave encriptada del usuario base del archivo /etc/shadow
CLAVE=$(getent shadow "$USUARIO_BASE" | awk -F ':' '{print $2}')

# Se guarda el separador actual para restaurarlo luego
ANT_IFS=$IFS
IFS=$'\n'  # Se cambia el separador para recorrer línea por línea

# Recorre las líneas del archivo, ignorando las que empiezan con #
for LINEA in $(grep -v "^#" "$LISTA"); do
    USUARIO=$(echo "$LINEA" | awk -F ',' '{print $1}')  # Nombre de usuario
    GRUPO=$(echo "$LINEA" | awk -F ',' '{print $2}')    # Grupo al que pertenece
    # Se genera el comando que se usaría para crear al usuario
    echo "sudo useradd -m -s /bin/bash -g $GRUPO -p '$CLAVE' $USUARIO"
done

# Se vuelve al separador original
IFS=$ANT_IFS

