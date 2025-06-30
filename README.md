##############################################
# DOCUMENTACIÓN:
##############################################

SCRIPT MASTER:

Este script automatiza la ejecución y validación de tres componentes del proyecto:

- Un playbook de Ansible.

- Un script Bash para dar de alta usuarios.

- Un script Bash que verifica el estado de distintas URLs.

Al finalizar, evalúa si todas las ejecuciones fueron exitosas. Si alguna falla, retorna un código de salida 1, permitiendo a otros scripts o herramientas detectar errores automáticamente.

FUNCIONALIDAD

- Ejecuta el playbook ansible/playbook.yml con el inventario ubicado en ansible/inventory/hosts.

- Ejecuta el script alta_usuarios.sh desde su ruta correspondiente.

- Ejecuta check_URL.sh y analiza los logs generados por dominio.

- Muestra la estructura de carpetas de logs y el contenido de archivos específicos si existen.

- Evalúa los códigos de salida de cada paso:

- Si todos fueron exitosos, retorna exit 0.

- Si alguno falló, retorna exit 1.

REQUISITOS

- Ansible instalado.

- Archivos alta_usuarios.sh y check_URL.sh disponibles en las rutas esperadas.

- El inventario de Ansible correctamente configurado.

- El comando tree instalado para mostrar estructura de logs.

EJECUCIÓN

./Script-Master.sh

##############################################

SCRIPT CHECK:

Este script ejecuta el archivo script_master.sh, el cual corre tres procesos clave:

Playbook de Ansible

Alta de usuarios (alta_usuarios.sh)

Verificación de URLs (check_URL.sh)

Luego de la ejecución:

Lee un archivo temporal (resultado.tmp) generado por script_master.sh que contiene los códigos de salida de cada uno.

Muestra en consola qué scripts se ejecutaron correctamente y cuáles fallaron.

Informa un resumen global personalizado, listando únicamente los scripts que fallaron.

EJECUCIÓN:

./check.sh

