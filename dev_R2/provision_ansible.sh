#!/bin/bash

# 🧾 Variables
ANSIBLE_DIR="$HOME/ansible"
FEDORA_VM="produccion"
UBUNTU_VM="testing"
FEDORA_IP="192.168.56.20"
FEDORA_USER="vagrant"

# 🔍 Función para verificar estado de la VM y levantarla si está apagada
check_and_up_vm() {
  vm_name="$1"
  status=$(vagrant status "$vm_name" | grep "$vm_name" | awk '{print $2}')
  if [ "$status" != "running" ]; then
    echo "🚀 Levantando VM $vm_name..."
    vagrant up "$vm_name"
  else
    echo "✅ VM $vm_name ya está corriendo."
  fi
}

echo "🖥️ Verificando estado de las VMs..."
check_and_up_vm "$UBUNTU_VM"
check_and_up_vm "$FEDORA_VM"

# 📁 Crear estructura de carpetas
mkdir -p "$ANSIBLE_DIR/inventario"
echo "[servidores]" > "$ANSIBLE_DIR/inventario/hosts"

echo "🔧 Generando inventario dinámico..."
for vm in "$UBUNTU_VM" "$FEDORA_VM"; do
  ip=$(vagrant ssh-config "$vm" | grep HostName | awk '{print $2}')
  key=$(vagrant ssh-config "$vm" | grep IdentityFile | awk '{print $2}')
  echo "$ip ansible_user=vagrant ansible_ssh_private_key_file=$key" >> "$ANSIBLE_DIR/inventario/hosts"
done

echo "✅ Inventario generado en $ANSIBLE_DIR/inventario/hosts"

# 🗝 Rutas de claves generadas por Vagrant
KEY_UBUNTU=$(vagrant ssh-config "$UBUNTU_VM" | grep IdentityFile | awk '{print $2}')
KEY_FEDORA=$(vagrant ssh-config "$FEDORA_VM" | grep IdentityFile | awk '{print $2}')

# 🔐 Copiar claves privadas a Fedora con clave correcta
echo "📤 Copiando claves privadas a Fedora..."
scp -i "$KEY_FEDORA" "$KEY_UBUNTU" "$FEDORA_USER@$FEDORA_IP:/home/$FEDORA_USER/.ssh/testing_id_rsa"
scp -i "$KEY_FEDORA" "$KEY_FEDORA" "$FEDORA_USER@$FEDORA_IP:/home/$FEDORA_USER/.ssh/produccion_id_rsa"

# 🔐 Ajustar permisos y crear inventario dentro de Fedora
echo "🔧 Configurando claves e inventario interno en Fedora..."
ssh -i "$KEY_FEDORA" "$FEDORA_USER@$FEDORA_IP" <<EOF
chmod 600 /home/$FEDORA_USER/.ssh/testing_id_rsa /home/$FEDORA_USER/.ssh/produccion_id_rsa
mkdir -p /home/$FEDORA_USER/ansible/inventario
cat <<EOL > /home/$FEDORA_USER/ansible/inventario/hosts
[servidores]
192.168.56.10 ansible_user=vagrant ansible_ssh_private_key_file=/home/vagrant/.ssh/testing_id_rsa
192.168.56.20 ansible_user=vagrant ansible_ssh_private_key_file=/home/vagrant/.ssh/produccion_id_rsa
EOL
EOF

echo ""
echo "🎯 Todo listo, Silvia."
echo ""
echo "👉 Ingresá a la VM Fedora con:"
echo "   vagrant ssh produccion"
echo ""
echo "📂 Y luego ejecutá dentro de Fedora:"
echo "   cd ~/ansible"
echo "   ansible-playbook -i inventario/hosts playbook.yml"
echo ""
