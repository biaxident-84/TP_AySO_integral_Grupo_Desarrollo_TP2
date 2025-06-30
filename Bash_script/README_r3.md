---

## Scripts desarrollados

### 1. `alta_usuarios.sh`
- Crea usuarios automáticamente leyendo desde `Lista_Usuarios.txt`.
- Asigna contraseña encriptada, shell, grupo y nombre del usuario.
- Verifica si el archivo existe antes de ejecutar.

### 2. `check_URL.sh`
- Lee la lista de dominios y URLs desde `Lista_URL.txt`.
- Realiza un `curl` a cada URL para obtener el código HTTP.
- Registra:
  - Log general en `/var/log/status_url.log`.
  - Log individual por dominio en `logs/$DOMINIO/status.log`.

---

## Comandos clave utilizados
- `curl` para obtener el status code.
- `awk` para procesar columnas.
- `mkdir -p` para crear directorios de forma recursiva.
- `sudo tee -a` para logear de forma segura en archivos del sistema.
- `date` para timestamp en formato `YYYYMMDD_HHMMSS`.

---

## Notas
- El script ignora comentarios en las listas (`#` al inicio de línea).
- Se asegura que los archivos existan antes de procesarlos.

---

## Cómo ejecutar los scripts

1. Asignar permisos de ejecución:
```bash
chmod +x alta_usuarios.sh
chmod +x check_URL.sh
```

2. Ejecutar el script de alta de usuarios:

./alta_usuarios.sh Lista_Usuarios.txt vagrant


3. Ejecutar el script para verificar URLs:

./check_URL.sh Lista_URL.txt
#Para mostrar los resultados del script

tree /tmp/head-check/
cat /tmp/head-check/ok/google.log
cat /tmp/head-check/Error/cliente/noexiste.log

> Asegurarse de tener los archivos `Lista_Usuarios.txt` y `Lista_URL.txt` correctamente formateados y accesibles desde el mismo directorio.

