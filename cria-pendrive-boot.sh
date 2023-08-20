#!/bin/bash

# Verifica se o script está sendo executado com privilégios de superusuário
if [[ $EUID -ne 0 ]]; then
   echo "Esse script deve ser executado como root." 
   exit 1
fi

# Solicita o caminho para a imagem ISO
read -p "Digite o caminho completo para a imagem ISO: " iso_path

# Identifica o dispositivo do pendrive
read -p "Insira o pendrive e pressione Enter..."
dev_list=$(lsblk -o NAME,SIZE,MOUNTPOINT | grep -Ev 'loop|sr|NAME' | awk '$2 == "" {print "/dev/" $1}')
echo "Dispositivos disponíveis:"
echo "$dev_list"
read -p "Digite o dispositivo do pendrive (ex: /dev/sdX): " pendrive_dev

# Confirmação
read -p "Você está prestes a criar um pendrive bootável em $pendrive_dev. Isso irá apagar todos os dados nele. Deseja continuar? (s/n): " choice
if [[ ! "$choice" =~ [sS] ]]; then
    echo "Operação cancelada."
    exit 1
fi

# Desmonta qualquer partição montada do pendrive
umount "$pendrive_dev"* 2>/dev/null

# Cria o pendrive bootável usando dd
echo "Criando pendrive bootável..."
dd if="$iso_path" of="$pendrive_dev" bs=4M status=progress oflag=sync

echo "Pendrive bootável criado com sucesso em $pendrive_dev!"

