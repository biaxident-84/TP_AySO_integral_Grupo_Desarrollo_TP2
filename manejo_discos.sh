#!/bin/bash

# Creo particiones y cambio su formato
sudo fdisk /dev/sdc << EOF
n
e



t
8e

w

EOF

sudo fdisk /dev/sdd << EOF
n
e


+3G

t
8e

w


EOF

# Memoria de tipo swap
sudo fdisk /dev/sde << EOF
n
e



t
82

w


EOF


# creo las pv
sudo pvcreate /dev/sdc1 /dev/sdd1 /dev/sde1

# Creo las VG
sudo vgcreate vg_datos /dev/sdc1 /dev/sde1
sudo vgcreate vg_temp /dev/sdd1

# Creo la LV
sudo lvcreate -L 10M vg_datos -n lv_docker
sudo lvcreate -L 2.5G vg_datos -n lv_workareas
sudo lvcreate -L 2.5G vg_temp -n lv_swap

# Creo el FS
sudo mkfs.ext4 /dev/mapper//vg_datos-lv_docker
sudo mkfs.ext4 /dev/mapper/vg_datos-lv_workareas

# Activamos la vg para que se inicie al reiniciar
sudo swapon /dev/mapper/vg_temp-lv_swap
sudo blkid /dev/mapper/vg_temp-lv_swap
echo "UUID=57190093-73b3-4059-a774-9c2e1cb298dc  none  swap  sw  0  0" | sudo tee -a /etc/fstab
sudo mkswap /dev/mapper/vg_temp-lv_swap

# Puntos de montaje
sudo mkdir -p /var/lib/docker/vg_datos-lv_docker
sudo mkdir -p /work/


# Montar
sudo mount /dev/mapper/vg_datos-lv_docker /var/lib/docker/
sudo mount /dev/mapper/vg_datos-lv_workareas /work/

















