
FUNCIONES QUE REALIZAN LOS ARCHIVOS DE ANSIBLE

    - playbook.yml: archivo principal que ejecuta los roles sobre los hosts.

    - inventory/hosts: archivo que define las IPs y grupos de los hosts (VMs).

    - group_vars/*.yml: variables específicas para cada grupo (como nombre_grupo).

    - roles/: contiene los roles que organizan y reutilizan tareas.

TAREAS DE ROLES 

    - crear_grupos: crea los grupos necesarios para el sistema.

    - alta_usuarios: crea usuarios asignados a grupos específicos.

    - Sudoers_ayso_parcial: otorga permisos sudo sin contraseña al grupo ayso_parcial.

    - Instala-tools_ayso_parcial: instala herramientas requeridas por el entorno.

AUTOMATIZACION DE TAREAS

    - Cada rol se ejecuta en orden lógico (primero grupos, luego usuarios).

    - Se utilizan variables para que las tareas se adapten a cada grupo (por ejemplo, nombre_grupo).

    - Se crean usuarios con sus respectivos grupos primarios.

    - Se configura acceso sudo sin contraseña.



