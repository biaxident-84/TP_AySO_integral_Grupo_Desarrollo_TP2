#!/bin/bash

# -------------------------------------------------------------------
# cruzar_claves_y_config_ansible.sh
# -------------------------------------------------------------------

set -e

ANSIBLE_DIR="$HOME/ansible"
FEDORA_VM="produccion"
UBUNTU_VM="testing"
FEDORA_IP="192.168.56.20"
UBUNTU_IP="192.168.56.10"
FEDORA_USER="vagrant"

echo "Verificando que ambas VMs estén encendidas..."
check_and_up_vm() {
  vm_name="$1"
  status=$(vagrant status "$vm_name" | grep "$vm_name" | awk '{print $2}')
  if [ "$status" != "running" ]; then
    echo "Levantando VM $vm_name..."
    vagrant up "$vm_name"
  else
    echo "La VM $vm_name ya está corriendo."
  fi
}

check_and_up_vm "$FEDORA_VM"
check_and_up_vm "$UBUNTU_VM"

# -------------------------------------------------------------------
# 1. Generar clave SSH ed25519 si no existe
# -------------------------------------------------------------------
if [ ! -f ~/.ssh/id_ed25519 ]; then
    echo "Generando clave SSH ed25519..."
    ssh-keygen -t ed25519 -N "" -f ~/.ssh/id_ed25519
else
    echo "La clave SSH ed25519 ya existe."
fi

# -------------------------------------------------------------------
# 2. Ajuste de IP estática en Fedora, si corresponde
# -------------------------------------------------------------------
HOSTNAME=$(hostname)
if [ "$HOSTNAME" == "produccion" ]; then
    echo "Configurando IP estática en Fedora..."
    sudo nmcli connection modify "Wired connection 1" ipv4.addresses 192.168.56.20/24
    sudo nmcli connection modify "Wired connection 1" ipv4.gateway 192.168.56.1
    sudo nmcli connection modify "Wired connection 1" ipv4.method manual
    sudo nmcli connection down "Wired connection 1" && sudo nmcli connection up "Wired connection 1"
fi

# -------------------------------------------------------------------
# 3. Cruzar claves SSH entre las VMs
# -------------------------------------------------------------------
echo "Copiando clave pública a Fedora..."
ssh-copy-id -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null vagrant@$FEDORA_IP
echo "Copiando clave pública a Ubuntu..."
ssh-copy-id -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null vagrant@$UBUNTU_IP

# -------------------------------------------------------------------
# 4. Generar inventario dinámico Ansible
# -------------------------------------------------------------------
mkdir -p "$ANSIBLE_DIR/inventario"

echo "[servidores]" > "$ANSIBLE_DIR/inventario/hosts"

for vm in "$UBUNTU_VM" "$FEDORA_VM"; do
  ip=$(vagrant ssh-config "$vm" | grep HostName | awk '{print $2}')
  key=$(vagrant ssh-config "$vm" | grep IdentityFile | awk '{print $2}')
  echo "$ip ansible_user=vagrant ansible_ssh_private_key_file=$key" >> "$ANSIBLE_DIR/inventario/hosts"
done

echo "Inventario generado en $ANSIBLE_DIR/inventario/hosts"

# -------------------------------------------------------------------
# 5. Copiar claves privadas de Vagrant a Fedora
# -------------------------------------------------------------------
KEY_UBUNTU=$(vagrant ssh-config "$UBUNTU_VM" | grep IdentityFile | awk '{print $2}')
KEY_FEDORA=$(vagrant ssh-config "$FEDORA_VM" | grep IdentityFile | awk '{print $2}')

echo "Copiando claves privadas a Fedora..."
scp -i "$KEY_FEDORA" "$KEY_UBUNTU" "$FEDORA_USER@$FEDORA_IP:/home/$FEDORA_USER/.ssh/testing_id_rsa"
scp -i "$KEY_FEDORA" "$KEY_FEDORA" "$FEDORA_USER@$FEDORA_IP:/home/$FEDORA_USER/.ssh/produccion_id_rsa"

echo "Ajustando permisos e inventario interno en Fedora..."
ssh -i "$KEY_FEDORA" "$FEDORA_USER@$FEDORA_IP" <<EOF
chmod 600 /home/$FEDORA_USER/.ssh/testing_id_rsa /home/$FEDORA_USER/.ssh/produccion_id_rsa
mkdir -p /home/$FEDORA_USER/ansible/inventario
cat <<EOL > /home/$FEDORA_USER/ansible/inventario/hosts
[servidores]
$UBUNTU_IP ansible_user=vagrant ansible_ssh_private_key_file=/home/vagrant/.ssh/testing_id_rsa
$FEDORA_IP ansible_user=vagrant ansible_ssh_private_key_file=/home/vagrant/.ssh/produccion_id_rsa
EOL
EOF

echo ""
echo "Proceso completo. Puedes acceder a la VM Fedora con:"
echo "   vagrant ssh produccion"
echo ""
echo "Y luego ejecutar dentro de Fedora:"
echo "   cd ~/ansible"
echo "   ansible-playbook -i inventario/hosts playbook.yml"
echo ""
