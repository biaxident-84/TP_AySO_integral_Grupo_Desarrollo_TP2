#!/bin/bash

# Obtener el directorio donde está este script
DIR_SCRIPT="$(cd "$(dirname "$0")" && pwd)"

# ===============================
# 1. Ejecutar Ansible Playbook
# ===============================
INVENTORY_PATH="$DIR_SCRIPT/ansible/inventory/hosts"
PLAYBOOK_PATH="$DIR_SCRIPT/ansible/playbook.yml"

echo "▶ Ejecutando playbook de Ansible..."
ansible-playbook -i "$INVENTORY_PATH" "$PLAYBOOK_PATH"
ANSIBLE_EXIT=$?

# ===============================
# 2. Ejecutar alta_usuarios.sh
# ===============================
echo "▶ Ejecutando alta_usuarios.sh..."
bash "$DIR_SCRIPT/Bash_script/alta_usuarios/alta_usuarios.sh"
USERS_EXIT=$?

# ===============================
# 3. Ejecutar check_URL.sh
# ===============================
echo "▶ Ejecutando check_URL.sh..."
bash "$DIR_SCRIPT/Bash_script/check_url/check_URL.sh"
CHECK_EXIT=$?

# ===============================
# 4. Mostrar resultados de check_URL
# ===============================
echo "<dcc2> Estructura de logs:"
tree "$DIR_SCRIPT/Bash_script/check_url/logs" || echo " No se pudo mostrar el árbol de logs"

echo -e "\n<dcc4> Contenido de google/status.log:"
cat "$DIR_SCRIPT/Bash_script/check_url/logs/google/status.log" || echo " Archivo no encontrado."

echo -e "\n<dcc4> Contenido de noexiste/status.log:"
cat "$DIR_SCRIPT/Bash_script/check_url/logs/noexiste/status.log" || echo " Archivo no encontrado."

# ===============================
# 5. Evaluar salidas
# ===============================
if [[ $ANSIBLE_EXIT -eq 0 && $USERS_EXIT -eq 0 && $CHECK_EXIT -eq 0 ]]; then
    echo -e "\n Todos los procesos se ejecutaron correctamente."
    exit 0
else
    echo -e "\n Alguno de los procesos falló."
    exit 1
fi
