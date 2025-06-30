#!/bin/bash
clear

#############################################
# Parámetros:
#   $1: Archivo con la lista de dominios y URLs
#
# Tareas:
#   - Leer la lista (ignorando líneas con '#')
#   - Verificar el código HTTP de cada URL
#   - Guardar los logs en un archivo general
#   - Guardar logs individuales por dominio
#   - Crear estructura de directorios en /tmp/head-check
#############################################

LISTA=$1
LOG_GENERAL="/var/log/status_url.log"
ANT_IFS=$IFS
IFS=$'\n'

# Crear estructura de directorios en una sola línea
mkdir -p /tmp/head-check/{ok,Error/{cliente,servidor}}

# Verificar que se haya recibido un archivo válido
if [ ! -f "$LISTA" ]; then
  echo "Error: No se encontró el archivo $LISTA"
  exit 1
fi

for LINEA in $(grep -v '^#' "$LISTA"); do
  DOMINIO=$(echo "$LINEA" | awk '{print $1}')
  URL=$(echo "$LINEA" | awk '{print $2}')

  # Obtener código HTTP
  STATUS_CODE=$(curl -LI -o /dev/null -w '%{http_code}\n' -s "$URL")

  # Obtener timestamp
  TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

  # Log general
  echo "$TIMESTAMP - Code:$STATUS_CODE - $DOMINIO - URL:$URL" | sudo tee -a "$LOG_GENERAL" > /dev/null

  # Log por dominio en carpeta logs/
  mkdir -p "./logs/$DOMINIO"
  echo "$TIMESTAMP - Code:$STATUS_CODE - URL:$URL" >> "./logs/$DOMINIO/status.log"

  # Log según código en /tmp/head-check
  if [ "$STATUS_CODE" -eq 200 ]; then
    echo "$TIMESTAMP - Code:$STATUS_CODE - URL:$URL" >> "/tmp/head-check/ok/$DOMINIO.log"
  elif [[ "$STATUS_CODE" -ge 400 && "$STATUS_CODE" -lt 500 ]]; then
    echo "$TIMESTAMP - Code:$STATUS_CODE - URL:$URL" >> "/tmp/head-check/Error/cliente/$DOMINIO.log"
  elif [[ "$STATUS_CODE" -ge 500 && "$STATUS_CODE" -lt 600 ]]; then
    echo "$TIMESTAMP - Code:$STATUS_CODE - URL:$URL" >> "/tmp/head-check/Error/servidor/$DOMINIO.log"
  fi
done

IFS=$ANT_IFS

