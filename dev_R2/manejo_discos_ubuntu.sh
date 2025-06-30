#!/bin/bash

# --- Creación y particionado de discos ---
sudo fdisk /dev/sdc << EOF
n
p


+1G

t
82

n
e



t

8e
w
EOF

sudo fdisk /dev/sdd << EOF
n
e



t

8e
w
EOF

sudo fdisk /dev/sde << EOF
n
e



t

82
w
EOF


# Generando pvs 
sudo pvcreate /dev/sdc2 /dev/sdd1 /dev/sde1

# Creando vgs
sudo vgcreate vg_datos /dev/sdc2 /dev/sde1
sudo vgcreate vg_temp /dev/sdd1

# Creando lvs
sudo lvcreate -L 10M vg_datos -n lv_docker
sudo lvcreate -L 2.5G vg_datos -n lv_workareas
sudo lvcreate -L 2.5G vg_temp -n lv_swap

# Formateando sistema de archivos
sudo mkfs.ext4 /dev/mapper/vg_datos-lv_docker
sudo mkfs.ext4 /dev/mapper/vg_datos-lv_workareas

# configurando memoria swap
sudo mkswap /dev/mapper/vg_temp-lv_swap
sudo mkswap /dev/sdc1


sudo swapon /dev/mapper/vg_temp-lv_swap
sudo swapon /dev/sdc1

# Obteniendo UUIDs para fstab
echo "--- Obteniendo UUIDs para configuración persistente de SWAP y montajes ---"
LV_SWAP_UUID=$(sudo blkid -s UUID -o value /dev/mapper/vg_temp-lv_swap)
SDC1_SWAP_UUID=$(sudo blkid -s UUID -o value /dev/sdc1)
SDE5_SWAP_UUID=$(sudo blkid -s UUID -o value /dev/sde5) # UUID para la partición swap en /dev/sde
LV_DOCKER_UUID=$(sudo blkid -s UUID -o value /dev/mapper/vg_datos-lv_docker)
LV_WORKAREAS_UUID=$(sudo blkid -s UUID -o value /dev/mapper/vg_datos-lv_workareas)

# --- Configuración de fstab para persistencia ---

echo "--- Añadiendo entradas a /etc/fstab para persistencia ---"

# Eliminar entradas existentes de estas UUIDs en fstab para evitar duplicados, si las hubiera
sudo sed -i "/$LV_SWAP_UUID/d" /etc/fstab
sudo sed -i "/$SDC1_SWAP_UUID/d" /etc/fstab
sudo sed -i "/$SDE5_SWAP_UUID/d" /etc/fstab
sudo sed -i "/$LV_DOCKER_UUID/d" /etc/fstab
sudo sed -i "/$LV_WORKAREAS_UUID/d" /etc/fstab


# Añadir las entradas de swap
echo "UUID=$LV_SWAP_UUID none swap sw 0 0" | sudo tee -a /etc/fstab
echo "UUID=$SDC1_SWAP_UUID none swap sw 0 0" | sudo tee -a /etc/fstab
echo "UUID=$SDE5_SWAP_UUID none swap sw 0 0" | sudo tee -a /etc/fstab

# --- Puntos de montaje ---

echo "--- Creando puntos de montaje ---"
sudo mkdir -p /var/lib/docker
sudo mkdir -p /work

# --- Montar sistemas de archivos ---

echo "--- Montando sistemas de archivos ---"
# Montar directamente usando el device mapper path
sudo mount /dev/mapper/vg_datos-lv_docker /var/lib/docker/
sudo mount /dev/mapper/vg_datos-lv_workareas /work/

# Añadir las entradas de montaje a fstab para persistencia
echo "UUID=$LV_DOCKER_UUID /var/lib/docker ext4 defaults 0 2" | sudo tee -a /etc/fstab
echo "UUID=$LV_WORKAREAS_UUID /work ext4 defaults 0 2" | sudo tee -a /etc/fstab
